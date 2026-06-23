import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DogParkResponseDto } from './dto/dog-park-response.dto.js';
import { ImportResponseDto } from './dto/import-response.dto.js';
import { NearbyQueryDto } from './dto/nearby-query.dto.js';
import { DogPark } from './entities/dog-park.entity.js';
import { OverpassService } from './overpass.service.js';

// 1 mile = 1609.344 meters — used to convert between units and meters (which PostGIS uses)
const METERS_PER_MILE = 1609.344;
const METERS_PER_KM = 1000;
const DEFAULT_RADIUS_MILES = 10;
const METERS_PER_DEGREE_LAT = 111_320;

@Injectable()
export class DogParksService {
  private readonly logger = new Logger(DogParksService.name);

  constructor(
    @InjectRepository(DogPark)
    private readonly dogParksRepository: Repository<DogPark>,
    private readonly overpassService: OverpassService,
  ) {}

  /**
   * Fetches dog parks from OpenStreetMap around a point (GPS or user-picked),
   * then upserts them into the database.
   */
  async importFromLocation(query: NearbyQueryDto): Promise<ImportResponseDto> {
    const radiusMeters = this.resolveRadiusMeters(query);
    const bbox = this.bboxFromCenter(query.lat, query.lng, radiusMeters);

    this.logger.log(
      `Importing dog parks near (${query.lat}, ${query.lng}) within ${radiusMeters}m`,
    );

    const imported = await this.importFromOverpass(
      bbox.south,
      bbox.west,
      bbox.north,
      bbox.east,
    );

    return { imported, bbox };
  }

  /**
   * Fetches dog parks from Overpass for a bounding box and upserts them
   * into the database. Uses osmId to avoid creating duplicates on re-runs.
   */
  async importFromOverpass(
    south: number,
    west: number,
    north: number,
    east: number,
  ): Promise<number> {
    const elements = await this.overpassService.fetchDogParks(south, west, north, east);

    let imported = 0;

    for (const element of elements) {
      const coords = this.overpassService.getCoordinates(element);

      // Skip elements with no usable coordinates
      if (!coords) {
        this.logger.warn(`Skipping OSM element ${element.id} — no coordinates`);
        continue;
      }

      const tags = element.tags ?? {};

      // Build the dog park record from the OSM element
      const dogPark: Partial<DogPark> = {
        name: tags.name ?? 'Unnamed Dog Park',
        description: tags.description ?? null,
        address: this.overpassService.buildAddress(tags),
        location: {
          type: 'Point',
          coordinates: [coords.lng, coords.lat], // GeoJSON order: [longitude, latitude]
        },
        isFenced: this.overpassService.isFenced(tags),
        isOffLeash: this.overpassService.isOffLeash(tags),
        hasWater: this.overpassService.hasWater(tags),
        hasLighting: this.overpassService.hasLighting(tags),
        hours: tags.opening_hours ?? null,
        phone: tags.phone ?? null,
        website: tags.website ?? null,
        osmId: element.id,
      };

      // upsert: insert if osmId doesn't exist, update if it does
      // This makes the import safe to run multiple times
      await this.dogParksRepository.upsert(dogPark, ['osmId']);
      imported++;
    }

    this.logger.log(`Imported ${imported} dog parks from Overpass`);
    return imported;
  }

  /**
   * Returns all dog parks, sorted alphabetically by name.
   */
  async findAll(): Promise<DogParkResponseDto[]> {
    const parks = await this.dogParksRepository.find({
      order: { name: 'ASC' },
    });

    return parks.map((park) => this.toResponse(park));
  }

  /**
   * Finds dog parks within a radius of a given lat/lng using PostGIS.
   *
   * ST_DWithin(geography, geography, meters) returns true if two geographic
   * objects are within the given distance in meters. Using the geography
   * type (instead of geometry) means PostGIS accounts for the Earth's
   * curvature, so distances are accurate over large areas.
   *
   * ST_Distance returns the exact distance in meters between two points,
   * which we convert to both miles and km for the response.
   */
  async findNearby(query: NearbyQueryDto): Promise<DogParkResponseDto[]> {
    const radiusMeters = this.resolveRadiusMeters(query);

    // Raw query using TypeORM's query builder
    // We need raw SQL here because PostGIS functions aren't part of TypeORM's
    // standard API — we call them directly using ST_DWithin and ST_Distance
    const results = await this.dogParksRepository
      .createQueryBuilder('dp')
      .addSelect(
        // ST_Distance returns meters; we calculate both miles and km here
        `ST_Distance(
          dp.location::geography,
          ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
        )`,
        'distance_meters',
      )
      .where(
        `ST_DWithin(
          dp.location::geography,
          ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
          :radiusMeters
        )`,
        { lat: query.lat, lng: query.lng, radiusMeters },
      )
      .orderBy('distance_meters', 'ASC')
      .getRawAndEntities();

    // getRawAndEntities() returns { raw, entities } — we zip them together
    return results.entities.map((park, index) => {
      const distanceMeters = parseFloat(results.raw[index].distance_meters);
      return this.toResponse(park, distanceMeters);
    });
  }

  /**
   * Builds a rectangular bounding box from a center point and search radius.
   * Overpass expects south, west, north, east — not a center + radius.
   */
  private bboxFromCenter(
    lat: number,
    lng: number,
    radiusMeters: number,
  ): ImportResponseDto['bbox'] {
    const deltaLat = radiusMeters / METERS_PER_DEGREE_LAT;
    const deltaLng =
      radiusMeters /
      (METERS_PER_DEGREE_LAT * Math.cos((lat * Math.PI) / 180));

    return {
      south: lat - deltaLat,
      west: lng - deltaLng,
      north: lat + deltaLat,
      east: lng + deltaLng,
    };
  }

  private resolveRadiusMeters(query: NearbyQueryDto): number {
    if (query.radiusKm !== undefined) {
      return query.radiusKm * METERS_PER_KM;
    }
    if (query.radiusMiles !== undefined) {
      return query.radiusMiles * METERS_PER_MILE;
    }
    return DEFAULT_RADIUS_MILES * METERS_PER_MILE;
  }

  /**
   * Maps a DogPark entity to the response DTO.
   * Optionally includes distance if this came from a nearby query.
   */
  private toResponse(park: DogPark, distanceMeters?: number): DogParkResponseDto {
    // Flip coordinates back to lat/lng order for the API response
    const [longitude, latitude] = park.location?.coordinates ?? [null, null];

    return {
      id: park.id,
      name: park.name,
      description: park.description,
      address: park.address,
      latitude,
      longitude,
      isFenced: park.isFenced,
      isOffLeash: park.isOffLeash,
      hasWater: park.hasWater,
      hasLighting: park.hasLighting,
      hours: park.hours,
      phone: park.phone,
      website: park.website,
      distanceMiles: distanceMeters != null
        ? Math.round((distanceMeters / METERS_PER_MILE) * 100) / 100
        : null,
      distanceKm: distanceMeters != null
        ? Math.round((distanceMeters / METERS_PER_KM) * 100) / 100
        : null,
      createdAt: park.createdAt,
      updatedAt: park.updatedAt,
    };
  }
}

// import { Injectable, OnModuleInit } from '@nestjs/common';
// import { InjectRepository } from '@nestjs/typeorm';
// import { Repository } from 'typeorm';
// import { ParkResponseDto } from './dto/dog-park-response.dto';
// import { GeoPoint, Park } from './entities/dog-park.entity';

// @Injectable()
// export class ParksService implements OnModuleInit {
//   constructor(
//     @InjectRepository(Park)
//     private readonly parksRepository: Repository<Park>,
//   ) {}

//   async onModuleInit(): Promise<void> {
//     const count = await this.parksRepository.count();
//     if (count > 0) {
//       return;
//     }

//     await this.parksRepository.save([
//       {
//         name: 'Central Park',
//         description: 'Iconic urban park in Manhattan with trails and open lawns.',
//         address: 'New York, NY 10024',
//         location: this.toGeoPoint(40.7829, -73.9654),
//       },
//       {
//         name: 'Golden Gate Park',
//         description: 'Large San Francisco park with gardens, museums, and trails.',
//         address: 'San Francisco, CA 94118',
//         location: this.toGeoPoint(37.7694, -122.4862),
//       },
//     ]);
//   }

//   async findAll(): Promise<ParkResponseDto[]> {
//     const parks = await this.parksRepository.find({
//       order: { name: 'ASC' },
//     });

//     return parks.map((park) => this.toResponse(park));
//   }

//   private toGeoPoint(latitude: number, longitude: number): GeoPoint {
//     return {
//       type: 'Point',
//       coordinates: [longitude, latitude],
//     };
//   }

//   private toResponse(park: Park): ParkResponseDto {
//     const [longitude, latitude] = park.location?.coordinates ?? [null, null];

//     return {
//       id: park.id,
//       name: park.name,
//       description: park.description,
//       address: park.address,
//       latitude,
//       longitude,
//       createdAt: park.createdAt,
//       updatedAt: park.updatedAt,
//     };
//   }
// }

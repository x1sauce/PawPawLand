import {
  BadRequestException,
  Controller,
  Get,
  Post,
  Query,
} from '@nestjs/common';
import { DogParkResponseDto } from './dto/dog-park-response.dto.js';
import { ImportResponseDto } from './dto/import-response.dto.js';
import { NearbyQueryDto } from './dto/nearby-query.dto.js';
import { DogParksService } from './dog-parks.service.js';

@Controller('dog-parks')
export class DogParksController {
  constructor(private readonly dogParksService: DogParksService) {}

  /**
   * GET /dog-parks
   * Returns all dog parks in the database, sorted alphabetically.
   */
  @Get()
  findAll(): Promise<DogParkResponseDto[]> {
    return this.dogParksService.findAll();
  }

  /**
   * POST /dog-parks/import?lat=40.78&lng=-73.97&radiusMiles=10
   *
   * Fetches dog parks from OpenStreetMap around the given point and saves them.
   * Use GPS coordinates or any location the user picks on a map.
   */
  @Post('import')
  importFromLocation(
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radiusMiles') radiusMiles?: string,
    @Query('radiusKm') radiusKm?: string,
  ): Promise<ImportResponseDto> {
    return this.dogParksService.importFromLocation(
      this.parseLocationQuery(lat, lng, radiusMiles, radiusKm),
    );
  }

  /**
   * GET /dog-parks/nearby?lat=34.05&lng=-118.24&radiusMiles=5
   * GET /dog-parks/nearby?lat=34.05&lng=-118.24&radiusKm=8
   */
  @Get('nearby')
  findNearby(
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radiusMiles') radiusMiles?: string,
    @Query('radiusKm') radiusKm?: string,
  ): Promise<DogParkResponseDto[]> {
    return this.dogParksService.findNearby(
      this.parseLocationQuery(lat, lng, radiusMiles, radiusKm),
    );
  }

  private parseLocationQuery(
    lat: string,
    lng: string,
    radiusMiles?: string,
    radiusKm?: string,
  ): NearbyQueryDto {
    const parsedLat = parseFloat(lat);
    const parsedLng = parseFloat(lng);

    if (!Number.isFinite(parsedLat) || parsedLat < -90 || parsedLat > 90) {
      throw new BadRequestException('lat must be a number between -90 and 90');
    }
    if (!Number.isFinite(parsedLng) || parsedLng < -180 || parsedLng > 180) {
      throw new BadRequestException(
        'lng must be a number between -180 and 180',
      );
    }

    let parsedRadiusMiles: number | undefined;
    let parsedRadiusKm: number | undefined;

    if (radiusMiles !== undefined) {
      parsedRadiusMiles = parseFloat(radiusMiles);
      if (!Number.isFinite(parsedRadiusMiles) || parsedRadiusMiles <= 0) {
        throw new BadRequestException('radiusMiles must be a positive number');
      }
    }

    if (radiusKm !== undefined) {
      parsedRadiusKm = parseFloat(radiusKm);
      if (!Number.isFinite(parsedRadiusKm) || parsedRadiusKm <= 0) {
        throw new BadRequestException('radiusKm must be a positive number');
      }
    }

    return {
      lat: parsedLat,
      lng: parsedLng,
      radiusMiles: parsedRadiusMiles,
      radiusKm: parsedRadiusKm,
    };
  }
}

// import { Controller, Get } from '@nestjs/common';
// import { ParkResponseDto } from './dto/dog-park-response.dto';
// import { ParksService } from './dog-parks.service';

// @Controller('parks')
// export class ParksController {
//   constructor(private readonly parksService: ParksService) {}

//   @Get()
//   findAll(): Promise<ParkResponseDto[]> {
//     return this.parksService.findAll();
//   }
// }

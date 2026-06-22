import { Controller, Get, Query } from '@nestjs/common';
import { DogParkResponseDto } from './dto/dog-park-response.dto.js';
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
   * GET /dog-parks/nearby?lat=34.05&lng=-118.24&radiusMiles=5
   * GET /dog-parks/nearby?lat=34.05&lng=-118.24&radiusKm=8
   *
   * @Query() pulls individual query string parameters and maps them to the DTO.
   * The + prefix converts the string value to a number (query params are always strings).
   */
  @Get('nearby')
  findNearby(
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radiusMiles') radiusMiles?: string,
    @Query('radiusKm') radiusKm?: string,
  ): Promise<DogParkResponseDto[]> {
    const query: NearbyQueryDto = {
      lat: parseFloat(lat),
      lng: parseFloat(lng),
      radiusMiles: radiusMiles !== undefined ? parseFloat(radiusMiles) : undefined,
      radiusKm: radiusKm !== undefined ? parseFloat(radiusKm) : undefined,
    };

    return this.dogParksService.findNearby(query);
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

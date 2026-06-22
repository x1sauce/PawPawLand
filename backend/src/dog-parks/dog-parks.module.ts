import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DogParksController } from './dog-parks.controller.js';
import { DogParksService } from './dog-parks.service.js';
import { DogPark } from './entities/dog-park.entity.js';
import { OverpassService } from './overpass.service.js';

@Module({
  imports: [
    // Registers the DogPark entity so @InjectRepository(DogPark) works in the service
    TypeOrmModule.forFeature([DogPark]),
  ],
  controllers: [DogParksController],
  providers: [
    DogParksService,
    // OverpassService is a provider too — Nest will inject it into DogParksService
    OverpassService,
  ],
})
export class DogParksModule {}

// import { Module } from '@nestjs/common';
// import { TypeOrmModule } from '@nestjs/typeorm';
// import { Park } from './entities/dog-park.entity';
// import { ParksController } from './dog-parks.controller';
// import { ParksService } from './dog-parks.service';

// @Module({
//   imports: [TypeOrmModule.forFeature([Park])],
//   controllers: [ParksController],
//   providers: [ParksService],
// })
// export class ParksModule {}

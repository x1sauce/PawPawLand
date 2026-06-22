import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DogParksModule } from './dog-parks/dog-parks.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get<string>('DB_USERNAME', 'pawpaw'),
        password: configService.get<string>('DB_PASSWORD', 'pawpaw'),
        database: configService.get<string>('DB_DATABASE', 'pawpawland'),
        // Replaced Park with DogPark — TypeORM uses this list to know
        // which entities to create/sync tables for
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: true,
      }),
    }),
    // Swapped ParksModule for DogParksModule
    DogParksModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}


// import { Module } from '@nestjs/common';
// import { ConfigModule, ConfigService } from '@nestjs/config';
// import { TypeOrmModule } from '@nestjs/typeorm';
// import { AppController } from './app.controller';
// import { AppService } from './app.service';
// import { Park } from './dog-parks/entities/dog-park.entity';
// import { ParksModule } from './dog-parks/dog-parks.module';

// @Module({
//   imports: [
//     ConfigModule.forRoot({
//       isGlobal: true,
//       envFilePath: '.env',
//     }),
//     TypeOrmModule.forRootAsync({
//       imports: [ConfigModule],
//       inject: [ConfigService],
//       useFactory: (configService: ConfigService) => ({
//         type: 'postgres',
//         host: configService.get<string>('DB_HOST', 'localhost'),
//         port: configService.get<number>('DB_PORT', 5432),
//         username: configService.get<string>('DB_USERNAME', 'pawpaw'),
//         password: configService.get<string>('DB_PASSWORD', 'pawpaw'),
//         database: configService.get<string>('DB_DATABASE', 'pawpawland'),
//         entities: [Park],
//         synchronize: true,
//       }),
//     }),
//     ParksModule,
//   ],
//   controllers: [AppController],
//   providers: [AppService],
// })
// export class AppModule {}

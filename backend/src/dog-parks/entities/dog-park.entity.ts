import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

export type GeoPoint = {
  type: 'Point';
  coordinates: [number, number]; // [longitude, latitude] — GeoJSON order
};

@Entity('dog_parks')
export class DogPark {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // The park name from OpenStreetMap (e.g. "Runyon Canyon Dog Park")
  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true })
  address: string | null;

  // PostGIS geometry point — stores lat/lng as a spatial type
  // srid 4326 = standard GPS coordinate system (WGS84)
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location: GeoPoint | null;

  // Dog-park-specific attributes sourced from OSM tags
  @Column({ name: 'is_fenced', default: false })
  isFenced: boolean;

  @Column({ name: 'is_off_leash', default: false })
  isOffLeash: boolean;

  @Column({ name: 'has_water', default: false })
  hasWater: boolean;

  @Column({ name: 'has_lighting', default: false })
  hasLighting: boolean;

  @Column({ type: 'varchar', length: 500, nullable: true })
  hours: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true })
  website: string | null;

  // The original OSM node/way ID — lets us avoid re-importing duplicates
  @Column({ name: 'osm_id', type: 'bigint', nullable: true, unique: true })
  osmId: number | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
// import {
//   Column,
//   CreateDateColumn,
//   Entity,
//   PrimaryGeneratedColumn,
//   UpdateDateColumn,
// } from 'typeorm';

// export type GeoPoint = {
//   type: 'Point';
//   coordinates: [number, number];
// };

// @Entity('parks')
// export class Park {
//   @PrimaryGeneratedColumn('uuid')
//   id: string;

//   @Column({ length: 255 })
//   name: string;

//   @Column({ type: 'text', nullable: true })
//   description: string | null;

//   @Column({ type: 'varchar', length: 500, nullable: true })
//   address: string | null;

//   @Column({
//     type: 'geometry',
//     spatialFeatureType: 'Point',
//     srid: 4326,
//     nullable: true,
//   })
//   location: GeoPoint | null;

//   @CreateDateColumn({ name: 'created_at' })
//   createdAt: Date;

//   @UpdateDateColumn({ name: 'updated_at' })
//   updatedAt: Date;
// }

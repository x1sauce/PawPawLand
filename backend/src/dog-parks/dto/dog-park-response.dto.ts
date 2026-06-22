export class DogParkResponseDto {
  id: string;
  name: string;
  description: string | null;
  address: string | null;
  latitude: number | null;
  longitude: number | null;

  // Dog-park-specific fields
  isFenced: boolean;
  isOffLeash: boolean;
  hasWater: boolean;
  hasLighting: boolean;
  hours: string | null;
  phone: string | null;
  website: string | null;

  // Populated only on nearby searches — distance from the queried point
  distanceMiles: number | null;
  distanceKm: number | null;

  createdAt: Date;
  updatedAt: Date;
}
// export class ParkResponseDto {
//   id: string;
//   name: string;
//   description: string | null;
//   address: string | null;
//   latitude: number | null;
//   longitude: number | null;
//   createdAt: Date;
//   updatedAt: Date;
// }

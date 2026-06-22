export class NearbyQueryDto {
    // Latitude of the user's location
    lat: number;
  
    // Longitude of the user's location
    lng: number;
  
    // How far to search — caller provides either miles or km, not both
    // Defaults to 10 miles if neither is provided
    radiusMiles?: number;
    radiusKm?: number;
  }
export class ImportResponseDto {
  imported: number;
  bbox: {
    south: number;
    west: number;
    north: number;
    east: number;
  };
}

-- Enable the PostGIS extension — required for geometry columns and spatial functions
CREATE EXTENSION IF NOT EXISTS postgis;

-- The dog_parks table is created by TypeORM (synchronize: true),
-- but we add a spatial index here manually for query performance.
-- ST_DWithin (used in nearby searches) is much faster with a GIST index
-- on the location column.
-- The IF NOT EXISTS guard makes this safe to run multiple times.
CREATE INDEX IF NOT EXISTS idx_dog_parks_location
  ON dog_parks
  USING GIST (location);


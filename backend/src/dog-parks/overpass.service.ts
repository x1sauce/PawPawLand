import { Injectable, Logger } from '@nestjs/common';

// The shape of a single OSM element returned by Overpass
export type OverpassElement = {
  type: 'node' | 'way' | 'relation';
  id: number;
  lat?: number;   // present on nodes
  lon?: number;   // present on nodes
  center?: {      // present on ways/relations — the centroid
    lat: number;
    lon: number;
  };
  tags?: {
    name?: string;
    description?: string;
    'addr:full'?: string;
    'addr:street'?: string;
    'addr:city'?: string;
    'addr:state'?: string;
    fence?: string;
    fenced?: string;
    leash?: string;
    'dog:leash'?: string;
    drinking_water?: string;
    lit?: string;
    opening_hours?: string;
    phone?: string;
    website?: string;
    [key: string]: string | undefined;
  };
};

type OverpassResponse = {
  elements: OverpassElement[];
};

@Injectable()
export class OverpassService {
  private readonly logger = new Logger(OverpassService.name);

  // Public Overpass API endpoint — no key needed
  private readonly OVERPASS_URL = 'https://overpass-api.de/api/interpreter';

  /**
   * Fetches all dog parks within a bounding box from OpenStreetMap.
   *
   * A bounding box is just a rectangle: [south, west, north, east]
   * e.g. for Los Angeles: [33.7, -118.7, 34.3, -118.1]
   *
   * We request both nodes (single points) and ways (polygons like park boundaries)
   * and ask Overpass to give us the center of ways so we always get a lat/lng.
   */
  async fetchDogParks(
    south: number,
    west: number,
    north: number,
    east: number,
  ): Promise<OverpassElement[]> {
    // Overpass QL — the query language for OpenStreetMap data
    // [out:json]          → return JSON (not XML)
    // [timeout:30]        → give up after 30 seconds
    // nw[leisure=dog_park] → find nodes AND ways tagged as dog parks
    // out center;         → include polygon centroids so ways have a lat/lng
    const bbox = `${south},${west},${north},${east}`;
    const query = `
      [out:json][timeout:30];
      (
        node[leisure=dog_park](${bbox});
        way[leisure=dog_park](${bbox});
      );
      out center;
    `;

    this.logger.log(`Querying Overpass for dog parks in bbox: ${bbox}`);

    const response = await fetch(this.OVERPASS_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'PawPawLand/1.0 (dog-park-finder)',
      },
      body: new URLSearchParams({ data: query.trim() }),
    });

    if (!response.ok) {
      throw new Error(`Overpass API error: ${response.status} ${response.statusText}`);
    }

    const data = (await response.json()) as OverpassResponse;

    this.logger.log(`Found ${data.elements.length} dog parks from Overpass`);

    return data.elements;
  }

  /**
   * Extracts a clean lat/lng from an element regardless of whether
   * it's a node (has lat/lon directly) or a way (has a center object).
   */
  getCoordinates(element: OverpassElement): { lat: number; lng: number } | null {
    if (element.lat !== undefined && element.lon !== undefined) {
      return { lat: element.lat, lng: element.lon };
    }
    if (element.center) {
      return { lat: element.center.lat, lng: element.center.lon };
    }
    return null;
  }

  /**
   * Builds a human-readable address from OSM address tags.
   * OSM breaks addresses into parts (street, city, state) rather than one field.
   */
  buildAddress(tags: OverpassElement['tags']): string | null {
    if (!tags) return null;

    const parts = [
      tags['addr:street'],
      tags['addr:city'],
      tags['addr:state'],
    ].filter(Boolean);

    if (tags['addr:full']) return tags['addr:full'];
    if (parts.length > 0) return parts.join(', ');
    return null;
  }

  /**
   * OSM uses various tags to indicate fencing — normalize them to a boolean.
   */
  isFenced(tags: OverpassElement['tags']): boolean {
    if (!tags) return false;
    return tags.fence === 'yes' || tags.fenced === 'yes';
  }

  /**
   * OSM uses leash=no or dog:leash=no to indicate off-leash areas.
   */
  isOffLeash(tags: OverpassElement['tags']): boolean {
    if (!tags) return false;
    return tags.leash === 'no' || tags['dog:leash'] === 'no';
  }

  /**
   * drinking_water=yes means there's water available at the park.
   */
  hasWater(tags: OverpassElement['tags']): boolean {
    if (!tags) return false;
    return tags.drinking_water === 'yes';
  }

  /**
   * lit=yes means the park has lighting.
   */
  hasLighting(tags: OverpassElement['tags']): boolean {
    if (!tags) return false;
    return tags.lit === 'yes';
  }
}
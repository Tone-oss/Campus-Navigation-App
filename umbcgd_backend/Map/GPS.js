class MapManager {
  constructor() {
    mapboxgl.accessToken = "pk.eyJ1IjoiYW50LXNoZWxlbmtlciIsImEiOiJjbWgwejhoMGowbWpxZnRwdTd0eHloeHoxIn0.0jkWtjN2ReKCcKswTH2Oqw";
    
    // Initialize the map
    this.map = new mapboxgl.Map({
      container: "map",
      style: "mapbox://styles/mapbox/streets-v12",
      center: [-76.70675, 39.2533],
      zoom: 12
    });

    // Add zoom and rotation controls to the map
    this.map.addControl(new mapboxgl.NavigationControl());
  }

  createMarker(coordinates, color = "red", popupText = "Marker") {
    const marker = new mapboxgl.Marker({ color })
      .setLngLat(coordinates)
      .setPopup(new mapboxgl.Popup().setHTML(`<h3>${popupText}</h3>`))
      .addTo(this.map);
    return marker;
  }
}

class GPS {
  constructor(map) {
    this.map = map;
    this.userLocation = null;
    this.watchId = null;
    this.currentRoute = null;
    this.locationAcquired = false; // Track if we've gotten first location

    // Create user marker (will be positioned when tracking starts)
    this.userMarker = new mapboxgl.Marker({ color: "blue" })
      .setPopup(new mapboxgl.Popup().setHTML("<h3>You are here!</h3>"));
  }
  
  trackLocation() {
    if (!navigator.geolocation) {
      console.error("Geolocation is not supported by this browser.");
      return;
    }

    // Wait for map to load before tracking
    if (!this.map.loaded()) {
      this.map.once('load', () => {
        this.startTracking();
      });
    } else {
      this.startTracking();
    }
  }

  startTracking() {
    this.watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const coords = [pos.coords.longitude, pos.coords.latitude];
        this.userLocation = coords;
        
        console.log("Position update:", coords);
        
        // Add marker to map on first position
        if (!this.locationAcquired) {
          this.locationAcquired = true;
          this.userMarker.setLngLat(coords);
          this.userMarker.addTo(this.map);
          
          console.log("First location acquired:", coords);
          
          // Pan to location
          if (coords && coords.length === 2) {
            this.map.panTo(coords);
          }
          
          // Trigger callback when location is first acquired
          if (this.onLocationAcquired) {
            this.onLocationAcquired(coords);
          }
        } else {
          // Update existing marker
          this.userMarker.setLngLat(coords);
          
          // Pan to location
          if (coords && coords.length === 2) {
            this.map.panTo(coords);
          }
        }
      },
      (error) => {
        console.error("Error getting location:", error.message);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0
      }
    );
  }

  stopTracking() {
    if (this.watchId !== null) {
      navigator.geolocation.clearWatch(this.watchId);
      this.watchId = null;
    }
  }

  async createRoute(endCoords) {
    console.log("createRoute called");
    console.log("User location:", this.userLocation);
    console.log("Destination:", endCoords);
    
    if (!this.userLocation) {
      console.error("User location not available yet");
      return;
    }

    const start = this.userLocation;
    const end = endCoords;

    const url = `https://api.mapbox.com/directions/v5/mapbox/walking/${start[0]},${start[1]};${end[0]},${end[1]}?geometries=geojson&access_token=${mapboxgl.accessToken}`;
    
    console.log("Fetching route from:", url);

    try {
      const response = await fetch(url);
      const data = await response.json();
      
      console.log("Route data:", data);

      if (data.routes && data.routes.length > 0) {
        const route = data.routes[0].geometry;
        
        console.log("Route found! Drawing on map...");

        // Remove existing route if present
        if (this.map.getLayer('route')) {
          this.map.removeLayer('route');
        }
        if (this.map.getSource('route')) {
          this.map.removeSource('route');
        }

        // Add route to map
        this.map.addSource('route', {
          type: 'geojson',
          data: {
            type: 'Feature',
            properties: {},
            geometry: route
          }
        });

        this.map.addLayer({
          id: 'route',
          type: 'line',
          source: 'route',
          layout: {
            'line-join': 'round',
            'line-cap': 'round'
          },
          paint: {
            'line-color': '#3887be',
            'line-width': 5,
            'line-opacity': 0.75
          }
        });

        // Fit map to show entire route
        const coordinates = route.coordinates;
        const bounds = coordinates.reduce((bounds, coord) => {
          return bounds.extend(coord);
        }, new mapboxgl.LngLatBounds(coordinates[0], coordinates[0]));

        this.map.fitBounds(bounds, { padding: 50 });

        this.currentRoute = route;
        
        console.log("Route drawn successfully!");
        return data.routes[0];
      } else {
        console.error("No routes found in response");
      }
    } catch (error) {
      console.error("Error creating route:", error);
    }
  }

  clearRoute() {
    if (this.map.getLayer('route')) {
      this.map.removeLayer('route');
    }
    if (this.map.getSource('route')) {
      this.map.removeSource('route');
    }
    this.currentRoute = null;
  }
}

// Initialize only if not already initialized
if (!window.mapInstance) {
  const myMap = new MapManager();
  
  // Wait for map to load before initializing GPS
  myMap.map.on('load', () => {
    const gps = new GPS(myMap.map);
    gps.trackLocation();
    
    // Store in window to prevent duplicate initialization
    window.mapInstance = myMap;
    window.gpsInstance = gps;
    
    // Example: Create a route after getting user location
    // Uncomment to test routing to a destination
    /*
    setTimeout(() => {
      const destination = [-76.71, 39.26]; // UMBC coordinates
      gps.createRoute(destination);
    }, 5000); // Wait 5 seconds for GPS to acquire location
    */
  });
}


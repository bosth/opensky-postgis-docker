CREATE SERVER opensky_api_states FOREIGN DATA WRAPPER multicorn OPTIONS ( WRAPPER 'geofdw.fdw.opensky.StateVector' );

CREATE FOREIGN TABLE live_aircraft (
  icao24 TEXT,
  callsign TEXT,
  time TIMESTAMP,
  geom GEOMETRY,
  origin_country TEXT,
  true_track FLOAT,
  velocity FLOAT,
  category_text TEXT) SERVER opensky_api_states;

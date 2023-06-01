CREATE SERVER opensky_api_states FOREIGN DATA WRAPPER multicorn OPTIONS ( WRAPPER 'geofdw.StateVector' );

CREATE FOREIGN TABLE live_aircraft (
  icao24 TEXT,
  category INT,
  callsign TEXT,
  time TIMESTAMP,
  geom GEOMETRY,
  squawk TEXT,
  origin_country TEXT,
  true_track FLOAT,
  velocity FLOAT,
  category_text TEXT,
  position_source INTEGER) SERVER opensky_api_states;

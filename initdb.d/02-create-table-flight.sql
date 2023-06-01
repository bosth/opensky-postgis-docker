CREATE TABLE flight (
  icao24   TEXT,
  callsign TEXT,
  airport_depart TEXT, -- departure airport
  airport_arrive TEXT, -- arrival airport
  time_depart TIMESTAMP, -- departure time
  time_arrive TIMESTAMP, -- arrival time
  geom GEOMETRY(LINESTRINGZM, 4326)
);

CREATE INDEX ON
  flight
USING
  gist (geom gist_geometry_ops_nd);

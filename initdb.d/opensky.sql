CREATE EXTENSION multicorn;
CREATE EXTENSION plpython3u;
CREATE EXTENSION postgis;

CREATE SERVER states foreign data wrapper multicorn OPTIONS ( WRAPPER  'geofdw.StateVector' );
CREATE FOREIGN TABLE states (
  icao24 TEXT,
  category INT,
  callsign TEXT,
  time TIMESTAMP,
  geom GEOMETRY,
  squawk TEXT,
  true_track FLOAT,
  velocity FLOAT,
  spi BOOLEAN,
  category_text TEXT,
  position_source INTEGER) SERVER states;


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

CREATE OR REPLACE FUNCTION
    get_aircraft_flights(icao24 TEXT, in_datebegin DATE, in_dateend DATE)
RETURNS
    TABLE (LIKE flight)
AS $$
    import os
    OSUSER = os.getenv("OPENSKY_USER")
    OSPASS = os.getenv("OPENSKY_PASS")
    OSURL = "https://opensky-network.org/api"

    from datetime import datetime
    from dateutil import parser
    from requests import Session
    from requests.auth import HTTPBasicAuth

    db = parser.parse(in_datebegin)
    de = parser.parse(in_dateend).replace(hour=23, minute=59)
    db = int(db.timestamp())
    de = int(de.timestamp())

    opensky = Session()
    opensky.auth = HTTPBasicAuth(OSUSER, OSPASS)

    res = opensky.get(
              OSURL + "/flights/aircraft/",
              params={"icao24" : icao24,
                      "begin" : db,
                      "end" : de})

    if res.status_code == 200 and res.text:
        plpy.info(res.request.url)
        flights = [(icao24,
                    f["callsign"].strip() if f["callsign"] else "",
                    f["estDepartureAirport"],
                    f["estArrivalAirport"],
                    datetime.fromtimestamp(f["firstSeen"]),
                    datetime.fromtimestamp(f["lastSeen"]),
                    None)
                   for f in res.json()]
        return flights
    else:
        plpy.info(res.request.url, res.status_code, res.text)
        return []

$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION
    get_track(icao24 TEXT, in_date TIMESTAMP WITH TIME ZONE)
RETURNS
    GEOMETRY(LINESTRINGZM, 4326)
AS $$
    import os
    OSUSER = os.getenv("OPENSKY_USER")
    OSPASS = os.getenv("OPENSKY_PASS")
    OSURL = "https://opensky-network.org/api"

    from datetime import datetime
    from dateutil import parser
    from requests import Session
    from requests.auth import HTTPBasicAuth
    from plpygis import LineString

    dt = parser.parse(in_date)
    dt = int(dt.timestamp())

    opensky = Session()
    opensky.auth = HTTPBasicAuth(OSUSER, OSPASS)

    res = opensky.get(
                OSURL + "/tracks/",
                params={"icao24" : icao24.lower(),
                        "time" : dt})
    if res.status_code == 200 and res.text:
        plpy.info(res.request.url)
        fl = res.json()
        return LineString(
                    [[v[2], v[1], v[3], v[0]]
                    for v in fl["path"]])
    else:
        plpy.info(res.request.url, res.status_code, res.text)
        return None
$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION
    get_airport_flights(airport TEXT, in_datebegin DATE, in_dateend DATE)
RETURNS
    TABLE (LIKE flight)
AS $$
    import os
    OSUSER = os.getenv("OPENSKY_USER")
    OSPASS = os.getenv("OPENSKY_PASS")
    OSURL = "Thttps://opensky-network.org/api"

    from datetime import datetime
    from dateutil import parser
    from requests import Session
    from requests.auth import HTTPBasicAuth

    db = parser.parse(in_datebegin)
    de = parser.parse(in_dateend).replace(hour=23, minute=59)
    db = int(db.timestamp())
    de = int(de.timestamp())

    opensky = Session()
    opensky.auth = HTTPBasicAuth(OSUSER, OSPASS)

    for endpoint in ["arrival", "departure"]:
      res = opensky.get(
                OSURL + "/flights/{}/".format(endpoint),
                params={"airport" : airport,
                        "begin" : db,
                        "end" : de})

      if res.status_code == 200 and res.text:
          plpy.info(res.request.url)
          for f in res.json():
            if not f["firstSeen"] or not f["lastSeen"]:
              continue
            yield (f["icao24"],
                   f["callsign"].strip() if f["callsign"] else "",
                   f["estDepartureAirport"],
                   f["estArrivalAirport"],
                   datetime.fromtimestamp(f["firstSeen"]),
                   datetime.fromtimestamp(f["lastSeen"]),
                   None)
      else:
          plpy.info(res.request.url, res.status_code, res.text)

$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION
    interpolate_track_evelation(geom_in GEOMETRY(LINESTRINGZM))
RETURNS
    GEOMETRY(LINESTRINGZM)
AS $$
    from plpygis import Geometry, LineString
    from itertools import groupby
    geom = Geometry(geom_in)

    elevations = []
    for _, group in groupby(geom.vertices, lambda x: x.z):
        elevations.append(list(group))

    vertices = []
    for i, _ in enumerate(elevations):
        if i == len(elevations) - 1:
            for v in elevations[i]:
                vertices.append([v.x, v.z, v.y, v.m])
        else:
            elev_st = elevations[i][0].z
            elev_ed = elevations[i+1][0].z
            time_st = elevations[i][0].m
            time_ed = elevations[i+1][0].m

            # catch error of repeating m values
            if time_ed == time_st:
                incr = 0
            else:
                incr = (elev_ed - elev_st) / (time_ed - time_st)
            for v in elevations[i]:
                x = v.x
                y = v.y
                z = v.z + ((v.m - time_st) * incr)
                m = v.m
                pt = [x, y, z, m]
                vertices.append(pt)
    return LineString(vertices, srid=4326)
$$ LANGUAGE plpython3u;



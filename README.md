# opensky-postgis-docker
Dockerfile for Aircraft trajectories in PostGIS talk

Create a `.evn` file that exports your OpenSky Network credentials:

```
export OPENSKY_USER="user name"
export OPENSKY_PASS="password"
```
Then start the container:

`docker compose up --build`

Then connect to Postgres runnign on port 54321:

`pgsql -h localhost -p 54321 opensky`

OpenSky Citation:

```
Bringing up OpenSky: A large-scale ADS-B sensor network for research
Matthias Schäfer, Martin Strohmeier, Vincent Lenders, Ivan Martinovic, Matthias Wilhelm
ACM/IEEE International Conference on Information Processing in Sensor Networks, April 2014
```

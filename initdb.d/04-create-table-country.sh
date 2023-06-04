#!/bin/bash
set -e 

cd /tmp
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip
unzip ne_10m_admin_0_countries.zip
shp2pgsql -I -g geom -s 4326 ne_10m_admin_0_countries.shp country | psql opensky

#!/bin/bash

set -e 

createdb opensky

psql opensky -c "CREATE EXTENSION multicorn;"
psql opensky -c "CREATE EXTENSION plpython3u;"
psql opensky -c "CREATE EXTENSION postgis;"

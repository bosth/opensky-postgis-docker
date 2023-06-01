FROM postgres:15.2-bullseye

RUN apt update
RUN apt install -y postgresql-server-dev-15 postgresql-plpython3-15
RUN apt install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc
RUN apt install -y python3 python3-dev python3-setuptools python3-pip python3-geopy python3-requests python3-dateutil
RUN apt install -y postgis
RUN apt install -y wget git unzip

# install Python packages
RUN pip3 install plpygis
RUN pip3 install requests --upgrade

# install multicorn2
#RUN wget https://github.com/pgsql-io/multicorn2/archive/refs/tags/v2.4.tar.gz
#RUN tar -xvf v2.4.tar.gz
#WORKDIR /multicorn2-2.4
ARG MULTICORN_REF=b68b75c253be72bdfd5b24bf76705c47c238d370
RUN wget https://github.com/pgsql-io/multicorn2/archive/$MULTICORN_REF.tar.gz
RUN tar -xvf $MULTICORN_REF.tar.gz
WORKDIR /multicorn2-$MULTICORN_REF
RUN make
RUN make install
RUN python3 setup.py install

RUN pip3 install git+https://github.com/bosth/geofdw

ADD initdb.d/ /docker-entrypoint-initdb.d
WORKDIR /
EXPOSE 5432

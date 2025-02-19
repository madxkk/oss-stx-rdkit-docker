FROM debian:buster
LABEL maintainer="madxkk@xaked.com"

ENV PG_MAJOR=11
ARG DOCKER_TAG=latest

# This adds the postgres apt repos as postgresql-10 is not available for buster
# and postgresql-11 does not seem to work with RDKit yet.
#
RUN apt-get update &&\
 apt-get -y install curl ca-certificates gnupg &&\
 curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
 echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >  /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
 apt-get upgrade -y &&\
 apt-get install -y --no-install-recommends\
 python3\
 python3-numpy\
 libboost-system1.67.0\
 libboost-thread1.67.0\
 libboost-serialization1.67.0\
 libboost-python1.67.0\
 libboost-regex1.67.0\
 libboost-chrono1.67.0\
 libboost-date-time1.67.0\
 libboost-atomic1.67.0\
 libboost-iostreams1.67.0\
 postgresql-$PG_MAJOR\
 postgresql-client-$PG_MAJOR\
 postgresql-plpython3-$PG_MAJOR\
 gosu\
 wget\
 zip &&\
 apt-get clean -y

COPY\
  artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Runtime.deb\
  artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Python.deb\
  artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-PgSQL.deb\
  /tmp/
RUN dpkg -i /tmp/*.deb && rm -f /tmp/*.deb

# symlink python3 to python
RUN cd /usr/bin && ln -s python3 python

WORKDIR /

# make the sample config easier to munge (and "correct by default")
RUN mv -v "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample" /usr/share/postgresql/ \
	&& ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/" \
	&& sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
ENV PATH $PATH:/usr/lib/postgresql/$PG_MAJOR/bin
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint-cartridge.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
FROM debian:buster
LABEL maintainer="madxkk@xaked.com"

ARG GIT_REPO
ARG GIT_BRANCH=master
ARG GIT_TAG
ARG POSTGRES_VERSION=11

RUN apt-get update &&\
 apt-get -y install curl ca-certificates gnupg &&\
 curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
 echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >  /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
  apt-get install -y --no-install-recommends \
  build-essential\
  python3-dev\
  python3-numpy\
  python3-pip\
  cmake\
  sqlite3\
  libsqlite3-dev\
  libboost-dev\
  libboost-system1.67-dev\
  libboost-thread1.67-dev\
  libboost-serialization1.67-dev\
  libboost-python1.67-dev\
  libboost-regex1.67-dev\
  libboost-iostreams1.67-dev\
  zlib1g-dev\
  swig\
  libeigen3-dev\
  git\
  wget\
  openjdk-11-jdk\
  postgresql-$POSTGRES_VERSION\
  postgresql-server-dev-$POSTGRES_VERSION\
  postgresql-plpython3-$POSTGRES_VERSION\
  zip\
  unzip &&\
  apt-get clean -y


RUN if [ $GIT_TAG ]; then echo "Checking out tag $GIT_TAG from repo $GIT_REPO branch $GIT_BRANCH"; else echo "Checking out repo $GIT_REPO branch $GIT_BRANCH"; fi
RUN git clone -b $GIT_BRANCH --single-branch $GIT_REPO &&\
  if [ $GIT_TAG ]; then cd rdkit && git fetch --tags && git checkout $GIT_TAG; fi

COPY patch_pgsql_rpm.patch /rdkit
RUN cd /rdkit && patch -p1 -l < patch_pgsql_rpm.patch

ENV RDBASE=/rdkit
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RDBASE/lib:$RDBASE/Code/JavaWrappers/gmwrapper:/usr/lib/x86_64-linux-gnu
ENV PYTHONPATH=$PYTHONPATH:$RDBASE
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CLASSPATH=$RDBASE/Code/JavaWrappers/gmwrapper/org.RDKit.jar

RUN mkdir $RDBASE/build
WORKDIR $RDBASE/build

RUN cmake -Wno-dev\
  -DPYTHON_EXECUTABLE=/usr/bin/python3\
  -DRDK_INSTALL_INTREE=OFF\
  -DRDK_BUILD_INCHI_SUPPORT=ON\
  -DRDK_BUILD_AVALON_SUPPORT=ON\
  -DRDK_BUILD_PYTHON_WRAPPERS=ON\
  -DRDK_BUILD_SWIG_WRAPPERS=ON\
  -DRDK_BUILD_PGSQL=ON\
  -DPostgreSQL_ROOT=/usr/lib/postgresql/$POSTGRES_VERSION\
  -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$POSTGRES_VERSION/server\
  -DCMAKE_INSTALL_PREFIX=/usr\
  -DCPACK_PACKAGE_RELOCATABLE=OFF\
  ..

RUN nproc=$(getconf _NPROCESSORS_ONLN)\
  && make -j $(( nproc > 2 ? nproc - 2 : 1 ))
RUN make install
RUN sh Code/PgSQL/rdkit/pgsql_install.sh
RUN cpack -G DEB

WORKDIR $RDBASE
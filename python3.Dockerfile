FROM debian:buster
LABEL maintainer="madxkk@xaked.com"

RUN apt-get update &&\
 apt-get upgrade -y &&\
 apt-get install -y --no-install-recommends\
 python3\
 python3-dev\
 python3-pip\
 python3-setuptools\
 python3-wheel\
 python3-six\
 gcc\
 libboost-system1.67.0\
 libboost-thread1.67.0\
 libboost-serialization1.67.0\
 libboost-python1.67.0\
 libboost-regex1.67.0\
 libboost-chrono1.67.0\
 libboost-date-time1.67.0\
 libboost-atomic1.67.0\
 libboost-iostreams1.67.0\
 libpcre3\
 libpcre3-dev\
 sqlite3\
 wget\
 cron\
 nginx\
 curl\
 zip &&\
 apt-get clean -y

ARG DOCKER_TAG=latest

COPY artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Runtime.deb artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Python.deb /tmp/
RUN dpkg -i /tmp/*.deb && rm -f /tmp/*.deb

# symlink python3 to python
RUN cd /usr/bin &&\
  ln -s python3 python &&\
  ln -s pip3 pip &&\
  pip install --upgrade\
  pandas==0.25.3\
  psycopg2-binary==2.8.4\
  flask==1.1.1\
  flask-cors==3.0.8\
  flask-restful==0.3.7\
  flask-jwt-extended==3.24.1\
  PyJWT==1.7.1\
  Flask-SQLAlchemy==2.4.1\
  flask-mail==0.9.1\
  simplejson==3.17.0\
  scipy==1.4.1\
  xlrd==1.2.0\
  passlib==1.7.2\
  requests==2.22.0\
  python-dotenv==0.10.3\
  numpy==1.18.0\
  certifi==2019.11.28\
  werkzeug==0.16.0\
  ipython==7.10.2\
  pytest==5.3.2\
  uwsgi==2.0.18

WORKDIR /

# add the rdkit user
RUN useradd -u 1000 -g 0 -m rdkit
USER 1000
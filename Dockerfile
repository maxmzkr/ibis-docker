FROM impala-docker

RUN apt-get update && apt-get install -y \
  clang-3.8 \
  cmake \
  git \
  libboost-dev \
  make \
  postgresql-server-dev-9.3 \
  python-dev \
  python-virtualenv


WORKDIR /ibis

RUN git clone https://github.com/maxmzkr/ibis.git

RUN pip install cython>=0.21
RUN pip install --upgrade setuptools
RUN pip install -r ibis/requirements.txt
RUN pip install mock
RUN pip install click

USER postgres
RUN service postgresql start && \
  createdb ibis_testing --owner=postgres

RUN service postgresql start && \
  psql -v ON_ERROR_STOP=1 -c 'ALTER USER postgres WITH PASSWORD '"'"'password'"'";

USER root

RUN ln -s /usr/bin/clang++-3.8 /usr/bin/clang++

ENV IBIS_TEST_WEBHDFS_PORT=50070
ENV IBIS_POSTGRES_USER=postgres
ENV IBIS_POSTGRES_PASS=password
ENV PYTHONPATH=${PYTHONPATH}:/ibis/ibis

RUN cp /etc/hive/conf/hive-site.xml /etc/impala/conf/hive-site.xml

CMD service postgresql start &&  \
  service hive-metastore start && \
  service hadoop-hdfs-namenode start && \
  service hadoop-hdfs-datanode start && \
  service impala-state-store start && \
  service impala-catalog start && \
  service impala-server start && \
  /bin/bash

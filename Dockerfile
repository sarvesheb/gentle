FROM ubuntu:18.04

ENV TZ=Asia/Dubai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y \
		software-properties-common --reinstall && \
	apt-get clean
	
RUN DEBIAN_FRONTEND=noninteractive && \
	add-apt-repository ppa:deadsnakes/ppa && \
	apt-get update && \
	apt-get install -y \
		gcc g++ gfortran \
		libc++-dev \
		libstdc++-6-dev zlib1g-dev \
		automake autoconf libtool \
		sox \
		git subversion \
		libatlas3-base \
		ffmpeg \
		python3 python3-dev python3-pip \
		python3.9 \
		python python-dev python-pip \
		wget unzip && \
	apt-get clean

ADD ext /gentle/ext
RUN cd /gentle/ext/kaldi/tools/ && ./extras/install_openblas.sh && make -j 4 && cd ../../../../
RUN export MAKEFLAGS=' -j4' &&  cd /gentle/ext && \
	./install_kaldi.sh && \
	make depend && make && rm -rf kaldi *.o
RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y \
		python3.9-distutils && \
	apt-get clean
RUN DEBIAN_FRONTEND=noninteractive && \
	python3.9 -m pip install --upgrade setuptools && \
	python3.9 -m pip install --upgrade pip && \
	python3.9 -m pip install --upgrade twisted && \
	python3.9 -m pip install --upgrade distlib

ADD . /gentle
RUN cd /gentle && python3.9 setup.py develop
RUN cd /gentle && ./install_models.sh

EXPOSE 8765

VOLUME /gentle/webdata

CMD cd /gentle && python3 serve.py

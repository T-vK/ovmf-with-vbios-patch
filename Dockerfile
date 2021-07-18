FROM ubuntu:bionic

RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    apt-get -qq -y install -y wget vim build-essential gcc-5 g++-5 libgcc-5-dev git python2.7 iasl nasm subversion libwww-perl uuid-dev dos2unix
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5 && \
    echo 1 | update-alternatives --config gcc
RUN git clone --depth 1 --single-branch --branch edk2-stable201905 --recursive https://github.com/tianocore/edk2.git
COPY files/ /ovmf
CMD /ovmf/compile-ovmf.sh ${VROM}
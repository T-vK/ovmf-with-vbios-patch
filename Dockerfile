FROM debian:buster-20210721-slim

RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    apt-get -qq -y install -y build-essential python2.7 iasl nasm subversion libwww-perl uuid-dev dos2unix vim git && \
    git clone --depth 1 --single-branch --branch edk2-stable201905 https://github.com/tianocore/edk2.git && \
    cd edk2 && \ 
    git submodule init && \
    git submodule update --depth 1 CryptoPkg/Library/OpensslLib/openssl && \
    apt-get remove -y git && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf .git && \
    rm -rf CryptoPkg/Library/OpensslLib/openssl/.git

COPY files/ /ovmf
CMD /ovmf/compile-ovmf.sh ${VROM}

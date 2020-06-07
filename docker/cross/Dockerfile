
FROM ubuntu:14.04
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/bin/bash"]

MAINTAINER Andrea Michelotti "andrea.michelotti@lnf.infn.it"
RUN apt-get clean && apt-get update
RUN apt-get install -y software-properties-common pkg-config
RUN add-apt-repository -y ppa:git-core/ppa


#installa package needed by chaos compilation and test
RUN apt-get clean && \
    apt-get update

RUN apt-get install -y \
    librtmp0 \
    git \
    cmake3 \
    wget \
    pkg-config \
    autoconf \
    automake \
    libtool \
    doxygen \
    scons \
    ruby \
    curl \
    gcc \
    g++-4.8-arm-linux-gnueabihf \
    gcc-4.8-arm-linux-gnueabihf \
    build-essential 

# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8

#downlaod crosstool neede for embedded devices
RUN curl -SL http://opensource.lnf.infn.it/binary/chaos/tools/chaos-cross-tools-x86_64.tgz | tar xvz -C / --exclude usr/local/chaos/qt-56 
COPY ./chaos_start.sh /tmp/
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /bin/repo;chmod +x /bin/repo
RUN git config --global user.email andrea.michelotti@lnf.infn.it;git config --global user.name amichelo;git config --global color.ui true
COPY ssh_config /root/.ssh/config
COPY key-for-docker /root/.ssh/id_rsa
COPY key-for-docker.pub /root/.ssh/id_rsa.pub
RUN chmod a+x /tmp/chaos_start.sh
CMD /tmp/chaos_start.sh

FROM amazonlinux:2018.03

ENV BUILD_DIR="/tmp/build"
ENV INSTALL_DIR="/opt/vapor"

WORKDIR /tmp

# Lock To Proper Release

RUN sed -i 's/releasever=latest/releaserver=2018.03/' /etc/yum.conf

# Install Development Tools

RUN set -xe \
    && yum makecache \
    && yum groupinstall -y "Development Tools"  --setopt=group_package_types=mandatory,default

# Install CMake

RUN  set -xe \
    && mkdir -p /tmp/cmake \
    && cd /tmp/cmake \
    && curl -Ls  https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz \
    | tar xzC /tmp/cmake --strip-components=1 \
    && ./bootstrap --prefix=/usr/local \
    && make \
    && make install

# Install the Unix ODBC headers (1)

RUN set -xe; \
    curl http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-2.3.1-14.el7.x86_64.rpm > /tmp/unixODBC-2.3.1-14.el7.x86_64.rpm \
    && yum -y install /tmp/unixODBC-2.3.1-14.el7.x86_64.rpm \
    && curl http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-devel-2.3.1-14.el7.x86_64.rpm > /tmp/unixODBC-devel-2.3.1-14.el7.x86_64.rpm \
    && LD_LIBRARY_PATH= yum -y install /tmp/unixODBC-devel-2.3.1-14.el7.x86_64.rpm

# Install the Unix ODBC headers (2)

ENV UNIX_ODBC_BUILD_DIR=${BUILD_DIR}/unixODBC

RUN set -xe; \
    mkdir -p ${UNIX_ODBC_BUILD_DIR}; \
    curl -Ls ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.7.tar.gz \
    | tar xzC ${UNIX_ODBC_BUILD_DIR} --strip-components=1

WORKDIR  ${UNIX_ODBC_BUILD_DIR}/

RUN set -xe; \
    ./configure --sysconfdir=/opt --prefix=/opt --disable-gui --disable-drivers \
    --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE --enable-stats=no

RUN set -xe; \
    make install

# Install the MSSQL ODBC driver (1)

RUN set -xe; \
    curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo \
    && yum remove unixODBC-utf16 unixODBC-utf16-devel \
    && ACCEPT_EULA=Y yum -y install msodbcsql17

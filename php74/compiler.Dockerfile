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

#ENV PATH="/opt/bin:${PATH}"
#ENV LD_LIBRARY_PATH="/opt/lib64:/opt/lib"

# Install the Unix ODBC headers (1)

RUN set -xe; \
    curl http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-2.3.1-14.el7.x86_64.rpm > /tmp/unixODBC-2.3.1-14.el7.x86_64.rpm \
    && yum -y install /tmp/unixODBC-2.3.1-14.el7.x86_64.rpm \
    && curl http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-devel-2.3.1-14.el7.x86_64.rpm > /tmp/unixODBC-devel-2.3.1-14.el7.x86_64.rpm \
    && LD_LIBRARY_PATH= yum -y install /tmp/unixODBC-devel-2.3.1-14.el7.x86_64.rpm

# Install the Unix ODBC headers (2)

#ARG unixODBC
#ENV VERSION_unixODBC=${unixODBC}
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

## Install the MSSQL ODBC driver (2)
#
##ARG unixODBC
##ENV VERSION_unixODBC=${unixODBC}
#ENV UNIX_ODBC_BUILD_DIR=${BUILD_DIR}/unixODBC
#
#
## Compile ODBC driver manager
#
#RUN set -xe; \
#    mkdir -p ${UNIX_ODBC_BUILD_DIR}; \
#    curl -Ls ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.1.tar.gz \
#    | tar xzC ${UNIX_ODBC_BUILD_DIR} --strip-components=1
#
#WORKDIR  ${UNIX_ODBC_BUILD_DIR}/
#
#RUN set -xe; \
#    ./configure --sysconfdir=/opt --prefix=/opt --disable-gui --disable-drivers \
#    --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE --enable-stats=no

## Instal MSQSL Server driver
#
#RUN set -xe; \
#    make install
#
#ENV MSODBCSQL_BUILD_DIR=/opt/msodbcsql
#
#RUN set -xe; \
#    mkdir -p ${MSODBCSQL_BUILD_DIR}; \
#    curl -Ls https://download.microsoft.com/download/1/9/A/19AF548A-6DD3-4B48-88DC-724E9ABCEB9A/msodbcsql-17.5.2.1.tar.gz \
#    | tar xzC ${MSODBCSQL_BUILD_DIR} --strip-components=1
#
#RUN set -xe \
#    && cp /opt/msodbcsql/lib/* /opt/lib/ \
#    && cp -r /opt/msodbcsql/share/* /opt/share/ \
#    && cp -r /opt/msodbcsql/include/* /opt/include/ \
#    && rm -rf /opt/msodbcsql
#
#RUN echo -e "[ODBC Driver 17 for SQL Server]\nDescription=Microsoft ODBC Driver 17 for SQL Server\nDriver=/opt/lib/libmsodbcsql.17.dylib\n" > /opt/odbcinst.ini

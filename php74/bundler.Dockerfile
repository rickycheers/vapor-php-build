FROM vapor/runtime/php-74:latest as php_builder

SHELL ["/bin/bash", "-c"]

ENV BUILD_DIR="/tmp/build"
ENV INSTALL_DIR="/opt/vapor"

# Configure Default Compiler Variables

ENV PKG_CONFIG_PATH="${INSTALL_DIR}/lib64/pkgconfig:${INSTALL_DIR}/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig" \
    PKG_CONFIG="/usr/bin/pkg-config" \
    PATH="${INSTALL_DIR}/bin:${PATH}"

ENV LD_LIBRARY_PATH="${INSTALL_DIR}/lib64:${INSTALL_DIR}/lib"

# Strip All Unneeded Symbols

RUN find ${INSTALL_DIR} -type f -name "*.so*" -o -name "*.a"  -exec strip --strip-unneeded {} \;
RUN find ${INSTALL_DIR} -type f -executable -exec sh -c "file -i '{}' | grep -q 'x-executable; charset=binary'" \; -print|xargs strip --strip-all

# Symlink All Binaries / Libaries

RUN mkdir -p /opt/bin
RUN mkdir -p /opt/lib
RUN mkdir -p /opt/lib/curl

RUN cp /opt/vapor/bin/* /opt/bin
RUN cp /opt/vapor/sbin/* /opt/bin
RUN cp /opt/vapor/lib/php/extensions/no-debug-zts-20190902/* /opt/bin

RUN cp /opt/vapor/lib/* /opt/lib || true
RUN cp /opt/vapor/lib/libcurl* /opt/lib/curl || true

RUN cp "${INSTALL_DIR}/ssl/cert.pem" /opt/lib/curl/cert.pem
RUN cp /opt/vapor/lib64/* /opt/lib || true

RUN cp /etc/odbcinst.ini /opt/odbcinst.ini

RUN ls /opt/bin
RUN /opt/bin/php -i | grep curl


FROM amazonlinux:latest as awsclibuilder

WORKDIR /root

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

RUN yum update -y && yum install -y unzip

RUN unzip awscli-bundle.zip && cd awscli-bundle;

RUN ./awscli-bundle/install -i /opt/awscli -b /opt/awscli/aws

# Copy Everything To The Base Container

FROM amazonlinux:2018.03

ENV INSTALL_DIR="/opt/vapor"

ENV PATH="/opt/bin:${PATH}" \
    LD_LIBRARY_PATH="${INSTALL_DIR}/lib64:${INSTALL_DIR}/lib"

RUN mkdir -p /opt

WORKDIR /opt

COPY --from=php_builder /opt /opt
COPY --from=awsclibuilder /opt/awscli/lib/python2.7/site-packages/ /opt/awscli/
COPY --from=awsclibuilder /opt/awscli/bin/ /opt/awscli/bin/
COPY --from=awsclibuilder /opt/awscli/bin/aws /opt/awscli/aws

RUN LD_LIBRARY_PATH= yum -y install zip

RUN rm -rf /opt/awscli/pip* /opt/awscli/setuptools* /opt/awscli/awscli/examples

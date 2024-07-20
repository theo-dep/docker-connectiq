FROM ubuntu:22.04

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG ADDITIONAL_PACKAGES
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Connect IQ SDK" \
      org.label-schema.description="Kalemena Connect IQ SDK" \
      org.label-schema.url="private" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/kalemena/docker-connectiq" \
      org.label-schema.vendor="Kalemena" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Check at https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
#          https://developer.garmin.com/downloads/connect-iq/sdk-manager/sdk-manager.json
ENV CONNECT_IQ_SDK_URL https://developer.garmin.com/downloads/connect-iq

# Compiler tools
RUN    apt-get update -y \
    && apt-get install --no-install-recommends -qqy libwebkit2gtk-4.0-dev \
# libwebkit2gtk-4.0 deps
    && apt-get install --no-install-recommends -qqy gir1.2-javascriptcoregtk-4.0 gir1.2-webkit2-4.0 libicu70 \
        libjavascriptcoregtk-4.0-18 libjavascriptcoregtk-4.0-dev libsoup2.4-dev libwebkit2gtk-4.0-37 \
# JDK and other deps
    && apt-get install --no-install-recommends -qqy openjdk-11-jdk \
    && apt-get install --no-install-recommends -qqy unzip wget curl git ssh tar gzip tzdata ca-certificates gnupg2 libusb-1.0 libpng16-16 \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# (optional) if .Garmin folder is mounted at runtime, SDK install is not required
RUN    echo "Downloading Connect IQ SDK: ${VERSION}" \
    && cd /opt \
    && curl -LsS -o ciq.zip ${CONNECT_IQ_SDK_URL}/sdks/connectiq-sdk-lin-${VERSION}.zip \
    && unzip ciq.zip -d ciq \
    && rm -f ciq.zip

RUN    echo "Downloading Connect IQ SDK Manager:" \
    && cd /opt \
    && curl -LsS -o ciq-sdk-manager.zip ${CONNECT_IQ_SDK_URL}/sdk-manager/connectiq-sdk-manager-linux.zip \
    && unzip ciq-sdk-manager.zip -d ciq \
    && rm -f ciq-sdk-manager.zip

# Fix missing libpng12 (monkeydo)
RUN ln -s /usr/lib/x86_64-linux-gnu/libpng16.so.16 /usr/lib/x86_64-linux-gnu/libpng12.so.0

# Set user=1000 and group=0 as the owner of all files under /home/developer
RUN    mkdir -p /home/developer \
    && echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd \
    && chown -R 1000:0 /home/developer && chmod -R ug+rw /home/developer \
    && chown -R 1000:0 /opt && chmod -R ug+rw /opt

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

ENV CIQ_HOME        /opt/ciq
ENV PATH ${PATH}:${CIQ_HOME}/bin

CMD [ "/bin/bash" ]
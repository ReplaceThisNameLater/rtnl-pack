FROM bellsoft/liberica-runtime-container:jre-21-musl
RUN apk add --no-cache coreutils curl ncurses \
    && rm -rf /var/cache/apk/*

# JVM patch
RUN sed -i 's|/proc/cgroups|/cgroups_fake|' /usr/lib/jvm/liberica21-container-jre/lib/server/libjvm.so
COPY --chmod=444 --chown=0:0 ./docker/cgroups_fake /cgroups_fake

ADD --chmod=555 \
    --checksum=sha256:c9f646908d340d84773948a9a7d98bc1dae250d35e1016dc6e2b8459760b5598 \
    https://github.com/packwiz/packwiz-installer/releases/download/v0.5.14/packwiz-installer.jar /opt/packwiz-installer.jar

ARG PROFILER=
ENV PROFILER=${PROFILER}
RUN if [ "$PROFILER" = "yjp" ]; then \
        wget https://www.yourkit.com/download/docker/YourKit-JavaProfiler-2025.3-docker.zip -P /tmp/ && \
        unzip /tmp/YourKit-JavaProfiler-2025.3-docker.zip -d /usr/local \
            YourKit-JavaProfiler-2025.3/bin/linux-musl-x86-64/libyjpagent.so && \
        rm /tmp/YourKit-JavaProfiler-2025.3-docker.zip; \
    fi

ARG UID=1000
ARG GID=1000
USER "${UID}:${GID}"

WORKDIR /srv/minecraft
VOLUME /srv/minecraft

COPY --chmod=555 --chown=0:0 ./docker/entrypoint.sh /entrypoint.sh
COPY --chmod=555 --chown=0:0 . /opt/pack

ENTRYPOINT ["/entrypoint.sh"]

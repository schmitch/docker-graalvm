FROM debian:trixie-slim AS build-env
ARG TARGETARCH
# GraalVM Community 25 Innovation 5 (graal 25.5.5.0.3, JDK 25.0.5)
# https://github.com/graalvm/graalvm-ce-builds/releases/tag/graal-25.5.5.0.3
ENV GRAAL_RELEASE=graal-25.5.5.0.3
ENV GRAAL_PKG_VERSION=25i5-25.0.5.0.3
ENV GRAAL_SHA256_X64=c6438dee6c3ade2220d40b7ccdcad24b512d30e233e61bb4fc70519522de34ef
ENV GRAAL_SHA256_AARCH64=41741c0650ae7564a78335f9e4fc353a902e6ff1d4140f2e4fabd1c55d5cce66
WORKDIR /app
RUN apt-get update -y && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/*
RUN case "$TARGETARCH" in \
        amd64) arch=x64; sha=$GRAAL_SHA256_X64 ;; \
        arm64) arch=aarch64; sha=$GRAAL_SHA256_AARCH64 ;; \
        *) echo "unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o graalvm.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/$GRAAL_RELEASE/graalvm-community-jdk-${GRAAL_PKG_VERSION}_linux-${arch}_bin.tar.gz && \
    echo "$sha  graalvm.tar.gz" | sha256sum -c - && \
    mkdir /app/graalvm && \
    tar xzf graalvm.tar.gz --strip-components=1 -C /app/graalvm && \
    rm graalvm.tar.gz

COPY certs/*.cer /tmp/certs/
COPY certs/*.crt /tmp/certs/

RUN for name in $(ls /tmp/certs); do /app/graalvm/bin/keytool -importcert -v -cacerts -storepass changeit -file /tmp/certs/$name -noprompt -alias $name ; done && \
    rm -rf /tmp/certs

# only the JIT runtime is needed to run the applications, drop the native-image builder and the sources
RUN rm -rf /app/graalvm/lib/svm /app/graalvm/lib/static /app/graalvm/lib/src.zip /app/graalvm/bin/native-image*

FROM debian:trixie-slim
ENV GRAAL_VERSION=25.5.5.0.3
ENV TZ='Europe/Berlin'

RUN apt-get update -y && apt-get install -y --no-install-recommends libfreetype6 locales tzdata && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE:de
ENV LC_ALL=de_DE.UTF-8

LABEL maintainer="c.schmitt@briefdomain.de"
COPY --from=build-env /app/graalvm /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV JAVA_HOME=/usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV PATH=$PATH:/usr/lib/jvm/graalvm-$GRAAL_VERSION/bin
RUN ln -s /usr/lib/jvm/graalvm-$GRAAL_VERSION/bin/java /usr/bin/java
ENTRYPOINT [ "/usr/bin/java", "-jar" ]

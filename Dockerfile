FROM ubuntu AS build-env
ENV GRAAL_VERSION 22.3.3
ENV GRAAL_PKG graalvm-ce-java11-linux-amd64-$GRAAL_VERSION
WORKDIR /app
RUN apt update -y && apt install -y curl tar
RUN curl -L -o /app/$GRAAL_PKG.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAAL_VERSION/$GRAAL_PKG.tar.gz
RUN tar xfvz $GRAAL_PKG.tar.gz

COPY certs/*.cer /tmp/certs/
COPY certs/*.crt /tmp/certs/

RUN for name in $(ls /tmp/certs); do /app/graalvm-ce-java11-$GRAAL_VERSION/bin/keytool -importcert -v -keystore /app/graalvm-ce-java11-$GRAAL_VERSION/lib/security/cacerts -storepass changeit -file /tmp/certs/$name -noprompt -alias $name ; done && \
    rm -rf /tmp/certs

RUN rm -rf /app/graalvm-ce-java11-$GRAAL_VERSION/bin/polyglot
RUN rm -rf /app/graalvm-ce-java11-$GRAAL_VERSION/languages
RUN rm -rf /app/graalvm-ce-java11-$GRAAL_VERSION/lib/polyglot

FROM debian:bookworm-slim
ENV GRAAL_VERSION 22.3.3
ENV TZ 'Europe/Berlin'

RUN apt-get update -y && apt-get install -y libfreetype6 locales tzdata && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

LABEL maintainer="c.schmitt@briefdomain.de"
COPY --from=build-env /app/graalvm-ce-java11-$GRAAL_VERSION /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV JAVA_HOME /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV PATH $PATH:/usr/lib/jvm/graalvm-$GRAAL_VERSION/bin
RUN ln -s /usr/lib/jvm/graalvm-$GRAAL_VERSION/bin/java /usr/bin/java
ENTRYPOINT [ "/usr/bin/java", "-jar" ]

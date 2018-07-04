FROM ubuntu AS build-env
ENV GRAAL_VERSION 1.0.0-rc3
ENV GRAAL_PKG graalvm-ce-$GRAAL_VERSION-linux-amd64
WORKDIR /app
RUN apt update -y && apt install -y curl tar
RUN curl -L -o /app/$GRAAL_PKG.tar.gz https://github.com/oracle/graal/releases/download/vm-$GRAAL_VERSION/$GRAAL_PKG.tar.gz
RUN tar xfvz $GRAAL_PKG.tar.gz

COPY certs/*.cer /tmp/certs/

RUN for name in $(ls /tmp/certs); do /app/graalvm-ce-$GRAAL_VERSION/jre/bin/keytool -importcert -v -keystore /app/graalvm-ce-$GRAAL_VERSION/jre/lib/security/cacerts -storepass changeit -file /tmp/certs/$name -noprompt -alias $name ; done && \
    rm -rf /tmp/certs

RUN rm -rf /app/graalvm-ce-$GRAAL_VERSION/jre/bin/polyglot
RUN rm -rf /app/graalvm-ce-$GRAAL_VERSION/jre/languages
RUN rm -rf /app/graalvm-ce-$GRAAL_VERSION/jre/lib/polyglot

FROM gcr.io/distroless/base
LABEL maintainer="c.schmitt@briefdomain.de"
ENV GRAAL_VERSION 1.0.0-rc3
COPY --from=build-env /app/graalvm-ce-$GRAAL_VERSION/jre /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV JAVA_HOME /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV PATH $PATH:/usr/lib/jvm/graalvm-$GRAAL_VERSION/bin
ENTRYPOINT [ "/usr/bin/java", "-jar" ]

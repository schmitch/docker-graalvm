FROM ubuntu AS build-env
ENV GRAAL_VERSION 1.0.0-rc1
ENV GRAAL_PKG graalvm-ce-$GRAAL_VERSION-linux-amd64
WORKDIR /app
RUN apt update -y && apt install -y curl tar
RUN curl -L -o /app/$GRAAL_PKG.tar.gz https://github.com/oracle/graal/releases/download/vm-1.0.0-rc1/$GRAAL_PKG.tar.gz
RUN tar xfvz $GRAAL_PKG.tar.gz
RUN rm -rf /app/graalvm-$GRAAL_VERSION/jre/bin/polyglot
RUN rm -rf /app/graalvm-$GRAAL_VERSION/jre/languages
RUN rm -rf /app/graalvm-$GRAAL_VERSION/jre/lib/polyglot

FROM gcr.io/distroless/base
ENV GRAAL_VERSION 1.0.0-rc1
LABEL maintainer="c.schmitt@briefdomain.de"
COPY --from=build-env /app/graalvm-$GRAAL_VERSION/jre /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV JAVA_HOME /usr/lib/jvm/graalvm-$GRAAL_VERSION
ENV PATH $PATH:/usr/lib/jvm/graalvm-$GRAAL_VERSION/bin
entrypoint [ "/usr/bin/java", "-jar" ]

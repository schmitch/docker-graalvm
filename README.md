# GraalVM Image to run Java Applications

Debian 13 (trixie) with GraalVM Community for JDK 25, used as the base image for the Java applications.

- GraalVM Community 25 Innovation 5 (graal 25.5.5.0.3, JDK 25.0.5), the download is pinned by its SHA-256
- only the JIT runtime: the native-image builder is removed
- `de_DE.UTF-8` locale and `Europe/Berlin` time zone
- `java` is on the `PATH` and linked to `/usr/bin/java`
- `linux/amd64` and `linux/arm64`

## Build

The image is published on Docker Hub as `schmitch/graalvm-debian`, tagged `<graal major.minor>-java<jdk>`:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --provenance=false --sbom=false \
  --output type=image,name=schmitch/graalvm-debian:25.5-java25,push=true,oci-mediatypes=false .
```

The flags keep it a Docker manifest list without attestations: the Jib version loki builds with (sbt-jib 1.0.0,
jib-core 0.20) can't read an OCI image index.

`registry.envisia.io` is only a proxy to Docker Hub, so the applications pull it as
`registry.envisia.io/schmitch/graalvm-debian:25.5-java25`.

To upgrade GraalVM, change `GRAAL_RELEASE`, `GRAAL_PKG_VERSION`, `GRAAL_VERSION` and the two checksums (the
`.sha256` files next to the downloads on the release page).

## Certificates

The certificates in `certs/` (`*.cer` and `*.crt`) are added to the JDK's `cacerts`: the Amazon Trust and
GoDaddy roots, plus the DHL / Deutsche Post, GlobalSign and Zscaler ones.

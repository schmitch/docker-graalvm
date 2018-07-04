# GraalVM Image to run Java Applications

Currently this Image builds the GraalVM in a way that only Java Applications can be run.

## Generate Symlink

Docker is unable to copy a symlink from a base image to another image, so we use a trick to
generate a tarball that will be extracted on the base image to also have a symlink at /usr/bin/java

## Certificates
 
This image contains all Amazon Trust Certificates and GoDaddy

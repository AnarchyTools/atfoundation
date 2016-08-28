FROM drewcrawford/buildbase:latest
RUN apt-get update
RUN apt-get install atbuild package-deb -y
ADD . /atpkg
WORKDIR /atpkg
RUN atbuild check
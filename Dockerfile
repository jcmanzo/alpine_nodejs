FROM alpine
ARG NodeVersion
ARG PythonVersion

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install dependency
RUN apk add --no-cache libstdc++
RUN apk add --no-cache --virtual .build-deps binutils-gold curl g++ gcc gnupg libgcc linux-headers make $PythonVersion

# donwload and compile node from source code.
RUN wget https://nodejs.org/dist/$NodeVersion/node-$NodeVersion.tar.gz && tar -zxvf node-$NodeVersion.tar.gz
RUN cd node-$NodeVersion && ./configure --dest-cpu=x64 --partly-static && make -j$(getconf _NPROCESSORS_ONLN)

# create and copy tar.gz into /node_staging
RUN mkdir -p /usr/src/out
WORKDIR /usr/src/out
RUN cp /usr/src/app/node-$NodeVersion/out/Release/node /usr/src/out/bin
RUN cp /usr/src/app/node-$NodeVersion/LICENSE /usr/src/out/LICENSE
RUN tar -czvf node-$NodeVersion-alpine-x64.tar.gz ./bin ./LICENSE
RUN cp ./node-$NodeVersion-alpine-x64.tar.gz /node_staging

# copy the tar.gz into the mapped in volume
CMD ["cp", "/node_staging", "/node_output"]

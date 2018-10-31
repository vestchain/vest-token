FROM vestio/builder
ARG branch=master
ARG symbol=SYS

RUN git clone -b $branch https://github.com/VESTIO/vest.git --recursive \
    && cd vest && echo "$branch:$(git rev-parse HEAD)" > /etc/vestio-version \
    && cmake -H. -B"/opt/vestio" -GNinja -DCMAKE_BUILD_TYPE=Release -DWASM_ROOT=/opt/wasm -DCMAKE_CXX_COMPILER=clang++ \
       -DCMAKE_C_COMPILER=clang -DCMAKE_INSTALL_PREFIX=/opt/vestio  -DSecp256k1_ROOT_DIR=/usr/local -DBUILD_MONGO_DB_PLUGIN=true -DCORE_SYMBOL_NAME=$symbol \
    && cmake --build /opt/vestio --target install \
    && cp /vest/Docker/config.ini / && ln -s /opt/vestio/contracts /contracts && cp /vest/Docker/nodvestd.sh /opt/vestio/bin/nodvestd.sh && ln -s /vest/tutorials /tutorials

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssl ca-certificates vim psmisc python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip3 install numpy
ENV VESTIO_ROOT=/opt/vestio
RUN chmod +x /opt/vestio/bin/nodvestd.sh
ENV LD_LIBRARY_PATH /usr/local/lib
VOLUME /opt/vestio/bin/data-dir
ENV PATH /opt/vestio/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

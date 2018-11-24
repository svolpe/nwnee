docker run --rm -it --network=my-net \
    -p 8022:22 -p 5121:5121/udp -p 80:80 -e NWN_PORT=5121 \
    -v $(pwd)/vagabondModules:/nwn/home \
    -v $(pwd)/www:/var/www \
    -e NWN_PUBLICSERVER=0 \
    -e NWNX_SQL_SKIP=n \
    -e NWNX_OBJECT_SKIP=n \
    -e NWNX_PLAYER_SKIP=n \
    -e NWNX_CREATURE_SKIP=n \
    -e NWNX_SQL_TYPE=MYSQL \
    -e NWNX_SQL_HOST=10.200.0.198 \
    -e NWNX_SQL_USERNAME=nwn \
    -e NWNX_SQL_PASSWORD=nwnuser1 \
    -e NWNX_SQL_DATABASE=nwn \
    -e NWN_MODULE=NWNEE_CEP2v1c_Dungeons_n_Dragons_04_02_18b \
    vagabond

#!/bin/bash
##########################
#  Variables:
#  DRIVE: location of the (probably external) drive holding a /BTC directory
##########################
DRIVE=/Volumes/sandisk

# Start BTC first so that proxy can access BTC's .cookie file
# Sleep so that the .cookie file is generated
BTC_DATADIR=$DRIVE/BTC
bitcoind -datadir=$BTC_DATADIR &
sleep 2

ELECTRS_DATADIR=$DRIVE/electrs
COOKIE=$(cat ${BTC_DATADIR}/.cookie)
export BTC_RPC_COOKIE_PASS=${COOKIE:11}
export BTC_RPC_PORT=8332
export BTC_NETWORK=MAIN
export ELECTRS_HOST=127.0.0.1
export ELECTRS_PORT=50001
export PROXY_PORT=50002

node src/server.js &

./electrs/target/release/electrs \
    --timestamp \
    --cookie-file $BTC_DATADIR/.cookie \
    --daemon-dir $BTC_DATADIR \
    --db-dir $ELECTRS_DATADIR \
    --daemon-rpc-addr "127.0.0.1:${BTC_RPC_PORT}" \
    --electrum-rpc-addr $ELECTRS_HOST:$ELECTRS_PORT

#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoind"

  set -- bitcoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bitcoind" ]; then
  mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/bitcoin.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
    server=${BITCOIN_SERVER:-0}
    daemon=1
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoin}
    walletnotify=$BITCOIN_NOTIFY_CMD
		EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"
	fi

  chmod 700 "$BITCOIN_DATA"
  chown -R bitcoin "$BITCOIN_DATA"
  rm -Rf /home/bitcoin/.bitcoin
  ln -sfn $BITCOIN_DATA /home/bitcoin/.bitcoin
  chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo
  exec gosu bitcoin "$@"
fi

echo
exec "$@"

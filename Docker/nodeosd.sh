#!/bin/sh
cd /opt/vestio/bin

if [ -f '/opt/vestio/bin/data-dir/config.ini' ]; then
    echo
  else
    cp /config.ini /opt/vestio/bin/data-dir
fi

if [ -d '/opt/vestio/bin/data-dir/contracts' ]; then
    echo
  else
    cp -r /contracts /opt/vestio/bin/data-dir
fi

while :; do
    case $1 in
        --config-dir=?*)
            CONFIG_DIR=${1#*=}
            ;;
        *)
            break
    esac
    shift
done

if [ ! "$CONFIG_DIR" ]; then
    CONFIG_DIR="--config-dir=/opt/vestio/bin/data-dir"
else
    CONFIG_DIR=""
fi

exec /opt/vestio/bin/nodvest $CONFIG_DIR "$@"

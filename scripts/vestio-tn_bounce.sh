#!/bin/bash

pushd $VESTIO_HOME

if [ ! -f programs/nodvest/nodvest ]; then
    echo unable to locate binary 
    exit 1
fi

config_base=etc/vestio/node_
if [ -z "$VESTIO_NODE" ]; then
    DD=`ls -d ${config_base}[012]?`
    ddcount=`echo $DD | wc -w`
    if [ $ddcount -ne 1 ]; then
        echo $HOSTNAME has $ddcount config directories, bounce not possible. Set environment variable
        cd -
        exit 1
    fi
    OFS=$((${#DD}-2))
    export VESTIO_NODE=${DD:$OFS}
else
    DD=${config_base}$VESTIO_NODE
    if [ ! \( -d $DD \) ]; then
        echo no directory named $PWD/$DD
        cd -
        exit 1
    fi
fi

bash $VESTIO_HOME/scripts/vestio-tn_down.sh
bash $VESTIO_HOME/scripts/vestio-tn_up.sh $*

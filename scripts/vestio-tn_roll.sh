#!/bin/bash

if [ -z "$VESTIO_HOME" ]; then
    echo VESTIO_HOME not set - $0 unable to proceed.
    exit -1
fi

cd $VESTIO_HOME

if [ -z "$VESTIO_NODE" ]; then
    DD=`ls -d var/lib/node_[012]?`
    ddcount=`echo $DD | wc -w`
    if [ $ddcount -gt 1 ]; then
        DD="all"
    fi
    OFS=$((${#DD}-2))
    export VESTIO_NODE=${DD:$OFS}
else
    DD=var/lib/node_$VESTIO_NODE
    if [ ! \( -d $DD \) ]; then
        echo no directory named $PWD/$DD
        cd -
        exit -1
    fi
fi

prog=""
RD=""
for p in vestd vestiod nodvest; do
    prog=$p
    RD=bin
    if [ -f $RD/$prog ]; then
        break;
    else
        RD=programs/$prog
        if [ -f $RD/$prog ]; then
            break;
        fi
    fi
    prog=""
    RD=""
done

if [ \( -z "$prog" \) -o \( -z "$RD" \) ]; then
    echo unable to locate binary 
    exit 1
fi

SDIR=staging/vest
if [ ! -e $SDIR/$RD/$prog ]; then
    echo $SDIR/$RD/$prog does not exist
    exit 1
fi

if [ -e $RD/$prog ]; then
    s1=`md5sum $RD/$prog | sed "s/ .*$//"`
    s2=`md5sum $SDIR/$RD/$prog | sed "s/ .*$//"`
    if [ "$s1" == "$s2" ]; then
        echo $HOSTNAME no update $SDIR/$RD/$prog
        exit 1;
    fi
fi

echo DD = $DD

bash $VESTIO_HOME/scripts/vestio-tn_down.sh

cp $SDIR/$RD/$prog $RD/$prog

if [ $DD = "all" ]; then
    for VESTIO_RESTART_DATA_DIR in `ls -d var/lib/node_??`; do
        bash $VESTIO_HOME/scripts/vestio-tn_up.sh $*
    done
else
    bash $VESTIO_HOME/scripts/vestio-tn_up.sh $*
fi
unset VESTIO_RESTART_DATA_DIR

cd -

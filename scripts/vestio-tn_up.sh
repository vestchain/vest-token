#!/bin/bash

connected="0"

rundir=programs/nodvest
prog=nodvest


if [ "$PWD" != "$VESTIO_HOME" ]; then
    echo $0 must only be run from $VESTIO_HOME
    exit -1
fi

if [ ! -e $rundir/$prog ]; then
    echo unable to locate binary
    exit -1
fi

if [ -z "$VESTIO_NODE" ]; then
    echo data directory not set
    exit -1
fi

datadir=var/lib/node_$VESTIO_NODE
now=`date +'%Y_%m_%d_%H_%M_%S'`
log=stderr.$now.txt
touch $datadir/$log
rm $datadir/stderr.txt
ln -s $log $datadir/stderr.txt

relaunch() {
    echo "$rundir/$prog $* --data-dir $datadir --config-dir etc/vestio/node_$VESTIO_NODE > $datadir/stdout.txt  2>> $datadir/$log "
    nohup $rundir/$prog $* --data-dir $datadir --config-dir etc/vestio/node_$VESTIO_NODE > $datadir/stdout.txt  2>> $datadir/$log &
    pid=$!
    echo pid = $pid
    echo $pid > $datadir/$prog.pid

    for (( a = 10; $a; a = $(($a - 1)) )); do
        echo checking viability pass $((11 - $a))
        sleep 2
        running=$(pgrep $prog | grep -c $pid)
        echo running = $running
        if [ -z "$running" ]; then
            break;
        fi
        connected=`grep -c "net_plugin.cpp:.*connection" $datadir/$log`
        if [ "$connected" -ne 0 ]; then
            break;
        fi
    done
}

if [ -z "$VESTIO_LEVEL" ]; then
    echo starting with no modifiers
    relaunch $*
    if [ "$connected" -eq 0 ]; then
        VESTIO_LEVEL=replay
    else
        exit 0
    fi
fi

if [ "$VESTIO_LEVEL" == replay ]; then
    echo starting with replay
    relaunch $* --hard-replay-blockchain
    if [  "$connected" -eq 0 ]; then
        VESTIO_LEVEL=resync
    else
        exit 0
    fi
fi
if [ "$VESTIO_LEVEL" == resync ]; then
    echo starting with delete-all-blocks
    relaunch $* --delete-all-blocks
fi

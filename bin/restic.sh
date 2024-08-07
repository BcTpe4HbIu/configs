#!/bin/bash

set -e

RESTIC=restic
export RESTIC_REPOSITORY=${RESTIC_REPOSITORY:-/run/media/bctpe4hbiu/backups/archpc}

export RESTIC_KEEP_LATEST=7
export RESTIC_KEEP_DAILY=30
export RESTIC_KEEP_MONTHLY=12
export RESTIC_KEEP_YEARLY=2

if [ ! -d "$RESTIC_REPOSITORY" ] ; then
    echo Connect backup disk
    exit 1
fi

if [ -z "$RESTIC_PASSWORD" ] ; then
    echo Input restic password:
    read -sr PASS
    export RESTIC_PASSWORD="$PASS"
fi

NO_LOG=0

if [[ "$*" =~ "--json" ]] ; then
    NO_LOG=1
fi

function log {
    [ $NO_LOG -eq 0 ] && echo "[$(date)]: $*" || true
}

function backup {
    log starting backup
    $RESTIC backup --files-from ~/.backup_list
    log backup done
    forget
}

function forget {
    log keep ${RESTIC_KEEP_LATEST} latest snapshots
    log keep ${RESTIC_KEEP_DAILY} daily snapshots
    log keep ${RESTIC_KEEP_MONTHLY} monthly snapshots
    log keep ${RESTIC_KEEP_YEARLY} yearly snapshots
    log forget all else
    $RESTIC forget -c --group-by "host" -l ${RESTIC_KEEP_LATEST} -d ${RESTIC_KEEP_DAILY} -m ${RESTIC_KEEP_MONTHLY} -y ${RESTIC_KEEP_YEARLY} --keep-tag archive
    log forget done
}


function prune {
    log pruning unused data from repository
    $RESTIC prune
}

if [[ "$1" = "--help" ]] ; then
    log Usage:
    log     $0
    log     $0 --help
    log     $0 check
    exit 0
fi


case "$1" in
    "backup" )
        backup
    ;;
    "prune" )
        prune
    ;;
    "clean" )
        forget
        ;;
    "" )
        backup
    ;;
    "--" )
        shift
        exec $RESTIC $*
        ;;
    * )
        exec $RESTIC $*
    ;;
esac

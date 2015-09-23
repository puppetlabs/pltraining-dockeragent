#! /bin/sh
#
# Just force the master to compile a bunch of catalogs concurrently.
#
# Usage: download_catalogs.sh <number of runs> <seconds to sleep between requests>
#

if [ "$#" -eq 0 ]; then
    echo "This is a silly shell script to request many concurrent catalog compiles."
    echo "It's used for very simple load testing."
    echo
    echo "Usage: download_catalogs.sh <number of runs> <seconds to sleep between requests>"
    echo
    exit 1
fi

NUM=${1-5}
DELAY=${2-3}

# This just makes sure the master has facts for our node, and doesn't blow up
# due to the trusted fact kerfuffle.
puppet agent -t --noop

for i in $(seq 1 ${NUM})
do
    $(puppet catalog download > /dev/null 2>&1) &
    sleep ${DELAY}
done

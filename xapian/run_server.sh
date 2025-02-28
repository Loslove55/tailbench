#!/bin/bash
# $1 is the core number
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh
if [ "$#" -ne 3 ]
then 
	echo "Usage:"
	echo "${BASH_SOURCE[0]} CORES QPS REQUESTS"
	exit 1
fi

LD_LIBRARY_PATH=LD_LIBRARY_PATH:${DIR}/xapian-core-1.2.13/install/lib
export LD_LIBRARY_PATH

NSERVERS=1
CORES=$1
QPS=$2
WARMUPREQS=500
REQUESTS=$3

echo "NSERVERS = ${NSERVERS}" 

#/home/yl408/scripts/bash_scripts/turnoff_HT.sh
TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
 taskset -c ${CORES}  ${DIR}/xapian_networked_server -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki \
    -r 1000000000 &
echo $! > server.pid
cat server.pid
sudo chrt -f -p 99 $(cat server.pid)
wait $(cat server.pid)
rm -f server.pid 

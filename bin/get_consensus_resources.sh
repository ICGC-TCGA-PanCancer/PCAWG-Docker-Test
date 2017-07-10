#!/bin/bash

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/consensus"
tmp_dir="$base_dir/tmp"

mkdir -p $tmp_dir $resource_dir
docker=$(cat $base_dir/etc/workflows | grep Consensus | cut -f 2)

docker run -it -v "$resource_dir":/dbs $docker download reference /dbs
docker run -it -v "$resource_dir":/dbs $docker download annotations /dbs
docker run -it -v "$resource_dir":/dbs $docker download cosmic /dbs


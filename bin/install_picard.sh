#!/bin/bash

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
lib_dir="${base_dir}/lib"
lib_picard="${lib_dir}/picard/"

mkdir -p $lib_picard
wget https://github.com/broadinstitute/picard/releases/download/2.9.0/picard.jar -O ${lib_picard}picard.jar

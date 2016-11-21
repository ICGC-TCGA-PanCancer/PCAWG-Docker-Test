#!/bin/bash


base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
modules_dir="${base_dir}/modules"
lib_dir="${base_dir}/lib"
lib_maus="${lib_dir}/libmaus"
lib_biobambam="${lib_dir}/biobambam"

old_pwd=$PWD

cd $modules_dir/libmaus
autoreconf -i -f
./configure --prefix="$lib_maus"
make && make install
cd $old_pwd


cd $modules_dir/biobambam
autoreconf -i -f
./configure --with-libmaus="$lib_maus" --prefix="$lib_biobambam"
make && make install
cd $old_pwd


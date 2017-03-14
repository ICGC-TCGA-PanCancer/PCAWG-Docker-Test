#!/bin/bash

donor=$1

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
resource_dir="$base_dir/resources/"
data_dir="$base_dir/data/$donor/"
tumor_bam="$base_dir/data/$donor/tumor.bam"
normal_bam="$base_dir/data/$donor/normal.bam"

tmp_folder="$base_dir/tmp/$donor"
tmp_tumor_unaligned="$base_dir/tmp/$donor/tumor/unaligned/"
tmp_normal_unaligned="$base_dir/tmp/$donor/normal/unaligned/"

normal_header_file="$base_dir/tmp/normal_bam_header.sam"
tumor_header_file="$base_dir/tmp/tumor_bam_header.sam"


mkdir -p $tmp_folder
mkdir -p $tmp_tumor_unaligned
mkdir -p $tmp_normal_unaligned

java -Xmx8G -jar $base_dir/lib/picard/picard.jar RevertSam \
		I=$tumor_bam \
		O=$tmp_tumor_unaligned \
		OUTPUT_BY_READGROUP=true \
		OUTPUT_BY_READGROUP_FILE_FORMAT=bam \
		ATTRIBUTE_TO_CLEAR=XS \
		SORT_ORDER=unsorted \
		RESTORE_ORIGINAL_QUALITIES=true \
		REMOVE_DUPLICATE_INFORMATION=true \
		REMOVE_ALIGNMENT_INFORMATION=true \
		TMP_DIR=$tmp_folder

counter=1

for file in $(find ${tmp_tumor_unaligned} -name *.bam)
do

	RG=$(java -Xmx8G -jar $base_dir/lib/picard/picard.jar ViewSam INPUT=$file HEADER_ONLY=true | grep "^@RG")

	cat > $tumor_header_file <<-EOF
	@HD	VN:1.4
	${RG}
	@CO	dcc_project_code:DOCKER-TEST
	@CO	submitter_donor_id:${1}
	@CO	submitter_specimen_id:${1}.specimen
	@CO	submitter_sample_id:${1}.sample
	@CO	dcc_specimen_type:Primary tumour - solid tissue
	@CO	use_cntl:85098796-a2c1-11e3-a743-6c6c38d06053
	EOF

	java -Xmx8G -jar $base_dir/lib/picard/picard.jar ReplaceSamHeader I=$file HEADER=$tumor_header_file O=${data_dir}tumor.unaligned.${counter}.bam

	((counter++))
done


java -Xmx8G -jar $base_dir/lib/picard/picard.jar RevertSam \
		I=$normal_bam \
		O=$tmp_normal_unaligned \
		OUTPUT_BY_READGROUP=true \
		OUTPUT_BY_READGROUP_FILE_FORMAT=bam \
		ATTRIBUTE_TO_CLEAR=XS \
		SORT_ORDER=unsorted \
		RESTORE_ORIGINAL_QUALITIES=true \
		REMOVE_DUPLICATE_INFORMATION=true \
		REMOVE_ALIGNMENT_INFORMATION=true \
		TMP_DIR=$tmp_folder


counter=1

for file in $(find ${tmp_normal_unaligned} -name *.bam)
do

	RG=$(java -Xmx8G -jar $base_dir/lib/picard/picard.jar ViewSam INPUT=$file HEADER_ONLY=true | grep "^@RG")

	cat > $normal_header_file <<-EOF
	@HD	VN:1.4
	${RG}
	@CO	dcc_project_code:DOCKER-TEST
	@CO	submitter_donor_id:${1}
	@CO	submitter_specimen_id:${1}.specimen
	@CO	submitter_sample_id:${1}.sample
	@CO	dcc_specimen_type:Normal
	@CO	use_cntl:85098796-a2c1-11e3-a743-6c6c38d06053
	EOF

	java -Xmx8G -jar $base_dir/lib/picard/picard.jar ReplaceSamHeader I=$file HEADER=$normal_header_file O=${data_dir}normal.unaligned.${counter}.bam

	((counter++))
done

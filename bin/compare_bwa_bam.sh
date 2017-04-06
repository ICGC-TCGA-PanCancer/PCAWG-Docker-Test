#!/bin/bash
bwa_bam=$1
orig_bam=$2

TAB="	"

base_dir=$(dirname $(dirname $(readlink -f bin/get_gnos_donor.sh)))
tmp_dir="$base_dir/tmp/BWA_BAM_compare"
bwa_cut="$tmp_dir/bwa.cut"
orig_cut="$tmp_dir/orig.cut"
comparison="$tmp_dir/comparison"

mkdir -p $tmp_dir
samtools view -f 64 "$bwa_bam" | cut -f 1,3,4,17 | LC_ALL=C sort -t "$TAB" > $bwa_cut
samtools view -f 64 "$orig_bam" | cut -f 1,3,4,17 | LC_ALL=C sort -t "$TAB" > $orig_cut

LC_ALL=C join "$bwa_cut" "$orig_cut" > $comparison

ruby <<-EOF
#!/usr/bin/ruby

lines = 0
matches = 0
misses = 0
soft = 0

File.open('$comparison') do |f|
  while line = f.gets
begin
    code, *parts = line.split(" ")

    chr1 = parts.shift
    pos1 = parts.shift

    tmp = parts.shift
    if tmp =~ /^..:./
      miss1 = tmp
      chr2 = parts.shift
      pos2 = parts.shift
    else
      miss1 = nil
      chr2 = tmp
      pos2 = parts.shift
    end
    miss2 =  parts.shift

    lines += 1
    if [chr1, pos1] == [chr2, pos2]
      matches += 1
    else
      if miss1 and miss1 =~ /[XS]A:/
        alt = miss1.split(":")[2].split(";").collect{|p| pp = p.split(','); [pp[0], pp[1].sub(/^[+-]/,'')]}
        if alt.select{|p| p == [chr2, pos2] }.any?
          soft += 1
          next
        end
      else
        if miss2 and miss2 =~ /[XS]A:/
          alt = miss2.split(":")[2].split(";").collect{|p| pp = p.split(','); [pp[0], pp[1].sub(/^[+-]/,'')]}
          if alt.select{|p| p == [chr1, pos1] }.any?
            soft += 1
            next
          end
        end
      end
      
      misses += 1
    end 
    
rescue
puts line
puts [chr1, chr2, pos1, pos2, miss1, miss2].inspect

raise $!
end
  end
end

puts "Lines: #{lines}"
puts "Matches: #{matches}"
puts "Misses: #{misses}"
puts "Soft: #{soft}"
EOF

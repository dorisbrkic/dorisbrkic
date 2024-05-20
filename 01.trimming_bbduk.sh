#!/bin/bash
# ----------------QSUB Parameters----------------- #
#PBS -q q2
#PBS -l select=ncpus=12:mem=40g
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N trim_adapters.PE
#PBS -j oe
#PBS -J 0-191
cd $PBS_O_WORKDIR

# ----------------Loading variables------------------- #
THREADS=12
MEMORY=40g

IN_DIR=../Data
IN_SEQ=($(find $IN_DIR -maxdepth 1 -name "*.fq.gz"))
UNIQ_SEQ=($(printf "%s\n" "${IN_SEQ[@]%_*fq.gz}" | sort -u))
FILE=${UNIQ_SEQ[$PBS_ARRAY_INDEX]}
BASE=${FILE#${IN_DIR}/}

ADAPTER="path/adapters_wxs.fasta"

BBDUK_PAR="overwrite=t \
ktrim=r \
k=23 \
rcomp=t \
mink=11 \
hdist=1 \
minoverlap=8 \
minlength=80 \
qtrim=lr \
trimq=25  \
tbo \
copyundefined=t \
threads=$THREADS \
-Xmx$MEMORY"

# ----------------Commands------------------- #
#removing spikein and bbduk adapters
bbduk.sh \
in1=${FILE}_1.fq.gz \
in2=${FILE}_2.fq.gz \
out1=${BASE}_1.phixtrim.fq.gz \
out2=${BASE}_2.phixtrim.fq.gz \
ref="artifacts,phix" \
ref=$ADAPTER \
stats=${BASE}.stats \
$BBDUK_PAR 2> ${BASE}.trim.log

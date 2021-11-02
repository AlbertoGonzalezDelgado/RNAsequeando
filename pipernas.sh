#! /bin/bash

##Help message
if [ $# -ne 1 ]
then
	echo " "
	echo "usage pipernas <param_file>"
	echo " "
	echo "param.file: file where  the parameters ares specified"
	exit
fi

##Loading the parameters file
PFILE=$1
echo "Loading the parameters file"

WD=$(grep "working_directory:" $PFILE | awk '{ print $2 }')
FD=$(grep "folder_name:" $PFILE | awk '{ print $2 }')
GD=$(grep "genome:" $PFILE | awk '{ print $2 }')
AN=$(grep "annotation:" $PFILE | awk '{ print $2 }')

echo "Parameters has been loading"
echo "Working directory: $WD"
echo "Folder name: $FD"
echo "Genome is at: $GD"
echo "Annotation is at: $AN"

##Creating working directory
cd $WD
mkdir $FD
cd $FD
mkdir genome annotation samples results

##Adding genome.fa and annotation.gtf
cd genome
cp $GD .
cd ../annotation/
cp $AN .
cd ..

##Making genome index
cd /genome/
extract_splice_sites.py ../annotation/*.gtf > annot_splice.ss
extract_exons.py ../annotation/*.gtf > annot_exons.exon
hisat2-build --ss annot_splice.ss --exon annot_exons.exon *.fa index


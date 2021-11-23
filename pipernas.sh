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
NUMSAM=$(grep "number_samples:" $PFILE | awk '{ print $2 }')
PIPER=$(grep "piper:" $PFILE | awk '{ print $2 }')
SAMPLES=()
i=0
while [ $i -lt $NUMSAM ]
do
	j=$(($i + 1))
	SAMPLES[$i]=$( grep "sample_${j}:" $PFILE | awk '{ print $2 }')
	((i++))
done

echo ""
echo "Parameters has been loaded"
echo ""
echo "Working directory: $WD"
echo "Folder name: $FD"
echo "Genome is at: $GD"
echo "Annotation is at: $AN"
echo ""
echo "Number of samples is: $NUMSAM"
echo "samples: ${SAMPLES[@]}"
echo ""

##Creating working directory
cd $WD
mkdir $FD
cd $FD
mkdir genome annotation samples results

##Adding genome.fa and annotation.gtf
cd genome
cp $GD genome.fa.gz
gunzip genome.fa.gz

cd ../annotation
cp $AN annotation.gtf.gz
gunzip annotation.gtf.gz
cd ..

##Making genome index
cd genome
extract_splice_sites.py ../annotation/annotation.gtf > annot_splice.ss
extract_exons.py ../annotation/annotation.gtf > annot_exons.exon
hisat2-build --ss annot_splice.ss --exon annot_exons.exon genome.fa index
cd ..

##Making samples folder
cd samples

i=0
while [ $i -lt $NUMSAM ]
do
	j=$(($i + 1))
	mkdir sample_$j
	cd sample_$j
	cp ${SAMPLES[$i]} sample_${j}.fq.gz
	cd ..
	((i++))
done
cd ..
##Sample processing
mkdir logs
cd logs
i=0
while [ $i -lt $NUMSAM ]
do
	j=$(($i + 1))
	sbatch $PIPER/sample_processing.sh $WD/$FD/samples/sample_${j} $j $NUMSAM $PIPER
	((i++))
  echo "."
done
echo "All sample processing scripts have been submitted"
echo "."
echo ".."
echo "..."
echo "uwu"
echo "...."
echo "....."
echo "......"
echo "......."
echo "o UwU asimismo"

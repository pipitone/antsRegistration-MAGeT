#!/bin/bash
#Script to generate csv file of LabelOverlapMeasures from a multiatlas_subject_cv run
#Run with multiatlas_subject_cv_collect.sh <output.csv> <optional matching pattern> <optional target dir>

if [[ $3 ]]
then
  targetdir=$3
else
  targetdir=.
fi

if [[ ! -n $1 ]]
then
  echo "Output file not specified"
  exit 1
fi

output=$1
echo "file,atlases,templates,fold,Label,Total/Target,Jaccard,Dice,VolumeSimilarity,FalseNegative,FalsePositive" > $output
for dir in $targetdir/NFOLD_multiatlas_subject/${2}*
do
  atlases=$(basename $dir | grep -Eho '[0-9]+atlases' | sed 's/atlases//g')
  fold=$(basename $dir | grep -Eho 'fold[0-9]+' | sed 's/fold//g')
  for label in $dir/*/output/multiatlas/labels/majorityvote/*.mnc
  do
cat <<EOT
LabelOverlapMeasures 3 input/atlas/$(basename $label | sed 's#_t1.mnc##g') $label >(tail -n +2) | awk -vT="$(basename $label),$atlases,0,$fold," '{ print T \$0 }' >> $output
EOT
  done | parallel -v
done

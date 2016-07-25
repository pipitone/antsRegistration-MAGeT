#!/bin/bash
#mb_resample.sh labelname atlasname templatename subjectname
set -euo pipefail
IFS=$'\n\t'

labelname=$1
atlas=$2
template=$3
subject=$4
subjectname=$(basename $subject)
atlasname=$(basename $atlas)
templatename=$(basename $template)

# Here, we do a check for the presence of morpho transforms, if they exist we
# will only have nonlinear transforms in model space
if [[ -s output/transforms/modelspace/${subjectname}0_GenericAffine.xfm ]]
then
  if [[ ${subjectname} = ${templatename} ]]
  then
    # Apply transforms to label
    # atlas to model (affine)
    # atlas to template/subject (nonlinear)
    # model to subject (affine)
    antsApplyTransforms -d 3  ${MB_VERBOSE:-} --interpolation GenericLabel -r ${subject} \
    -i $(echo $atlas | sed -E "s/t1\.(nii|nii\.gz|mnc)/${labelname}/g") \
    -o /tmp/${atlasname}-${templatename}-${subjectname}-${labelname} \
    -t [output/transforms/modelspace/${subjectname}0_GenericAffine.xfm,1] \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}0_NL.xfm \
    -t output/transforms/modelspace/${atlasname}0_GenericAffine.xfm
  else
    # Apply transforms to label
    # atlas to model (affine)
    # atlas to template (nonlinear)
    # template to subject (nonlinear)
    # model to subject (affine)
    antsApplyTransforms -d 3  ${MB_VERBOSE:-} --interpolation GenericLabel -r ${subject} \
    -i $(echo $atlas | sed -E "s/t1\.(nii|nii\.gz|mnc)/${labelname}/g") \
    -o /tmp/${atlasname}-${templatename}-${subjectname}-${labelname} \
    -t [output/transforms/modelspace/${subjectname}0_GenericAffine.xfm,1] \
    -t output/transforms/template-subject/${subjectname}/${templatename}-${subjectname}0_NL.xfm \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}0_NL.xfm \
    -t output/transforms/modelspace/${atlasname}0_GenericAffine.xfm
  fi
else
  if [[ ${subjectname} = ${templatename} ]]
  then
    # Apply transforms to label
    # atlas to template/subject (affine)
    # atlas to template/subject (nonlinear)
    antsApplyTransforms -d 3  ${MB_VERBOSE:-} --interpolation GenericLabel -r ${subject} \
    -i $(echo $atlas | sed -E "s/t1\.(nii|nii\.gz|mnc)/${labelname}/g") \
    -o /tmp/${atlasname}-${templatename}-${subjectname}-${labelname} \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}1_NL.xfm \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}0_GenericAffine.xfm
  else
    # Apply transforms to label
    # atlas to template (affine)
    # atlas to template (nonlinear)
    # template to subject (affine)
    # template to subject (nonlinear)
    antsApplyTransforms -d 3  ${MB_VERBOSE:-} --interpolation GenericLabel -r ${subject} \
    -i $(echo $atlas | sed -E "s/t1\.(nii|nii\.gz|mnc)/${labelname}/g") \
    -o /tmp/${atlasname}-${templatename}-${subjectname}-${labelname} \
    -t output/transforms/template-subject/${subjectname}/${templatename}-${subjectname}1_NL.xfm \
    -t output/transforms/template-subject/${subjectname}/${templatename}-${subjectname}0_GenericAffine.xfm \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}1_NL.xfm \
    -t output/transforms/atlas-template/${templatename}/${atlasname}-${templatename}0_GenericAffine.xfm
  fi
fi

ConvertImage 3 /tmp/${atlasname}-${templatename}-${subjectname}-${labelname} output/labels/candidates/${subjectname}/${atlasname}-${templatename}-${subjectname}-${labelname} 1
rm /tmp/${atlasname}-${templatename}-${subjectname}-${labelname}

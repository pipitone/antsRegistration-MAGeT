#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

movingfile=$1
fixedfile=$2
outputdir=$3

#Define location of morpho transforms
initalmovingxfm=$(dirname $(dirname $outputdir))/modelspace/$(basename $movingfile)0_GenericAffine.xfm
initalfixedxfm=$(dirname $(dirname $outputdir))/modelspace/$(basename $fixedfile)0_GenericAffine.xfm

#If morpho transforms exist, use those to bootstrap registration
if [[ -s $initalmovingxfm && -s $initalfixedxfm ]]
then
stages=$(cat << EOF
--initial-moving-transform $initalmovingxfm --initial-fixed-transform $initalfixedxfm
--transform SyN[0.5,3,0] --metric CC[$fixedfile,$movingfile,1,4] --convergence [100x100x100x20,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 4x2x1x0
EOF
)
else
stages=$(cat << EOF
--initial-moving-transform [$fixedfile,$movingfile,1] \
--transform Rigid[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 8x4x2x1 \
--transform Similarity[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 8x4x2x1 \
--transform Affine[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1x1 --smoothing-sigmas 8x4x2x1x0 \
--transform SyN[0.5,3,0] --metric CC[$fixedfile,$movingfile,1,4] --convergence [100x100x100x20,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 4x2x1x0
EOF
)
fi

antsRegistration --dimensionality 3 --float 0 --collapse-output-transforms 1 ${MB_VERBOSE:-} --minc \
  --output [$outputdir/$(basename $movingfile)-$(basename $fixedfile)] \
  --winsorize-image-intensities [0.01,0.99] --use-histogram-matching 1 \
  ${stages} && \
ImageMath 3 $outputdir/$(basename $movingfile)-$(basename $fixedfile)0_GenericAffine.xfm MakeAffineTransform 1 && \
rm $outputdir/$(basename $movingfile)-$(basename $fixedfile)*inverse*
# Inverses are never used, remove them right after creation (if only I could disable creation...)

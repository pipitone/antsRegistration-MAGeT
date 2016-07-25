#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

movingfile=$1
fixedfile=$2
outputdir=$3

antsRegistration --dimensionality 3 --float 0 --collapse-output-transforms 1 ${MB_VERBOSE:-} --minc \
  --output [$outputdir/$(basename $movingfile)-$(basename $fixedfile)] \
  --winsorize-image-intensities [0.01,0.99] --use-histogram-matching 1 \
  --initial-moving-transform [$fixedfile,$movingfile,1] \
  --transform Rigid[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 8x4x2x1 \
  --transform Similarity[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 8x4x2x1 \
  --transform Affine[0.1] --metric Mattes[$fixedfile,$movingfile,1] --convergence [2000x2000x2000x2000x2000,1e-6,10] --shrink-factors 8x4x2x1x1 --smoothing-sigmas 8x4x2x1x0

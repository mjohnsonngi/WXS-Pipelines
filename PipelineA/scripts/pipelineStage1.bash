#!/bin/bash
source /scripts/pipelineCommonFunctions.bash
source /scripts/pipelineStage1HelperFunctions.bash
SAMPLEID=$(echo $FULLSMID | cut -d '^' -f 1)
RGBASE="$(echo ${RGBASES} | cut -d ' ' -f $LSB_JOBINDEX)"
FQ1="$(ls $INDIR/${RGBASE}*1*)"
FQ1EXT="$(echo ${FQ1##*${RGBASE}})"
if [[ -e $FQ1 ]]; then FQ2="$(echo $INDIR/${RGBASE}${FQ1EXT/1/2})"; else unset FQ2; fi
FQI="$(ls $INDIR/${RGBASE}*f*q*)"
MEM_SPLIT=$((${MEM}/${THREADS}))
echo -e "" > ${OUTDIR}/stage1complete.txt
reportToLog "Starting pipeline for $RGBASE. Staging Data to scratch1."
stageDataForRGBASE
reportToLog "Aligning and sorting"
if [[ -e $FQ1 ]] && [[ -e $FQ2 ]]; then
alignSortPairedFQs || alignSortPairedHugeFQs
elif [[ ! -e $FQ1 ]] && [[ ! -e $FQ2 ]] && [[ -e $FQI ]]; then
alignSortInterleavedFQs || alignSortHugeInterleavedFQs
else
reportToLog "Check input files"; exit 3;
fi
reportToLog "Aligned FASTQs into BAM. Validating"
validateCurrentBam
reportToLog "Validating and saving BAM as CRAM"
saveBamAsCram ${CURRENT_BAM}
if [ "${RUN_TYPE}" = "paddedexome" ]
then
  reportToLog "Intersecting BAM with BED"
  intersectBamWithBed ${CURRENT_BAM} ${REF_PADBED}
  reportToLog "Intersected."
fi
saveToOutputDirectory ${CURRENT_BAM}
validateCurrentBam
reportToLog "Validated. Adding to stage1complete list."
#NOTE: This can lead to a race condition on the list. A failed Stage 2 could be caused by the stage1complete.txt file being messed up. Fixing the file manually solves this and Stage 2 can be run normally after.
saveToOutputDirectory ${CURRENT_BAM}
echo -e "${CURRENT_BAM##*/}" >> ${OUTDIR}/stage1complete.txt
reportToLog "Finished for $RGBASE"

#!/bin/bash
source /scripts/pipelineCommonFunctions.bash
source /scripts/pipelineStage2HelperFunctions.bash
#1. set variables, equivalent to setting the environment in the original pipeline
SAMPLEID=$(echo $FULLSMID | cut -d '^' -f 1)
SAMPLEID_VE=$(echo ${SAMPLEID} | tr "^" "-")
MEM_SPLIT=$((${S2MEM}/${S2THREADS}))
validateCurrentBam
CURRENT_BAM="$OUTDIR/${SAMPLEID}_GATKready.bam"
reportToLog "Validated. Analyzing depth of coverage."
analyzeDepthOfCoverage
reportToLog "Analyzed. Recalibrating bases"
recalibrateBases
reportToLog "Recalibrated. Validating"
validateCurrentBam
reportToLog "Validated. Getting FREEMIX."
SAMPLE_FREEMIX=$(getFreeMix)
reportToLog "FREEMIX for ${FULLSMID} is ${SAMPLE_FREEMIX}"
#if [ ${SAMPLE_FREEMIX} -le 0.03 ]
#then reportToLog "${FULLSMID} is likely contaminated"; exit 3; fi
reportToLog "Calling variants on sample"
callSampleVariants
#saveToOutputDirectory ${CURRENT_VCF}
reportToLog "Called. Evaluating variants"
evaluateSampleVariants
reportToLog "Evaluated."
SAMPLE_TITV=$(getTitvRatio)
reportToLog "TITV for ${FULLSMID} is ${SAMPLE_TITV}"
reportToLog "Transferring output files to ${FINAL_OUTDIR}"
transferOutputFilesToStorage
if [[ $(wc -c $CURRENT_VCF) -lt 40000000 ]]; then
mv ${FINAL_OUTDIR} /final_output/CHECK_${FULLSMID}; cleanUp; exit 8; fi
cleanUp
reportToLog "Finished for $FULLSMID."
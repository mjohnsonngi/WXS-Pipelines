#!/bin/bash
STATSFILE="/storage1/fs1/cruchagac/Active/${USER}/stats.csv"
OUTDIR="/storage1/fs1/cruchagac/Active/${USER}/c1out/"
echo "FULLSM,COVERAGE,FREEMIX,TITV" > ${STATSFILE}
for CSV in $(ls ${OUTDIR}/M* | grep "stats.csv"); do
  cat ${OUTDIR}/${CSV%_stats.csv}/${CSV} >> ${STATSFILE}
done
cat $STATSFILE | wc -l

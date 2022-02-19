#!/bin/bash
export LSF_DOCKER_VOLUMES="/storage1/fs1/cruchagac/Active/matthewj/c1in:/staged_input \
/scratch1/fs1/cruchagac/matthewj/c1in:/input \
/scratch1/fs1/cruchagac/matthewj/ref:/ref \
/scratch1/fs1/cruchagac/matthewj/c1out:/output \
/storage1/fs1/cruchagac/Active/matthewj/c1out:/final_output"
export THREADS=32
export MEM=256
JOB_GROUP="/${USER}/compute-cruchagac"
bgadd -L 10 ${JOB_GROUP}
for FULLSMID in $(cat $1); do
bash ./makeSampleEnv.bash $FULLSMID
JOBS_IN_ARRAY=$(ls /storage1/fs1/cruchagac/Active/matthewj/c1in/${FULLSMID}/*.rgfile | wc -w)
LSF_DOCKER_ENV_FILE="/scratch1/fs1/cruchagac/matthewj/c1in/envs/${FULLSMID}.env" \
bsub -g ${JOB_GROUP} \
-J ngi-${USER}-stage1-$FULLSMID[1-$JOBS_IN_ARRAY] \
-n ${THREADS} \
-r \
-o /scratch1/fs1/cruchagac/matthewj/c1out/${FULLSMID}/${FULLSMID}_s1.%J.%I.out \
-R 'select[mem>275000] rusage[mem=270000]' \
-M 275000 \
-G compute-cruchagac \
-q general \
-a 'docker(mjohnsonngi/wxspipeline:dev)' /scripts/pipelineStage1.bash && \
LSF_DOCKER_ENV_FILE="/scratch1/fs1/cruchagac/matthewj/c1in/envs/${FULLSMID}.env" \
bsub -g ${JOB_GROUP} \
-w "done(\"ngi-${USER}-stage1-$FULLSMID\")" \
-J ngi-${USER}-stage2-$FULLSMID \
-n ${THREADS} \
-N \
-o /scratch1/fs1/cruchagac/matthewj/c1out/${FULLSMID}/${FULLSMID}_s2.%J.out \
-R 'select[mem>275000] rusage[mem=270000]' \
-M 275000 \
-G compute-cruchagac \
-q general \
-a 'docker(mjohnsonngi/wxspipeline:dev)' /scripts/pipelineStage2.bash
done

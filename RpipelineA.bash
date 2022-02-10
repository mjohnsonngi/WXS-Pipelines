#!/bin/bash
export LSF_DOCKER_VOLUMES="/storage1/fs1/cruchagac/Active/matthewj/c1in/staged_input \
/scratch1/fs1/cruchagac/matthewj/c1in:/input \
/scratch1/fs1/cruchagac/matthewj/ref:/ref \
/scratch1/fs1/cruchagac/matthewj/c1out:/output \
/storage1/fs1/cruchagac/Active/matthewj/c1out:/final_output"
export THREADS=8
export MEM=48
JOB_GROUP="/${USER}/compute-cruchagac"
bgadd -L 10 ${JOB_GROUP}
bash ./perSampleEnvs.bash $1
for FULLSMID in $(cat $1); do
JOBS_IN_ARRAY=$(ls /scratch1/fs1/cruchagac/matthewj/c1in/${FULLSMID}/*.rgfile | wc -w)
LSF_DOCKER_ENV_FILE="/scratch1/fs1/cruchagac/matthewj/baseEnvs/pipelineBase.env \
/scratch1/fs1/cruchagac/matthewj/baseEnvs/references.env \
/scratch1/fs1/cruchagac/matthewj/c1in/envs/${FULLSMID}.env" \
bsub -g ${JOB_GROUP} \
-J ngi-${USER}-pre-$FULLSMID[1-$JOBS_IN_ARRAY] \
-n ${THREADS} \
-R 'select[mem>48000] rusage[mem=48GB]' \
-M ${MEM}GB \
-G compute-cruchagac \
-q general \
-a 'docker(mjohnsonngi/pipelinea:latest)' /scripts/pipelineAStage1.bash
LSF_DOCKER_ENV_FILE="/scratch1/fs1/cruchagac/matthewj/baseEnvs/pipelineBase.env \
/scratch1/fs1/cruchagac/matthewj/baseEnvs/references.env \
/scratch1/fs1/cruchagac/matthewj/c1in/envs/${FULLSMID}.env" \
bsub -g ${JOB_GROUP} \
-w "done(\"ngi-${USER}-pre-$FULLSMID\")" \
-J ngi-${USER}-post-$FULLSMID \
-n ${THREADS} \
-R 'select[mem>48000] rusage[mem=48GB]' \
-M ${MEM}GB \
-G compute-cruchagac \
-q general \
-a 'docker(mjohnsonngi/pipelinea:R)' /scripts/pipelineABStage2.bash
done

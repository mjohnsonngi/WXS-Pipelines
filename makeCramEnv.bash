#!/bin/bash
ENVS_DIR="/scratch1/fs1/cruchagac/matthewj/c1in/envs"
BASE_ENVS_DIR="./baseEnvs"
LINE="$1"
FULLSMID=$(echo $LINE | cut -d ' ' -f1)
CRAM=$(echo $LINE | cut -d ' ' -f2)
STAGE1_WORKFILE="~/work${CRAM##/*}.txt"
ENV_FILE="$ENVS_DIR/${CRAM}.env"
echo -e "FULLSMID=${FULLSMID}" > $ENV_FILE
echo -e "STAGE_INDIR=/staged_input/${FULLSMID}" >> $ENV_FILE
echo -e "INDIR=/input/${FULLSMID}" >> $ENV_FILE
mkdir /scratch1/fs1/cruchagac/matthewj/c1out/$FULLSMID
echo -e "OUTDIR=/output/${FULLSMID}" >> $ENV_FILE
echo -e "STAGE1_WORKFILE=${STAGE1_WORKFILE}"
cat ${BASE_ENVS_DIR}/pipelinebase.env >> $ENV_FILE
cat ${BASE_ENVS_DIR}/references.env >> $ENV_FILE
cp $ENV_FILE /scratch1/fs1/cruchagac/matthewj/c1out/$FULLSMID/
echo $CRAM

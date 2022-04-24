#! /bin/bash

WORKING_DIR=/home/zhangzheng/DebtCollection_EVA/
export CUDA_VISIBLE_DEVICES="6"

MP_SIZE=1

NUM_GPUS_PER_WORKER=1

CONFIG_PATH="${WORKING_DIR}/src/configs/model/eva2.0_model_config.json"
#CKPT_PATH="${WORKING_DIR}/results_qingdao_full/finetune"
CKPT_PATH="${WORKING_DIR}/results_qingdao_full_0421/finetune"
#CKPT_PATH="${WORKING_DIR}/model/eva2.0"

DS_CONFIG="${WORKING_DIR}/src/configs/deepspeed/eva_ds_config.json"
TOKENIZER_PATH="${WORKING_DIR}/bpe_dialog_new"
RULE_PATH="${WORKING_DIR}/rules"

TEMP=0.9
#If TOPK/TOPP are 0 it defaults to greedy sampling, top-k will also override top-p
TOPK=0
TOPP=0.9
NUM_BEAMS=4


OPTS=""
OPTS+=" --model-config ${CONFIG_PATH}"
OPTS+=" --model-parallel-size ${MP_SIZE}"
OPTS+=" --load ${CKPT_PATH}"
OPTS+=" --no_load_strict"
OPTS+=" --distributed-backend nccl"
OPTS+=" --weight-decay 1e-2"
OPTS+=" --clip-grad 1.0"
OPTS+=" --tokenizer-path ${TOKENIZER_PATH}"
OPTS+=" --temperature ${TEMP}"
OPTS+=" --top_k ${TOPK}"
OPTS+=" --top_p ${TOPP}"
OPTS+=" --num-beams ${NUM_BEAMS}"
OPTS+=" --length-penalty 1.6"
OPTS+=" --repetition-penalty 1.6"
OPTS+=" --rule-path ${RULE_PATH}"
OPTS+=" --fp16"
OPTS+=" --deepspeed"
OPTS+=" --deepspeed_config ${DS_CONFIG}"

CMD="torchrun --master_port 1238 --nproc_per_node ${NUM_GPUS_PER_WORKER} ${WORKING_DIR}/src/flask_api.py ${OPTS}"
#CMD="python ${NUM_GPUS_PER_WORKER} ${WORKING_DIR}/src/flask_api.py ${OPTS}"

echo ${CMD}
${CMD}

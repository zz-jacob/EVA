#! /bin/bash

WORKING_DIR=/root/autodl-tmp/EVA/

MP_SIZE=1 # the model parallel size

NUM_GPUS_PER_WORKER=1 # number of gpus used on one node
GPU_IDS="0"
PORT='1234'


#DATA_PATH="${WORKING_DIR}/data/kdconv"
#CACHE_PATH="./cache_data_kd"
#CKPT_PATH="${WORKING_DIR}/model/eva2.0"
#SAVE_PATH="${WORKING_DIR}/results/finetune/"

#DATA_PATH="/home/zhangzheng/qingdao_data_small" # path of the directory of the dataset
#CACHE_PATH="./cache_data_qingdao_small"
#CKPT_PATH="${WORKING_DIR}/results_qingdao/finetune/7000"
#SAVE_PATH="${WORKING_DIR}/results_qingdao/finetune/"

DATA_PATH="${WORKING_DIR}/data/kdconv" # path of the directory of the dataset
CACHE_PATH="${DATA_PATH}/.cache"

# DATA_PATH="${WORKING_DIR}/data/qingdao_data_full" # path of the directory of the dataset
# CACHE_PATH="./cache_data_qingdao_full"
#CKPT_PATH="${WORKING_DIR}/model/eva2.0"
#CKPT_PATH="${WORKING_DIR}/results_qingdao_full_0421/finetune/"
#SAVE_PATH="${WORKING_DIR}/results_qingdao_full_0421/finetune/"
# CKPT_PATH="${WORKING_DIR}/../eva2.0"
# SAVE_PATH="${WORKING_DIR}/results_qingdao_full_0423/finetune/"

DATA_PATH="${WORKING_DIR}/data/kdconv" # path of the directory of the dataset
CACHE_PATH="${DATA_PATH}/.cache_en256_de64"
ENC_LEN=256 # max input length of encoder
DEC_LEN=64 # max input length of decoder

CKPT_PATH="${WORKING_DIR}/../eva2.0"
SAVE_PATH="${WORKING_DIR}/results/kdconv/finetune/"

CONFIG_PATH="${WORKING_DIR}/src/configs/model/eva2.0_model_config.json"

LR=${2-0.0001} # learning rate
WM=${3-0.01} # ratio of warmup steps
GRAD_ACC=${4-1} # gradient accumulation steps

LOG_FILE="${SAVE_PATH}/log.txt"
DS_CONFIG="${WORKING_DIR}/src/configs/deepspeed/eva_ds_config.json" # config of deepspeed
TOKENIZER_PATH="${WORKING_DIR}/bpe_dialog_new" # vocab path

BATCH_SIZE=128
TRAIN_ITER=-1 # total number of train iterations, if set to -1, the iterations depend on the training epochs (epochs * data_size / (batch_size * grad_acc) )
EPOCHS=3


OPTS=""
#OPTS+=" --build_data_cache"
OPTS+=" --model-config ${CONFIG_PATH}"
OPTS+=" --model-parallel-size ${MP_SIZE}"
OPTS+=" --batch-size ${BATCH_SIZE}"
OPTS+=" --epochs ${EPOCHS}"
OPTS+=" --gradient-accumulation-steps ${GRAD_ACC}"
OPTS+=" --enc-seq-length ${ENC_LEN}"
OPTS+=" --dec-seq-length ${DEC_LEN}"
OPTS+=" --train-iters ${TRAIN_ITER}"
OPTS+=" --save ${SAVE_PATH}"
OPTS+=" --log-file ${LOG_FILE}"
OPTS+=" --load ${CKPT_PATH}"
OPTS+=" --no_load_strict"
OPTS+=" --data-path ${DATA_PATH}"
OPTS+=" --distributed-backend nccl"
OPTS+=" --lr ${LR}"
OPTS+=" --lr-decay-style noam"
OPTS+=" --weight-decay 1e-2"
OPTS+=" --clip-grad 1.0"
OPTS+=" --warmup ${WM}"
OPTS+=" --tokenizer-path ${TOKENIZER_PATH}"
OPTS+=" --eval-interval 500"
OPTS+=" --log-interval 100"
OPTS+=" --save-interval 500"
OPTS+=" --checkpoint-activations"
OPTS+=" --deepspeed-activation-checkpointing"
OPTS+=" --fp16"
OPTS+=" --deepspeed"
OPTS+=" --deepspeed_config ${DS_CONFIG}"
OPTS+=" --do-train"
OPTS+=" --do-valid"
OPTS+=" --do-eval"
# OPTS+=" --eval-generation" # run the evaluation of generation
OPTS+=" --train-ratio 1"
OPTS+=" --cache-path ${CACHE_PATH}"
# OPTS+=" --start_step 12000"


CMD="torchrun --master_port ${PORT} --nproc_per_node ${NUM_GPUS_PER_WORKER} ${WORKING_DIR}/src/eva_finetune.py ${OPTS}"

export CUDA_VISIBLE_DEVICES=${GPU_IDS}
echo ${CMD}
mkdir -p ${SAVE_PATH}
${CMD} 2>&1 | tee ${SAVE_PATH}/train_log

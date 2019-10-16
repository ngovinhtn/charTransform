#!/bin/bash
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


onmt=$NMTGMinor/

SAVEDIR=saves/vitok.jacha #### Change to vitok.jabpe vitok.jabpe viws.jabpe viws.jakytea for each scenario HERE!!!!
LOGDIR=$SAVEDIR/logs/
MODEL=transformer.8layer.shortwarmup
MODELDIR=$SAVEDIR/models/$MODEL
GPU=0
bsz=4096

mkdir -p $MODELDIR
mkdir -p $LOGDIR

OMP_NUM_THREADS=4 python3 -u  $onmt/train.py   -data $SAVEDIR/train \
                                -data_format raw \
                                -save_model $MODELDIR/model \
                                -model transformer \
                                -batch_size_words $bsz \
                                -batch_size_update 24568 \
                                -batch_size_sents 999999 \
                                -layers 4 \
                                -model_size 512 \
                                -inner_size 1024 \
                                -n_heads 8 \
                                -dropout 0.2 \
                                -attn_dropout 0.2 \
                                -word_dropout 0.1 \
                                -emb_dropout 0.2 \
                                -label_smoothing 0.1 \
                                -epochs 100 \
                                -learning_rate 1 \
                                -optim 'adam' \
                                -update_method 'noam' \
                                -warmup_steps 480 \
                                -tie_weights \
                                -seed 8877 \
								-log_interval 100 \
                                -gpus $GPU 2>&1 | tee $LOGDIR/$MODEL.log


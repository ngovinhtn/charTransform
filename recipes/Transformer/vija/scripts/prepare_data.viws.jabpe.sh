#!/bin/bash
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


onmt=$NMTGMinor/

src=ws.vi
tgt=kytea.bpe.ja

DATADIR=data
SAVEDIR=saves/viws.jabpe


mkdir -p $SAVEDIR

python3 -u $onmt/preprocess.py                       -train_src $DATADIR/all.$src \
                                                     -train_tgt $DATADIR/all.$tgt \
                                                     -valid_src $DATADIR/dev2010.$src \
                                                     -valid_tgt $DATADIR/dev2010.$tgt \
                                                     -src_seq_length 2024 \
                                                     -tgt_seq_length 2024 \
                                                     -tgt_vocab_size 200000 \
                                                     -save_data $SAVEDIR/train
                                                     


#!/bin/bash


onmt=$NMTGMinor/
MOSES=$mosesdecoder

src=cha.ja
tgt=singword.vi

SAVEDIR=saves/jacha.vitok
MODEL=transformer.shortwarmup.8layers.8heads
basedir=$SAVEDIR/models/$MODEL
GPU=0

for model in 'model_ppl_17.03_e99.00.pt' 'model_ppl_17.08_e84.00.pt' 'model_ppl_17.05_e96.00.pt'
do
    for beam in 8
    do
        for alpha in 0.2
        do
            OUTDIR=$basedir/translations/$model.beam$beam.alpha$alpha
            mkdir -p $OUTDIR
            root=$PWD

            inputdir=data

            for set in dev2010 tst2010
            do

                python -u $onmt/translate.py -model $basedir/$model -verbose \
                                             -gpu $GPU \
                                             -src $inputdir/$set.$src \
                                             -output $OUTDIR/$set.$tgt.pred \
                                             -beam_size $beam \
                                             -normalize \
                                             -alpha $alpha \
                                             -verbose \
                                             -batch_size 8 | tee $OUTDIR/$set.log

$MOSES/scripts/generic/multi-bleu.perl $inputdir/$set.$tgt < $OUTDIR/$set.$tgt.pred > $OUTDIR/$set.bleu

cat $OUTDIR/$set.bleu
cd $root

done
done
done
done

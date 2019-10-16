#!/bin/bash


onmt=$NMTGMinor/
MOSES=$mosesdecoder

src=kytea.ja
tgt=ws.vi
tgt2=singword.vi

SAVEDIR=saves/jakytea.viws
MODEL=transformer.shortwarmup.8layers.8heads
basedir=$SAVEDIR/models/$MODEL
GPU=0


for model in 'model_ppl_30.79_e16.00.pt' 'model_ppl_30.88_e18.00.pt' 'model_ppl_31.21_e20.00.pt'
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

                    sed 's/_/ /g' $OUTDIR/$set.$tgt.pred > $OUTDIR/$set.$tgt.nows.pred 
                    $MOSES/scripts/generic/multi-bleu.perl $inputdir/$set.$tgt2 < $OUTDIR/$set.$tgt.nows.pred > $OUTDIR/$set.bleu

                    cat $OUTDIR/$set.bleu

                    cd $root

done
done
done
done

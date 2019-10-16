#!/bin/bash


onmt=$NMTGMinor/
MOSES=$mosesdecoder
KYTEA=$kytea/

src=singword.vi
tgt=cha.ja

src1=vi
tgt1=ja


SAVEDIR=saves/vitok.jacha
MODEL=transformer.shortwarmup.8layers.8heads
basedir=$SAVEDIR/models/$MODEL
GPU=0

for model in 'model_ppl_8.42_e80.00.pt' 'model_ppl_8.46_e62.00.pt' 'model_ppl_8.45_e86.00.pt'
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


                $MOSES/scripts/generic/multi-bleu.perl $inputdir/$set.$tgt < $OUTDIR/$set.$tgt.pred > $OUTDIR/$set.cha.bleu

                cat $OUTDIR/$set.cha.bleu

                sed 's/ //g' $OUTDIR/$set.$tgt.pred > $OUTDIR/$set.$tgt1.ns.pred
                $KYTEA/src/bin/kytea -model $KYTEA/data/model.bin -notags < $OUTDIR/$set.$tgt1.ns.pred > $OUTDIR/$set.$tgt1.kytea.pred

                $MOSES/scripts/generic/multi-bleu.perl $inputdir/$set.kytea.$tgt1 < $OUTDIR/$set.$tgt1.kytea.pred > $OUTDIR/$set.kytea.bleu
                cat $OUTDIR/$set.kytea.bleu

                cd $root

done
done
done
done



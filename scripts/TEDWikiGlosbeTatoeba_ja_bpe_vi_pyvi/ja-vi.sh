
#----------------------------training ja->vi--------------------------------------------------


source /home/ntvinh/lib/bin/activate 

tmux 


export CORPUS=/home/ntvinh/data
export SAVEDIR=/home/ntvinh/model 
export MODELDIR=$SAVEDIR/TEDWikiGlosbeTatoeba_ja_bpe_vi_pyvi_javi  

cd /home/ntvinh/OpenNMT 

rm -r $MODELDIR 
mkdir -p $MODELDIR


python preprocess.py -train_src $CORPUS/all.ky.bpe.ja  -train_tgt $CORPUS/all.vipy.vi -valid_src $CORPUS/dev2010.ja-vi.ky.bpe.ja  -valid_tgt $CORPUS/dev2010.ja-vi.vipy.vi -src_seq_length=150 -tgt_seq_length=150 -src_vocab_size=50000  -tgt_vocab_size=50000 -save_data $MODELDIR/data 


python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=adam -dropout=0.5 -epochs=16 -learning_rate=0.001 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_35.65_ppl_35.34_e6.pt

python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -train_from=$MODELDIR/model_acc_35.65_ppl_35.34_e6.pt -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=sgd -dropout=0.5 -epochs=16 -learning_rate=0.0005 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_36.39_ppl_33.22_e9.pt

python translate.py -model $MODELDIR/model_acc_36.39_ppl_33.22_e9.pt -src $CORPUS/tst2010.ja-vi.ky.bpe.ja -output $MODELDIR/trans.vi -replace_unk -verbose 1>$MODELDIR/trans.output 2> $MODELDIR/trans.error

sed 's/_/ /g' $MODELDIR/trans.vi > $MODELDIR/trans_de.vi

sed 's/_/ /g' $CORPUS/tst2010.ja-vi.vipy.vi > $CORPUS/tst2010.ja-vi.vipy.notok.vi

cd /home/ntvinh/eval-BLEU

./eval.sh $MODELDIR/trans_de.vi $CORPUS/tst2010.ja-vi.vipy.notok.vi  $CORPUS/tst2010.ja-vi.vipy.notok.vi

#Official BLEU: 2.20
#BLEU = 11.05, 48.8/21.0/10.0/5.1 (BP=0.731, ratio=0.761, hyp_len=23010, ref_len=30229)

cd /home/ntvinh/RIBES 
python RIBES.py -r $CORPUS/tst2010.ja-vi.vipy.notok.vi  $MODELDIR/trans_de.vi

#0.663610 alpha=0.250000 beta=0.100000


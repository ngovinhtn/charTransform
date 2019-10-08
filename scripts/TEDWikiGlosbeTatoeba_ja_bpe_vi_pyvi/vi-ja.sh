
#------------training vi->ja---------------------------
source /workspace/vinhnt/lib/bin/activate 

tmux 


export CORPUS=/home/ntvinh/data
export SAVEDIR=/home/ntvinh/model 
export MODELDIR=$SAVEDIR/TEDWikiGlosbeTatoeba_ja_bpe_vi_pyvi_vija   

cd /home/ntvinh/OpenNMT 

rm -r $MODELDIR 
mkdir -p $MODELDIR


python preprocess.py -train_src $CORPUS/all.vipy.vi  -train_tgt $CORPUS/all.ky.bpe.ja -valid_src $CORPUS/dev2010.ja-vi.vipy.vi  -valid_tgt $CORPUS/dev2010.ja-vi.ky.bpe.ja -src_seq_length=150 -tgt_seq_length=150 -src_vocab_size=50000  -tgt_vocab_size=50000 -save_data $MODELDIR/data 


python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=adam -dropout=0.5 -epochs=16 -learning_rate=0.001 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_43.94_ppl_22.99_e7.pt

python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -train_from=$MODELDIR/model_acc_43.94_ppl_22.99_e7.pt -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=sgd -dropout=0.5 -epochs=16 -learning_rate=0.0005 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_45.24_ppl_22.01_e11.pt

python translate.py -model $MODELDIR/model_acc_45.24_ppl_22.01_e11.pt -src $CORPUS/tst2010.ja-vi.vipy.vi -output $MODELDIR/trans.ja -replace_unk -verbose 1>$MODELDIR/trans.output 2> $MODELDIR/trans.error

sed 's/@@ //g' $MODELDIR/trans.ja > $MODELDIR/trans_de.ja

sed 's/@@ //g' $CORPUS/tst2010.ja-vi.ky.bpe.ja > $CORPUS/tst2010.ja-vi.ky.nobpe.ja 

cd /home/ntvinh/eval-BLEU

./eval.sh $MODELDIR/trans_de.ja $CORPUS/tst2010.ja-vi.ky.nobpe.ja  $CORPUS/tst2010.ja-vi.ky.nobpe.ja

#Official BLEU: 11.13
#BLEU = 11.13, 45.3/18.9/9.4/5.0 (BP=0.784, ratio=0.804, hyp_len=23658, ref_len=29413)

cd /home/ntvinh/RIBES 
python RIBES.py -r $CORPUS/tst2010.ja-vi.ky.nobpe.ja  $MODELDIR/trans_de.ja

#0.593435 alpha=0.250000 beta=0.100000 /workspace/vinhnt/model/TEDWikiGlosbeTatoeba_ja_bpe_vi_pyvi_vija/trans_de.ja


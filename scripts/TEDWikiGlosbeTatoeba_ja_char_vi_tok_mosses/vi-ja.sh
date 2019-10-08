#---------------vi->ja--------------------------------------


source /home/ntvinh/lib/bin/activate 

tmux 


export CORPUS=/home/ntvinh/data
export SAVEDIR=/home/ntvinh/model 
export MODELDIR=$SAVEDIR/TEDWikiGlosbeTatoeba_ja_char_vi_tok_mosses_vija  

cd /home/ntvinh/OpenNMT 

rm -r $MODELDIR 
mkdir -p $MODELDIR


python preprocess.py -train_src $CORPUS/all.vi  -train_tgt $CORPUS/all.char.ja -valid_src $CORPUS/dev2010.ja-vi.vi  -valid_tgt $CORPUS/dev2010.ja-vi.char.ja -src_seq_length=150 -tgt_seq_length=150 -src_vocab_size=50000  -tgt_vocab_size=50000 -save_data $MODELDIR/data 


python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=adam -dropout=0.5 -epochs=16 -learning_rate=0.001 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_49.42_ppl_11.07_e5.pt


python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -train_from=$MODELDIR/model_acc_49.42_ppl_11.07_e5.pt -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=sgd -dropout=0.5 -epochs=16 -learning_rate=0.0005 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_52.19_ppl_9.58_e13.pt

#---testing----------
python translate.py -model $MODELDIR/model_acc_52.19_ppl_9.58_e13.pt -src $CORPUS/tst2010.ja-vi.vi -output $MODELDIR/trans.ja -replace_unk -verbose 1>$MODELDIR/trans.output 2> $MODELDIR/trans.error

sed 's/ //g' $MODELDIR/trans.ja > $MODELDIR/trans_de.ja

sed 's/ //g' $CORPUS/tst2010.ja-vi.char.ja > $CORPUS/tst2010.ja-vi.ja

KYTEA=/home/ntvinh

cd $KYTEA

kytea/bin/kytea -notags < $MODELDIR/trans_de.ja > $MODELDIR/trans_de_ky.ja

kytea/bin/kytea -notags < $CORPUS/tst2010.ja-vi.ja > $CORPUS/tst2010.ja-vi.ky.ja

cd /home/ntvinh/eval-BLEU

./eval.sh $MODELDIR/trans_de_ky.ja $CORPUS/tst2010.ja-vi.ky.ja  $CORPUS/tst2010.ja-vi.ky.ja 

#Official BLEU: 9.64
#BLEU = 9.61, 45.3/18.4/9.0/4.8 (BP=0.699, ratio=0.737, hyp_len=21665, ref_len=29411)


cd /home/ntvinh/RIBES 
python RIBES.py -r $CORPUS/tst2010.ja-vi.ky.ja  $MODELDIR/trans_de_ky.ja

#0.566101 alpha=0.250000 beta=0.100000


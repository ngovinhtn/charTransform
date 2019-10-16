#----------ja->vi------------------------

source /home/ntvinh/lib/bin/activate 

tmux 


export CORPUS=/home/ntvinh/data
export SAVEDIR=/home/ntvinh/model 
export MODELDIR=$SAVEDIR/TEDWikiGlosbeTatoeba_ja_char_vi_tok_mosses_javi  

cd /home/ntvinh/OpenNMT 

rm -r $MODELDIR 
mkdir -p $MODELDIR


python preprocess.py -train_src $CORPUS/all.char.ja  -train_tgt $CORPUS/all.vi -valid_src $CORPUS/dev2010.ja-vi.char.ja  -valid_tgt $CORPUS/dev2010.ja-vi.vi -src_seq_length=150 -tgt_seq_length=150 -src_vocab_size=50000  -tgt_vocab_size=50000 -save_data $MODELDIR/data 


python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=adam -dropout=0.5 -epochs=16 -learning_rate=0.001 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_40.42_ppl_25.61_e5.pt

python train.py -data $MODELDIR/data  -save_model $MODELDIR/model -train_from=$MODELDIR/model_acc_40.42_ppl_25.61_e5.pt -encoder_type=brnn -rnn_size=512 -word_vec_size=512 -batch_size=32 -max_generator_batches=32 -optim=sgd -dropout=0.5 -epochs=16 -learning_rate=0.0005 -global_attention=mlp -coverage_attn -layers=2 -gpuid 0 1>$MODELDIR/std0.output 2> $MODELDIR/std0.error

#model_acc_42.09_ppl_22.51_e9.pt

#---test------------
python translate.py -model $MODELDIR/model_acc_42.09_ppl_22.51_e9.pt -src $CORPUS/tst2010.ja-vi.char.ja -output $MODELDIR/trans.vi -replace_unk -verbose 1>$MODELDIR/trans.output 2> $MODELDIR/trans.error


cd /home/ntvinh/eval-BLEU

./eval.sh $MODELDIR/trans.vi $CORPUS/tst2010.ja-vi.vi  $CORPUS/tst2010.ja-vi.vi

#Official BLEU: 1.25
#BLEU = 10.06, 46.2/19.1/8.8/4.1 (BP=0.755, ratio=0.781, hyp_len=23594, ref_len=30229)

cd /home/ntvinh/RIBES 
python RIBES.py -r $CORPUS/tst2010.ja-vi.vi  $MODELDIR/trans.vi

#0.657731 alpha=0.250000 beta=0.100000


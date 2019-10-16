cd#!/bin/bash

TOOLDIR=../../../../tools/
BPE=$TOOLDIR/subwords/

# Characted-based Japanese texts
sed 's/./& /g' all.ja | tr -s " " > all.cha.ja

sed 's/./& /g' glosbe.ja | tr -s " " > glosbe.cha.ja
sed 's/./& /g' TED.ja-vi.ja | tr -s " " > TED.cha.ja
sed 's/./& /g' wikinews.ja | tr -s " " > wikinews.cha.ja
sed 's/./& /g' tatoeba.ja | tr -s " " > tatoeba.cha.ja

sed 's/./& /g' dev2010.ja-vi.ja | tr -s " " > dev2010.cha.ja
sed 's/./& /g' tst2010.ja-vi.ja | tr -s " " > tst2010.cha.ja


# Tokenized Japanese texts using Kytea	
kytea -notags < all.ja > all.kytea.ja

kytea -notags < glosbe.ja > glosbe.kytea.ja
kytea -notags < TED.ja-vi.ja > TED.kytea.ja
kytea -notags < wikinews.ja > wikinews.kytea.ja
kytea -notags < tatoeba.ja > tatoeba.kytea.ja

kytea -notags < dev2010.ja-vi.ja > dev2010.kytea.ja
kytea -notags < tst2010.ja-vi.ja > tst2010.kytea.ja


# BPEd Japanese texts from  tokenized texts using Kytea
# Learn BPE
cat all.kytea.ja | python $BPE/BPE-JA/learn_bpe.py -s 40000 > codes.kytea
                    
# Apply
cat all.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > all.kytea.bpe.ja

cat glosbe.kytea.ja | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > glosbe.kytea.bpe.ja
cat TED.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > TED.kytea.bpe.ja
cat wikinews.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > wikinews.kytea.bpe.ja
cat tatoeba.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > tatoeba.kytea.bpe.ja

cat dev2010.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > dev2010.kytea.bpe.ja
cat tst2010.kytea.ja  | $BPE/BPE-JA/apply_bpe.py -c codes.kytea > tst2010.kytea.bpe.ja

# single-word-based Vietnamese texts 
ln -s all.vi all.singword.vi

ln -s glosbe.vi glosbe.singword.vi
ln -s TED.ja-vi.vi TED.singword.vi
ln -s wikinews.vi wikinews.singword.vi
ln -s tatoeba.vi tatoeba.singword.vi

ln -s dev2010.ja-vi.vi dev2010.singword.vi
ln -s tst2010.ja-vi.vi tst2010.singword.vi

# word-segmented Vietnamese texts using pyvi
# Need python3 and pyvi.
# You can install pyvi by running pip3 install pyvi
# And then you can use the script vietws.py 
python3 $TOOLDIR/vietws.py all.vi all.ws.vi

python3 $TOOLDIR/vietws.py glosbe.vi glosbe.ws.vi
python3 $TOOLDIR/vietws.py TED.ja-vi.vi TED.ws.vi
python3 $TOOLDIR/vietws.py wikinews.vi wikinews.ws.vi
python3 $TOOLDIR/vietws.py tatoeba.vi tatoeba.ws.vi

python3 $TOOLDIR/vietws.py dev2010.ja-vi.vi dev2010.ws.vi
python3 $TOOLDIR/vietws.py tst2010.ja-vi.vi tst2010.ws.vi


# modified-BPEd Vietnamese texts from  tokenized texts

echo "Done!"

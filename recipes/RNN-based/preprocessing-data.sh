cd data 

#--------------ja------------------------
#tokenizing using kytea 
kytea -notags < all.ja > all.ky.ja 
kytea -notags < dev2010.ja-vi.ja > dev2010.ja-vi.ky.ja 
kytea -notags < tst2010.ja-vi.ja > tst2010.ja-vi.ky.ja 

#learning -bpe 

python learn_bpe.py -i all.ky.ja -o codes.ja -s 50000
python apply_bpe.py -i  all.ky.ja -c codes.ja -o all.ky.bpe.ja

python apply_bpe.py -i  dev2010.ja-vi.ky.ja -c codes.ja -o dev2010.ja-vi.ky.bpe.ja
python apply_bpe.py -i  tst2010.ja-vi.ky.ja -c codes.ja -o tst2010.ja-vi.ky.bpe.ja

#character 

sed 's/./& /g' all.ja | tr -s " " > all.char.ja
sed 's/./& /g' dev2010.ja-vi.ja | tr -s " " > dev2010.ja-vi.char.ja
sed 's/./& /g' tst2010.ja-vi.ja | tr -s " " > tst2010.ja-vi.char.ja

#-----------vi---------------------------
python vietws.py all.vi all.vipy.vi
python vietws.py dev2010.ja-vi.vi dev2010.ja-vi.vipy.vi 
python vietws.py tst2010.ja-vi.vi tst2010.ja-vi.vipy.vi



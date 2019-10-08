# Transformer and Recurrent Machine Translation systems for Japanese - Vietnamese 
This repository contains all data and scripts for building a neural
machine translation systems for Japanese - Vietnamese.

# Dataset

The data is used and collected from [Glosbe (https://glosbe.com/), TED talks, Asian Language Treebank (http://www2.nict.go.jp/astrec-att/member/mutiyama/ALT/) and Tatoeba corpus].

For all experiments, the corpus was split into training, development (dev) and test (tst) set:

| Data set    | Sentences 
| ----------- | --------- 
| Training    | 339523
| Dev2010     | 558
| Tst2010     | 1,215

# BLEU 
##Japnese -> Vietnamese 

| Models     | BLEU | RIRES 
| -----------| -----| -----------------
| Word2WordRecurrent |  11.05 | 0.663
| Word2WordTransformer |  11.72  | 0.681
| Char2CharRecurrent   |  10.06  | 0.657
| Char2CharTransformer |  13.34  | 0.688 

# Citation

If you use this data set please  citing the paper
[How Transformer Revitalizes Character-based Neural Machine Translation: An Investigation on Japanese-Vietnamese Translation Systems](https://arxiv.org/abs/1910.02238)
by Ngo et al. (2019).



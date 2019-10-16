# Japanese - Vietnamese Character-based NMT systems
This repository contains all data and recipes for building the systems and replicating the results of our paper **How Transformer Revitalizes Character-based Neural Machine Translation: An Investigation on Japanese-Vietnamese Translation Systems**, which achieved SOTA results in term of BLEU/RIBES for the Japanese$\leftrightarrow$Vietnamese translation directions.

### Dataset
The data is collected from Globse, TED talks, Asian Language Treebank and Tatoeba corpus. More detailed information about the data, please go to https://github.com/ngovinhtn/JaViCorpus

For all experiments, the corpus was split into training, development (dev2010) and test (tst2010) sets:

| Dataset       | Sentences | 
| ------------- | --------- | 
| Training Data | 339523 |
| Development   | 558 |
| Test          | 1,215 |

### Recipes

We compared word-based (sub-word-based) and character-based NMT systems using two architectures: Recurrent-based and Transformer. In order to run our experiments with the NMT frameworks you need to install the libraries that each of the framework requires:
1. Recurrent: OpenNMT-py(https://github.com/OpenNMT/OpenNMT-py)
2. Transformer: NMTGMinor (https://github.com/quanpn90/NMTGMinor)

We provide the ready-to-train data, but in case if you want to run the preprocessing steps for Japanese and Vietnamese texts, you need the following tools:
1. [KyTea](http://www.phontron.com/kytea/) - for Japanese tokenization and word segmentation
2. [Pyvi](https://pypi.org/project/pyvi/) - for Vietnamese word segmentation
3. [Moses scripts](https://github.com/moses-smt/mosesdecoder/tree/master/scripts/tokenizer) - for Vietnamese tokenization

The steps:
1. prepare_data_***.sh - to extract vocabularies and convert the preprocessed texts into pytorch tensors prior to the training process
2. train***.sh - train the model
3. translate_***.sh - use the trained model to translate new texts.

You need to modify those scripts a little bit to point to the paths of those toolkits installed/downloaded in your computers/GPU clusters.

### Performance 
#### 1. Japanese to Vietnamese 
| Models     | BLEU | RIRES |
| -----------| -----| ----------------- |
| Word2WordRecurrent |  11.05 | 0.663 |
| Word2WordTransformer |  11.72  | 0.681 |
| Char2CharRecurrent   |  10.06  | 0.657 |
| **Char2CharTransformer** | **13.34**  | **0.688** |

#### 2. Vietnamese to Japanese
| Models     | BLEU | RIRES | 
| -----------| -----| ----------------- |
| Word2WordRecurrent |  11.13 | 0.593 |
| Word2WordTransformer |  13.07  | 0.679 |
| Char2CharRecurrent   |  9.61  | 0.566  |
| **Char2CharTransformer** |  **15.05**  | **0.691** |

### Citation
If you use the recipes, please cite our paper:
Thi-Vinh Ngo, Thanh-Le Ha, Phuong-Thai Nguyen, Le-Minh Nguyen: [How Transformer Revitalizes Character-based Neural Machine Translation: An Investigation on Japanese-Vietnamese Translation Systems](https://arxiv.org/pdf/1910.02238.pdf). Proceedings of the 16th International Workshop on Spoken Language Translation 2019 (IWSLT 2019), Hongkong.

Bibtex:
```
@inproceedings{Ngo2019How,
  author    = {Thi{-}Vinh Ngo and
               Thanh{-}Le Ha and
               Phuong{-}Thai Nguyen and
               Le{-}Minh Nguyen},
  title     = {{How Transformer Revitalizes Character-based Neural Machine Translation: An Investigation on Japanese-Vietnamese Translation Systems}},
  booktitle = {{Proceedings of the 16th International Workshop on Spoken Language Translation 2019 (IWSLT 2019))}},
  year      = {2019},
  address   = {{Hongkong}},
  url       = {https://arxiv.org/pdf/1910.02238.pdf}
}
```


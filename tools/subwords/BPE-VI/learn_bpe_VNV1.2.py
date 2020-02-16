#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: Ngo Vinh

"""
Learn BPE with 2-gram from data training

Run: python learn_bpe_VNV1.1.py -i train.ja-vi.vi -o train.ja-vi.bpe.vi -c codes.vi -s 1 -l log.txt
"""

from __future__ import unicode_literals

import sys
import codecs
import re
import copy
import argparse
from collections import defaultdict, Counter
import collections

# hack for python2/3 compatibility
from io import open
import threading
import time
import operator
argparse.open = open

import numpy

def create_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="learn BPE-based word segmentation")

    parser.add_argument(
        '--input', '-i', type=argparse.FileType('r'), default=sys.stdin,
        metavar='PATH',
        help="Input text (default: standard input).")
    parser.add_argument(
        '--output', '-o', type=argparse.FileType('w'), default=sys.stdout,
        metavar='PATH',
        help="Output file for BPE codes (default: standard output)")
    parser.add_argument(
        '--codefile', '-c', type=argparse.FileType('w'), default=sys.stdout,
        metavar='PATH',
        help="Code file for BPE codes (default: standard output)")
    parser.add_argument(
        '--logfile', '-l', type=argparse.FileType('w'), default=sys.stdout,
        metavar='PATH',
        help="log file ")
    parser.add_argument(
        '--num_get_pairs', '-s', type=int, default=2,
        help="Create this many new symbols (each representing a character n-gram) (default: %(default)s))")
    parser.add_argument(
        '--min-frequency', '-m', type=int, default=100, metavar='FREQ',
        help='Stop if no symbol pair has frequency >= FREQ (default: %(default)s))')
    parser.add_argument('--dict-input', action="store_true",
                        help="If set, input file is interpreted as a dictionary where each line contains a word-count pair")
    parser.add_argument(
        '--verbose', '-v', action="store_true",
        help="verbose mode.")

    return parser


def get_vocabulary(fobj, is_dict=False):
    """Read text and return dictionary that encodes vocabulary
    """
    vocab = Counter()
    for line in fobj:
        if is_dict:
            word, count = line.strip().split()
            vocab[word] = int(count)
        else:
            for word in line.split():
                vocab[word] += 1
    return vocab

# **********************************************************************************
#thread print state of processing to log file
class Thread_Print (threading.Thread):
    def __init__(self, num_opera=0,state=1,pair=('',''),freq=0,logfile="log.txt"):
        threading.Thread.__init__(self)
        self.num_opera = num_opera
        self.state = state
        self.pair=pair
        self.freq=freq
        self.logfile=logfile
    def run(self):
        f = open(self.logfile.name, 'a')
        if self.state == 0:
            f.write("Start BPE ...\n")
        if self.state == 1:
            f.write("operation ="+str(self.num_opera)+" Time:"+time.ctime(time.time())+"\n")
        if self.state == 2:
            f.write("Best pair "+str(self.pair)+" with freq: "+str(self.freq)+"\n")
        if self.state == 3:
            f.write("Finish BPE.")
        f.close()
#thread print vocab to log file
class Thread_Write_Vocab_Code (threading.Thread):
    def __init__(self, file,vocab):
        threading.Thread.__init__(self)
        self.file = file
        self.vocab = vocab
    def run(self):
        fvocab = open(self.file.name, 'a')
        fvocab.write(self.vocab+'\n')
        fvocab.close()

def get_pairs_most_freq(content,min_frequency):
    pairs = collections.defaultdict(int)
    for line in content.splitlines():
        prevWord = None
        for word in line.split():   #'và','nhưng','/','tôi','bạn'
            if prevWord not in [None,'♫','“','”','&amp;',',','.','-','?',')','(','quot',';','--',':','&quot;','quot','và','nhưng','/','tôi','bạn','Tôi','Bạn'] and prevWord.isdigit()== False:
                if word not in [None,'♫','“','”','&amp;',',','.','-','?',')','(','quot',';','--',':','&quot;','quot','và','nhưng','/','tôi','bạn','Tôi','Bạn'] and word.isdigit()== False:
                    pairs[prevWord, word] += 1
            # if prevWord=="Tây" and word =="Ban":
            #     print(prevWord,word)

            prevWord = word
    # f.close()
    # print(pairs["Tây", "Ban"]) #80
    pairs=dict((k,v) for k,v in pairs.items() if v >= min_frequency)
    # for k,v in pairs.items():
    #     print(k," ",v)
    # print('_____________________________________________________')
    # get most freq
    # best_pair_freq = max(pairs,key=pairs.get)


    # print (pairs1)
    return pairs


def update_pairs(best,content,fvocab):
    # ket hop vao pair roi cuoi cung in phan ket hop cua pair
    wordcat = " "+best[0] + "_" + best[1]+" "
    wordsub = " "+best[0] + " " + best[1]+" "
    # if best[0]=="Tây" and best[1]=="Ban":
    #     print(wordsub)
    replaced=content
    replaced = content.replace(wordsub, wordcat)
    thread1 = Thread_Write_Vocab_Code(fvocab,wordsub.strip())
    thread1.start()
    # print(replaced)

    return replaced


def main(infile, outfile, codefile, logfile, num_get_pairs,  min_frequency, verbose=False, is_dict=False):
    """Learn num_symbols BPE operations from vocabulary, and write to outfile.
    """
    f1 = open(infile.name, 'r')
    content = f1.read()
    f1.close()

    #add space to the beginning and the end of lines
    f_tmp = open("tmp.vi", 'w')
    for line in content.splitlines():
        f_tmp.write(" "+line+" \n")
    f_tmp.close()

    f_tmp = open("tmp.vi", 'r')
    content = f_tmp.read()
    f_tmp.close()
    #count the operation
    opera=0
    thread1 = Thread_Print(0,0,('',''),0,logfile)
    thread1.start()
    # num_get_pairs is the number get pairs


    # for i in range(num_get_pairs):

    while opera < num_get_pairs:
        # if i==0:
        pairs = get_pairs_most_freq(content,min_frequency)
        # else:
        #     min_frequency=min_frequency*2
        #     pairs = get_pairs_most_freq(content,min_frequency)
        # print("pairs: ", pairs)
        # for v,k in pairs.items():
        #     print(k," ",v)

        words = list(pairs.keys())
        freqs = list(pairs.values())
        sorted_idx = numpy.argsort(freqs)
        # print(sorted_idx)
        # pairs1=dict((v,k) for k,v in pairs.items())
        # print(pairs1)
        for ii in sorted_idx[::-1]:
                                    # for v,k in sorted(pairs1.items(),reverse=True):
            # print(k,v)
            # if k[0]=='Tây' and k[1]=='Ban':
            #     print(k)
            if opera < num_get_pairs:
                content1=""

                content1=update_pairs(words[ii],content,codefile)
                content=content1
                opera = opera +1
                thread = Thread_Print(0,2,words[ii],freqs[ii],logfile)
                thread.start()
                if opera % 2000 == 0:
                    thread2 = Thread_Print(opera,1,('',''),0,logfile)
                    thread2.start()
            else:
                break


    # remove space at the beginning and the end of file, and write to file
    f2 = open(outfile.name, 'w')
    for line in content.splitlines():
        f2.write(line.strip()+" \n")
    # content = f2.write(content)
    f2.close()
    # print (pair)
    thread1 = Thread_Print(0,3,('',''),0,logfile)
    thread1.start()

if __name__ == '__main__':

    # python 2/3 compatibility
    if sys.version_info < (3, 0):
        sys.stderr = codecs.getwriter('UTF-8')(sys.stderr)
        sys.stdout = codecs.getwriter('UTF-8')(sys.stdout)
        sys.stdin = codecs.getreader('UTF-8')(sys.stdin)
    else:
        sys.stderr = codecs.getwriter('UTF-8')(sys.stderr.buffer)
        sys.stdout = codecs.getwriter('UTF-8')(sys.stdout.buffer)
        sys.stdin = codecs.getreader('UTF-8')(sys.stdin.buffer)

    parser = create_parser()
    args = parser.parse_args()

    # read/write files as UTF-8
    if args.input.name != '<stdin>':
        args.input = codecs.open(args.input.name, encoding='utf-8')
    if args.output.name != '<stdout>':
        args.output = codecs.open(args.output.name, 'w', encoding='utf-8')

    main(args.input, args.output, args.codefile,args.logfile, args.num_get_pairs, args.min_frequency, args.verbose, is_dict=args.dict_input)

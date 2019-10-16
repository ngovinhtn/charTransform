from __future__ import unicode_literals
"""
Apply BPE to dev and test or train set 
Run: python apply_bpe_VNV1.1.py -i dev2010.ja-vi.vi -c codes.vi -o dev2010.ja-vi.bpe.vi 
"""
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
argparse.open = open

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
        '--codefile', '-c', type=argparse.FileType('r'), default=sys.stdin,
        metavar='PATH',
        help="Code file for BPE codes (default: standard output)")
    return parser
def update_codes(code,content):
    # ket hop vao pair roi cuoi cung in phan ket hop cua pair
    code1=" "+code.strip().replace('_',' ')+" "
    # print(code1)
    replaced=content

    replaced = content.replace(code1, " "+code.strip()+" ")
    # print(replaced)
    return replaced



def main(infile, codefile,outfile):
    print("Start Apply BPE")
    # Read file
    f1 = open(infile.name, 'r')
    content = f1.read()
    f1.close()
    #add space to the beginning and the end of line
    f_tmp = open("tmp.vi", 'w')
    for line in content.splitlines():
        f_tmp.write(" "+line+" \n")
    f_tmp.close()

    f_tmp = open("tmp.vi", 'r')
    content = f_tmp.read()
    f_tmp.close()

    # read codefile to codes
    f1 = open(codefile.name, 'r')
    codes = f1.readlines()
    f1.close()
    # codes.reverse()
    # replace a pair of word in file with code
    for code in codes:
        # print(code)
        content1=update_codes(code,content)
        content=content1

    # remove space at the beginning and at the end of line and write to file
    f1 = open(outfile.name, 'w')
    for line in content.splitlines():
        f1.write(line.strip()+" \n")
    # f1.write(content)
    f1.close()
    print("Done")
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
    # if args.input.name != '<stdin>':
    #     args.input = codecs.open(args.input.name, encoding='utf-8')
    # if args.codefile.name != '<stdin>':
    #     args.input = codecs.open(args.codefile.name, encoding='utf-8')
    # if args.output.name != '<stdout>':
    #     args.output = codecs.open(args.output.name, 'w', encoding='utf-8')

    main(args.input, args.codefile,args.output)

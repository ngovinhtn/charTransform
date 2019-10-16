"""
edited by
Thanh-Le Ha, MSc.
Karlsruhe Institute of Technology (KIT)

https://pypi.org/project/pyvi/
"""



import codecs
import sys
import os
from pyvi import ViTokenizer

def word_seg(sentence):
    return ViTokenizer.tokenize(sentence)
    
if __name__ == "__main__":
    filein = sys.argv[1]
    fileout = sys.argv[2]
    with codecs.open(filein,'r','utf8') as fi:
        with codecs.open(fileout,'w','utf8') as fo:
            for line in fi.readlines():
                fo.write(word_seg(line) + os.linesep)
                
    print("Done")
        


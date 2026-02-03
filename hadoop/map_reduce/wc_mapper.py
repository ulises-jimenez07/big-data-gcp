#! /opt/conda/default/bin/python
import sys

def main():
    for line in sys.stdin:
        line=line.strip()
        words=line.split()
        for word in words:
            print ('%s\t%s' % (word,1))

if __name__ == "__main__":
    main()
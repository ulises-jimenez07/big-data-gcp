#! /opt/conda/default/bin/python
import sys

# Using a dictionary for In-Mapper Combining (Optimization)
# This reduces the number of key-value pairs sent to the shuffle/sort phase,
# improving network and disk I/O performance.
def main():
    word_counts = {}
    for line in sys.stdin:
        # Remove leading/trailing whitespace
        line = line.strip()
        # Split line into words
        words = line.split()
        for word in words:
            # Aggregate counts in the local dictionary
            word_counts[word] = word_counts.get(word, 0) + 1
    
    # Emit aggregated results: word <tab> count
    for word, count in word_counts.items():
        print('%s\t%s' % (word, count))

if __name__ == "__main__":
    main()
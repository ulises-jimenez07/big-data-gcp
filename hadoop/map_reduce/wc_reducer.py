#! /opt/conda/default/bin/python
import sys

# Optimized Reducer using a dictionary
# Time Complexity: O(n) where n is the number of lines received
# Space Complexity: O(u) where u is the number of unique words assigned to this reducer
def main():
    word_counts = {}
    for line in sys.stdin:
        # Remove whitespace and split into word/count
        line = line.strip()
        try:
            word, count = line.split('\t', 1)
            count = int(count)
        except ValueError:
            # Skip invalid lines
            continue
        
        # Aggregate counts by word
        word_counts[word] = word_counts.get(word, 0) + count

    # Print final word counts
    for word, count in word_counts.items():
        print('%s\t%s' % (word, count))

if __name__ == "__main__":
    main()
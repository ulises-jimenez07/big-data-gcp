#! /opt/conda/default/bin/python
import sys

def main():
    current_word = None
    current_count = 0

    for line in sys.stdin:
        try:
            word, count = line.strip().split('\t', 1)
            count = int(count)
        except ValueError:
            continue

        # If the word is the same as the last, just add the count
        # This exploits the 'Sorted' nature of MapReduce
        if current_word == word:
            current_count += count
        else:
            if current_word:
                print(f"{current_word}\t{current_count}")
            current_word = word
            current_count = count

    # Don't forget the last word!
    if current_word:
        print(f"{current_word}\t{current_count}")

if __name__ == "__main__":
    main()
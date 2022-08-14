#!/usr/bin/env bash
# Script to generate passwords for new users

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")

numWords=5
numLines=10
minLength=1
wordlist=/usr/share/dict/words
joinChar=' '
verbose='false'
camelCase='false'

print_usage() {
echo "
Usage:
$0 [ -w numWords ] [ -m minLength ] [ -l numLines ] [ -f wordlist-file ] [ -j joinChars ] [ -v ] [ -c ]

Options:
 -w <integer>     number of words in each line. Default 5
 -l <integer>     number of lines. Default 10
 -f <path>        the wordlist file path. Default /usr/share/dict/words
 -j <chars>       the chars to use to join each word in a line. Default ' '
 -m <integer>     min length of password. No default
 -v               be more verbose
 -c               Uppercase first letter of each word
 -h               display this help
" 1>&2
}

while getopts 'w:l:f:j:m:cvh' flag; do
  case "${flag}" in
    w) numWords="${OPTARG}" ;;
    m) minLength="${OPTARG}" ;;
    l) numLines="${OPTARG}" ;;
    f) wordlist="${OPTARG}" ;;
    j) joinChar="${OPTARG}" ;;
    v) verbose='true' ;;
    c) camelCase='true' ;;
    h) print_usage
       exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done

[[ "$verbose" = true ]] && echo #newline
[[ "$verbose" = true ]] && echo "$numLines random lines:"
[[ "$verbose" = true ]] && echo "-----------------"

RANGE=$(cat "$wordlist" | wc -l)
FLOOR=0
phrases=1
until [[ "$phrases" -gt ${numLines} ]]
do
    words=1
    length=0
    while [[ "$length" -le ${minLength} || "$words" -le ${numWords}  ]]      # Generate 10 ($numWords) random integers.
    do
        number=0   #initialize
        while [[ "$number" -le $FLOOR ]] # ?
        do
          number=$(openssl rand 4 | od -DAn)
          let "number %= $RANGE"  # Scales $number down within $RANGE.
        done
        word=$(tail -n+$number "$wordlist" | head -1)
        if [[ "$word" == *"-"* ]]; then
          continue
        fi
        if [[ "$camelCase" = true ]]; then
            echo -n "${word^}${joinChar}"
        else
            echo -n "${word}${joinChar}"
        fi
        let "words += 1"  # Increment count.
        let "length += "$(expr length "${word}${joinChar}")
    done
	  [[ "$verbose" = true ]] && echo #newline
    let "phrases += 1"  # Increment count.
    echo #newline
done
[[ "$verbose" = true ]] && echo "-----------------";
exit 0

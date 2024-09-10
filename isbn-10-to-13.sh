#!/bin/zsh-5.9
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <isbn-10-without-dashes>"
	exit 1
fi
isbn10=$1
isbn13="978${isbn10:0:9}"
sum=0
for (( i=0; i<${#isbn13}; i++ )); do
	digit="${isbn13:$i:1}"
	if (( i % 2 == 0 )); then
		sum=$((sum + digit))
	else
		sum=$((sum + 3 * digit))
	fi
done
check_digit=$((10 - sum % 10))
if [[ $check_digit -eq 10 ]]; then
	check_digit=0
fi
isbn13="${isbn13}${check_digit}"
echo "Converted ISBN-13: ${isbn13}"

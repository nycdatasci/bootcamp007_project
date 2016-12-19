#!/bin/sh

trap `rm -f tmp.$$; exit 1` 1 2 15

for i in 1 2 3 4 5
do
	head -`expr $i \* 55339` rb.data | tail -55339 > tmp.$$
	sort -t"	" -k 1,1n -k 2,2n tmp.$$ > rb$i.test
	head -`expr \( $i - 1 \) \* 55339` rb.data > tmp.$$
	tail -`expr \( 5 - $i \) \* 55339` rb.data >> tmp.$$
	sort -t"	" -k 1,1n -k 2,2n tmp.$$ > rb$i.base
done

# perl allbut.pl rb_20_n1a 1 10 276693 rb.data
# sort -t"	" -k 1,1n -k 2,2n rb_20_n1a.base > tmp.$$
# mv tmp.$$ rb_20_n1a.base
# sort -t"	" -k 1,1n -k 2,2n rb_20_n1a.test > tmp.$$
# mv tmp.$$ rb_20_n1a.test

# perl allbut.pl rb_20_n1b 11 20 276693 rb.data
# sort -t"	" -k 1,1n -k 2,2n rb_20_n1b.base > tmp.$$
# mv tmp.$$ rb_20_n1b.base
# sort -t"	" -k 1,1n -k 2,2n rb_20_n1b.test > tmp.$$
# mv tmp.$$ rb_20_n1b.test


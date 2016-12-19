#!/bin/bash

filename=./data/fc1.txt

while read line || [[ -n "$line" ]]; do
    echo downloading $line
done < "$filename"
#!/bin/bash -e
for t in $(grep test_ runner.sh | grep $1 auth | cut -d '(' -f1); do
    ./runner.sh $t | tee $t.log
done

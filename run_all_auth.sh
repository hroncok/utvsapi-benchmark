#!/bin/bash -e
mkdir logs 2>/dev/null || true

for t in $(grep test_ runner.sh | grep $1 auth | cut -d '(' -f1); do
    ./runner.sh $t | tee logs/$t.log
done

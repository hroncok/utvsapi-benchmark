#!/bin/bash -e
sed -Ei \
    -e 's/"personal_number": .*(,|$)/"personal_number": XXXXXX\1/g' \
    -e 's/personal_number=.*"/personal_number=XXXXXX"/g' \
    *.log

! grep personal_number *.log | grep -v XXXXXX

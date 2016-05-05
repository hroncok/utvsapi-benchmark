#!/bin/bash -eu
sed -Ei \
    -e 's/"personal_number": .*(,|$)/"personal_number": XXXXXX\1/g' \
    -e 's/personal_number=.*"/personal_number=XXXXXX"/g' \
    -e "s/$STUDENT/XXXXXX/g" \
    logs/*.log

! grep personal_number logs/*.log | grep -v XXXXXX
! grep "$STUDENT" logs/*.log | grep -v XXXXXX

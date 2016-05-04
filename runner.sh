#!/bin/bash -e
NUM=5000
CON=100

output="Test results:\n"


b() {
    echo "IN: $1"
    pushd "$1" > /dev/null
    . venv/bin/activate
    gunicorn -w 2 "$2" &
    sleep 2
    echo GET "$3"
    H="-H "
    if [ -z "$4" ]; then
        H=""
    else
        echo "$4"
    fi
    echo
    curl $H "$4" "http://localhost:8000$3" | python3 -m json.tool
    ab_out=`ab -n "$NUM" -c "$CON" $H "$4" "http://localhost:8000$3"`
    killall gunicorn
    rps=`echo "$ab_out" | grep "Requests per second"`
    crs=`echo "$ab_out" | grep "Complete requests"`
    ccrs=`echo "$ab_out" | grep "Concurrency Level"`
    output="$output\n$1:\n\t$rps\n\t$crs\n\t$ccrs"
    deactivate
    popd > /dev/null
    echo -e "\n"
}

f() {
    # change this for your directories
    case "$1" in
    "d")
        echo ../utvsapi-django utvsapi.wsgi
        ;;
    "e")
        echo ../utvsapi-eve utvsapi.main:app
        ;;
    "r")
        echo ../utvsapi-ripozo utvsapi.main:app
        ;;
    "s")
        echo ../utvsapi-sandman utvsapi.main:app
        ;;
    esac
}

test_simpleauth() {
    b `f d` /courses/1/ "Authorization: Token 12345"
    b `f e` /courses/1/ "Authorization: Bearer 12345"
    b `f r` /courses/1/ "Authorization: Bearer 12345"
}

test_teacherauth() {
    b `f d` /enrollments/?page_size=20 "Authorization: Token 666"
    b `f e` /enrollments/?max_results=20 "Authorization: Bearer 666"
    b `f r` /enrollments/?count=20 "Authorization: Bearer 666"
}

test_godauth() {
    b `f d` /enrollments/?page_size=20 "Authorization: Token GODGODGOD"
    b `f e` /enrollments/?max_results=20 "Authorization: Bearer GODGODGOD"
    b `f r` /enrollments/?count=20 "Authorization: Bearer GODGODGOD"
}

test_studentauth() {
    b `f d` /enrollments/?page_size=20 "Authorization: Token $STUDENT"
    b `f e` /enrollments/?max_results=20 "Authorization: Bearer $STUDENT"
    b `f r` /enrollments/?count=20 "Authorization: Bearer $STUDENT"
}

test_$1

sleep 2
echo -e "$output"

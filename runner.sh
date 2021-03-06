#!/bin/bash -e
if [ -z "$DEBUG" ]; then
    NUM=5000
    CON=100
else
    NUM=5
    CON=1
fi

output="Test results:\n"


b() {
    echo "IN: $1"
    pushd "$1" > /dev/null
    set +u # activate would fail
    . venv/bin/activate
    gunicorn -w 2 "$2" &
    sleep 2
    echo GET "$3"
    if [ -z "$4" ]; then
        echo
        curl "http://localhost:8000$3" | python3 -m json.tool
        ab_out=`ab -n "$NUM" -c "$CON" -H "$4" "http://localhost:8000$3"`
    else
        echo "$4"
        echo
        curl $H "$4" "http://localhost:8000$3" | python3 -m json.tool
        ab_out=`ab -n "$NUM" -c "$CON" "http://localhost:8000$3"`
    fi
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
    set -u
    b `f d` /enrollments/?page_size=20 "Authorization: Token $STUDENT"
    b `f e` /enrollments/?max_results=20 "Authorization: Bearer $STUDENT"
    b `f r` /enrollments/?count=20 "Authorization: Bearer $STUDENT"
}

test_teacherauth_one() {
    b `f d` /enrollments/25563/ "Authorization: Token 666"
    b `f e` /enrollments/25563/ "Authorization: Bearer 666"
    b `f r` /enrollments/25563/ "Authorization: Bearer 666"
}

test_godauth_one() {
    b `f d` /enrollments/25563/ "Authorization: Token GODGODGOD"
    b `f e` /enrollments/25563/ "Authorization: Bearer GODGODGOD"
    b `f r` /enrollments/25563/ "Authorization: Bearer GODGODGOD"
}

test_studentauth_one() {
    set -u
    b `f d` /enrollments/25563/ "Authorization: Token $STUDENT"
    b `f e` /enrollments/25563/ "Authorization: Bearer $STUDENT"
    b `f r` /enrollments/25563/ "Authorization: Bearer $STUDENT"
}

test_one() {
    b `f d` /enrollments/25563/
    b `f e` /enrollments/25563/
    b `f r` /enrollments/25563/
    b `f s` /enrollments/25563
}

test_list() {
    b `f d` /enrollments/?page_size=20
    b `f e` /enrollments/?max_results=20
    b `f r` /enrollments/?count=20
    b `f s` /enrollments?page=1
}

test_filter() {
    b `f d` '/courses/?page_size=20&day=5'
    b `f e` '/courses/?max_results=20&where=%7B%22day%22%3A5%7D'
    b `f r` '/courses/?count=20&day=5'
    b `f s` '/courses?page=1&day=5'
}

$1

sleep 2
echo -e "$output"

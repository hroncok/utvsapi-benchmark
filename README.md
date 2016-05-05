utvsapi-benchmark
=================

Simple benchmark designed to be run against [ÚTVS ČVUT](https://rozvoj.fit.cvut.cz/Main/rozvrhy-utvs-db) APIs
implemented in various frameworks.

Requirements
------------

You need the actual implementations cloned:

 * [utvsapi-django](https://github.com/hroncok/utvsapi-django)
 * [utvsapi-eve](https://github.com/hroncok/utvsapi-eve)
 * [utvsapi-ripozo](https://github.com/hroncok/utvsapi-ripozo)
 * [utvsapi-sandman](https://github.com/hroncok/utvsapi-sandman)

The `runner.sh` script expects them to be located in `..`, but you can change that in the script.

The repositories need to be cloned, virtualenvs created in `venv` subdirectory,
dependencies and `gunicorn` installed in those.
Database credentials in appropriate locations for each project are required as well.
See each project's README for details.

Of course, you also need the MySQL/MariaDB database to be running and filled with data,
preferably on localhost not to screw up the results too much.
Unfortunately the data is not public for you to use, but if you are interested contact me and we can figure that out somehow.

You'll also need [utvsapitoken](https://github.com/hroncok/utvsapitoken)'s `fakeserver` to be running on default port (8080).

For some authentication based tests, you'll need to provide a student's personal number in `$STUDENT`. The number is not hardcoded in the scripts for obvious reasons.

How-to
------

Running an individual test and observing the logs:

    ./runner.sh test_foo

Running all auth related tests and observing the logs together with saving them to `logs` directory:

    ./run_all_auth.sh

Note that [utvsapi-sandman](https://github.com/hroncok/utvsapi-sandman) does not
implement auth and is not included in those tests.

Running all not auth related tests and observing the logs together with saving them to `logs` directory:

    ./run_all_auth.sh -v  # -v as in grep's option, not verbose or version

Note that in the spirit of fair play, you should disable auth in other implementations
if you'd like to compare them with [utvsapi-sandman](https://github.com/hroncok/utvsapi-sandman);
there is no simple way to do so, but special `noauth` branches are available in the repos.

Customization
-------------

If you'd like to change the total number of requests and the number of concurrent requests being run for each test,
there are two bash variables for that at the very beginning of the `runner.sh` script.

Censorship
----------

There is a `censor.sh` script provided in order to remove personal information from the logs.
It is wise to use it before publishing the logs.

License
-------

This software is licensed under the terms of the MIT license, see LICENSE for full text and copyright information.
It was inspired by [pycnic's benchmark](https://github.com/nullism/pycnic/tree/master/benchmark)
and [@nullism](https://github.com/nullism) is listed in the copyright notice as well.

Apache2.4+PHP5.4 build pack for Moodle
========================

This is a build pack bundling PHP and Apache for Heroku apps.

Configuration
-------------

The config files are bundled with the build pack itself:

* conf/httpd.conf
* conf/php.ini
* conf/config.php (Moodle default configuration)


Pre-compiling binaries
----------------------

Run `sudo ./precompile.sh` under a Ubuntu 10.04 VM, and it will produce
`/app/apache-VERSION.tar.gz` and `/app/php-VERSION.tar.gz` binary archives
which you can host somewhere for `/bin/compile` to download.


Hacking
-------

To change this buildpack, fork it on Github. Push up changes to your fork, then
create a test app with --buildpack <your-github-url> and push to it.


Meta
----

Froked from https://github.com/grahamjenson/heroku-buildpack-mahara

[![Build
Status](https://travis-ci.org/dennmart/quakeapi.png)](https://travis-ci.org/dennmart/quakeapi)

This is just a simple Sinatra app that fetches earthquake information
from http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt and
can be fetched through an API.

## Local Setup

* The app uses PostgreSQL. You will need to create a database for your
development and test environments.

```sql
CREATE DATABASE quakeapi_development;
CREATE DATABASE quakeapi_test;
```

* Make sure tests are passing correctly by running `rake spec`.

* There's a Rackup file already included, so you can start the app by
running `rackup config.ru`.

* To import earthquake information from
http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt, run `rake quakeapi:fetch_new`. You can run this
at any time, and it will only import new earthquake information.

## Heroku Setup Tips

* Make sure you set up a database with `heroku addons:add heroku-postgresql:dev` and establish it as your primary
database with `heroku pg:promote HEROKU_POSTGRESQL_COLOR_URL` (where
`HEROKU_POSTGRESQL_COLOR_URL` is the setting that Heroku provided when
setting up the database add-on). You can find more info in [Heroku's PostgreSQL
docs](https://devcenter.heroku.com/articles/heroku-postgresql)

* To continuously add new earthquake information, you can set up [Heroku
Scheduler](https://addons.heroku.com/scheduler) to run the `rake quakeapi:fetch_new` task automatically.

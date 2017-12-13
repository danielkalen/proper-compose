# proper-compose
[![Build Status](https://travis-ci.org/danielkalen/proper-compose.svg?branch=master)](https://travis-ci.org/danielkalen/proper-compose)
[![Code Climate](https://codeclimate.com/github/danielkalen/proper-compose/badges/gpa.svg)](https://codeclimate.com/github/danielkalen/proper-compose)
[![NPM](https://img.shields.io/npm/v/proper-compose.svg)](https://npmjs.com/package/proper-compose)

Features:
- inline imports
- `production` service flag
- `disabled` service flag
- inline javascript evaluation
- support for `./docker-compose/index.yml` file
- auto loads `.env.dev` when `NODE_ENV === 'development'` (in addition)
- auto loads `.env.prod` when `NODE_ENV === 'production'` (in addition)
- auto loads `.env.test` when `NODE_ENV === 'test'` (in addition)
- extra commands/functionality
    - `proper-compose *services*` for a summary of all matching services
    - `proper-compose *stats*` for real-time service stats
    - `proper-compose *status*` for online/offline status for given services
    - `proper-compose *online*` for boolean indicating if a service is online
    - `proper-compose *enter*` alias for `docker-compose exec <service> bash`
    - `proper-compose *reup*` alias for `docker-compose stop && docker-compose up`
    - `proper-compose *logs*` will load last 10 lines by default (vs all)

Note: this library is still under development stage and is being processed through heavy real-world battle testing. Full documentation will be released once this module is ready for alpha release.


## License
MIT © [Daniel Kalen](https://github.com/danielkalen)
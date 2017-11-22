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

Note: this library is still under development stage and is being processed through heavy real-world battle testing. Full documentation will be released once this module is ready for alpha release.


## License
MIT © [Daniel Kalen](https://github.com/danielkalen)
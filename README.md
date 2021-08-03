# VAINKEURZ

Make a ranking site that is fun and community.

Based on tournaments which allows to define rankings that will be shareable and comparable.
One of the ranking methods will be a sequence of versus until a ranking.


## Requirements

### Docker
 - open a docker account on id.docker.com
 - download and install docker on your machine
 - tweak the docker config to use 4GB of ram instead of the default

## Setup
* To init the working environment, run `make up`
* To import DB, run `DUMPFILE=./your/path/dumpfile.sql make db-restore`

## Development
To begin working on the project, 

run `make up` to run the docker containers

## Useful links
- frontend client: http://localhost:8000


## Tips

### dev user accounts 
When developing, you can use the following accounts to impersonate a given user type :
* `admin@vainkeurz.com` (ADMIN)
* `user@vainkeurz.com` (USER)

All user passwords are set to `pwd`

### export DB
Run `make db-dump` and find the dump in `./db/dumps/`


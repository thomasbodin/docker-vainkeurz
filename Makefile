.DEFAULT_GOAL := help
.PHONY: logs

MAKE_COMMAND ?= help

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

############## Vars ##############
CURRENT_DB_CONTAINER_ID = $(docker ps -q -f name=db)


########################################################################################################################
#
# HELP
#
########################################################################################################################

#COLORS
RED    := $(shell tput -Txterm setaf 1)
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
PINK   := $(shell tput -Txterm setaf 5)
CYAN   := $(shell tput -Txterm setaf 6)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_HELPER = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-\%]+)\s*:.*\#\#(?:@([a-zA-Z\-\%]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (32 - length $$_->[0]); \
    print "  ${PINK}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

help: ##prints help
	@perl -e '$(HELP_HELPER)' $(MAKEFILE_LIST)


########################################################################################################################
#
# CONTROL
#
########################################################################################################################

up: ##@control Remount all containers
	docker-compose up --remove-orphans -d

rebuild: ##@control Rebuild all containers
	docker-compose up --remove-orphans --build -d

stop: ## Stop running containers
	docker-compose stop -t 0

down: ##@control Unmount all containers
	docker-compose down

ps: ##@control list all containers
	@echo "docker:" && docker ps
	@echo "\n\ndocker-compose:" && docker-compose ps

db-dump: ##@control generate a dump of the database (file will be copied to ./db/dumps/)
	@echo "${PINK}Generating database dump"
	@echo "Create dumps directory if it doesn't exist${RESET}" \
		&& [ -d ./db/dumps/ ] || mkdir -p ./db/dumps/		
	@FILENAME=_dump__${MYSQL_DATABASE}__$$(date +%F_%H-%M-%S).custom.sql \
		&& docker exec -i -e MYSQL_PWD=${MYSQL_ROOT_PASSWORD} $(value CURRENT_DB_CONTAINER_ID) mysqldump -u root ${MYSQL_DATABASE} > ./db/dumps/$${FILENAME}

db-restore: ##@control restore a dump of the database (i.e. `DUMPFILE=./your/path/file.sql make db-restore`)
	@echo "${PINK}Dropping database${RESET}" \
		&& docker exec -i -e MYSQL_PWD=${MYSQL_ROOT_PASSWORD} $(value CURRENT_DB_CONTAINER_ID) mysql -u root -e "DROP DATABASE IF EXISTS $(MYSQL_DATABASE)"
	@echo "${PINK}Creating database${RESET}" \
		&& docker exec -i -e MYSQL_PWD=${MYSQL_ROOT_PASSWORD} $(value CURRENT_DB_CONTAINER_ID) mysql -u root -e "CREATE DATABASE $(MYSQL_DATABASE)"
	@echo "${PINK}Restoring database dump${RESET}" \
		&& docker exec -i -e MYSQL_PWD=${MYSQL_ROOT_PASSWORD} $(value CURRENT_DB_CONTAINER_ID) mysql -u root ${MYSQL_DATABASE} < ${DUMPFILE}

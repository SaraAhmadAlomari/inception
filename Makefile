NAME    = inception
LOGIN   = saalomar
DATA    = /home/$(LOGIN)/data
COMPOSE = docker compose -f srcs/docker-compose.yml

all: data_dirs
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d


ps:
	$(COMPOSE) ps

data_dirs:
	mkdir -p $(DATA)/wordpress
	mkdir -p $(DATA)/mariadb

clean:
	$(COMPOSE) down --rmi all --volumes --remove-orphans

fclean: clean
	sudo rm -rf $(DATA)/wordpress
	sudo rm -rf $(DATA)/mariadb

re: fclean all

.PHONY: all build up down stop start restart logs ps data_dirs clean fclean re

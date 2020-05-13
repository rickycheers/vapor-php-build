SHELL := /bin/bash

compiler: compiler.Dockerfile
	docker build -f ${PWD}/compiler.Dockerfile -t vapor/runtime/compiler:latest .

build-php:
	docker build -f ${PWD}/php.Dockerfile -t vapor/runtime/php-74:latest $(shell helpers/buildArguments.php php74) .

bundle:
	docker build -f ${PWD}/bundler.Dockerfile -t vapor/runtime/bundle:latest $(shell helpers/buildArguments.php php74) .

distribution:
	docker run --rm \
		--env PHP_SHORT_VERSION=74 \
		--volume ${PWD}/runtime:/runtime:ro \
		--volume ${PWD}/../export:/export \
		--volume ${PWD}/export.sh:/export.sh:ro \
		vapor/runtime/bundle:latest \
		/export.sh

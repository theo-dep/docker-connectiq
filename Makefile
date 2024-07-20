# Check at https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
VERSION := 7.2.1-2024-06-25-7463284e6

all: build

pull:
	docker pull kalemena/connectiq:$(VERSION) ;

build:
	@echo "+++ Building docker image +++"
	docker build --pull --build-arg VERSION=$(VERSION) -t kalemena/connectiq:$(VERSION) . ;
	docker tag kalemena/connectiq:$(VERSION) kalemena/connectiq:latest ;

console:
	bash ./run.sh

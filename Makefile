IMAGE=benhall/nginx-sticky
TAG=1.11.1

default: build

build:
	docker build -t $(IMAGE):$(TAG) .

test:
	docker rm -f nginx-sticky
	docker run -p 80:80 -d --name nginx-sticky $(IMAGE):$(TAG)

push:
	docker push $(IMAGE):$(TAG)

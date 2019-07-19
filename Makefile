
DOCKER_IMAGE=mastodon-build

mastodon.tar.xz:
	docker build -t $(DOCKER_IMAGE) .
	docker run --rm $(DOCKER_IMAGE) tar JcC /home/mastodon . > mastodon.tar.xz

clean:
	docker rmi $(DOCKER_IMAGE)

.PHONY: clean

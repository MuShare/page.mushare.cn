VERSION=$(shell cat VERSION)

docker-build:
	docker build --build-arg VERSION=$(VERSION) -t leeif/page-mushare-cn:latest .
	docker tag leeif/page-mushare-cn:latest leeif/page-mushare-cn:$(VERSION)

docker-push:
	docker push leeif/page-mushare-cn:latest
	docker push leeif/page-mushare-cn:$(VERSION)

docker-run: local-docker-build
	docker run -d -t page-mushare-cn-server:latest

docker-clean:
	docker rmi leeif/page-mushare-cn:latest || true
	docker rmi leeif/page-mushare-cn:$(VERSION) || true
	docker rm -v $(shell docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null || true
	docker rmi $(shell docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null || true

check-version-tag:
	git pull --tags
	if git --no-pager tag --list | grep $(VERSION) -q ; then echo "$(VERSION) already exsits"; exit 1; fi

update-tag:
	git pull --tags
	if git --no-pager tag --list | grep $(VERSION) -q ; then echo "$(VERSION) already exsits"; exit 1; fi
	git tag $(VERSION)
	git push origin $(VERSION)

jenkins-ci: check-version-tag docker-build docker-push docker-clean update-tag
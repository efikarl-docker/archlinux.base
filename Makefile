DOCKER_USER:=efikarl
DOCKER_NAME:=archlinux

rootfs:
	$(eval TMPDIR := $(shell mktemp -d))
	cp /usr/share/devtools/pacman-extra.conf rootfs/etc/pacman.conf
	env -i pacstrap -C rootfs/etc/pacman.conf -c -d -G -M $(TMPDIR) $(shell cat packages)
	cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* $(TMPDIR)/
	arch-chroot $(TMPDIR) locale-gen
	tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(TMPDIR) -c . -f archlinux.tar
	rm -rf $(TMPDIR)

docker-image: rootfs
	docker build -t $(DOCKER_USER)/$(DOCKER_NAME) .

docker-image-test: docker-image
	docker run --rm $(DOCKER_USER)/$(DOCKER_NAME) sh -c "/usr/bin/pacman -Syu --noconfirm && locale | grep -q UTF-8"

ci-test:
	docker run --rm --privileged -v /run/docker.sock:/run/docker.sock -v $(PWD):/app \
		-w /app --tmpfs=/tmp:exec --tmpfs=/run/shm $(DOCKER_USER)/$(DOCKER_NAME) \
		sh -c 'pacman -Syu --noconfirm make devtools docker && make docker-image-test'

docker-push:
	docker push $(DOCKER_USER)/$(DOCKER_NAME)

.PHONY: rootfs docker-image docker-image-test ci-test docker-push

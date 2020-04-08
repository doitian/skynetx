VERSION := $(shell sed -n 's/:major: //p' .semver).$(shell sed -n 's/:minor: //p' .semver).$(shell sed -n 's/:patch: //p' .semver)

default: check test

doc:
	@type ldoc &>/dev/null || echo "未安装 ldoc, 请查看 README.md"
	cd doc && ldoc .

doc-clean:
	rm -rf doc/html

release:
	sed -i.bak -e '1,5s/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/v'$(FULL_VERSION)'/' README.md && rm -f README.md.bak
	sed -i.bak -e '1,5s/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/v'$(FULL_VERSION)'/' doc/config.ld && rm -f doc/config.ld.bak
	git add README.md doc/config.ld .semver
	git commit -m "Bump to v$(FULL_VERSION)"
	git tag -a $(FULL_VERSION) -m "tagging $(FULL_VERSION)"

check:
	@type luacheck &>/dev/null || echo "未安装 luacheck, 请查看 README.md"
	luacheck .

test:
	@type busted &>/dev/null || echo "未安装 busted, 请查看 README.md"
	sx exec busted -m './spec/?.lua' .

integration:
	sx integration

.PHONY: default doc doc-clean release
.PHONY: test check integration

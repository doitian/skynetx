default: luacheck test

luacheck:
	luacheck -q src

test:
	busted

doc:
	cd doc && ldoc .

release:
	@which semver > /dev/null || ( echo "gem install semver" && exit 1 )
	echo "return '$$(semver tag)'" > src/xi/version.lua
	cat README.md | sed -e '1,3s/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/'$$(semver tag)'/' > README.md
	cat doc/config.ld | sed -e 's/v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/'$$(semver tag)'/' > doc/config.ld
	git add README.md doc/config.ld src/xi/version.lua .semver
	git commit -m "Bump to $$(semver tag)"
	git tag -a $$(semver tag) -m "tagging $$(semver tag)"

.PHONY: default luacheck test doc release

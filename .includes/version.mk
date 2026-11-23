#-*- mode: makefile; -*-

.PHONY: version release minor major

version:
	@if [[ "$$bump" = "release" ]]; then \
	  bump=2; \
	elif [[ "$$bump" = "minor" ]]; then \
	  bump=1; \
	elif [[ "$$bump" = "major" ]]; then \
	  bump=0; \
	fi; \
	ver=$$(cat VERSION); \
	v=$$(echo $${bump}.$$ver | \
	  perl -a -F[.] -pe '$$i=shift @F;$$F[$$i]++;$$j=$$i+1;$$F[$$_]=0 for $$j..2;$$"=".";$$_="@F"'); \
	echo $$v >VERSION;
	@cat VERSION

release: clean ## bump the patch version (major.minor.patch)
	@$(MAKE) -s version bump=release

minor: clean ## bump the minor version (major.minor.patch)
	@$(MAKE) -s version bump=minor

major: clean ## bump the major version (major.minor.patch)
	@$(MAKE) -s version bump=major

next-release:
	$(NO_ECHO)git checkout main >/dev/null 2>&1; \
	$(MAKE) release >/dev/null; \
	version=$$(cat VERSION); \
	git checkout -b $$version >/dev/null; \
	changelog=$$(mktemp); trap 'rm -f $$changelog' EXIT; \
	printf "$$(date +%c)  $(GIT_NAME)  <$(GIT_EMAIL)>\n\n" > $$changelog; \
	printf "\t[$$version]:\n\n" >> $$changelog; \
	printf "\t* VERSION: bump\n\n" >> $$changelog; \
	cat $$changelog ChangeLog > ChangeLog.tmp; \
	mv ChangeLog.tmp ChangeLog; \
	git add VERSION ChangeLog; \
	git commit -m "release: $$version begins"; \
	echo "$$version begins..."

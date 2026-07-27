# Create a distribution release for this GitHub Action.
#
# Usage:
#   make release              # uses version from package.json
#   make release VERSION=7.1.0
#
# Creates releases/vX.Y.Z with built lib/ and production node_modules,
# tags vX.Y.Z, and pushes both to origin.

VERSION ?= $(shell node -p "require('./package.json').version")
TAG := v$(VERSION)
RELEASE_BRANCH := releases/$(TAG)

.PHONY: help release

help:
	@echo "Targets:"
	@echo "  release [VERSION=x.y.z]  Build a distribution branch, tag, and push"
	@echo ""
	@echo "Current package.json version: $(VERSION)"
	@echo "Would create: $(RELEASE_BRANCH) and tag $(TAG)"

release:
	@test -n "$(VERSION)" || (echo "VERSION is required" >&2; exit 1)
	@echo "$(VERSION)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$$' \
		|| (echo "VERSION must be semver (got: $(VERSION))" >&2; exit 1)
	@git diff --quiet && git diff --cached --quiet \
		|| (echo "Working tree is dirty; commit or stash first" >&2; exit 1)
	@! git rev-parse --verify --quiet "refs/heads/$(RELEASE_BRANCH)" >/dev/null \
		|| (echo "Branch $(RELEASE_BRANCH) already exists" >&2; exit 1)
	@! git rev-parse --verify --quiet "refs/tags/$(TAG)" >/dev/null \
		|| (echo "Tag $(TAG) already exists" >&2; exit 1)
	@echo "Creating release $(TAG) on branch $(RELEASE_BRANCH)..."
	git checkout -b "$(RELEASE_BRANCH)"
	sed -i.bak -E 's/^node_modules\/$$/# node_modules\//; s/^lib\/$$/# lib\//' .gitignore
	rm -f .gitignore.bak
	npm ci
	npm run build
	npm prune --omit=dev
	git add -A
	git status --short
	git commit -m "check in prod dependencies"
	git tag "$(TAG)"
	git push -u origin "HEAD:$(RELEASE_BRANCH)"
	git push origin "refs/tags/$(TAG)"
	@echo "Released $(TAG) -> $(RELEASE_BRANCH)"
	@echo "Use: uses: signalscode/github-tag-action@$(TAG)"

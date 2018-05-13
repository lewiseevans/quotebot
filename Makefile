# List out go packages and files
GOPACKAGES=$(shell go list ./... | grep -v /vendor/ | grep -v /test )
GOFILES=$(shell find . -type f -name '*.go' -not -path "./vendor/*" )

# Gather version information to tag the image
GIT_COMMIT_SHA="$(shell git rev-parse HEAD 2>/dev/null)"
BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Default the build environment variables if unknown
BUILD_ID?=unknown
BUILD_NUMBER?=unknown

#############################################
# Build targets

.PHONY: all
all: deps gotasks test

.PHONY: deps
deps:
	glide install --strip-vendor

.PHONY: update-deps
update-deps:
	glide cc
	glide update --strip-vendor

.PHONY: gotasks
gotasks: fmt lint vet 

.PHONY: fmt
fmt:
	@if [ -n "$$(gofmt -l ${GOFILES})" ]; then echo "Please run 'make reformat'" && exit 1; fi

.PHONY: lint
lint:
	$(GOPATH)/bin/golint -set_exit_status=true main.go

.PHONY: vet
vet:
	go vet ${GOPACKAGES}

.PHONY: buildgo
buildgo:
	CGO_ENABLED=0 GOOS=linux go build -ldflags "-s" -a -installsuffix cgo .

.PHONY: test
test:
	go test -v -race ./...

.PHONY: build-docker-image
build-docker-image:
	docker build \
		--build-arg git_commit_id=${GIT_COMMIT_SHA} \
		--build-arg build_date=${BUILD_DATE} \
		--build-arg build_id=${BUILD_ID} \
		--build-arg build_number=${BUILD_NUMBER} \
		-t lewiseevans/quotebot:${GIT_COMMIT_SHA} .
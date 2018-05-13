# Default values
ARG git_commit_id=unknown
ARG git_remote_url=unknown
ARG build_date=unknown
ARG build_id=unknown
ARG build_number=unknown

# Build our app
FROM golang:1.9.1 as app
WORKDIR /go/src/github.com/lewiseevans/quotebot/
ADD . /go/src/github.com/lewiseevans/quotebot/
RUN make buildgo

# Start prepping our image
FROM scratch
LABEL git-commit-id=${git_commit_id}
LABEL build-date=${build_date}
LABEL build-id=${build_id}
LABEL build-number=${build_number}

# Copy the precompiled app
COPY --from=app /go/src/github.com/lewiseevans/quotebot/quotebot /go/bin/

ENV GOPATH /go
ENV BUILD_NUMBER=${build_number}

# GOGOGOGOGOGO
ENTRYPOINT [ "/go/bin/quotebot" ]

# The app listens on port 8080
EXPOSE 8080
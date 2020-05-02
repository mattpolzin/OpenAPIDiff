FROM swift:5.2.3 as build

WORKDIR /build

COPY ./Package.* ./

RUN swift package resolve

COPY . .

RUN swift build -c release --enable-test-discovery

# ----------------

FROM swift:5.2.3-slim

WORKDIR /api

COPY --from=build ./build/.build/release/openapi-diff ./openapi-diff

# SUGGESTED USE:
# - bind mount your two API JSON/YAML files to `/api/old.yml` and `/api/new.yml`
# - pass `/api/old.yml /api/new.yml` as arguments to docker container.
# - optionally pass `--markdown` to generate markdown instead of plaintext.
#
# EXAMPLE:
# `docker run -v ./old.yml:/api/old.yml -v ./new.yml:/api/new.yml mattpolzin2/openapi-diff /api/old.yml /api/new.yml`

ENTRYPOINT ["./openapi-diff"]

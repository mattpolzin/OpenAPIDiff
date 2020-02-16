The following command was run in this directory to produce `diff.md`.

```shell
docker run --rm -v "$(pwd)/v1.yml:/api/v1.yml" -v "$(pwd)/v2.yml:/api/v2.yml" mattpolzin2/openapi-diff /api/v1.yml /api/v2.yml --markdown > ./diff.md
```

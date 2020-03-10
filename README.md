# OpenAPIDiff

This is a WIP diffing library for OpenAPI documentation. It produces a hierarchical list of changes between two versions of an API. Only OpenAPI v3.x is supported.

## Example
To see an example of what this library produces when run against two YAML OpenAPI documents with the markdown option, take a look at the `example` folder.

## Usage
### Executable
The library ships with a very simple executable. If you just want to play with what you get out-of-the-box, the easiest option is to run the Docker image I host on Docker Hub.

The dockerized executable will require you to mount one or more volumes containing the versions of the API you wish to diff. Assuming you have the old and new versions of your API in the current working directory (named `old.json` and `new.json`), a simple invocation would be:
```shell
docker run --rm -v "$(pwd)/old.json:/api/old.json" -v "$(pwd)/new.json:/api/new.json" mattpolzin2/openapi-diff /api/old.json /api/new.json
```

You can pass `mattpolzin2/openapi-diff` the `--markdown` flag in addition to the two API document files to produce a markdown diff instead of the default plaintext diff.

For all options, see the `--help`.

### Library
As a library, you first reference this package from your manifest or pull it in via Xcode.

```swift
...
dependencies: [
  .package(url: "https://github.com/mattpolzin/OpenAPIDiff.git", .upToNextMinor(from: "0.0.3")),
  ...
],
...
```

Then you can produce diffs with
```swift
import OpenAPIKit
import OpenAPIDiff

let file1 = try Data(contentsOf: oldOpenAPIFile)
let file2 = try Data(contentsOf: newOpenAPIFile)

let api1 = try JSONDecoder().decode(OpenAPI.Document.self, from: file1)
let api2 = try JSONDecoder().decode(OpenAPI.Document.self, from: file2)

let comparison = api1.compare(to: api2)

let markdownDiff = comparison.markdownDescription
let plaintextDiff = comparison.description
```

By default you will be getting entries for all of the things that have _not_ changed as well as those that have changed. You can easily omit the similarities with
```swift
let differences = comparison.description { !$0.isSame }
let markdownDifferences = comparison.markdownDescription { !$0.isSame }
```

The structure you are producing is `ApiDiff`. You can take a look at `ApiDiff.swift` if you want to operate on the diff in some way different than the `description()` and `markdownDescription()` methods do.

## Building From Source
The library target (`OpenAPIDiff`) and executable target (`openapi-diff`) can both be built quite easily with either `swift build` or by opening the repository root folder in Xcode 11.

The docker image can be build from the included Dockerfile with
```shell
docker build -t openapi-diff .
```

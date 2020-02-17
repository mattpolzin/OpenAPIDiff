
# Changes to OpenAPI Example API

## Changes to paths
- Added **/healthcheck**

### Changes to **/hello**

#### Changes to GET endpoint

##### Changes to responses → status code 200 → content → application/json
- Updated **schema**

```diff
  properties:
  [...]
      - spanish
+     - french
+     - german
      type: string
  required:
- - greeting
  - language
+ - greeting
  type: object
```


##### Changes to parameters → `language` → schema or content
- Updated **schema**

```diff
  enum:
  - english
  - spanish
+ - french
+ - german
  type: string
```


## Changes to servers
- Added https://remote.host.com

## Changes to info
- Updated **description**
	- from
 > ## Descriptive Text
 > This text supports _markdown_!
	- to
 > ## Descriptive Text
 > Now with a _more descriptive_ description than before!

- Updated **API version**
	- from
 > 1.0
	- to
 > 2.0

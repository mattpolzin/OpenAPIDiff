
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
- - language
  - greeting
+ - language
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

 _from_ ↯
 > ## Descriptive Text
 > This text supports _markdown_!

 _to_ ↯
 > ## Descriptive Text
 > Now with a _more descriptive_ description than before!

- Updated **API version**

 _from_ ↯
 > 1.0

 _to_ ↯
 > 2.0

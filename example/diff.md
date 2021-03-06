
# Changes to OpenAPI Example API

## Changes to paths
- Added **/healthcheck**

### Changes to **/hello**

#### Changes to GET endpoint
- Updated **responses → status code 200 → content → application/json → schema** 

```diff
properties:
[...]
- spanish
+     - french
+     - german
[...]
type: object
```

- Updated **parameters → `language` → schema or content → schema** 

```diff
enum:
- english
- spanish
+ - french
+ - german
type: string
```


##### Changes to security → 1st item
- Removed #/components/securitySchemes/hello_secure_1
- Added #/components/securitySchemes/hello_secure_2

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

# go-import examples

## Bad

```go
import (
    "github.com/acme/foo"
    "fmt"
    "mycorp/app/internal/bar"
)
```

## Good

In this fallback layout, `mycorp/shared/logging` stays in the external group unless its import path prefix exactly matches the current `go.mod` module value.

```go
import (
    "fmt"

    "github.com/acme/foo"
    "mycorp/shared/logging"

    "mycorp/app/internal/bar"
)
```

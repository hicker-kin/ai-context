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

```go
import (
    "fmt"

    "github.com/acme/foo"

    "mycorp/app/internal/bar"
)
```

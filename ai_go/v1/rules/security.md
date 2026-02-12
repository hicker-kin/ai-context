# Go Security Rules

## Scope

Input handling, authz, data protection, and logging practices for Go services.

## Core MUSTs

- Validate and sanitize all external inputs; use framework validators (`binding`, `validator`) and explicit `json` tags.
- Enforce AuthN/AuthZ at boundaries (middleware/handler); least privilege everywhere.
- Use parameterized queries / prepared statements; never string-concatenate SQL.
- Escape/encode template output; avoid unsafe HTML unless explicitly required.
- Do not log secrets, tokens, passwords, or PII; scrub before logging.
- Load secrets from env/secret stores; never commit them.
- Add rate limiting / circuit breaking on public endpoints and outbound calls where appropriate.
- Keep dependencies updated; run vulnerability scans periodically.

## Good / Bad Examples

### Safe DB query + authz + no sensitive logging (GOOD)

```go
if !rbac.Allowed(user, "order:read") {
    return ErrForbidden
}
row := db.QueryRowContext(ctx, "SELECT id, amount FROM orders WHERE id = ?", id)
if err := row.Scan(&o.ID, &o.Amount); err != nil {
    return fmt.Errorf("query order %d: %w", id, err)
}
logger.Info("order fetched", "user_id", user.ID, "order_id", id) // no PII ✅
```

### SQL injection + secret leak (BAD)

```go
q := fmt.Sprintf("SELECT * FROM orders WHERE id = %s", id) // injection ❌
logger.Infof("token=%s", token)                            // leaks secret ❌
```

## Input and Output

- Validate lengths, formats, and enums; reject early with clear errors.
- Use `omitempty` for optional fields; avoid implicit defaults that mask errors.
- Escape output in templates (`html/template` auto-escapes); avoid `text/template` for untrusted data.

## Transport and Storage

- Use TLS for all network traffic; verify certificates when calling external services.
- For passwords, store salted hashes (e.g., bcrypt/argon2); never reversible storage.
- Rotate credentials; prefer short-lived tokens.

## Logging and Monitoring

- Centralize structured logging; include request_id/trace_id.
- Avoid duplicate logging of the same error across layers.
- Monitor auth failures, rate-limit triggers, and unusual access patterns.
- Never log secrets, tokens, passwords, PII; avoid noisy logs in loops; avoid `fmt.Println`/`log.Println` in services.

### Logging Anti-Patterns (BAD) and Safer Alternatives (GOOD)

```go
// BAD: sensitive data
logger.Infof("user password: %s", password)  // ❌
logger.Infof("auth token: %s", token)        // ❌

// BAD: noisy loop
for _, item := range items {
    logger.Infof("processing %v", item) // ❌ too verbose
}

// BAD: ad-hoc prints (no structure, no redaction)
fmt.Println("debug info") // ❌

// GOOD: summarized, structured, no secrets
logger.Info("batch processed", "count", len(items))
```

## Defensive Controls

- Apply rate limiting and timeouts on inbound handlers.
- Add retries with backoff only for idempotent outbound calls; cap attempts.
- Use context deadlines for all network and storage calls.

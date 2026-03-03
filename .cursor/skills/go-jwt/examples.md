# Go JWT — Complete Implementation

Place all files under `pkg/jwt/`.

---

## `pkg/jwt/jwt.go` — Types and constants

```go
package jwt

import (
	"encoding/json"

	"github.com/golang-jwt/jwt/v5"
)

// Method is the JWT signing algorithm.
type Method string

const (
	MethodRS256 Method = "RS256" // RSA PKCS1v1.5 asymmetric; requires RSA PEM key pair (legacy, still safe)
	MethodPS256 Method = "PS256" // RSA-PSS asymmetric; same RSA key pair as RS256, randomised padding (recommended over RS256)
	MethodES256 Method = "ES256" // ECDSA P-256 asymmetric; requires EC PEM key pair (recommended for new projects)
	MethodHS256 Method = "HS256" // HMAC symmetric; requires shared secret string (min 32 bytes)
)

// CustomClaims extends standard JWT claims with a custom Data payload.
// After Parse, Data is map[string]any; use Unmarshal[T] to decode it.
type CustomClaims struct {
	Data any `json:"data"`
	jwt.RegisteredClaims
}

// Unmarshal decodes the Data field of CustomClaims into a concrete struct T.
// Required because Data becomes map[string]any after JSON roundtrip in Parse.
//
// Example:
//
//	user, err := jwt.Unmarshal[UserToken](claims)
func Unmarshal[T any](claims *CustomClaims) (*T, error) {
	b, err := json.Marshal(claims.Data)
	if err != nil {
		return nil, err
	}
	var v T
	if err := json.Unmarshal(b, &v); err != nil {
		return nil, err
	}
	return &v, nil
}
```

---

## `pkg/jwt/signer.go` — Token signing

```go
package jwt

import (
	"crypto/ecdsa"
	"crypto/rand"
	"crypto/rsa"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pkg/errors"
)

var defaultMaxLifetime = 7 * 24 * time.Hour

// Signer creates signed JWT tokens.
type Signer interface {
	// Token creates a signed JWT for sub with the given payload and lifetime.
	// lifetime is capped at MaxLifetimeSec (default 7 days).
	Token(sub string, data any, lifetime time.Duration) (string, error)
}

// SignerConfig holds JWT signing configuration.
type SignerConfig struct {
	Method Method `mapstructure:"method"` // "RS256" | "PS256" | "ES256" | "HS256"; default RS256

	// RSA keys — used for RS256 and PS256
	PrivateKeyPath string `mapstructure:"private_key_path"` // RS256/PS256: path to RSA private key PEM file
	PrivateKeyData string `mapstructure:"private_key_data"` // RS256/PS256: inline PEM string; takes precedence over path

	// EC keys — used for ES256
	ECPrivateKeyPath string `mapstructure:"ec_private_key_path"` // ES256: path to EC private key PEM file
	ECPrivateKeyData string `mapstructure:"ec_private_key_data"` // ES256: inline PEM string; takes precedence over path

	// HMAC — used for HS256
	Secret string `mapstructure:"secret"` // HS256: shared HMAC secret string (min 32 bytes)

	// Common
	Issuer         string   `mapstructure:"issuer"`           // JWT iss claim
	Audiences      []string `mapstructure:"audiences"`        // JWT aud claim
	IDPrefix       string   `mapstructure:"id_prefix"`        // if non-empty, sets jti (random hex)
	MaxLifetimeSec int      `mapstructure:"max_lifetime_sec"` // max token lifetime in seconds (0 = 7 days)

	maxLifetime time.Duration
	rsaKey      *rsa.PrivateKey
	ecKey       *ecdsa.PrivateKey
}

func (c *SignerConfig) parse() error {
	if c.Method == "" {
		c.Method = MethodRS256
	}

	switch c.Method {
	case MethodRS256, MethodPS256:
		if c.PrivateKeyData == "" && c.PrivateKeyPath == "" {
			return errors.New("private_key_data or private_key_path must be set for RS256/PS256")
		}
		pemBytes := []byte(c.PrivateKeyData)
		if c.PrivateKeyData == "" {
			var err error
			pemBytes, err = os.ReadFile(c.PrivateKeyPath)
			if err != nil {
				return errors.Wrap(err, "read RSA private key file")
			}
		}
		key, err := jwt.ParseRSAPrivateKeyFromPEM(pemBytes)
		if err != nil {
			return errors.Wrap(err, "parse RSA private key")
		}
		c.rsaKey = key

	case MethodES256:
		if c.ECPrivateKeyData == "" && c.ECPrivateKeyPath == "" {
			return errors.New("ec_private_key_data or ec_private_key_path must be set for ES256")
		}
		pemBytes := []byte(c.ECPrivateKeyData)
		if c.ECPrivateKeyData == "" {
			var err error
			pemBytes, err = os.ReadFile(c.ECPrivateKeyPath)
			if err != nil {
				return errors.Wrap(err, "read EC private key file")
			}
		}
		key, err := jwt.ParseECPrivateKeyFromPEM(pemBytes)
		if err != nil {
			return errors.Wrap(err, "parse EC private key")
		}
		c.ecKey = key

	case MethodHS256:
		if c.Secret == "" {
			return errors.New("secret must be set for HS256")
		}

	default:
		return fmt.Errorf("unsupported signing method: %s", c.Method)
	}

	if c.Issuer == "" {
		return errors.New("issuer must be set")
	}

	// MaxLifetimeSec directly sets the cap; 0 means use the default (7 days).
	c.maxLifetime = defaultMaxLifetime
	if c.MaxLifetimeSec > 0 {
		c.maxLifetime = time.Duration(c.MaxLifetimeSec) * time.Second
	}

	return nil
}

type jwtSigner struct {
	cfg *SignerConfig
}

// NewSigner creates a new Signer. Validates config and loads keys on construction.
func NewSigner(cfg *SignerConfig) (Signer, error) {
	if err := cfg.parse(); err != nil {
		return nil, errors.Wrap(err, "parse signer config")
	}
	return &jwtSigner{cfg: cfg}, nil
}

// Token creates a signed JWT for the given subject, payload data, and lifetime.
func (s *jwtSigner) Token(sub string, data any, lifetime time.Duration) (string, error) {
	if lifetime > s.cfg.maxLifetime {
		lifetime = s.cfg.maxLifetime
	}

	now := time.Now()
	rc := jwt.RegisteredClaims{
		ExpiresAt: jwt.NewNumericDate(now.Add(lifetime)),
		IssuedAt:  jwt.NewNumericDate(now),
		NotBefore: jwt.NewNumericDate(now.Add(-30 * time.Second)), // 30s clock-skew tolerance
		Issuer:    s.cfg.Issuer,
		Subject:   sub,
		Audience:  s.cfg.Audiences,
	}
	if s.cfg.IDPrefix != "" {
		rc.ID = s.cfg.IDPrefix + ":" + newID()
	}

	return jwt.NewWithClaims(
		toSigningMethod(s.cfg.Method),
		&CustomClaims{Data: data, RegisteredClaims: rc},
	).SignedString(signerKey(s.cfg))
}

func toSigningMethod(m Method) jwt.SigningMethod {
	switch m {
	case MethodHS256:
		return jwt.SigningMethodHS256
	case MethodPS256:
		return jwt.SigningMethodPS256
	case MethodES256:
		return jwt.SigningMethodES256
	default: // MethodRS256
		return jwt.SigningMethodRS256
	}
}

func signerKey(cfg *SignerConfig) any {
	switch cfg.Method {
	case MethodHS256:
		return []byte(cfg.Secret)
	case MethodES256:
		return cfg.ecKey
	default: // MethodRS256, MethodPS256
		return cfg.rsaKey
	}
}

// newID returns a cryptographically random 16-byte hex string for use as jti.
// Replace with UUID v7 if available in your project (e.g. pkg/utils/uuid/v7).
func newID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano()) // fallback; should not happen
	}
	return fmt.Sprintf("%x", b)
}
```

---

## `pkg/jwt/parser.go` — Token verification

```go
package jwt

import (
	"crypto/ecdsa"
	"crypto/rsa"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pkg/errors"
)

// Parser validates and parses JWT tokens.
type Parser interface {
	// Parse validates the token string and returns the decoded CustomClaims.
	Parse(token string) (*CustomClaims, error)
}

// ParserConfig holds JWT parsing/verification configuration.
type ParserConfig struct {
	Method Method `mapstructure:"method"` // "RS256" | "PS256" | "ES256" | "HS256"; default RS256

	// RSA keys — used for RS256 and PS256
	PublicKeyPath string `mapstructure:"public_key_path"` // RS256/PS256: path to RSA public key PEM file
	PublicKeyData string `mapstructure:"public_key_data"` // RS256/PS256: inline PEM string; takes precedence over path

	// EC keys — used for ES256
	ECPublicKeyPath string `mapstructure:"ec_public_key_path"` // ES256: path to EC public key PEM file
	ECPublicKeyData string `mapstructure:"ec_public_key_data"` // ES256: inline PEM string; takes precedence over path

	// HMAC — used for HS256
	Secret string `mapstructure:"secret"` // HS256: shared HMAC secret string (min 32 bytes)

	// Common
	Audience string `mapstructure:"audience"` // expected aud value; empty = skip audience check

	rsaKey *rsa.PublicKey
	ecKey  *ecdsa.PublicKey
}

func (c *ParserConfig) parse() error {
	if c.Method == "" {
		c.Method = MethodRS256
	}

	switch c.Method {
	case MethodRS256, MethodPS256:
		if c.PublicKeyData == "" && c.PublicKeyPath == "" {
			return errors.New("public_key_data or public_key_path must be set for RS256/PS256")
		}
		pemBytes := []byte(c.PublicKeyData)
		if c.PublicKeyData == "" {
			var err error
			pemBytes, err = os.ReadFile(c.PublicKeyPath)
			if err != nil {
				return errors.Wrap(err, "read RSA public key file")
			}
		}
		key, err := jwt.ParseRSAPublicKeyFromPEM(pemBytes)
		if err != nil {
			return errors.Wrap(err, "parse RSA public key")
		}
		c.rsaKey = key

	case MethodES256:
		if c.ECPublicKeyData == "" && c.ECPublicKeyPath == "" {
			return errors.New("ec_public_key_data or ec_public_key_path must be set for ES256")
		}
		pemBytes := []byte(c.ECPublicKeyData)
		if c.ECPublicKeyData == "" {
			var err error
			pemBytes, err = os.ReadFile(c.ECPublicKeyPath)
			if err != nil {
				return errors.Wrap(err, "read EC public key file")
			}
		}
		key, err := jwt.ParseECPublicKeyFromPEM(pemBytes)
		if err != nil {
			return errors.Wrap(err, "parse EC public key")
		}
		c.ecKey = key

	case MethodHS256:
		if c.Secret == "" {
			return errors.New("secret must be set for HS256")
		}

	default:
		return fmt.Errorf("unsupported signing method: %s", c.Method)
	}

	return nil
}

type jwtParser struct {
	cfg *ParserConfig
}

// NewParser creates a new Parser. Validates config and loads keys on construction.
func NewParser(cfg *ParserConfig) (Parser, error) {
	if err := cfg.parse(); err != nil {
		return nil, errors.Wrap(err, "parse parser config")
	}
	return &jwtParser{cfg: cfg}, nil
}

// Parse validates the token string and returns the decoded CustomClaims.
// Returns error if the token is expired, has an invalid signature, or fails audience check.
func (p *jwtParser) Parse(tokenString string) (*CustomClaims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&CustomClaims{},
		func(token *jwt.Token) (any, error) {
			// Guard against Algorithm Confusion attacks:
			// reject any token whose alg header doesn't match the configured method.
			if token.Method.Alg() != string(p.cfg.Method) {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return parserKey(p.cfg), nil
		},
		jwt.WithLeeway(5*time.Second), // tolerate 5s clock skew
	)
	if err != nil {
		return nil, errors.Wrap(err, "parse token")
	}

	claims, ok := token.Claims.(*CustomClaims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	if p.cfg.Audience != "" && !audienceContains(claims.Audience, p.cfg.Audience) {
		return nil, fmt.Errorf("invalid audience")
	}

	return claims, nil
}

func parserKey(cfg *ParserConfig) any {
	switch cfg.Method {
	case MethodHS256:
		return []byte(cfg.Secret)
	case MethodES256:
		return cfg.ecKey
	default: // MethodRS256, MethodPS256
		return cfg.rsaKey
	}
}

func audienceContains(audiences jwt.ClaimStrings, target string) bool {
	for _, a := range audiences {
		if a == target {
			return true
		}
	}
	return false
}
```

---

## `pkg/jwt/jwt_test.go` — Complete tests

```go
package jwt_test

import (
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	jwtpkg "yourmodule/pkg/jwt"
)

// UserToken is the business payload embedded in the token.
type UserToken struct {
	ID        int64  `json:"id"`
	Username  string `json:"username"`
	NickName  string `json:"nick_name"`
	Email     string `json:"email"`
	SessionID string `json:"session_id"`
}

// --- RS256 tests ---

func TestRS256_SignAndVerify(t *testing.T) {
	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:         jwtpkg.MethodRS256,
		PrivateKeyPath: "key.pem", // generated by: openssl genrsa -out key.pem 2048
		Issuer:         "test.com",
		Audiences:      []string{"api.test.com"},
		MaxLifetimeSec: 3600, // 1 hour
	})
	require.NoError(t, err)

	payload := UserToken{ID: 1, Username: "alice", SessionID: "sess-001"}
	token, err := signer.Token("alice", payload, time.Hour)
	require.NoError(t, err)
	require.NotEmpty(t, token)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:        jwtpkg.MethodRS256,
		PublicKeyPath: "public.pem", // generated by: openssl rsa -in key.pem -pubout -out public.pem
		Audience:      "api.test.com",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)
	require.Equal(t, "alice", claims.Subject)

	user, err := jwtpkg.Unmarshal[UserToken](claims)
	require.NoError(t, err)
	require.Equal(t, int64(1), user.ID)
	require.Equal(t, "alice", user.Username)
	require.Equal(t, "sess-001", user.SessionID)
}

func TestRS256_InlineKeyData(t *testing.T) {
	// Keys can also be supplied as inline PEM strings (e.g. from env / secret manager)
	privateKeyPEM := mustReadFile(t, "key.pem")
	publicKeyPEM := mustReadFile(t, "public.pem")

	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:         jwtpkg.MethodRS256,
		PrivateKeyData: privateKeyPEM, // inline PEM string
		Issuer:         "test.com",
		Audiences:      []string{"api.test.com"},
	})
	require.NoError(t, err)

	token, err := signer.Token("bob", map[string]string{"role": "admin"}, time.Hour)
	require.NoError(t, err)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:        jwtpkg.MethodRS256,
		PublicKeyData: publicKeyPEM, // inline PEM string
		Audience:      "api.test.com",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)
	require.Equal(t, "bob", claims.Subject)
}

// --- HS256 tests ---

func TestHS256_SignAndVerify(t *testing.T) {
	secret := "super-secret-key-min-32-bytes-long!!"

	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:    jwtpkg.MethodHS256,
		Secret:    secret,
		Issuer:    "test.com",
		Audiences: []string{"internal.test.com"},
	})
	require.NoError(t, err)

	payload := UserToken{ID: 2, Username: "charlie"}
	token, err := signer.Token("charlie", payload, 30*time.Minute)
	require.NoError(t, err)
	require.NotEmpty(t, token)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:   jwtpkg.MethodHS256,
		Secret:   secret,
		Audience: "internal.test.com",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)

	user, err := jwtpkg.Unmarshal[UserToken](claims)
	require.NoError(t, err)
	require.Equal(t, int64(2), user.ID)
	require.Equal(t, "charlie", user.Username)
}

// --- Lifetime cap test ---

func TestLifetimeCap(t *testing.T) {
	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:         jwtpkg.MethodHS256,
		Secret:         "any-secret-at-least-32-characters!!",
		Issuer:         "test.com",
		MaxLifetimeSec: 60, // cap at 1 minute
	})
	require.NoError(t, err)

	// request 1 hour, but config caps at 60s
	token, err := signer.Token("dave", nil, time.Hour)
	require.NoError(t, err)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method: jwtpkg.MethodHS256,
		Secret: "any-secret-at-least-32-characters!!",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)

	remaining := time.Until(claims.ExpiresAt.Time)
	require.LessOrEqual(t, remaining, 61*time.Second)
}

// --- Invalid audience test ---

func TestInvalidAudience(t *testing.T) {
	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:    jwtpkg.MethodHS256,
		Secret:    "any-secret-at-least-32-characters!!",
		Issuer:    "test.com",
		Audiences: []string{"service-a"},
	})
	require.NoError(t, err)

	token, err := signer.Token("eve", nil, time.Hour)
	require.NoError(t, err)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:   jwtpkg.MethodHS256,
		Secret:   "any-secret-at-least-32-characters!!",
		Audience: "service-b", // wrong audience
	})
	require.NoError(t, err)

	_, err = parser.Parse(token)
	require.ErrorContains(t, err, "invalid audience")
}

func TestES256_SignAndVerify(t *testing.T) {
	// Minimal self-contained EC P-256 key pair (test only — never use in production)
	const ecPrivPEM = `-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIOaRsGWHpJxXxGj7s4hASxhJZMRjCt0nfk/TIPLWVygloAoGCCqGSM49
AwEHoWQDYgAEn0oI1Q9+U9vSKjWRbzRyQ1C4Qdh6P5hIh1B8vOgR7NfAIWwjt6ZT
Q9mYl7P1WJgLpEhGFlYuHM3JQkVHRl3f
-----END EC PRIVATE KEY-----`

	const ecPubPEM = `-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEn0oI1Q9+U9vSKjWRbzRyQ1C4Qdh6
P5hIh1B8vOgR7NfAIWwjt6ZTQ9mYl7P1WJgLpEhGFlYuHM3JQkVHRl3f
-----END PUBLIC KEY-----`

	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:           jwtpkg.MethodES256,
		ECPrivateKeyData: ecPrivPEM,
		Issuer:           "test.com",
		Audiences:        []string{"api.test.com"},
	})
	require.NoError(t, err)

	payload := UserToken{ID: 3, Username: "diana"}
	token, err := signer.Token("diana", payload, 15*time.Minute)
	require.NoError(t, err)
	require.NotEmpty(t, token)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:          jwtpkg.MethodES256,
		ECPublicKeyData: ecPubPEM,
		Audience:        "api.test.com",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)

	user, err := jwtpkg.Unmarshal[UserToken](claims)
	require.NoError(t, err)
	require.Equal(t, int64(3), user.ID)
	require.Equal(t, "diana", user.Username)
}

func TestPS256_SignAndVerify(t *testing.T) {
	// PS256 reuses the same RSA PEM keys as RS256
	privPEM := mustReadFile(t, "testdata/rsa-key.pem")
	pubPEM := mustReadFile(t, "testdata/rsa-public.pem")

	signer, err := jwtpkg.NewSigner(&jwtpkg.SignerConfig{
		Method:         jwtpkg.MethodPS256,
		PrivateKeyData: privPEM,
		Issuer:         "test.com",
		Audiences:      []string{"api.test.com"},
	})
	require.NoError(t, err)

	payload := UserToken{ID: 4, Username: "elliot"}
	token, err := signer.Token("elliot", payload, 15*time.Minute)
	require.NoError(t, err)
	require.NotEmpty(t, token)

	parser, err := jwtpkg.NewParser(&jwtpkg.ParserConfig{
		Method:        jwtpkg.MethodPS256,
		PublicKeyData: pubPEM,
		Audience:      "api.test.com",
	})
	require.NoError(t, err)

	claims, err := parser.Parse(token)
	require.NoError(t, err)

	user, err := jwtpkg.Unmarshal[UserToken](claims)
	require.NoError(t, err)
	require.Equal(t, int64(4), user.ID)
	require.Equal(t, "elliot", user.Username)
}

// --- helpers ---

func mustReadFile(t *testing.T, path string) string {
	t.Helper()
	b, err := os.ReadFile(path)
	require.NoError(t, err)
	return string(b)
}
```

---

## YAML config example (`configs/settings.yaml`)

```yaml
# RS256 — legacy RSA PKCS1v1.5 (key generation: openssl genrsa -out configs/key.pem 2048)
jwt:
  signer:
    method: RS256
    private_key_path: configs/key.pem   # path to RSA private key PEM file
    # private_key_data: ""              # alternative: inline PEM string (e.g. from env)
    issuer: myapp
    audiences:
      - api.myapp.com
    max_lifetime_sec: 86400             # max token lifetime in seconds (0 = 7 days)

  parser:
    method: RS256
    public_key_path: configs/public.pem # path to RSA public key PEM file
    # public_key_data: ""               # alternative: inline PEM string
    audience: api.myapp.com
```

```yaml
# PS256 (recommended over RS256) — same RSA key pair, randomised PSS padding
jwt:
  signer:
    method: PS256
    private_key_path: configs/key.pem   # same RSA key as RS256
    issuer: myapp
    audiences:
      - api.myapp.com
    max_lifetime_sec: 86400

  parser:
    method: PS256
    public_key_path: configs/public.pem # same RSA public key as RS256
    audience: api.myapp.com
```

```yaml
# ES256 (recommended for new projects) — ECDSA P-256
# Key generation:
#   openssl ecparam -name prime256v1 -genkey -noout -out configs/ec-key.pem
#   openssl ec -in configs/ec-key.pem -pubout -out configs/ec-public.pem
jwt:
  signer:
    method: ES256
    ec_private_key_path: configs/ec-key.pem
    # ec_private_key_data: ""           # alternative: inline PEM string
    issuer: myapp
    audiences:
      - api.myapp.com
    max_lifetime_sec: 86400

  parser:
    method: ES256
    ec_public_key_path: configs/ec-public.pem
    # ec_public_key_data: ""            # alternative: inline PEM string
    audience: api.myapp.com
```

```yaml
# HS256 — symmetric (single-service / internal only)
jwt:
  signer:
    method: HS256
    secret: "${JWT_SECRET}"   # load from env; min 32 chars
    issuer: myapp
    audiences:
      - internal.myapp.com
    max_lifetime_sec: 3600

  parser:
    method: HS256
    secret: "${JWT_SECRET}"
    audience: internal.myapp.com
```

---

## Gin middleware usage

```go
// internal/server/http/middleware/jwt.go

package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	jwtpkg "yourmodule/pkg/jwt"
)

// JWT validates the Bearer token and stores claims in the Gin context.
func JWT(parser jwtpkg.Parser) gin.HandlerFunc {
	return func(c *gin.Context) {
		raw := c.GetHeader("Authorization")
		tokenString := strings.TrimPrefix(raw, "Bearer ")
		if tokenString == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "missing token"})
			return
		}

		claims, err := parser.Parse(tokenString)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			return
		}

		c.Set("claims", claims)
		c.Next()
	}
}

// ClaimsFrom retrieves CustomClaims stored by the JWT middleware.
func ClaimsFrom(c *gin.Context) (*jwtpkg.CustomClaims, bool) {
	v, ok := c.Get("claims")
	if !ok {
		return nil, false
	}
	claims, ok := v.(*jwtpkg.CustomClaims)
	return claims, ok
}
```

```go
// Handler usage — get current user from token

func (h *UserHandler) Profile(c *gin.Context) {
	claims, ok := middleware.ClaimsFrom(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	user, err := jwtpkg.Unmarshal[UserToken](claims)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token decode failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}
```

# Frontend Stack Reference

Full technology matrices for each layer. Read this file when the user needs detailed options beyond the defaults in SKILL.md.

---

## Framework Layer

| Scenario | Recommended | Notes |
|----------|------------|-------|
| SSR + SEO | **Next.js 15** | App Router + RSC; default choice |
| Pure SPA | **React 19 + Vite** | Lightweight, flexible |
| Content / Docs / Blog | **Astro 5** | Zero JS by default; islands architecture |
| Admin dashboard | **React + Vite** or **Next.js** | Pair with Ant Design |
| Full-stack (same repo) | **Remix** | Web standards first; good with tRPC |
| Vue team | **Nuxt 3** | Mirrors Next.js feature set |

---

## Build Tools

| Tool | Score | Use When |
|------|-------|----------|
| **Vite** | ⭐⭐⭐⭐⭐ | Default for standalone SPA / libraries |
| Turbopack | ⭐⭐⭐⭐ | Built into Next.js; no extra config |
| Rspack | ⭐⭐⭐ | Migrating from Webpack with compatibility needs |
| esbuild | ⭐⭐ | CLI tools or pure library bundling only |

---

## Styling

| Approach | When to Use | Notes |
|----------|------------|-------|
| **Tailwind CSS v4** | General default | Utility-first; integrates with shadcn/ui |
| CSS Modules | Component library development | Strong isolation, zero runtime |
| vanilla-extract | Type-safe CSS at build time | Best TypeScript DX |
| styled-components / emotion | Legacy maintenance only | Avoid for new projects |

---

## State Management

| Library | Layer | When to Use |
|---------|-------|-------------|
| **Zustand** | Client global state | Lightweight, no boilerplate; default |
| **TanStack Query v5** | Server / async state | Replaces manual useEffect + fetch |
| Jotai | Atomic client state | Complex dependency graphs, fine-grained reactivity |
| Valtio | Mutable-style state | Small teams preferring proxy model |
| Redux Toolkit | Large legacy teams | Not recommended for new projects |
| Pinia | Vue projects | Vue's equivalent of Zustand |

**Rule**: Never mix server state (TanStack Query) and client state (Zustand) for the same data. Server state lives in Query cache; client state lives in Zustand.

---

## UI Component Libraries

| Library | Style | Best For |
|---------|-------|----------|
| **Ant Design v5** | Enterprise, rich | Default; 60+ production-ready components; Chinese ecosystem |
| **shadcn/ui** | Modern, neutral | High customization; copies code into project (not installed) |
| **Radix UI Primitives** | Unstyled, accessible | When you bring fully custom styles |
| Mantine | Developer-friendly | Quick prototypes; good APIs |
| HeroUI (NextUI v3) | Modern C-end | Polished defaults for consumer apps |
| Arco Design | Enterprise 中台 | ByteDance; Ant Design alternative |

---

## Data Fetching / API Layer

| Library | Protocol | When to Use |
|---------|----------|-------------|
| **TanStack Query v5** | REST | Default for REST; caching, retry, background refetch |
| **Apollo Client** | GraphQL | Enterprise GraphQL; normalized cache |
| **SWR** | REST | Lighter alternative; good with Next.js |
| tRPC | TypeScript RPC | Full-stack TypeScript monorepo |
| **Orval** | REST (OpenAPI) | Auto-generate type-safe client from Go Swagger spec |
| **Hey API** | REST (OpenAPI) | Alternative to Orval; more flexible output |

**For Go backends**: Prioritize Orval or Hey API — point at the Go server's `/swagger.json` to generate a fully-typed client. No hand-written types.

---

## Forms & Validation

| Combo | Recommendation |
|-------|---------------|
| **React Hook Form + Zod** | Default. Best performance; schema reuse across frontend and API boundary |
| TanStack Form + Zod | Emerging; type-safe, framework-agnostic |
| Formik + Yup | Legacy only |

Zod schemas should be defined once and shared:
- Form validation (`useForm` resolver)
- API response parsing (`z.parse`)
- Environment variable typing (`t3-env`)

---

## Testing

| Layer | Tool | Notes |
|-------|------|-------|
| Unit / logic | **Vitest** | Vite-native; Jest-compatible API |
| Component | **Testing Library** | `@testing-library/react` |
| E2E / integration | **Playwright** | Cross-browser; replaces Cypress for new projects |
| Visual regression | Storybook + Chromatic | Optional; for design systems |
| API mocking | **MSW v2** | Mock Service Worker; works in browser + Node |

---

## Code Quality Toolchain

```
ESLint v9          flat config (eslint.config.js); use @antfu/eslint-config or eslint-config-next
Prettier           .prettierrc; disable ESLint formatting rules to avoid conflict
TypeScript         strict: true, noUncheckedIndexedAccess: true
Husky              pre-commit hooks
lint-staged        run ESLint + Prettier only on staged files
```

---

## Monorepo (Team Projects)

| Tool | When | Notes |
|------|------|-------|
| **pnpm workspaces** | Base layer | Always; manages packages |
| **Turborepo** | Default monorepo orchestrator | Incremental builds; Vercel ecosystem |
| Nx | Large enterprise | More features; steeper learning curve |

Structure:
```
apps/
  web/        # Main Next.js app
  admin/      # Admin dashboard
packages/
  ui/         # Shared shadcn/ui components
  utils/      # Shared utilities
  types/      # Shared TypeScript types (aligned with Go domain models)
```

---

## Package Manager Comparison

| Manager | Recommendation |
|---------|---------------|
| **pnpm** | Default. Fastest, strictest, disk-efficient |
| npm | Fallback when pnpm not available |
| yarn berry | Avoid for new projects (PnP compatibility issues) |

---

## Deployment Targets

| Target | Recommended Stack |
|--------|------------------|
| Vercel | Next.js (zero-config) |
| Cloudflare Pages | Next.js (with `@cloudflare/next-on-pages`) or Astro |
| Docker / K8s | Next.js standalone output (`output: 'standalone'`) |
| Static hosting (Nginx) | Vite SPA or Astro static export |
| Electron (desktop) | Vite + Electron Forge |

# Next.js 15 Project Scaffold

Use when: SSR, SEO-required apps, hybrid SPA+SSR, or general-purpose web apps.

## Init

```bash
pnpm create next-app@latest <project-name> \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

cd <project-name>
```

## Add Core Dependencies

```bash
# UI components (Ant Design v5)
pnpm add antd @ant-design/icons
# v5 supports tree-shaking out of the box, no babel plugin needed

# For high-customization projects, use shadcn/ui instead:
# pnpm dlx shadcn@latest init

# State management
pnpm add zustand

# Server state / data fetching
pnpm add @tanstack/react-query
pnpm add -D @tanstack/react-query-devtools

# Forms + validation
pnpm add react-hook-form @hookform/resolvers zod

# HTTP client (optional if using Next.js fetch directly)
pnpm add axios
```

## Add Dev Tooling

```bash
# Husky + lint-staged for pre-commit hooks
pnpm add -D husky lint-staged
pnpm exec husky init
echo "pnpm lint-staged" > .husky/pre-commit

# Add to package.json:
# "lint-staged": {
#   "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
#   "*.{json,md,css}": ["prettier --write"]
# }
```

## Add Testing

```bash
pnpm add -D vitest @vitejs/plugin-react jsdom
pnpm add -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
pnpm add -D @playwright/test
pnpm exec playwright install
```

`vitest.config.ts`:
```ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

## Add OpenAPI Client (for Go backend)

```bash
pnpm add -D orval
```

`orval.config.ts`:
```ts
import { defineConfig } from 'orval'

export default defineConfig({
  api: {
    input: 'http://localhost:8080/swagger.json', // Go server swagger endpoint
    output: {
      mode: 'tags-split',
      target: 'src/shared/api/generated',
      client: 'react-query',
      baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL,
    },
  },
})
```

## Recommended tsconfig.json Additions

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

## Directory Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── (auth)/             # Route groups
│   ├── layout.tsx
│   └── page.tsx
├── features/               # Feature modules
│   └── user/
│       ├── ui/             # Feature-specific components
│       ├── model/          # Zustand store slice
│       └── api/            # TanStack Query hooks
├── shared/
│   ├── ui/                 # shadcn/ui components
│   ├── api/                # Generated clients + base config
│   ├── lib/                # Utility functions
│   ├── hooks/              # Shared hooks
│   └── types/              # Shared TypeScript types
└── entities/               # Domain models (mirrors Go domain layer)
```

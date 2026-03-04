# Vite SPA Project Scaffold

Use when: Pure SPA, admin dashboard, no SSR requirement, or when Next.js is overkill.

## Init

```bash
pnpm create vite@latest <project-name> -- --template react-ts
cd <project-name>
pnpm install
```

## Configure Path Aliases

`vite.config.ts`:
```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
})
```

`tsconfig.json` (add under `compilerOptions`):
```json
{
  "baseUrl": ".",
  "paths": { "@/*": ["./src/*"] },
  "strict": true,
  "noUncheckedIndexedAccess": true
}
```

## Add Core Dependencies

```bash
# Routing
pnpm add @tanstack/react-router
# or: pnpm add react-router-dom

# Styling
pnpm add -D tailwindcss @tailwindcss/vite
# Add to vite.config.ts plugins: tailwindcss()
# Create src/index.css with: @import "tailwindcss";

# UI components (Ant Design v5)
pnpm add antd @ant-design/icons
# v5 supports tree-shaking out of the box, no babel plugin needed

# State
pnpm add zustand

# Server state
pnpm add @tanstack/react-query
pnpm add -D @tanstack/react-query-devtools

# Forms + validation
pnpm add react-hook-form @hookform/resolvers zod

# HTTP
pnpm add axios
```

## For High-Customization Projects (use shadcn/ui instead)

```bash
# Remove antd, add shadcn/ui (copies component source into your project)
pnpm dlx shadcn@latest init
pnpm dlx shadcn@latest add button input label card dialog form
```

## Add Testing

```bash
pnpm add -D vitest jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom
pnpm add -D @playwright/test && pnpm exec playwright install
```

`vite.config.ts` (add test config):
```ts
/// <reference types="vitest" />
export default defineConfig({
  // ...existing config
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
  },
})
```

## Add Dev Tooling

```bash
pnpm add -D husky lint-staged prettier eslint
pnpm exec husky init
echo "pnpm lint-staged" > .husky/pre-commit
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
    input: 'http://localhost:8080/swagger.json',
    output: {
      mode: 'tags-split',
      target: 'src/shared/api/generated',
      client: 'react-query',
      baseUrl: import.meta.env.VITE_API_BASE_URL,
    },
  },
})
```

## Directory Structure

```
src/
├── main.tsx
├── App.tsx
├── features/
│   └── dashboard/
│       ├── ui/
│       ├── model/
│       └── api/
├── shared/
│   ├── ui/
│   ├── api/
│   ├── lib/
│   └── types/
├── pages/               # Route-level components
└── entities/
```

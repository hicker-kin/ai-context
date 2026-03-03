# Astro 5 Project Scaffold

Use when: Content sites, blogs, documentation, landing pages, marketing pages.  
Key feature: Zero JS by default; add interactivity only where needed (islands).

## Init

```bash
pnpm create astro@latest <project-name>
# Choose: Empty project (or Blog template for content sites)
# TypeScript: Strict
cd <project-name>
pnpm install
```

## Add Integrations

```bash
# Tailwind CSS
pnpm astro add tailwind

# React islands (for interactive components)
pnpm astro add react

# MDX (for content with components)
pnpm astro add mdx

# Sitemap (for SEO)
pnpm astro add sitemap
```

## Add Styling & Components

```bash
# shadcn/ui (works in React island components)
pnpm dlx shadcn@latest init
```

## For Documentation Sites

```bash
# Starlight (Astro's official docs theme)
pnpm create astro@latest --template starlight
```

## Directory Structure

```
src/
├── components/        # Astro components (.astro) + React islands (.tsx)
├── layouts/           # Page layouts
├── pages/             # File-based routing (.astro, .md, .mdx)
│   ├── index.astro
│   └── blog/
│       └── [slug].astro
├── content/           # Content collections (type-safe markdown/MDX)
│   └── blog/
│       └── post-1.md
└── styles/
    └── global.css
```

## Content Collections (Type-safe content)

`src/content/config.ts`:
```ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    publishDate: z.date(),
    description: z.string(),
    tags: z.array(z.string()).default([]),
  }),
})

export const collections = { blog }
```

## Deploy Adapters

```bash
# Vercel
pnpm astro add vercel

# Cloudflare Pages
pnpm astro add cloudflare

# Static export (default, no adapter needed)
# output: 'static' in astro.config.mjs
```

## astro.config.mjs

```js
import { defineConfig } from 'astro/config'
import tailwind from '@astrojs/tailwind'
import react from '@astrojs/react'
import mdx from '@astrojs/mdx'
import sitemap from '@astrojs/sitemap'

export default defineConfig({
  site: 'https://your-domain.com',
  integrations: [tailwind(), react(), mdx(), sitemap()],
})
```

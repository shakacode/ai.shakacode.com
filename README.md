# ShakaCode AI Strategy

Published at [ai.shakacode.com](https://ai.shakacode.com)

How ShakaCode approaches AI-assisted development: our governance model, industry research, and open-source tooling.

## Articles

- **[Codex Desktop App: Projects, Worktrees, Threads, and Cleanup](https://ai.shakacode.com/codex-desktop-projects-worktrees-cleanup)** — A practical guide to the Codex desktop app model: when to create new projects, when to reuse them, and how auto-cleanup works.
- **[The Executive Chef Model](https://ai.shakacode.com/executive-chef-model)** — How we govern AI-assisted development. Every engineer is an executive chef: use whatever AI tools you want, you own what you ship.
- **[How 10 Companies Are Governing AI-Assisted Development in 2026](https://ai.shakacode.com/industry-survey)** — A survey of AI policies across Shopify, Meta, GitLab, Anthropic, Google/DORA, Amazon, and others.

## Related

Our AI development toolkit is a separate repo: [shakacode/claude-code-commands-skills-agents](https://github.com/shakacode/claude-code-commands-skills-agents). It includes the slash commands, agents, templates, and GitHub Actions that implement the philosophy described here.

## Contributing

This is an open-source repo. If you disagree with something, think we're missing something, or want to share how your team handles AI governance — open a PR or start a discussion.

We're especially interested in:
- How other teams are implementing governance frameworks
- Research we should be citing
- Practical tooling and workflow improvements
- Corrections or clarifications

## Development

This site is built with [Astro](https://astro.build/) and deployed to [Cloudflare Pages](https://pages.cloudflare.com/).

```bash
npm install
npm run dev      # Local dev server at localhost:4321
npm run build    # Build to ./dist
npm run preview  # Preview production build
```

## Deployment

Merging to `main` triggers an automatic build and deploy to Cloudflare Pages. The site publishes to [ai.shakacode.com](https://ai.shakacode.com).

### Connecting this repo to Cloudflare Pages

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
2. Select the **shakacode/ai-strategy** repository and authorize access
3. Configure the build settings:
   - **Project name:** `ai-strategy`
   - **Production branch:** `main`
   - **Framework preset:** Astro
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
4. Under **Environment variables**, add: `NODE_VERSION` = `22`
5. Click **Save and Deploy** — Cloudflare will build and publish the site
6. To use a custom domain (`ai.shakacode.com`): go to **Custom domains** in the Pages project settings, add `ai.shakacode.com`, and create the CNAME record it provides in your DNS

## About ShakaCode

[ShakaCode](https://shakacode.com) is a consultancy specializing in AI-augmented Ruby on Rails and React development. We're the company behind [React on Rails](https://github.com/shakacode/react_on_rails) and the ShakaCode open-source ecosystem.

If your team is navigating AI-assisted development and could use experienced partners, [reach out](https://shakacode.com).

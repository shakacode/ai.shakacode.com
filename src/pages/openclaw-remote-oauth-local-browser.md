---
layout: ../layouts/Article.astro
title: "The One SSH Alias That Makes Remote OpenClaw OAuth Actually Work"
description: "How to complete OpenClaw's browser-based OAuth on a headless VPS using a dedicated SSH alias with local port forwarding."
author: "Justin Gordon, CEO of ShakaCode"
date: "April 2026"
---

I spent an embarrassing amount of time staring at a browser callback error before I figured this out.

I run [OpenClaw](https://github.com/nicepkg/openclaw) on a headless VPS. Codex login was fine — `codex login --device-auth` gives you a URL and a one-time code, you type it into your local browser, done. But OpenClaw's OpenAI Codex OAuth flow is different. It wants to complete a browser redirect back to `127.0.0.1:1455` on the machine running OpenClaw. My browser is on my Mac. OpenClaw is on the VPS. That callback has nowhere to go.

The fix turned out to be one SSH alias. Here's the whole story.

## Two Auth Flows, Two Different Problems

This is the distinction that tripped me up. Not all remote auth flows work the same way:

<figure class="diagram-card">
  <img
    src="/articles/openclaw-remote-oauth-local-browser/auth-flows.svg"
    alt="Comparison of device code flow (works anywhere) versus OAuth redirect flow (needs localhost callback)."
  />
  <figcaption>
    <strong>Two flows, two problems:</strong> device-code auth doesn't care where your browser is. OAuth redirect auth <strong>does</strong> — it needs a callback URL that actually reaches the process that started the flow.
  </figcaption>
</figure>

<details class="diagram-source">
  <summary>View Mermaid source</summary>
  <pre><code class="language-mermaid">flowchart TB
    subgraph device["Device Code Flow (codex login)"]
        direction LR
        D1["CLI shows URL + code"] --&gt; D2["You open URL in&lt;br&gt;any browser, anywhere"]
        D2 --&gt; D3["Type the code"]
        D3 --&gt; D4["CLI polls and picks&lt;br&gt;up the token ✓"]
    end

    subgraph oauth["OAuth Redirect Flow (OpenClaw)"]
        direction LR
        O1["CLI opens OAuth URL"] --&gt; O2["You log in via browser"]
        O2 --&gt; O3["Browser redirects to&lt;br&gt;127.0.0.1:1455/callback"]
        O3 --&gt; O4["❌ Nothing is listening&lt;br&gt;on your Mac's port 1455"]
    end

    style device fill:#e8f5e9,stroke:#43a047
    style oauth fill:#fff3e0,stroke:#ef6c00</code></pre>
</details>

On a headless VPS, that's a problem.

## What My Normal SSH Alias Looks Like

My day-to-day alias drops me straight into a persistent tmux session on the VPS:

```zsh
alias jack='echo -ne "\033]0;Jack (OpenClaw Droplet)\007" && ssh -t -i ~/.ssh/vps_ed25519 user@203.0.113.10 "tmux -CC attach -t work || tmux -CC new -s work"'
```

It's great for regular work:

- drops me right in
- reconnects to my persistent tmux session
- keeps long-running agents alive if my connection drops

But it does **not** forward the OAuth callback port. So when OpenClaw started the browser-based OAuth flow, my local browser had nowhere to send the callback. I could start the flow, but I couldn't complete it.

## My First Instinct Was Wrong

My first move was to bolt `-L 1455:127.0.0.1:1455` onto the regular `jack` alias. It worked! But it created a mess:

- my normal shell session now carried a hidden auth tunnel I'd forget about
- if that session was attached to a persistent tmux session, the tunnel just lived there indefinitely
- I started getting tmux sessions named `work`, `work2`, `work-auth` and lost track of which was which

That's the wrong mental model. Auth should be temporary. Start it, finish the flow, verify it worked, close it.

## The Clean Fix: A Separate Auth Alias

```zsh
alias jack-auth='echo -ne "\033]0;Jack (OpenClaw Auth)\007" && ssh -L 1455:127.0.0.1:1455 -i ~/.ssh/vps_ed25519 user@203.0.113.10'
```

One extra alias. That's it.

<figure class="diagram-card">
  <img
    src="/articles/openclaw-remote-oauth-local-browser/tunnel-flow.svg"
    alt="SSH tunnel flow showing how port 1455 on the Mac is forwarded to port 1455 on the VPS through the SSH connection."
  />
  <figcaption>
    <strong>The tunnel trick:</strong> without port forwarding, your browser only sees <code>127.0.0.1</code> as <strong>your Mac</strong>. With <code>ssh -L 1455:127.0.0.1:1455</code>, your Mac pretends port 1455 is local, but SSH quietly carries that traffic to the remote OpenClaw process on the VPS.
  </figcaption>
</figure>

<details class="diagram-source">
  <summary>View Mermaid source</summary>
  <pre><code class="language-mermaid">flowchart LR
    A["OpenClaw on VPS&lt;br&gt;listening on&lt;br&gt;127.0.0.1:1455"] --&gt;|"SSH tunnel&lt;br&gt;-L 1455:127.0.0.1:1455"| B["Your Mac&lt;br&gt;port 1455 forwarded"]
    B --&gt; C["Browser opens&lt;br&gt;OAuth URL"]
    C --&gt; D["Browser redirects to&lt;br&gt;http://127.0.0.1:1455/callback"]
    D --&gt;|"traffic flows through&lt;br&gt;SSH tunnel"| A

    style A fill:#e3f2fd,stroke:#1565c0
    style B fill:#f3e5f5,stroke:#7b1fa2
    style D fill:#e8f5e9,stroke:#2e7d32</code></pre>
</details>

That's the whole trick. No special OpenClaw magic. Just SSH local port forwarding.

## The Two-Alias Setup

Here's what I keep in my shell config:

```zsh
# Day-to-day work — persistent tmux, no port forwarding
alias jack='echo -ne "\033]0;Jack (OpenClaw Droplet)\007" && ssh -t -i ~/.ssh/vps_ed25519 user@203.0.113.10 "tmux -CC attach -t work || tmux -CC new -s work"'

# Temporary OAuth tunnel — port forwarding, no tmux
alias jack-auth='echo -ne "\033]0;Jack (OpenClaw Auth)\007" && ssh -L 1455:127.0.0.1:1455 -i ~/.ssh/vps_ed25519 user@203.0.113.10'
```

If `~/.ssh/vps_ed25519` isn't your key path, the quickest ways to find yours:

- already have a working alias? run `alias jack` and check the `-i` argument
- use `~/.ssh/config`? run `ssh -G jack | rg '^identityfile '`
- just want to see what keys exist? run `ls ~/.ssh`

The key difference between the two aliases:

| | `jack` | `jack-auth` |
|---|---|---|
| **Purpose** | Day-to-day work | OAuth login flow |
| **tmux** | Yes, persistent session | No |
| **Port forwarding** | No | Yes, port 1455 |
| **Lifetime** | Long-lived | Temporary — close after auth |
| **When to use** | Any time you need a shell | Only when OpenClaw needs browser OAuth |

The important part: `jack-auth` intentionally does **not** use tmux. For a one-off login flow, you don't want persistent state. You want a clean shell, a live tunnel, a successful auth, and then an exit.

## The Login Flow Step by Step

When OpenClaw needs browser-based OAuth on the VPS:

<figure class="diagram-card">
  <img
    src="/articles/openclaw-remote-oauth-local-browser/login-sequence.svg"
    alt="Sequence diagram showing the step-by-step OAuth login flow through the SSH tunnel."
  />
  <figcaption>
    <strong>The full flow:</strong> open the auth tunnel, start the OAuth flow on the VPS, complete it in your local browser, verify the token, then close the tunnel immediately.
  </figcaption>
</figure>

<details class="diagram-source">
  <summary>View Mermaid source</summary>
  <pre><code class="language-mermaid">sequenceDiagram
    participant Mac as Your Mac
    participant SSH as SSH Tunnel
    participant VPS as VPS (OpenClaw)
    participant Browser as Local Browser

    Mac-&gt;&gt;SSH: jack-auth (opens tunnel on port 1455)
    Mac-&gt;&gt;VPS: openclaw models auth login&lt;br&gt;--provider openai-codex --set-default
    VPS--&gt;&gt;Mac: Auth URL printed to terminal
    Mac-&gt;&gt;Browser: Open the URL
    Browser-&gt;&gt;Browser: Log in to OpenAI
    Browser-&gt;&gt;SSH: Redirect to 127.0.0.1:1455/callback
    SSH-&gt;&gt;VPS: Forward callback through tunnel
    VPS--&gt;&gt;VPS: Token stored ✓
    Mac-&gt;&gt;VPS: openclaw models status (verify)
    Mac-&gt;&gt;SSH: Exit jack-auth session</code></pre>
</details>

In practice:

1. On your Mac, run `jack-auth`
2. In that SSH session, start the auth flow:

```bash
openclaw models auth login --provider openai-codex --set-default
```

Or if you're in the full setup wizard: `openclaw onboard`

3. Open the auth URL in your local browser
4. Let the browser complete the redirect to `http://127.0.0.1:1455/...`
5. Verify login on the VPS:

```bash
openclaw models status
```

6. **Close the `jack-auth` terminal immediately.** Don't minimize it. Don't switch to another tab and forget about it. Close it.

Go back to the normal `jack` alias for regular work.

## When You Don't Need `jack-auth`

This is the part that's easy to overuse.

You do **not** need the port-forwarding alias for device-code flows like:

```bash
codex login --device-auth
```

Device-code auth doesn't need a localhost callback. The CLI gives you a URL and code to enter manually. Your local browser is just a browser — it doesn't need to talk back to the VPS on port 1455.

You specifically need `jack-auth` for flows that expect a browser callback to a process listening on the VPS loopback interface. That's why this came up with OpenClaw OAuth and not with Codex device auth.

## Why This Matters More for OpenAI Than Claude Right Now

There's also a provider-policy reason this setup matters.

OpenClaw's current docs say OpenAI Codex OAuth is explicitly supported for use in external tools like OpenClaw. That makes this alias-and-tunnel pattern a practical way to keep using subscription-style access from a remote gateway host.

Anthropic's story is different. As of April 4, 2026, Anthropic told OpenClaw users that the OpenClaw Claude-login path is treated as third-party harness traffic and requires Extra Usage billed separately from included Claude subscription limits.

That's an important nuance. Anthropic didn't remove the path technically — OpenClaw can still reuse Claude CLI login, and legacy setup-token flows still exist. But the billing posture changed. The safe assumption is no longer "this is covered by my normal Claude subscription."

In practice:

- **For subscription-style external-tool access**: OpenAI Codex is currently the clearer fit in OpenClaw
- **For Claude with OpenClaw**: expect Anthropic API key billing or Extra Usage requirements
- **For production workloads**: OpenClaw recommends Anthropic API key auth as the safer path

That's the real motivation for switching some OpenClaw setups to OpenAI Codex OAuth. The issue isn't model preference. The issue is that the provider policy changed, and the old mental model of "my regular Claude subscription covers this" is no longer safe.

The annoying part: the switch is conceptually simple but operationally awkward on a headless VPS. On a laptop, browser OAuth is routine. On a headless VPS, there's no browser, and the OAuth flow still wants a callback to `127.0.0.1:1455` on that machine. That's why this feels harder than it should.

<figure class="diagram-card">
  <img
    src="/articles/openclaw-remote-oauth-local-browser/headless-gap.svg"
    alt="Diagram showing the headless VPS gap and how jack-auth bridges it with SSH port forwarding."
  />
  <figcaption>
    <strong>The gap and the fix:</strong> <code>jack-auth</code> bridges the disconnect between your local browser and the remote OpenClaw process by forwarding port 1455 through the SSH connection.
  </figcaption>
</figure>

<details class="diagram-source">
  <summary>View Mermaid source</summary>
  <pre><code class="language-mermaid">flowchart TB
    subgraph gap["The Headless VPS Gap"]
        direction TB
        G1["OpenClaw running on VPS&lt;br&gt;(no browser)"]
        G2["OAuth needs browser callback&lt;br&gt;to 127.0.0.1:1455"]
        G3["Your browser is on your Mac&lt;br&gt;(different machine)"]
        G1 --- G2 --- G3
    end

    subgraph fix["jack-auth Bridges It"]
        direction TB
        F1["SSH -L 1455:127.0.0.1:1455"]
        F2["Mac port 1455 → VPS port 1455"]
        F3["Browser callback lands&lt;br&gt;on the right machine ✓"]
        F1 --- F2 --- F3
    end

    gap --&gt; fix

    style gap fill:#fff3e0,stroke:#ef6c00
    style fix fill:#e8f5e9,stroke:#2e7d32</code></pre>
</details>

## Seriously, Close That Auth Terminal

I cannot stress this enough. Once OAuth succeeds, **close `jack-auth` immediately.**

OpenClaw stores the resulting credentials on the VPS. The tunnel has done its job. But if you leave that session open — and you will, because it looks like any other terminal — here's what happens three days later:

- you have four terminal tabs open to the same VPS
- one of them is silently forwarding port 1455 and you don't remember which
- you try to open a *new* `jack-auth` session and get `bind: Address already in use`
- you can't figure out what's holding the port
- you start killing SSH sessions at random
- you accidentally kill your working tmux session

Ask me how I know.

The right lifecycle is exactly four steps:

1. Start `jack-auth`
2. Complete auth
3. Verify auth worked (`openclaw models status`)
4. **Close `jack-auth` right now, not later**

The tunnel is dead weight the moment the token is stored. Treat it like scaffolding — take it down as soon as the wall is up.

## The Rule of Thumb

- Doing normal work on the box? **`jack`**
- Doing a remote OAuth flow that needs your local browser to callback into the VPS? **`jack-auth`**
- Auth done? **Close `jack-auth`. Now. Not in five minutes. Now.**

That one separation — and the discipline to actually close the auth session — made the whole setup feel obvious instead of mysterious.

Aloha,
Justin

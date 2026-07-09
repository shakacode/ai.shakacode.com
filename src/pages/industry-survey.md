---
layout: ../layouts/Article.astro
title: "How 10 Companies Are Governing AI-Assisted Development in 2026"
description: "From Shopify's mandate to GitLab's playbook — what engineering leaders can learn from the industry's AI governance experiments"
author: "Justin Gordon, CEO of ShakaCode"
date: "February 2026"
---

This is a test.


If you lead an engineering team in 2026, you've probably noticed: everyone's using AI coding tools, but nobody agrees on how to govern them.

Some companies are mandating AI usage in performance reviews. Others are firing engineers who don't adopt. Others are publishing careful, evolving guidelines. And most are somewhere in between—figuring it out as they go, hoping they don't break too much along the way.

We surveyed the public policies, leadership statements, and published research from 10 companies and one major research program to understand the current landscape. Here's what we found—and what engineering leaders should take from it.

## The Governance Spectrum

The approaches fall on a clear spectrum from coercive to cultural:

| Company | Approach | AI Mandatory? | Key Mechanism |
|---------|----------|---------------|---------------|
| Coinbase | Coercive | Yes (fired engineers) | Usage targets (50% AI code) |
| Meta | Mandate | Yes | Performance reviews (2026) |
| Shopify | Mandate | Yes | Headcount gating + 360 reviews |
| Microsoft | Structural | Implicit | $80B+ infrastructure investment |
| Amazon | Framework | Optional | Sandboxing + approval gates |
| GitLab | Governance | Optional | ISO 42001 + model selection |
| Atlassian | Principles | Optional | HULA framework + EU AI Pact |
| Anthropic | Cultural | Encouraged | Research-informed transparency |

## The Mandate Camp: Shopify, Meta, and Coinbase

**Shopify** set the tone in March 2025 when CEO Tobi Lütke declared AI usage a "fundamental expectation." Teams must demonstrate why AI can't do the work before requesting headcount. AI proficiency is evaluated in 360-degree reviews. The company aims for 90–95% AI usage while retaining manual review skills.

**Meta** went further: starting 2026, all employees are formally evaluated on "AI-driven impact." Mark Zuckerberg stated the company will begin automating midlevel engineering roles. They're backing it with $66–72 billion in AI compute infrastructure for 2025 alone.

**Coinbase** took the most aggressive action: engineers who refused to adopt Cursor and Copilot were let go. The company set an explicit target of 50% AI-written code.

**The upside:** These approaches generate fast adoption and send a clear organizational signal. **The risk:** They incentivize AI usage even when it's the wrong tool, can damage engineering culture, and conflate adoption with quality. When people are evaluated on *whether* they use AI rather than *what they ship*, you optimize for the wrong thing.

## The Framework Camp: GitLab, Amazon, and Atlassian

**GitLab** has the most comprehensive publicly documented approach. Their five-phase AI development playbook (Prepare, Develop, Test/Evaluate, Launch, Improve) provides structured process without mandating tool usage. They achieved ISO/IEC 42001 certification—the international AI management standard—and provide granular controls: admins select which AI models power different features, teams can exclude sensitive files from AI context, and agents are treated as privileged identities linked to human operators for accountability.

GitLab's CTO frames what they call the "AI paradox": coding is only 20% of developer time, so optimizing code generation alone is insufficient. Their strategy addresses the other 80%—meetings, tests, documentation, coordination—through specialized agents.

**Amazon** provides tools and governance without mandates. Their Kiro agent can operate autonomously for hours but requires developer approval before merging. AgentCore lets developers set boundaries with three network access levels, sandboxing, and comprehensive logging. The philosophy: "tool and framework first, mandate never."

**Atlassian** developed their HULA (Human-in-the-Loop Automation) framework—the name itself is their philosophy. A central AI team builds shared infrastructure while product teams make their own AI-driven decisions. They joined the EU AI Pact and published Responsible Technology Principles.

**The upside:** Preserves engineering autonomy and judgment. Engineers adopt at their own pace based on what actually helps. **The risk:** Adoption may be uneven. Without clear expectations, some teams may fall behind while others move ahead.

## The Research-Informed Camp: Anthropic and Google DORA

**Anthropic** encourages its people to use AI "as aggressively as possible" but pairs this with unusual transparency about the trade-offs. Their published research acknowledges that AI has the least productivity gains for design and planning tasks, and that passive delegation degrades engineering skills. The key finding: engineers who actively engage with AI output—questioning, debugging, understanding—retain and sharpen their skills. Those who just accept what AI produces lose them.

**Google's DORA program** provides the most rigorous empirical data. Their 2025 report's headline finding: **"AI doesn't fix a team; it amplifies what's already there."** Teams with strong practices get stronger. Teams with weak foundations get worse. DORA identifies seven capabilities that predict positive AI outcomes, with "working in small batches" and "organizational learning culture" among the most critical. They also found that 30% of developers still have little or no trust in AI-generated code—reinforcing the need for human review.

**The upside:** Grounded in evidence rather than hype or fear. Provides actionable guidance. **The implication:** Investing in engineering discipline is not competing with AI adoption—it's the prerequisite for making it work.

## Five Lessons for Engineering Leaders

1. **AI proficiency is becoming table stakes.** No serious company is treating AI tools as optional. The question is not whether to adopt—it's how to adopt well. Whether through mandate, framework, or culture, every company surveyed is pushing engineers toward AI proficiency.

2. **Human review is non-negotiable.** Every company that addresses code quality—Amazon, GitLab, Atlassian, DORA—requires human review of AI output before it ships. Even Shopify, pushing 90–95% AI usage, requires review skills. Amazon's agents need human approval before merging. Atlassian named their framework "Human-in-the-Loop." The consensus is clear: AI writes code, humans decide whether it ships.

3. **Strong foundations amplify AI's benefits.** DORA's amplification finding is the most important insight in the landscape. Good testing, version control, small batches, and fast feedback loops aren't things you trade away for AI speed—they're what make AI speed safe. Companies cutting engineering corners to "adopt AI faster" are going in the wrong direction.

4. **Active engagement beats passive delegation.** Anthropic's research confirms what experienced engineers feel intuitively: using AI well requires more skill, not less. Engineers who question AI output, debug it, and understand its choices get better. Those who copy-paste lose their edge. The best AI governance frameworks encourage active engagement, not just adoption.

5. **Evolving guidelines beat rigid rules.** AI capabilities change every few months. GitLab publishes evolving guidelines rather than fixed policies. Anthropic iterates based on internal research. The companies with rigid, static AI rules will find them outdated almost immediately. The best approach: publish, gather feedback, refine, repeat.

## Where This Is Heading

The industry consensus is unmistakable: AI-assisted development is the present. Every company surveyed is either mandating it, building infrastructure for it, or researching how to do it well. The differentiator is governance quality—the companies that adopt aggressively *and* govern thoughtfully will outperform those that do only one or the other.

At ShakaCode, we've found that the answer isn't mandates or metrics. It's a framework we call the **Executive Chef Model**: every engineer owns what they ship, uses whatever tools they choose, and applies professional judgment to match rigor to risk. It's backed by DORA's evidence, informed by Anthropic's research, and battle-tested in production.

The companies that thrive in this era will be the ones that figure out the right balance between speed and discipline. Based on what we're seeing, the answer looks less like Coinbase and more like DORA: invest in your engineering foundation, give your best people autonomy, and let AI amplify what's already strong.

---

**Sources:** Shopify CEO memo (March 2025), Pragmatic Engineer coverage, Meta performance review policy (WinBuzzer, Feb 2026), Coinbase CEO AI mandate, Anthropic "How AI Is Transforming Work" research, Google DORA 2025 State of DevOps and AI reports, Amazon re:Invent 2025, GitLab AI Feature Development Playbook and ISO 42001 certification, GitLab AI Transparency Center, Microsoft/GitHub organizational restructuring, Atlassian HULA framework.

*Justin Gordon is the CEO of ShakaCode, a consultancy specializing in AI-augmented Ruby on Rails and React development. ShakaCode builds HiChee and ShakaFlow, and maintains the React on Rails open-source ecosystem.*

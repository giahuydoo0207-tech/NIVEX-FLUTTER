# Nova Mobile (NIVEX Flutter)

Nova Mobile is the freelancer-facing Flutter prototype for Nova, a professional social marketplace that connects Vietnamese freelancers with international businesses through profiles, community content, jobs, portfolios, messaging, invoices, and cross-border payment concepts.

The repository is still named `NIVEX-FLUTTER` during the transition from the original NIVEX brand to Nova.

> **Prototype status:** This mobile app is a UI demo with local/demo data. Solana, USDC, wallet, invoice, and payment screens are product simulations only. The app does not submit on-chain transactions, custody funds, convert USDC to VND, or process real payouts.

## Product Direction

Nova is no longer only a jobs and payments prototype. The current direction combines three product layers:

- A professional social network for freelancers and businesses.
- A freelance marketplace for jobs, portfolios, business opportunities, and applications.
- A cross-border payment layer for USDC payment requests, invoices, wallet history, and settlement concepts.

The mobile app focuses on the freelancer experience first: building reputation, publishing work, discovering jobs, interacting with businesses, and reviewing payment-related states in a safe demo environment.

## User Role

Nova Mobile currently represents the **Freelancer** role.

Freelancers can:

- Build a professional profile.
- Publish personal progress posts.
- Publish product or portfolio posts.
- Attach images and hashtags.
- Browse a mixed community feed.
- React, comment, reply, save, hide, and pin posts.
- View public freelancer and business profiles.
- Follow profiles during the session.
- Discover jobs and inspect job details.
- Simulate application, invoice, wallet, and payment request flows.

## Companion Business Portal

The organization-facing web portal lives in [NIVEX Business](https://github.com/giahuydoo0207-tech/NIVEX-BUSINESS).

The two products should eventually share the same backend contracts, but the current milestone prioritizes:

1. Completing the mobile UI demo.
2. Completing the business web UI demo.
3. Finalizing backend core design, ERD, API contracts, and local migrations.

## Current Mobile Features

- Authentication, registration, session lock, biometric unlock, and demo PIN flows.
- Freelancer profile, public profile, professional profile, portfolio, skills, reputation entry point, and activity tabs.
- Community feed with personal posts, product/portfolio posts, business posts, and jobs.
- Shared post composer with image selection, preview, hashtag input, and gallery layouts.
- Facebook/LinkedIn-style media grid for multiple images, overlay count, and fullscreen image viewer.
- Post options for owner and viewer contexts.
- My Posts screen with posted, saved, and hidden tabs.
- Reaction, comment, and reply UI patterns for demo social interaction.
- Job discovery, saved jobs, job detail, and simulated application states.
- Wallet, receive, payment request, invoice, transaction, and cashout concept screens.
- Four visual themes and mobile-first layouts.

## Content Model

Nova content is organized around four primary feed item types:

| Content type | Created by | Purpose | Primary CTA |
| --- | --- | --- | --- |
| Personal post | Freelancer | Share progress, thoughts, updates, and work moments | View profile |
| Product / portfolio post | Freelancer | Showcase finished work, case studies, prototypes, and products | View product |
| Business post | Business | Share company updates, events, hiring news, and announcements | View company |
| Job post | Business | Publish freelance or remote opportunities | View job |

The mobile `+` creation flow should support the freelancer side first:

- **Personal post**
- **Product / portfolio**

The business web `+` flow should support:

- **Business post**
- **Job**

Both sides should eventually use the same backend content primitives where possible.

## Feed Rules

The community feed should feel closer to Facebook and LinkedIn than a simple job board.

- A feed can contain personal posts, product posts, business posts, and job posts together.
- Images should preserve a polished layout in the feed and open full-size in a viewer.
- Multiple images should use a social-style grid with a `+N` overlay when needed.
- Owner actions and viewer actions must be different.
- Public reputation should not be displayed as an obvious avatar ring or public hierarchy marker. Reputation details belong inside the profile/reputation section for users who choose to inspect them.

## Hashtags

Hashtags are a discovery layer, not a replacement for skills.

Rules:

- Maximum 5 hashtags per post.
- No duplicates after normalization.
- Normalize casing and spacing.
- Hashtags can be used for feed discovery and topic grouping.
- Skill tags remain separate from hashtags and belong to the profile/job matching layer.

## Payment And Solana Scope

Current payment-related screens are demo-only.

In scope for this prototype:

- Wallet UI.
- Transaction history UI.
- Invoice and payment request mock screens.
- USDC amount formatting.
- Receive/payment address demo states.
- Local proof-of-concept flows.

Out of scope before the current milestone:

- Solana Mainnet.
- Real USDC transfer.
- Real custody.
- Real bank payout.
- KYC/AML production flow.
- Custom Solana Program.
- Production treasury operations.

## Architecture

The Flutter app is organized around feature folders and demo controllers.

Important areas:

- `lib/features/auth`
- `lib/features/home`
- `lib/features/jobs`
- `lib/features/posts`
- `lib/features/profile`
- `lib/features/wallet`
- `lib/features/theme`

The current product work should stay small and focused:

- Avoid broad refactors.
- Preserve existing file structure unless a focused UI task requires a local widget.
- Keep mobile UI work separate from backend production infrastructure.
- Do not introduce Kubernetes, Kafka, microservices, or complex CI/CD for this milestone.

## Backend Direction

The future backend should support:

- Auth
- Users
- Organizations
- Freelancer profiles
- Business profiles
- Jobs
- Applications
- Posts
- Post media
- Hashtags
- Comments
- Reactions
- Messaging
- Files
- Invoices
- Payment requests
- Wallets
- Deposits
- Ledger
- Withdrawals
- Notifications
- Audit events
- Moderation

Expected backend artifacts for the current milestone:

- ERD
- Data dictionary
- API contract
- State machines
- Flyway migrations if schema work has started
- Minimal `docker-compose.yml` for PostgreSQL if backend work has started
- `.env.example`
- Local setup README

## Project Status

The current priority is a strong demo foundation:

1. Finish mobile UI demo for freelancers.
2. Finish web UI demo for businesses.
3. Align user flows between mobile and web.
4. Finalize backend core design.
5. Finalize API contracts.
6. Add local setup and basic tests for implemented pieces.

Production DevOps work is intentionally deferred.

## Getting Started

Install Flutter and run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Build a debug APK:

```bash
flutter build apk --debug
```

## Safety Notes

- Do not treat demo balances, invoices, jobs, or wallet addresses as real financial data.
- Do not add production payout, custody, or Mainnet behavior without a separate product and security review.
- Do not expose reputation as a public class marker around avatars; keep it discoverable inside profile/reputation views.
- Keep changes scoped and verify with format, analyze, and relevant tests.

## Author

Nova is developed as a prototype by [Gia Huy Do](https://github.com/giahuydoo0207-tech).

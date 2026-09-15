# NIVEX

NIVEX is a Flutter MVP that explores a recipient-facing experience for USDC payments, remote work opportunities, and simulated USDC-to-VND cashout in Vietnam.

> **Prototype status:** The current build uses demo data and Solana Devnet labels. It does not submit on-chain transactions or transfer real USDC or VND.

## Overview

NIVEX explores how a remote worker could receive a USDC payment request, inspect wallet activity, and review a local-currency cashout quote from one mobile interface. The project focuses on clear payment states, precise USDC amount handling, authentication UX, and explicit separation between implemented UI and future financial infrastructure.

The companion [NIVEX Business](https://github.com/giahuydoo0207-tech/NIVEX-BUSINESS) portal represents the organization-facing side of the concept.

## Screenshots

Project screenshots have not yet been committed to this repository. This section is intentionally left as a placeholder until screenshots from the current Flutter build are added.

## Implemented Features

- Login and registration flows with form validation.
- On-device biometric authentication through the platform biometric prompt.
- Session timeout, biometric unlock, and a six-digit demo PIN with persisted lockout state.
- Demo wallet balance, transaction history, profile, verification, and linked-bank screens.
- A QR code and copy action for a fixed demo Solana Devnet address.
- Arbitrary positive USDC cashout amounts with up to six decimal places.
- Mock USDC-to-VND quotes with fees, a 30-second expiry, review, processing, and receipt screens.
- Remote job discovery with search, filters, saved jobs, job details, and a simulated application state.
- Four visual themes, responsive layouts, reduced-motion support, and widget/integration tests.

## How It Works

1. The user enters the demo through credentials or the device biometric prompt.
2. The home and wallet screens show sample USDC balances and activity.
3. The receive flow displays a QR code containing the configured demo address.
4. The cashout flow accepts a USDC amount, selects a sample bank account, and generates a local mock quote.
5. The user reviews the rate and fees, then confirms with biometrics or the demo PIN.
6. Processing and receipt screens complete the simulated USDC-to-VND flow.
7. The Jobs tab presents local fixture data and simulates saving or applying for remote opportunities.

## Solana Integration

| Area | Current implementation |
| --- | --- |
| Network | The interface is explicitly labeled **Solana Devnet**. |
| USDC | Amounts are modeled with six-decimal fixed precision using integer minor units. |
| Receive flow | The app renders a QR code for a fixed demo address and supports copying it. |
| Wallet signing | Not implemented. The app does not hold a private key or sign transactions. |
| RPC and indexing | Not implemented. No Solana RPC client or indexer is connected. |
| Transactions | Wallet balances, confirmations, and history are demo data. |
| VND payout | Fully simulated; no bank or payout provider is connected. |

There is currently no Solana SDK dependency in the Flutter project. Real wallet ownership, token-account validation, transaction tracking, and payout infrastructure remain future work.

## Tech Stack

- **Application:** Flutter, Dart, Material
- **Local state:** Stateful widgets, constructor-based dependency injection
- **Device services:** `local_auth`, `flutter_secure_storage`, `shared_preferences`
- **QR rendering:** `qr_flutter`
- **Quality:** `flutter_test`, Flutter integration tests, `flutter_lints`

## Architecture

The source uses a feature-first structure:

```text
lib/
|-- app/                 # Application composition and theme system
|-- features/
|   |-- auth/            # Login and registration
|   |-- cashout/         # Quote, authentication, processing, and receipt
|   |-- home/            # Home experience and educational content
|   |-- jobs/            # Remote job discovery demo
|   |-- receive/         # Devnet address and QR flow
|   |-- session/         # Session timeout and unlock
|   |-- wallet/          # Wallet presentation
|   +-- ...              # Profile, transactions, and help
+-- shared/              # Shared constants and widgets
```

Cashout logic separates presentation, domain value objects, and demo data/repositories. External services are injected behind small interfaces where device authentication or persistence needs to be replaceable in tests.

## Project Status

This repository is a student-built MVP and is not production-ready.

Current limitations include:

- Authentication and registration are not connected to an account backend.
- Identity, balances, bank accounts, jobs, and transaction states are sample data.
- Job notifications and applications do not use a remote API or push service.
- No real Solana wallet connection, RPC verification, or USDC transfer exists.
- Exchange rates, fees, settlement, and VND payout are simulated.
- Security and compliance requirements for a financial product are not complete.

## Getting Started

### Requirements

- Flutter SDK compatible with Dart `^3.13.2`
- An Android/iOS device, emulator, or another Flutter-supported target

### Run locally

```bash
git clone https://github.com/giahuydoo0207-tech/NIVEX-FLUTTER.git
cd NIVEX-FLUTTER
flutter pub get
flutter analyze
flutter test
flutter run
```

The app defaults to demo mode. Do not use real funds or production wallet credentials with this build.

## Author

**Gia Huy Do**

Software Engineering Student

[GitHub](https://github.com/giahuydoo0207-tech)

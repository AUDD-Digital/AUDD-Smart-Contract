# AUDD Smart Contract

This repository contains the Solidity smart contracts for the **AUDD** token system — a dual-token architecture consisting of a **Governance Token** and a **StableCoin**, deployed on both the Ethereum and Base networks.

## Deployments

| Network  | Contract Address                                                                                                              |
|----------|-------------------------------------------------------------------------------------------------------------------------------|
| Ethereum | [0x4cce605ed955295432958d8951d0b176c10720d5](https://etherscan.io/token/0x4cce605ed955295432958d8951d0b176c10720d5#tokenInfo) |
| Base     | [0x449b3317a6d1efb1bc3ba0700c9eaa4ffff4ae65](https://basescan.org/token/0x449b3317a6d1efb1bc3ba0700c9eaa4ffff4ae65)          |

## Architecture

The contracts follow an **upgradeable proxy pattern** using OpenZeppelin's `TransparentUpgradeableProxy` (via `import.sol`). All core contracts inherit from OpenZeppelin's upgradeable contract suite and use `initialize()` instead of constructors.

### Repository Structure

```
├── Base/                  # Contracts deployed to Base network
│   ├── Common.sol         # Shared types, state, events, and helpers
│   ├── GovernanceToken.sol# ERC20 governance token with whitelist and swap
│   ├── StableCoin.sol     # ERC20 stablecoin minted via swap mechanism
│   ├── Migrations.sol     # Truffle migration tracking (deployment utility)
│   └── import.sol         # Proxy compilation shim for tooling compatibility
├── Ethereum/              # Contracts deployed to Ethereum network
│   ├── Common.sol
│   ├── GovernanceToken.sol
│   ├── StableCoin.sol
│   ├── Migrations.sol
│   └── import.sol
└── README.md
```

The `Base/` and `Ethereum/` directories contain **identical contract source code**. They are maintained as separate copies per network.

### Contract Hierarchy

```
Common.sol (base contract + ArrayOps library)
├── GovernanceToken.sol (inherits Common + OZ Upgradeable contracts)
│   └── imports StableCoin.sol (for cross-contract swap call)
└── StableCoin.sol (inherits Common + OZ Upgradeable contracts)
```

Both token contracts inherit from:
- `Initializable` — one-time proxy initialization
- `ERC20Upgradeable` — standard ERC20
- `ERC20PausableUpgradeable` — pause/unpause transfers
- `OwnableUpgradeable` — ownership management
- `Common` — shared governance logic
- `ReentrancyGuardUpgradeable` — reentrancy protection

## How It Works

### Multi-Signatory Governance

All administrative operations require a multi-step approval workflow:

1. **Create** — A signatory creates a request (e.g., mint tokens, add signatory)
2. **Vote** — Other signatories approve or retract approval on the request
3. **Execute** — Once approvals meet the threshold, the request owner executes it

Requests can be **updated** (which resets all approvals) or **cancelled** by the original creator at any point before execution.

### Request Types

| Request Type           | Sub-Types       | Description                                       | Available In         |
|------------------------|-----------------|---------------------------------------------------|----------------------|
| Token Supply Control   | MINT, BURN      | Mint new tokens or burn existing tokens            | Both tokens          |
| Transaction Control    | PAUSE, UNPAUSE  | Pause or unpause all token transfers               | Both tokens          |
| Signatory Control      | ADD, REMOVE     | Add or remove signatories from the approval system | Both tokens          |
| Threshold Control      | UPDATE          | Change the number of approvals required            | Both tokens          |
| Whitelist Control      | ADD, REMOVE     | Add or remove addresses from the transfer whitelist| GovernanceToken only |

Each request type has its own configurable approval threshold. All thresholds default to `1` (single-signatory approval) at initialization.

### Governance Token

- **ERC20** with configurable decimals
- **Whitelist-gated transfers** — both sender and recipient must be whitelisted for `transfer()` and `transferFrom()`
- **Swap mechanism** — whitelisted users can burn governance tokens and receive an equal amount of stablecoins via `swap()`
- Full multi-signatory governance for supply, pause, signatory, threshold, and whitelist management

### StableCoin

- **ERC20** with configurable decimals
- **Unrestricted transfers** — no whitelist requirement (only pausable)
- **Minting via swap only** — the `swap()` function is restricted to calls from the registered `GovernanceToken` contract address
- Multi-signatory governance for supply, pause, signatory, and threshold management (no whitelist control)

### Token Swap Flow

```
User (whitelisted)
  │
  ├─► GovernanceToken.swap(stableCoinAddress, amount)
  │     ├─ Burns `amount` governance tokens from caller
  │     └─ Calls StableCoin(stableCoinAddress).swap(caller, amount)
  │
  └─► StableCoin.swap(user, amount)
        ├─ Verifies msg.sender == _governanceTokenAddress
        └─ Mints `amount` stablecoins to user
```

### Shared Utilities

**`Common.sol`** contains:
- `ArrayOps` library — address array manipulation (swap-and-pop deletion, element search)
- All enums, structs, and state variable declarations for the request system
- Event definitions for request lifecycle (`RequestCreated`, `RequestApproval`, `RequestCancelled`, etc.)
- `onlySignatory` access control modifier
- Internal helpers for request state validation (`_isCancellable`, `_isApprovable`, `_isExecutable`)

**`import.sol`** forces compilation of OpenZeppelin proxy artifacts (`BeaconProxy`, `UpgradeableBeacon`, `ERC1967Proxy`, `TransparentUpgradeableProxy`, `ProxyAdmin`) for tooling compatibility. The `AdminUpgradeabilityProxy` contract is a pass-through wrapper for backward compatibility with older Hardhat/Truffle plugins.

**`Migrations.sol`** is a standard Truffle migration tracking contract used during deployment. It has no relationship to the token system.

## Solidity Versions

| File               | Pragma           |
|--------------------|------------------|
| Common.sol         | `0.8.21`         |
| GovernanceToken.sol| `0.8.21`         |
| StableCoin.sol     | `0.8.21`         |
| import.sol         | `^0.8.0`         |
| Migrations.sol     | `>=0.4.22 <0.9.0`|

## Access Control

| Operation                        | Access Restriction                               |
|----------------------------------|--------------------------------------------------|
| Create/update/cancel requests    | `onlySignatory` modifier                         |
| Vote on requests                 | `onlySignatory` + `nonReentrant`                 |
| Execute approved requests        | Request owner only (checked internally)          |
| GovernanceToken transfers        | Both parties must be whitelisted                 |
| StableCoin transfers             | Unrestricted (pausable only)                     |
| GovernanceToken `swap()`         | Caller must be whitelisted                       |
| StableCoin `swap()`              | Caller must be the GovernanceToken contract       |

## Code Coverage

This repository contains **source contracts only**. There is no test suite, testing framework configuration (Hardhat/Truffle/Foundry), build scripts, deployment scripts, or CI/CD pipeline present in the repository.

## Incomplete or Unused Items

- **No test infrastructure** — no tests, test framework config, or build tooling exists in this repository.
- **No deployment scripts** — no migration scripts, deploy scripts, or environment configuration files are present.
- **No package manifest** — no `package.json`, `foundry.toml`, `hardhat.config.js`, or `truffle-config.js` exists.
- **`WHITELIST_CONTROL` in `Common.sol`** — the `RequestType.WHITELIST_CONTROL` enum value and its `requestTypeCount` entry (set to 2) are defined in `Common.sol` and inherited by `StableCoin`, but `StableCoin` has no whitelist state variables or code paths for it. All `StableCoin` functions revert with `'UNKNOWN_REQUEST!'` when called with `WHITELIST_CONTROL`.
- **`_governanceTokenAddress` is immutable post-initialization** — `StableCoin` sets the governance token address during `initialize()` with no setter function to update it later. Changing it requires a contract upgrade.
- **`GovernanceToken.swap()` accepts any address** — the `token_` parameter in `GovernanceToken.swap()` is cast directly to `StableCoin` without validating it is a known/trusted contract address.
- **`transferFrom()` whitelist gap** — `GovernanceToken.transferFrom()` checks `isWhiteListed` for the spender (`msg.sender`) and `to`, but does not check the `from` address (the token holder being spent from).
- **Duplicate contract directories** — `Base/` and `Ethereum/` contain identical source files with no differentiation between networks.

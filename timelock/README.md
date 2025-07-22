### 📘 `README.md` for Time-Locked Wallet Contract

```markdown
# ⏳ Time-Locked Wallet Smart Contract

This Clarity smart contract enables users to lock STX tokens until a specified block height, providing a simple, decentralized time-based escrow system. Users can create time-locked wallets, view wallet information, and withdraw funds once the lock period has expired.

## 📜 Features

- Lock STX funds until a future block height
- Unique wallet IDs per user
- Withdrawals only allowed by wallet owner after unlock time
- Emergency withdrawal option for contract owner
- Read-only methods to inspect wallet status

## 📦 Contract Structure

### Constants

| Name                   | Description                        |
|------------------------|------------------------------------|
| `err-not-authorized`   | Thrown if caller isn't authorized  |
| `err-funds-locked`     | Thrown if funds are still locked   |
| `err-no-funds`         | Thrown if wallet not found or amount invalid |
| `err-invalid-unlock-height` | Thrown if unlock height is in the past or current block |

### Data Variables

- `contract-owner`: Address of the contract deployer

### Maps

- `time-locked-wallets`: Stores wallet data (`owner`, `unlock-height`, `amount`) by `wallet-id`
- `user-wallet-counter`: Tracks how many wallets each user has created

## 🔧 Public Functions

### `create-timelock(unlock-height, amount)`

Creates a wallet and locks STX tokens until the given block height.

### `withdraw(wallet-id)`

Withdraws funds from the wallet if the caller is the owner and the lock period has expired.

### `emergency-withdraw(wallet-id)`

Allows the contract owner to recover funds in exceptional cases.

## 🧪 Read-Only Functions

### `get-user-wallet-count(user)`

Returns the number of wallets a user has created.

### `get-wallet-info(wallet-id)`

Returns wallet data (`owner`, `unlock-height`, `amount`).

### `is-wallet-unlocked(wallet-id)`

Returns `true` if the wallet can be withdrawn from.

### `get-current-block-height()`

Returns the current block height.

## 🛡 Security & Notes

- Only the wallet creator can withdraw locked funds (after the lock time).
- The contract owner has a built-in emergency override to recover funds.
- Wallet IDs are deterministically generated and unique to each user.

## ✅ Deployment Checklist

- [ ] Set the `contract-owner` correctly during deployment.
- Ensure proper testing of withdrawal timing.
- utValidate correct block height calculations and test edge cases.

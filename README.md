# Advanced UUPS Proxy Architecture & EVM State Upgrades

A robust, Foundry-based implementation of the UUPS (Universal Upgradeable Proxy Standard) architecture. This repository demonstrates secure smart contract upgradeability by decoupling business logic (Implementation) from state storage (EIP-1967 Proxy), ensuring seamless protocol iterations without data loss or storage collisions.

## 🏗️ Architectural Overview

This system utilizes the **EIP-1967 Storage Standard** paired with the **UUPS (EIP-1822) Upgrade Pattern**.

* **`ERC1967Proxy.sol`**: The persistent state layer. It holds all user data, balances, and the critical EIP-1967 storage slot (`0x360894a1...`) that points to the current implementation address. It routes all incoming function calls via `delegatecall`.
* **`BoxV1.sol` / `BoxV2.sol`**: The implementation contracts containing the business logic and the UUPS upgrade mechanisms. These contracts execute within the context of the proxy's storage.

## 🛡️ Key Security Implementations

As upgradeability introduces significant attack vectors, this project strictly enforces the following security invariants:

1.  **Atomic Initialization:** The proxy deployment and `initialize()` execution are bundled into a single transaction using `abi.encodeCall` in `DeployBox.s.sol`. This mathematically eliminates the risk of MEV bots front-running the initialization phase to hijack proxy ownership.
2.  **UUPS Anti-Bricking Guardrails:** Upgrades utilize OpenZeppelin's `proxiableUUID()` check to verify that any incoming V2 contract contains the necessary UUPS upgrade logic before finalizing the pointer swap, preventing permanent protocol lock-outs.
3.  **State Isolation & Collision Prevention:** Demonstrates the strict separation of code and state. Implementation contracts act purely as stateless logic engines, preventing storage slot corruption during version transitions.
4.  **Negative Execution Path Verification:** The test suite (`TestDeployAndUpgrade.t.sol`) intentionally bypasses the Solidity compiler to send raw, malformed calldata via low-level `.call()`. This verifies the EVM's underlying behavior, proving that un-upgraded state securely triggers implicit "naked" reverts without exposing vulnerable fallback mechanisms.


## 🧱 Core Smart Contract Architecture

This protocol is built on three distinct architectural pillars, meticulously separating EVM state from business logic.

### 1. The ERC-1967 Proxy (State & Routing)
Instead of hardcoding implementation addresses into standard storage slots (which risks fatal storage collisions), this protocol utilizes the **EIP-1967 Storage Standard**. 
* **The Mechanism:** The proxy stores the address of the logic contract in an ultra-distant, mathematically randomized Yul storage slot: `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`.
* **Execution:** The proxy contains absolutely no business logic. It relies entirely on a low-level `fallback()` function to intercept unrecognized calldata and route it to the implementation contract via `delegatecall`. 
* **State Persistence:** All user data, state variables, and balances physically reside within the proxy's storage, completely immune to the destruction or deprecation of old implementation contracts.

### 2. The UUPS Pattern (Upgrade Engine)
This repository implements **EIP-1822 (Universal Upgradeable Proxy Standard)** instead of the older Transparent Proxy Pattern. 
* **The Mechanism:** The upgrade logic (`upgradeToAndCall`) is deliberately omitted from the proxy shell and inherited directly by the implementation contract (`BoxV1.sol`, `BoxV2.sol`). 
* **Security & Gas Efficiency:** By keeping the proxy lightweight, UUPS significantly reduces deployment gas costs. Security is enforced via the `_authorizeUpgrade()` function, which acts as a mandatory access-control gatekeeper (e.g., `onlyOwner`), ensuring that only verified administrators can overwrite the EIP-1967 storage slot.

### 3. The Initializer Pattern (Atomic State Setup)
Because proxies rely on `delegatecall`, standard Solidity `constructor()` functions are fundamentally broken in this architecture (constructors execute in the context of the implementation, leaving the proxy state dangerously blank).
* **The Mechanism:** We replace constructors with a standard, callable `initialize()` function. 
* **Security Guardrails:** To prevent malicious actors from re-initializing the protocol, the function is protected by an `initializer` modifier, which permanently locks the state after the first execution.
* **Atomic Deployment:** The deployment script utilizes `abi.encodeCall` to package the initialization calldata directly into the proxy's deployment transaction. This guarantees an atomic, unbreakable deployment, entirely neutralizing the risk of MEV front-running attacks on protocol ownership.

## 🚀 Quick Start

### Prerequisites
Ensure you have [Foundry](https://getfoundry.sh/) installed on your machine.

### Installation
Clone the repository and install dependencies:
```bash
git clone <your-repo-url>
cd foundry-upgradesf23
forge install

Compilation
Compile the contracts, forcing the Yul optimizer for efficient bytecode generation:

Bash
forge build --via-ir
🧪 Testing Suite
The testing suite validates both positive state changes and critical security invariants using deeply traced EVM execution logs.

Run the test suite with maximum verbosity to trace delegatecall routing and storage operations:

Bash
forge test -vvvv
Core Invariant Tests:

testUpgradeAndStateChange(): Verifies that state modifications persist in the EIP-1967 storage slot after the implementation pointer is upgraded to V2.

testsetNumberAsV1(): Uses low-level calldata testing to ensure the proxy successfully reverts unauthorized or non-existent function selectors prior to upgrading.

📜 Deployment Scripts
Deploy the V1 implementation and initialize the proxy atomically:

Bash
forge script script/DeployBox.s.sol:DeployBox --rpc-url <YOUR_RPC_URL> --broadcast
Execute a state-preserving UUPS upgrade to V2:

Bash
forge script script/UpgradeBox.s.sol:UpgradeBox --rpc-url <YOUR_RPC_URL> --broadcast
Developed by Pratik Das as a Proof of Work in Smart Contract Auditing and EVM Architecture.

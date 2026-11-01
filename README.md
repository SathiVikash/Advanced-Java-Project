# Blockchain Supply Chain Traceability System

A hybrid on-chain/off-chain supply chain traceability system built with **Spring Boot 3**, **Spring Security**, **Spring Data JPA**, **Web3j**, **Ethereum Smart Contracts (Solidity)**, and **JSP**.

## 📌 Project Architecture

- **Off-Chain Database**: Embedded H2 database (or MySQL via XAMPP) stores rich relational product data, actor details, location metadata, and environmental telemetry (temperature, humidity).
- **Cryptographic Hashing**: Every batch registration and lifecycle checkpoint produces a deterministic **SHA-256 state hash** calculated from its off-chain payload.
- **On-Chain Ethereum Ledger**: Hashes, stage numbers, locations, and timestamps are committed as immutable transactions on the **Ethereum Sepolia Testnet** using smart contracts.
- **Integrity Verification Engine**: Performs real-time bit-for-bit comparisons between local database state hashes and the blockchain ledger to detect any unauthorized database tampering or fraud.
- **Rule-Based Anomaly Detection**: Automatically flags cold-chain temperature violations, impossible transit velocities, out-of-sequence stages, and unauthorized actors.

---

## 🛠️ Tech Stack

- **Java**: 21
- **Framework**: Spring Boot 3.2.5
- **Security**: Spring Security 6 (Role-Based Access Control)
- **Database / ORM**: Hibernate, Spring Data JPA, Embedded H2 / MySQL
- **Blockchain**: Web3j 4.10.3, Solidity 0.8.20 (Ethereum Sepolia Testnet)
- **Frontend**: JSP, JSTL, HTML5, CSS3 (Modern Glassmorphic Dark UI)
- **Build Tool**: Maven

---

## 👥 Consortium Roles & Demo Credentials

All test accounts share the default password: **`password123`**

| Role | Username | Description & Permissions |
| :--- | :--- | :--- |
| **Manufacturer** | `manufacturer1` | Registers new product batches, defines cold-chain limits, and mints on-chain genesis records. |
| **Distributor** | `distributor1` | Logs transit stages, route checkpoints, temperature, and humidity telemetry. |
| **Warehouse** | `warehouse1` | Logs warehouse receipt, storage bay allocation, and storage environment conditions. |
| **Retailer** | `retailer1` | Confirms store arrival and marks items as `SOLD` to consumers. |
| **Auditor** | `auditor1` | Full compliance dashboard, anomaly incident resolution, and cryptographic on-chain verification. |
| **Consumer** | `consumer1` | Public tracking and provenance verification before purchase (no login required for `/track`). |

---

## 📁 Smart Contract Details

- **Contract Source**: [`src/main/resources/contracts/SupplyChain.sol`](src/main/resources/contracts/SupplyChain.sol)
- **Key Functions**:
  - `registerProduct(string productId, string batchNumber, bytes32 dataHash, string location)`
  - `addStageEvent(string productId, uint8 stage, bytes32 dataHash, string location)`
  - `getLatestDataHash(string productId)`
  - `getEvent(string productId, uint256 index)`
  - `getEventCount(string productId)`

---

## 🚀 Getting Started

### 1. Prerequisites
- **JDK 21** or higher
- **Maven 3.8+**
- (Optional) **MetaMask** wallet with Sepolia ETH for live blockchain transactions

### 2. Configuration
Copy `application-local.properties` or set environment variables:
```properties
BLOCKCHAIN_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
BLOCKCHAIN_CONTRACT_ADDRESS=0xYourDeployedContractAddress
BLOCKCHAIN_PRIVATE_KEY=your_private_key_without_0x
```

### 3. Run Application
Run using the provided script:
```bash
./start.bat
```
Or with Maven:
```bash
mvn spring-boot:run
```

Access the application in your browser:
👉 **http://localhost:9090/** (or directly at `http://localhost:9090/login`)

---

## 🔍 Key Endpoints

- `/login` — Consortium authentication portal
- `/dashboard` — Role-customized supply chain metrics and recent alerts
- `/product/register` — Product batch registration (Manufacturer only)
- `/product/update-stage` — Checkpoint stage handover (Manufacturer, Distributor, Warehouse, Retailer)
- `/product/list` — Consortium product catalog
- `/track?productId=...` — Public chronological timeline and provenance trail
- `/verify?productId=...` — Cryptographic hash vs. blockchain integrity audit
- `/anomalies` — Anomaly detection and violation management (Auditor)
- `/h2-console` — Embedded database explorer (JDBC URL: `jdbc:h2:mem:supply_chain_db`)


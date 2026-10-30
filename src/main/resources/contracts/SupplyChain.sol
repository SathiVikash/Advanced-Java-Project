// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SupplyChain
 * @notice Immutable on-chain ledger for supply chain batch registration,
 *         cryptographic SHA-256 state tracking, and tamper verification.
 */
contract SupplyChain {

    enum Stage {
        MANUFACTURED,        // 0
        IN_TRANSIT,          // 1
        WAREHOUSE_RECEIVED,  // 2
        RETAIL_RECEIVED,     // 3
        SOLD                 // 4
    }

    struct EventRecord {
        uint8 stage;
        bytes32 dataHash;
        string location;
        address recordedBy;
        uint256 timestamp;
    }

    struct ProductRecord {
        string productId;
        string batchNumber;
        address manufacturer;
        uint256 createdAt;
        bool exists;
    }

    // Mapping from productId -> ProductRecord
    mapping(string => ProductRecord) public products;

    // Mapping from productId -> chronological array of EventRecords
    mapping(string => EventRecord[]) public productHistory;

    // Events
    event ProductRegistered(
        string indexed productId,
        string batchNumber,
        bytes32 dataHash,
        string location,
        address indexed manufacturer,
        uint256 timestamp
    );

    event StageEventAdded(
        string indexed productId,
        uint8 indexed stage,
        bytes32 dataHash,
        string location,
        address indexed recorder,
        uint256 timestamp
    );

    /**
     * @notice Register a newly manufactured product batch.
     * @param productId Unique identifier of product
     * @param batchNumber Batch / lot number
     * @param dataHash SHA-256 hash of off-chain database record
     * @param location Origin manufacturing location
     */
    function registerProduct(
        string calldata productId,
        string calldata batchNumber,
        bytes32 dataHash,
        string calldata location
    ) external {
        require(!products[productId].exists, "Product already registered");
        require(bytes(productId).length > 0, "Product ID cannot be empty");
        require(bytes(batchNumber).length > 0, "Batch number cannot be empty");

        products[productId] = ProductRecord({
            productId: productId,
            batchNumber: batchNumber,
            manufacturer: msg.sender,
            createdAt: block.timestamp,
            exists: true
        });

        productHistory[productId].push(EventRecord({
            stage: uint8(Stage.MANUFACTURED),
            dataHash: dataHash,
            location: location,
            recordedBy: msg.sender,
            timestamp: block.timestamp
        }));

        emit ProductRegistered(productId, batchNumber, dataHash, location, msg.sender, block.timestamp);
    }

    /**
     * @notice Append a lifecycle stage transition event with cryptographic state hash.
     * @param productId Product ID
     * @param stage Transition stage (0..4)
     * @param dataHash SHA-256 hash of off-chain database record
     * @param location Current geographical location
     */
    function addStageEvent(
        string calldata productId,
        uint8 stage,
        bytes32 dataHash,
        string calldata location
    ) external {
        require(products[productId].exists, "Product does not exist");
        require(stage <= uint8(Stage.SOLD), "Invalid stage");

        productHistory[productId].push(EventRecord({
            stage: stage,
            dataHash: dataHash,
            location: location,
            recordedBy: msg.sender,
            timestamp: block.timestamp
        }));

        emit StageEventAdded(productId, stage, dataHash, location, msg.sender, block.timestamp);
    }

    /**
     * @notice Returns the latest on-chain SHA-256 hash for integrity verification.
     * @param productId Product ID
     * @return Latest cryptographic bytes32 hash
     */
    function getLatestDataHash(string calldata productId) external view returns (bytes32) {
        require(products[productId].exists, "Product does not exist");
        uint256 total = productHistory[productId].length;
        require(total > 0, "No events found");
        return productHistory[productId][total - 1].dataHash;
    }

    /**
     * @notice Total number of lifecycle events for a product.
     */
    function getEventCount(string calldata productId) external view returns (uint256) {
        require(products[productId].exists, "Product does not exist");
        return productHistory[productId].length;
    }

    /**
     * @notice Retrieve an event record by index.
     */
    function getEvent(string calldata productId, uint256 index)
        external
        view
        returns (
            uint8 stage,
            bytes32 dataHash,
            string memory location,
            address recordedBy,
            uint256 timestamp
        )
    {
        require(products[productId].exists, "Product does not exist");
        require(index < productHistory[productId].length, "Index out of bounds");
        EventRecord memory rec = productHistory[productId][index];
        return (rec.stage, rec.dataHash, rec.location, rec.recordedBy, rec.timestamp);
    }

    /**
     * @notice Check whether a product ID exists.
     */
    function isRegistered(string calldata productId) external view returns (bool) {
        return products[productId].exists;
    }
}


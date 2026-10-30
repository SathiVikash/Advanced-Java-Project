package com.supplychain.app.blockchain;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.abi.FunctionEncoder;
import org.web3j.abi.FunctionReturnDecoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.*;
import org.web3j.abi.datatypes.generated.Bytes32;
import org.web3j.abi.datatypes.generated.Uint8;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

/**
 * BlockchainService handles all on-chain interactions:
 * - Registering products
 * - Adding supply chain events
 * - Verifying on-chain hashes
 */
@Service
public class BlockchainService {

    private static final Logger log = LoggerFactory.getLogger(BlockchainService.class);

    private final Web3j web3j;
    private final Credentials credentials;
    private final ContractGasProvider gasProvider;

    @Value("${blockchain.contract.address}")
    private String contractAddress;

    @Value("${blockchain.chain.id}")
    private long chainId;

    @Autowired
    public BlockchainService(Web3j web3j, Credentials credentials, ContractGasProvider gasProvider) {
        this.web3j = web3j;
        this.credentials = credentials;
        this.gasProvider = gasProvider;
    }

    /**
     * Registers a new product on-chain.
     *
     * @param productId   Off-chain product UUID
     * @param batchNumber Batch/lot number
     * @param dataHash    SHA-256 hash of initial MySQL record (hex string, 64 chars)
     * @param location    Origin location string
     * @return Transaction hash
     */
    public String registerProduct(String productId, String batchNumber, String dataHash, String location) throws Exception {
        log.info("Registering product on-chain: {}", productId);

        byte[] hashBytes = hexStringToBytes32(dataHash);

        Function function = new Function(
            "registerProduct",
            Arrays.asList(
                new Utf8String(productId),
                new Utf8String(batchNumber),
                new Bytes32(hashBytes),
                new Utf8String(location)
            ),
            Collections.emptyList()
        );

        return sendTransaction(function);
    }

    /**
     * Adds a stage event on-chain.
     *
     * @param productId Off-chain product ID
     * @param stage     Stage number (0=MANUFACTURED, 1=IN_TRANSIT, etc.)
     * @param dataHash  SHA-256 hash of the MySQL event row
     * @param location  Location at time of event
     * @return Transaction hash
     */
    public String addStageEvent(String productId, int stage, String dataHash, String location) throws Exception {
        log.info("Adding stage event on-chain: product={}, stage={}", productId, stage);

        byte[] hashBytes = hexStringToBytes32(dataHash);

        Function function = new Function(
            "addStageEvent",
            Arrays.asList(
                new Utf8String(productId),
                new Uint8(BigInteger.valueOf(stage)),
                new Bytes32(hashBytes),
                new Utf8String(location)
            ),
            Collections.emptyList()
        );

        return sendTransaction(function);
    }

    /**
     * Retrieves the latest on-chain data hash for a product for integrity verification.
     *
     * @param productId Product ID
     * @return Hex-encoded 64-character SHA-256 hash stored on-chain
     */
    public Optional<String> getLatestOnChainHash(String productId) {
        try {
            Function function = new Function(
                "getLatestDataHash",
                Collections.singletonList(new Utf8String(productId)),
                Collections.singletonList(new TypeReference<Bytes32>() {})
            );

            String encodedFunction = FunctionEncoder.encode(function);

            EthCall response = web3j.ethCall(
                org.web3j.protocol.core.methods.request.Transaction.createEthCallTransaction(
                    credentials.getAddress(), contractAddress, encodedFunction),
                DefaultBlockParameterName.LATEST
            ).send();

            if (response.hasError()) {
                log.error("Error calling getLatestDataHash: {}", response.getError().getMessage());
                return Optional.empty();
            }

            List<Type> decoded = FunctionReturnDecoder.decode(response.getValue(),
                function.getOutputParameters());

            if (decoded.isEmpty()) return Optional.empty();

            byte[] hashBytes = (byte[]) decoded.get(0).getValue();
            return Optional.of(bytesToHex(hashBytes));

        } catch (Exception e) {
            log.error("Failed to fetch on-chain hash for productId={}: {}", productId, e.getMessage());
            return Optional.empty();
        }
    }

    /**
     * Returns the connected wallet address (the signing account).
     */
    public String getConnectedAddress() {
        return credentials.getAddress();
    }

    /**
     * Checks the live connection to the Ethereum node.
     */
    public boolean isConnected() {
        try {
            EthBlockNumber blockNumber = web3j.ethBlockNumber().send();
            log.info("Connected to Ethereum node. Block number: {}", blockNumber.getBlockNumber());
            return true;
        } catch (Exception e) {
            log.error("Ethereum node not reachable: {}", e.getMessage());
            return false;
        }
    }

    // ==============================
    //   PRIVATE HELPERS
    // ==============================

    private String sendTransaction(Function function) throws Exception {
        String encodedFunction = FunctionEncoder.encode(function);
        RawTransactionManager txManager = new RawTransactionManager(web3j, credentials, chainId);

        EthSendTransaction txResponse = txManager.sendTransaction(
            gasProvider.getGasPrice(null),
            gasProvider.getGasLimit(null),
            contractAddress,
            encodedFunction,
            BigInteger.ZERO
        );

        if (txResponse.hasError()) {
            throw new RuntimeException("Transaction failed: " + txResponse.getError().getMessage());
        }

        String txHash = txResponse.getTransactionHash();
        log.info("Transaction submitted. TxHash: {}", txHash);
        return txHash;
    }

    private byte[] hexStringToBytes32(String hex) {
        if (hex.startsWith("0x") || hex.startsWith("0X")) {
            hex = hex.substring(2);
        }
        byte[] result = new byte[32];
        byte[] decoded = hexToBytes(hex);
        int offset = Math.max(0, 32 - decoded.length);
        System.arraycopy(decoded, 0, result, offset, Math.min(decoded.length, 32));
        return result;
    }

    private byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }

    public static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}

package com.supplychain.app.blockchain;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;
import org.web3j.crypto.Credentials;
import org.web3j.tx.gas.DefaultGasProvider;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.StaticGasProvider;
import java.math.BigInteger;

@Configuration
public class Web3jConfig {

    @Value("${blockchain.rpc.url}")
    private String rpcUrl;

    @Value("${blockchain.wallet.private-key}")
    private String privateKey;

    @Value("${blockchain.gas.limit}")
    private long gasLimit;

    @Value("${blockchain.gas.price}")
    private long gasPrice;

    @Bean
    public Web3j web3j() {
        return Web3j.build(new HttpService(rpcUrl));
    }

    @Bean
    public Credentials credentials() {
        return Credentials.create(privateKey);
    }

    @Bean
    public ContractGasProvider contractGasProvider() {
        return new StaticGasProvider(
            BigInteger.valueOf(gasPrice),
            BigInteger.valueOf(gasLimit)
        );
    }
}

package com.supplychain.app.config;

import com.supplychain.app.entity.User;
import com.supplychain.app.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Seeds the database with default consortium users on first run.
 * All users have password "password123" (BCrypt-encoded).
 */
@Configuration
public class DataSeeder {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public DataSeeder(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Bean
    public CommandLineRunner seedUsers() {
        return args -> {
            if (userRepository.count() == 0) {
                log.info("Seeding consortium users...");

                createUser("manufacturer1", "Arvind Kumar",  User.Role.MANUFACTURER, "0xManufacturerWalletAddress");
                createUser("distributor1", "Priya Sharma",  User.Role.DISTRIBUTOR,   "0xDistributorWalletAddress");
                createUser("warehouse1",   "Rajan Das",     User.Role.WAREHOUSE,     "0xWarehouseWalletAddress");
                createUser("retailer1",    "Sneha Patel",   User.Role.RETAILER,      "0xRetailerWalletAddress");
                createUser("auditor1",     "Dr. Mehta",     User.Role.AUDITOR,       "0xAuditorWalletAddress");
                createUser("consumer1",    "Amit Singh",    User.Role.CONSUMER,      "0xConsumerWalletAddress");

                log.info("Seeded 6 consortium users. Login with password: password123");
            }
        };
    }

    private void createUser(String username, String fullName, User.Role role, String wallet) {
        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName);
        user.setRole(role);
        user.setWalletAddress(wallet);
        user.setPassword(passwordEncoder.encode("password123"));
        user.setEnabled(true);
        userRepository.save(user);
    }
}

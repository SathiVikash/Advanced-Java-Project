package com.supplychain.app.repository;

import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface SupplyChainEventRepository extends JpaRepository<SupplyChainEvent, Long> {
    List<SupplyChainEvent> findByProductOrderByEventTimeAsc(Product product);
    Optional<SupplyChainEvent> findTopByProductOrderByEventTimeDesc(Product product);
    List<SupplyChainEvent> findByActorWallet(String actorWallet);
    List<SupplyChainEvent> findByIntegrityStatus(SupplyChainEvent.IntegrityStatus status);
    long countByProduct(Product product);
}

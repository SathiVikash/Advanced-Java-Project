package com.supplychain.app.repository;

import com.supplychain.app.entity.AnomalyLog;
import com.supplychain.app.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AnomalyLogRepository extends JpaRepository<AnomalyLog, Long> {
    List<AnomalyLog> findByProductOrderByDetectedAtDesc(Product product);
    List<AnomalyLog> findByResolvedFalseOrderByDetectedAtDesc();
    List<AnomalyLog> findBySeverityOrderByDetectedAtDesc(AnomalyLog.Severity severity);

    @Query("SELECT COUNT(a) FROM AnomalyLog a WHERE a.resolved = false")
    long countUnresolved();

    @Query("SELECT COUNT(a) FROM AnomalyLog a WHERE a.severity = 'CRITICAL' AND a.resolved = false")
    long countCriticalUnresolved();
}

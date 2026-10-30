package com.supplychain.app.controller;

import com.supplychain.app.entity.AnomalyLog;
import com.supplychain.app.entity.Product;
import com.supplychain.app.repository.AnomalyLogRepository;
import com.supplychain.app.repository.ProductRepository;
import com.supplychain.app.repository.SupplyChainEventRepository;
import com.supplychain.app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class DashboardController {

    private final ProductRepository productRepository;
    private final SupplyChainEventRepository eventRepository;
    private final AnomalyLogRepository anomalyLogRepository;
    private final UserRepository userRepository;

    @Autowired
    public DashboardController(ProductRepository productRepository,
                               SupplyChainEventRepository eventRepository,
                               AnomalyLogRepository anomalyLogRepository,
                               UserRepository userRepository) {
        this.productRepository = productRepository;
        this.eventRepository = eventRepository;
        this.anomalyLogRepository = anomalyLogRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        long totalProducts = productRepository.count();
        long totalEvents = eventRepository.count();
        long unresolvedAnomalies = anomalyLogRepository.countUnresolved();
        long criticalAnomalies = anomalyLogRepository.countCriticalUnresolved();

        List<AnomalyLog> recentAnomalies = anomalyLogRepository
            .findByResolvedFalseOrderByDetectedAtDesc()
            .stream().limit(10).toList();

        List<Product> recentProducts = productRepository
            .findAllOrderByCreatedAtDesc()
            .stream().limit(5).toList();

        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("totalEvents", totalEvents);
        model.addAttribute("unresolvedAnomalies", unresolvedAnomalies);
        model.addAttribute("criticalAnomalies", criticalAnomalies);
        model.addAttribute("recentAnomalies", recentAnomalies);
        model.addAttribute("recentProducts", recentProducts);

        return "dashboard";
    }

    @GetMapping("/")
    public String home() {
        return "redirect:/dashboard";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }
}

package com.supplychain.app.controller;

import com.supplychain.app.bean.ProductRegistrationBean;
import com.supplychain.app.bean.StageUpdateBean;
import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import com.supplychain.app.entity.User;
import com.supplychain.app.repository.UserRepository;
import com.supplychain.app.service.SupplyChainService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/product")
public class ProductController {

    private static final Logger log = LoggerFactory.getLogger(ProductController.class);

    private final SupplyChainService supplyChainService;
    private final UserRepository userRepository;

    @Autowired
    public ProductController(SupplyChainService supplyChainService, UserRepository userRepository) {
        this.supplyChainService = supplyChainService;
        this.userRepository = userRepository;
    }

    // ============ REGISTRATION ============

    @GetMapping("/register")
    public String showRegistrationForm(Model model) {
        model.addAttribute("productBean", new ProductRegistrationBean());
        return "register-product";
    }

    @PostMapping("/register")
    public String registerProduct(
            @Valid @ModelAttribute("productBean") ProductRegistrationBean bean,
            BindingResult result,
            RedirectAttributes redirectAttrs) {

        if (result.hasErrors()) {
            return "register-product";
        }

        try {
            String walletAddress = getCurrentUserWallet();
            Product product = supplyChainService.registerProduct(bean, walletAddress);
            redirectAttrs.addFlashAttribute("successMsg",
                "Product '" + product.getName() + "' registered! ID: " + product.getProductId());
            return "redirect:/dashboard";
        } catch (Exception e) {
            log.error("Error registering product", e);
            redirectAttrs.addFlashAttribute("errorMsg", "Registration failed: " + e.getMessage());
            return "redirect:/product/register";
        }
    }

    // ============ STAGE UPDATE ============

    @GetMapping("/update-stage")
    public String showStageUpdateForm(@RequestParam(required = false) String productId, Model model) {
        model.addAttribute("stageBean", new StageUpdateBean());
        model.addAttribute("stages", Product.Stage.values());
        if (productId != null) {
            model.addAttribute("prefilledProductId", productId);
        }
        return "update-stage";
    }

    @PostMapping("/update-stage")
    public String updateStage(
            @Valid @ModelAttribute("stageBean") StageUpdateBean bean,
            BindingResult result,
            RedirectAttributes redirectAttrs,
            Model model) {

        if (result.hasErrors()) {
            model.addAttribute("stages", Product.Stage.values());
            return "update-stage";
        }

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth.getName();
            String role = auth.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
            String wallet = getCurrentUserWallet();

            Optional<User> user = userRepository.findByUsername(username);
            String actorName = user.map(User::getFullName).orElse(username);

            SupplyChainEvent event = supplyChainService.addStageEvent(bean, wallet, role, actorName);
            redirectAttrs.addFlashAttribute("successMsg",
                "Stage updated to " + bean.getStage() + " for product " + bean.getProductId() +
                ". TxHash: " + (event.getBlockchainTxHash() != null ? event.getBlockchainTxHash() : "Pending"));
            return "redirect:/track?productId=" + bean.getProductId();

        } catch (Exception e) {
            log.error("Error updating stage", e);
            redirectAttrs.addFlashAttribute("errorMsg", "Stage update failed: " + e.getMessage());
            return "redirect:/product/update-stage";
        }
    }

    // ============ TRACKING / HISTORY ============

    @GetMapping("/track")
    public String trackProduct(@RequestParam(required = false) String productId, Model model) {
        model.addAttribute("productId", productId);
        if (productId != null && !productId.isBlank()) {
            Optional<Product> productOpt = supplyChainService.findByProductId(productId);
            if (productOpt.isPresent()) {
                Product product = productOpt.get();
                List<SupplyChainEvent> history = supplyChainService.getProductHistory(product);
                model.addAttribute("product", product);
                model.addAttribute("history", history);
            } else {
                model.addAttribute("notFound", true);
            }
        }
        return "track-product";
    }

    // ============ ALL PRODUCTS LIST ============

    @GetMapping("/list")
    public String listProducts(Model model) {
        model.addAttribute("products", supplyChainService.getAllProducts());
        return "product-list";
    }

    // ============ HELPER ============

    private String getCurrentUserWallet() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return userRepository.findByUsername(username)
            .map(User::getWalletAddress)
            .orElse("0x0000000000000000000000000000000000000000");
    }
}

package com.salesianos.triana.animanga.order;

import com.salesianos.triana.animanga.cart.CartItem;
import com.salesianos.triana.animanga.cart.CartItemRepository;
import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.catalog.MangaStatsUpdater;
import com.salesianos.triana.animanga.catalog.Volume;
import com.salesianos.triana.animanga.catalog.VolumeRepository;
import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.order.OrderDtos.*;
import com.salesianos.triana.animanga.user.User;
import com.salesianos.triana.animanga.user.UserRepository;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OrderService {

    private static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("yyyyMMdd").withZone(ZoneOffset.UTC);

    private final OrderRepository orders;
    private final CartItemRepository cartItems;
    private final VolumeRepository volumes;
    private final UserRepository users;
    private final MangaStatsUpdater stats;

    /**
     * Convierte el carrito en un pedido. Las filas de los volúmenes se bloquean mientras dura
     * la transacción, así que dos compras simultáneas no pueden vender la misma última unidad.
     */
    @Transactional
    public OrderDto checkout(User principal, CheckoutRequest req) {
        User user = users.findById(principal.getId()).orElseThrow();
        String last4 = CardValidator.validate(req.cardNumber(), req.cardExpiry(), req.cardCvc(),
                YearMonth.now(ZoneOffset.UTC));

        // Se bloquean los volúmenes ANTES de leerlos, para trabajar con el stock real
        List<UUID> volumeIds = cartItems.volumeIdsOf(user);
        if (volumeIds.isEmpty()) throw ApiException.badRequest("Tu carrito está vacío");
        Map<UUID, Volume> locked = new HashMap<>();
        volumes.lockAllByIdIn(volumeIds).forEach(v -> locked.put(v.getId(), v));
        List<CartItem> cart = cartItems.findByUserOrderByVolumeTitleAsc(user);

        Order order = Order.builder()
                .number(newNumber())
                .user(user)
                .status(OrderStatus.PAID)
                .shipping(req.shipping().toEntity())
                .cardLast4(last4)
                .total(BigDecimal.ZERO)
                .build();

        BigDecimal total = BigDecimal.ZERO;
        Set<Manga> touched = new HashSet<>();
        for (CartItem item : cart) {
            Volume v = locked.get(item.getVolume().getId());
            if (v.getStock() < item.getQuantity()) {
                throw ApiException.conflict(v.getStock() == 0
                        ? v.getTitle() + " se ha agotado"
                        : "Solo quedan " + v.getStock() + " unidades de " + v.getTitle());
            }
            v.setStock(v.getStock() - item.getQuantity());
            order.addLine(OrderLine.builder()
                    .volume(v)
                    .volumeTitle(v.getTitle())
                    .mangaTitle(v.getManga().getTitle())
                    .mangaId(v.getManga().getId())
                    .coverImage(v.getCoverImage())
                    .unitPrice(v.getPrice())
                    .quantity(item.getQuantity())
                    .build());
            total = total.add(v.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            touched.add(v.getManga());
        }
        order.setTotal(total);
        orders.saveAndFlush(order);
        cartItems.deleteByUser(user);
        touched.forEach(stats::refresh);
        return OrderDto.from(order);
    }

    @Transactional(readOnly = true)
    public PageResponse<OrderDto> mine(User principal, int page, int size) {
        User user = users.findById(principal.getId()).orElseThrow();
        return PageResponse.of(orders.findByUserOrderByCreatedAtDesc(user, PageRequest.of(page, Math.min(size, 50))),
                OrderDto::from);
    }

    @Transactional(readOnly = true)
    public OrderDto get(User principal, UUID id) {
        return OrderDto.from(loadVisible(principal, id));
    }

    /** El cliente puede cancelar mientras no se haya enviado. Se devuelve el stock. */
    @Transactional
    public OrderDto cancel(User principal, UUID id) {
        Order order = loadVisible(principal, id);
        changeStatus(order, OrderStatus.CANCELLED);
        return OrderDto.from(order);
    }

    @Transactional(readOnly = true)
    public PageResponse<OrderDto> search(OrderStatus status, String q, int page, int size) {
        Specification<Order> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (status != null) predicates.add(cb.equal(root.get("status"), status));
            if (q != null && !q.isBlank()) {
                String like = "%" + q.trim().toLowerCase() + "%";
                Join<Order, User> user = root.join("user");
                predicates.add(cb.or(cb.like(cb.lower(root.get("number")), like),
                        cb.like(cb.lower(user.get("fullName")), like),
                        cb.like(cb.lower(user.get("username")), like),
                        cb.like(cb.lower(user.get("email")), like)));
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        var pageable = PageRequest.of(page, Math.min(size, 100), Sort.by(Sort.Order.desc("createdAt")));
        return PageResponse.of(orders.findAll(spec, pageable), OrderDto::from);
    }

    @Transactional
    public OrderDto updateStatus(UUID id, OrderStatus status) {
        Order order = orders.findById(id).orElseThrow(() -> ApiException.notFound("Pedido"));
        changeStatus(order, status);
        return OrderDto.from(order);
    }

    private void changeStatus(Order order, OrderStatus next) {
        if (!order.getStatus().canChangeTo(next)) {
            throw ApiException.conflict("No se puede pasar un pedido de " + label(order.getStatus())
                    + " a " + label(next));
        }
        if (next == OrderStatus.CANCELLED) {
            Set<Manga> touched = new HashSet<>();
            for (OrderLine line : order.getLines()) {
                if (line.getVolume() != null) {
                    line.getVolume().setStock(line.getVolume().getStock() + line.getQuantity());
                    touched.add(line.getVolume().getManga());
                }
            }
            order.setStatus(next);
            order.setUpdatedAt(Instant.now());
            orders.flush();
            touched.forEach(stats::refresh);
            return;
        }
        order.setStatus(next);
        order.setUpdatedAt(Instant.now());
    }

    private Order loadVisible(User principal, UUID id) {
        Order order = orders.findById(id).orElseThrow(() -> ApiException.notFound("Pedido"));
        if (!principal.isAdmin() && !order.getUser().getId().equals(principal.getId())) {
            // 404 en vez de 403: no se confirma que exista el pedido de otra persona
            throw ApiException.notFound("Pedido");
        }
        return order;
    }

    private String newNumber() {
        return numberFor(Instant.now());
    }

    private static String label(OrderStatus status) {
        return switch (status) {
            case PAID -> "pagado";
            case SHIPPED -> "enviado";
            case DELIVERED -> "entregado";
            case CANCELLED -> "cancelado";
        };
    }

    /** Número de pedido para los datos de ejemplo. */
    public String numberFor(Instant date) {
        String number;
        do {
            StringBuilder code = new StringBuilder();
            for (int i = 0; i < 4; i++) code.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
            number = "AM-" + DAY.format(date) + "-" + code;
        } while (orders.existsByNumber(number));
        return number;
    }
}

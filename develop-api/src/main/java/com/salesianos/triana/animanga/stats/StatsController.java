package com.salesianos.triana.animanga.stats;

import com.salesianos.triana.animanga.catalog.CatalogDtos.VolumeDto;
import com.salesianos.triana.animanga.catalog.CatalogMapper;
import com.salesianos.triana.animanga.catalog.MangaRepository;
import com.salesianos.triana.animanga.catalog.VolumeRepository;
import com.salesianos.triana.animanga.order.Order;
import com.salesianos.triana.animanga.order.OrderDtos.OrderDto;
import com.salesianos.triana.animanga.order.OrderRepository;
import com.salesianos.triana.animanga.order.OrderStatus;
import com.salesianos.triana.animanga.user.Role;
import com.salesianos.triana.animanga.user.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.*;

@Tag(name = "Administración · Estadísticas")
@RestController
@RequiredArgsConstructor
public class StatsController {

    public record Totals(long mangas, long volumes, long unitsInStock, long customers, long orders,
                         BigDecimal revenue, BigDecimal averageOrder) {}

    public record MonthPoint(String month, BigDecimal revenue, long orders, long units) {}

    public record TopVolume(UUID volumeId, String title, String coverImage, long units, BigDecimal revenue) {}

    public record StatsDto(Totals totals, List<MonthPoint> revenueByMonth, Map<OrderStatus, Long> ordersByStatus,
                           List<TopVolume> topVolumes, List<VolumeDto> lowStock, List<OrderDto> recentOrders) {}

    private final MangaRepository mangas;
    private final VolumeRepository volumes;
    private final UserRepository users;
    private final OrderRepository orders;

    @Operation(summary = "Métricas del panel: ingresos por mes, pedidos por estado, más vendidos y stock bajo")
    @GetMapping("/admin/stats")
    @Transactional(readOnly = true)
    public StatsDto stats(@RequestParam(defaultValue = "6") int months) {
        months = Math.min(Math.max(months, 1), 24);
        long orderCount = orders.count() - orders.countByStatus(OrderStatus.CANCELLED);
        BigDecimal revenue = orders.totalRevenue();
        BigDecimal average = orderCount == 0 ? BigDecimal.ZERO
                : revenue.divide(BigDecimal.valueOf(orderCount), 2, java.math.RoundingMode.HALF_UP);

        var totals = new Totals(mangas.count(), volumes.count(), volumes.totalStock(), users.countByRole(Role.USER),
                orderCount, revenue, average);

        Map<OrderStatus, Long> byStatus = new EnumMap<>(OrderStatus.class);
        for (OrderStatus s : OrderStatus.values()) byStatus.put(s, orders.countByStatus(s));

        List<TopVolume> top = orders.topVolumes(PageRequest.of(0, 5)).stream()
                .map(r -> new TopVolume((UUID) r[0], (String) r[1], (String) r[2],
                        ((Number) r[3]).longValue(), (BigDecimal) r[4]))
                .toList();

        return new StatsDto(totals, revenueByMonth(months), byStatus, top,
                volumes.findLowStock(5).stream().map(CatalogMapper::volume).toList(),
                orders.findTop5ByOrderByCreatedAtDesc().stream().map(OrderDto::from).toList());
    }

    /** Ingresos de los últimos N meses (incluido el actual), con los meses sin ventas a cero. */
    private List<MonthPoint> revenueByMonth(int months) {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        YearMonth first = current.minusMonths(months - 1L);
        Map<YearMonth, BigDecimal> revenue = new TreeMap<>();
        Map<YearMonth, Long> count = new HashMap<>();
        Map<YearMonth, Long> units = new HashMap<>();
        for (int i = 0; i < months; i++) revenue.put(first.plusMonths(i), BigDecimal.ZERO);

        for (Order o : orders.findActiveSince(first.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC))) {
            YearMonth ym = YearMonth.from(o.getCreatedAt().atZone(ZoneOffset.UTC));
            revenue.computeIfPresent(ym, (k, v) -> v.add(o.getTotal()));
            count.merge(ym, 1L, Long::sum);
            units.merge(ym, (long) o.totalUnits(), Long::sum);
        }
        return revenue.entrySet().stream()
                .map(e -> new MonthPoint(e.getKey().toString(), e.getValue(),
                        count.getOrDefault(e.getKey(), 0L), units.getOrDefault(e.getKey(), 0L)))
                .toList();
    }
}

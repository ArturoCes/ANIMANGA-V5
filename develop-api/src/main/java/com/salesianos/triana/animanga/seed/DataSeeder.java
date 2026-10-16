package com.salesianos.triana.animanga.seed;

import com.salesianos.triana.animanga.catalog.*;
import com.salesianos.triana.animanga.config.AppProperties;
import com.salesianos.triana.animanga.order.*;
import com.salesianos.triana.animanga.review.Review;
import com.salesianos.triana.animanga.review.ReviewRepository;
import com.salesianos.triana.animanga.storage.ImageValidator;
import com.salesianos.triana.animanga.storage.StorageService;
import com.salesianos.triana.animanga.user.Role;
import com.salesianos.triana.animanga.user.User;
import com.salesianos.triana.animanga.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 * Carga los datos de demostración si la base de datos está vacía: categorías, 8 series con
 * volúmenes y personajes, clientes, reseñas y pedidos repartidos en los últimos meses
 * (para que las gráficas del panel tengan datos).
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements ApplicationRunner {

    record SeedVolume(int number, BigDecimal price, int stock, String isbn, String cover) {}

    record SeedCharacter(String name, Integer age, String description, String image) {}

    record SeedSeries(String title, String author, String publisher, LocalDate releaseDate, String synopsis,
                      String cover, List<String> categories, List<SeedVolume> volumes,
                      List<SeedCharacter> characters) {}

    record SeedCategory(String name, String description) {}

    record SeedCustomer(String username, String fullName, String email) {}

    record SeedReview(String user, String series, int rating, String comment) {}

    record SeedData(List<SeedCategory> categories, List<SeedSeries> series, List<SeedCustomer> customers,
                    List<SeedReview> reviews) {}

    private static final String[][] ADDRESSES = {
            {"Calle Feria 12, 2ºB", "Sevilla", "41003"},
            {"Avenida de la Constitución 45", "Madrid", "28013"},
            {"Carrer de Mallorca 220, 4º1ª", "Barcelona", "08008"},
            {"Calle Colón 8", "Valencia", "46004"},
            {"Gran Vía 30, 3ºA", "Bilbao", "48009"},
            {"Calle Larios 5", "Málaga", "29005"},
            {"Paseo Independencia 14", "Zaragoza", "50004"},
            {"Calle Mayor 3", "Granada", "18001"},
    };

    private final AppProperties props;
    private final JsonMapper jsonMapper;
    private final PasswordEncoder passwordEncoder;
    private final StorageService storage;
    private final UserRepository users;
    private final CategoryRepository categories;
    private final MangaRepository mangas;
    private final ReviewRepository reviews;
    private final OrderRepository orders;
    private final OrderService orderService;
    private final MangaStatsUpdater stats;

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws IOException {
        if (!props.seed().enabled()) return;
        copyImages();
        if (mangas.count() > 0) return;

        SeedData data;
        try (InputStream in = new ClassPathResource("seed/catalog.json").getInputStream()) {
            data = jsonMapper.readValue(in, SeedData.class);
        }

        users.save(User.builder().username("admin").fullName("Administrador").email("admin@animanga.dev")
                .password(passwordEncoder.encode(props.seed().adminPassword())).role(Role.ADMIN)
                .emailVerified(true).avatar(avatar("Administrador")).build());

        Map<String, User> customers = new LinkedHashMap<>();
        for (SeedCustomer c : data.customers()) {
            customers.put(c.username(), users.save(User.builder().username(c.username()).fullName(c.fullName())
                    .email(c.email()).password(passwordEncoder.encode(props.seed().userPassword()))
                    .role(Role.USER).emailVerified(true).avatar(avatar(c.fullName()))
                    .createdAt(Instant.now().minus(200, ChronoUnit.DAYS)).build()));
        }

        Map<String, Category> categoryByName = new HashMap<>();
        for (SeedCategory c : data.categories()) {
            categoryByName.put(c.name(), categories.save(Category.builder().name(c.name()).description(c.description()).build()));
        }

        Map<String, Manga> mangaByTitle = new LinkedHashMap<>();
        for (SeedSeries s : data.series()) {
            Manga manga = Manga.builder().title(s.title()).author(s.author()).publisher(s.publisher())
                    .releaseDate(s.releaseDate()).synopsis(s.synopsis()).coverImage(s.cover())
                    .categories(new HashSet<>(s.categories().stream().map(categoryByName::get).toList()))
                    .createdAt(Instant.now().minus(180, ChronoUnit.DAYS))
                    .build();
            for (SeedVolume v : s.volumes()) {
                manga.addVolume(Volume.builder().number(v.number()).title(s.title() + " " + v.number())
                        .price(v.price()).stock(v.stock()).isbn(v.isbn()).coverImage(v.cover()).build());
            }
            for (SeedCharacter c : s.characters()) {
                manga.addCharacter(MangaCharacter.builder().name(c.name()).age(c.age())
                        .description(c.description()).image(c.image()).build());
            }
            mangaByTitle.put(s.title(), mangas.save(manga));
        }

        Random reviewDates = new Random(7);
        for (SeedReview r : data.reviews()) {
            reviews.save(Review.builder().user(customers.get(r.user())).manga(mangaByTitle.get(r.series()))
                    .rating(r.rating()).comment(r.comment())
                    .createdAt(Instant.now().minus(reviewDates.nextInt(90) + 1L, ChronoUnit.DAYS))
                    .build());
        }

        seedOrders(new ArrayList<>(customers.values()), new ArrayList<>(mangaByTitle.values()));

        // Favoritos del usuario demo para que la app muestre recomendaciones
        User demo = customers.get("demo");
        demo.getFavorites().add(mangaByTitle.get("Spy×Family"));
        demo.getFavorites().add(mangaByTitle.get("Chainsaw Man"));

        mangas.flush();
        mangaByTitle.values().forEach(stats::refresh);
        log.info("Datos de demostración cargados: {} series, {} clientes, {} pedidos",
                mangaByTitle.size(), customers.size(), orders.count());
    }

    /** Pedidos deterministas repartidos en los últimos 6 meses (las ventas crecen mes a mes). */
    private void seedOrders(List<User> customers, List<Manga> catalog) {
        Random random = new Random(42);
        List<Volume> allVolumes = catalog.stream().flatMap(m -> m.getVolumes().stream()).toList();
        Instant now = Instant.now();
        int[] ordersPerMonth = {3, 4, 4, 5, 6, 4};

        for (int monthsAgo = 5; monthsAgo >= 0; monthsAgo--) {
            for (int i = 0; i < ordersPerMonth[5 - monthsAgo]; i++) {
                long daysAgo = monthsAgo * 30L + random.nextInt(monthsAgo == 0 ? 10 : 28);
                Instant date = now.minus(daysAgo, ChronoUnit.DAYS).minus(random.nextInt(600), ChronoUnit.MINUTES);
                User customer = customers.get(random.nextInt(customers.size()));
                String[] addr = ADDRESSES[random.nextInt(ADDRESSES.length)];

                OrderStatus status = daysAgo > 14 ? OrderStatus.DELIVERED
                        : daysAgo > 5 ? OrderStatus.SHIPPED : OrderStatus.PAID;
                if (random.nextInt(12) == 0) status = OrderStatus.CANCELLED;

                Order order = Order.builder()
                        .number(orderService.numberFor(date))
                        .user(customer)
                        .status(status)
                        .shipping(new ShippingAddress(customer.getFullName(), addr[0], addr[1], addr[2],
                                "6" + (10000000 + random.nextInt(89999999))))
                        .cardLast4(List.of("4242", "4444", "1881", "0005").get(random.nextInt(4)))
                        .total(BigDecimal.ZERO)
                        .createdAt(date)
                        .updatedAt(date.plus(2, ChronoUnit.DAYS))
                        .build();

                Set<Volume> picked = new LinkedHashSet<>();
                int lines = 1 + random.nextInt(3);
                while (picked.size() < lines) picked.add(allVolumes.get(random.nextInt(allVolumes.size())));
                BigDecimal total = BigDecimal.ZERO;
                for (Volume v : picked) {
                    int qty = 1 + (random.nextInt(4) == 0 ? 1 : 0);
                    order.addLine(OrderLine.builder().volume(v).volumeTitle(v.getTitle())
                            .mangaTitle(v.getManga().getTitle()).mangaId(v.getManga().getId())
                            .coverImage(v.getCoverImage()).unitPrice(v.getPrice()).quantity(qty).build());
                    total = total.add(v.getPrice().multiply(BigDecimal.valueOf(qty)));
                }
                order.setTotal(total);
                orders.save(order);
            }
        }
    }

    /** Copia las portadas de ejemplo al almacén de imágenes si aún no están. */
    private void copyImages() throws IOException {
        var resolver = new org.springframework.core.io.support.PathMatchingResourcePatternResolver();
        for (var resource : resolver.getResources("classpath:seed/covers/*")) {
            String name = resource.getFilename();
            if (name == null || storage.exists(name)) continue;
            try (InputStream in = resource.getInputStream()) {
                storage.save(name, in.readAllBytes(), ImageValidator.contentTypeOf(name));
            }
        }
    }

    private static String avatar(String fullName) {
        return "https://ui-avatars.com/api/?background=673ab7&color=fff&name=" + fullName.replace(" ", "+");
    }
}

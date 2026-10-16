package com.salesianos.triana.animanga.imagesearch;

import com.salesianos.triana.animanga.catalog.CatalogDtos.MangaSummary;
import com.salesianos.triana.animanga.catalog.CatalogMapper;
import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.catalog.MangaRepository;
import com.salesianos.triana.animanga.catalog.Volume;
import com.salesianos.triana.animanga.storage.ImageValidator;
import com.salesianos.triana.animanga.storage.StorageException;
import com.salesianos.triana.animanga.storage.StorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Busca en el catálogo el manga que aparece en una foto o captura, comparándola con todas las portadas
 * (la de la serie y la de cada volumen).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ImageSearchService {

    /** A partir de aquí se considera que la foto es de esa portada. */
    static final double MATCH_THRESHOLD = 0.62;
    /** Con fotos peores también vale si destaca claramente sobre el segundo. */
    static final double WEAK_MATCH_THRESHOLD = 0.5;
    static final double CLEAR_MARGIN = 0.15;
    /** Por debajo no se sugiere ni como "parecido". */
    static final double SUGGESTION_THRESHOLD = 0.35;
    private static final int MAX_RESULTS = 5;

    public record ImageMatch(MangaSummary manga, Integer volumeNumber, String cover, int similarity) {}

    public record ImageSearchResult(boolean found, List<ImageMatch> matches) {}

    private record Cover(Manga manga, Volume volume, String image) {}

    private final MangaRepository mangas;
    private final StorageService storage;

    /** Huellas de las portadas por nombre de fichero. Los nombres son únicos, así que no caducan. */
    private final Map<String, Optional<ImageFingerprint>> index = new ConcurrentHashMap<>();

    /** Calcula las huellas al arrancar para que la primera búsqueda sea rápida. */
    @EventListener(ApplicationReadyEvent.class)
    @Transactional(readOnly = true)
    public void warmUp() {
        long start = System.currentTimeMillis();
        long indexed = covers().stream().map(c -> fingerprint(c.image())).filter(Optional::isPresent).count();
        log.info("Búsqueda por imagen: {} portadas indexadas en {} ms", indexed, System.currentTimeMillis() - start);
    }

    @Transactional(readOnly = true)
    public ImageSearchResult search(MultipartFile file) {
        byte[] data;
        try {
            data = file.getBytes();
        } catch (IOException e) {
            throw new StorageException("No se ha podido leer la imagen");
        }
        ImageValidator.validate(data, file.getOriginalFilename());
        List<ImageFingerprint> query = ImageDecoder.candidates(ImageDecoder.decode(data)).stream()
                .map(ImageFingerprint::of).toList();

        // Mejor puntuación por manga (puede coincidir con la portada de la serie o con la de un tomo)
        Map<UUID, ImageMatch> best = new LinkedHashMap<>();
        for (Cover cover : covers()) {
            Optional<ImageFingerprint> fp = fingerprint(cover.image());
            if (fp.isEmpty()) continue;
            double score = query.stream().mapToDouble(q -> q.similarity(fp.get())).max().orElse(0);
            if (score < SUGGESTION_THRESHOLD) continue;
            ImageMatch current = best.get(cover.manga().getId());
            int similarity = (int) Math.round(score * 100);
            // Si la portada de la serie y la del tomo son la misma, se prefiere el tomo (dice cuál comprar)
            boolean better = current == null || similarity > current.similarity()
                    || (similarity == current.similarity() && cover.volume() != null && current.volumeNumber() == null);
            if (better) {
                best.put(cover.manga().getId(), new ImageMatch(CatalogMapper.summary(cover.manga()),
                        cover.volume() == null ? null : cover.volume().getNumber(), cover.image(), similarity));
            }
        }
        List<ImageMatch> matches = best.values().stream()
                .sorted(Comparator.comparingInt(ImageMatch::similarity).reversed())
                .limit(MAX_RESULTS)
                .toList();
        return new ImageSearchResult(isClearMatch(matches), matches);
    }

    private static boolean isClearMatch(List<ImageMatch> matches) {
        if (matches.isEmpty()) return false;
        int top = matches.get(0).similarity();
        int second = matches.size() > 1 ? matches.get(1).similarity() : 0;
        return top >= MATCH_THRESHOLD * 100
                || (top >= WEAK_MATCH_THRESHOLD * 100 && top - second >= CLEAR_MARGIN * 100);
    }

    private List<Cover> covers() {
        List<Cover> covers = new ArrayList<>();
        for (Manga m : mangas.findAll()) {
            if (isLocal(m.getCoverImage())) covers.add(new Cover(m, null, m.getCoverImage()));
            for (Volume v : m.getVolumes()) {
                if (isLocal(v.getCoverImage())) covers.add(new Cover(m, v, v.getCoverImage()));
            }
        }
        return covers;
    }

    private Optional<ImageFingerprint> fingerprint(String image) {
        return index.computeIfAbsent(image, name -> storage.load(name).flatMap(stored -> {
            try {
                BufferedImage decoded = ImageDecoder.decode(stored.data());
                return Optional.of(ImageFingerprint.of(decoded));
            } catch (StorageException e) {
                log.warn("No se ha podido indexar la portada {}: {}", name, e.getMessage());
                return Optional.empty();
            }
        }));
    }

    private static boolean isLocal(String image) {
        return image != null && !image.isBlank() && !image.startsWith("http");
    }
}

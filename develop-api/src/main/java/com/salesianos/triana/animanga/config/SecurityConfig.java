package com.salesianos.triana.animanga.config;

import com.salesianos.triana.animanga.security.JsonSecurityHandlers;
import com.salesianos.triana.animanga.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final JsonSecurityHandlers handlers;
    private final AppProperties props;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // API sin cookies: el token va en la cabecera
                .cors(Customizer.withDefaults())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(e -> e
                        .authenticationEntryPoint(handlers.entryPoint())
                        .accessDeniedHandler(handlers.accessDenied()))
                .headers(h -> h.frameOptions(f -> f.sameOrigin())) // consola H2 en desarrollo
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Autenticación y cuentas
                        .requestMatchers("/auth/verify-email/resend").authenticated()
                        .requestMatchers("/auth/**").permitAll()
                        // Lectura pública del catálogo: se puede navegar sin cuenta
                        .requestMatchers(HttpMethod.GET, "/mangas/**", "/categories/**", "/images/**").permitAll()
                        // Documentación, salud y consola H2
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html",
                                "/actuator/health", "/h2-console/**", "/error").permitAll()
                        // Administración
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/mangas/*/reviews").authenticated()
                        .requestMatchers(HttpMethod.POST, "/mangas/**", "/volumes/**", "/categories/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/mangas/**", "/volumes/**", "/characters/**", "/categories/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/mangas/**", "/volumes/**", "/characters/**", "/categories/**").hasRole("ADMIN")
                        // Resto (carrito, pedidos, perfil, favoritos, reseñas propias): sesión iniciada
                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(props.cors().allowedOrigins());
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    /** La autenticación es propia (AuthService); este bean evita el usuario por defecto de Spring Boot. */
    @Bean
    UserDetailsService userDetailsService() {
        return username -> {
            throw new UsernameNotFoundException(username);
        };
    }
}

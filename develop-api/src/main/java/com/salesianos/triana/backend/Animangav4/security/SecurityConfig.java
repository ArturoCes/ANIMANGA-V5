package com.salesianos.triana.backend.Animangav4.security;

import com.salesianos.triana.backend.Animangav4.security.jwt.access.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsService userDetailsService;
    private final PasswordEncoder passwordEncoder;

    private final AuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final AccessDeniedHandler jwtAccessDeniedHandler;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
        AuthenticationManagerBuilder authenticationManagerBuilder =
                http.getSharedObject(AuthenticationManagerBuilder.class);

        return authenticationManagerBuilder.authenticationProvider(authenticationProvider())
                .build();
    }


    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authenticationProvider = new DaoAuthenticationProvider();

        authenticationProvider.setUserDetailsService(userDetailsService);
        authenticationProvider.setPasswordEncoder(passwordEncoder);
        // No revelamos si el usuario existe o no: siempre "Bad credentials"
        authenticationProvider.setHideUserNotFoundExceptions(true);

        return authenticationProvider;
    }


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .cors(Customizer.withDefaults())
                .csrf().disable()
                .exceptionHandling()
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                .accessDeniedHandler(jwtAccessDeniedHandler)
                .and()
                .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .authorizeRequests()
                // Público
                .antMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .antMatchers("/auth/login", "/auth/register", "/refreshtoken").permitAll()
                .antMatchers(HttpMethod.GET, "/download/**").permitAll()
                .antMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html", "/swagger-resources/**").permitAll()
                .antMatchers("/h2-console/**").permitAll()

                // Solo administradores
                .antMatchers("/auth/register/admin").hasRole("ADMIN")
                .antMatchers("/upload", "/upload/**").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/all").hasRole("ADMIN")
                .antMatchers(HttpMethod.POST, "/find/").hasRole("ADMIN")
                .antMatchers("/give/admin/**", "/remove/admin/**").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/purchase/all").hasRole("ADMIN")
                .antMatchers(HttpMethod.POST, "/category/find/").hasRole("ADMIN")

                // Favoritos y búsqueda: cualquier usuario autenticado
                .antMatchers("/manga/favorite/**", "/manga/all/favorite/**").authenticated()
                .antMatchers(HttpMethod.POST, "/manga/search/all").authenticated()

                // Escritura de catálogo: solo administradores
                .antMatchers(HttpMethod.POST, "/manga/**", "/volumen/**", "/category/**").hasRole("ADMIN")
                .antMatchers(HttpMethod.PUT, "/manga/**", "/volumen/**", "/category/**").hasRole("ADMIN")
                .antMatchers(HttpMethod.DELETE, "/manga/**", "/volumen/**", "/category/**").hasRole("ADMIN")

                // Lectura de catálogo, carrito, compras propias y perfil
                .anyRequest().authenticated();


        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        // Necesario para la consola H2 en desarrollo
        http.headers().frameOptions().sameOrigin();

        return http.build();
    }

}

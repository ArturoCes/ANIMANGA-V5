package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Cart;
import com.salesianos.triana.backend.Animangav4.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ApplicationStartup implements ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CartRepository cartRepository;

    @Override
    public void onApplicationEvent(final ApplicationReadyEvent event) {
        List<User> users = userRepository.findAll();
        for (User user : users) {
            if (user.getCarrito() == null) {
                Cart cart = new Cart();
                cart.setUser(user);
                cartRepository.save(cart);
                user.setCarrito(cart);
                userRepository.save(user);
            }
        }
    }
}

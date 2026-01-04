package com.itkannadigaru.service;

import com.itkannadigaru.model.User;
import com.itkannadigaru.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public boolean usernameTaken(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean emailTaken(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional
    public boolean register(String username, String email, String rawPassword) {
        if (usernameTaken(username) || emailTaken(email)) {
            return false;
        }
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(rawPassword));
        return userRepository.save(user) > 0;
    }
}

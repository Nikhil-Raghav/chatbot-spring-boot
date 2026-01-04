package com.itkannadigaru.controller;

import com.itkannadigaru.model.Post;
import com.itkannadigaru.service.PostService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class HomeController {

    private final PostService postService;

    public HomeController(PostService postService) {
        this.postService = postService;
    }

    @GetMapping("/")
    public String home(Model model, Authentication authentication) {
        model.addAttribute("title", "Home - ITKANNADIGARU");

        if (authentication != null) {
            model.addAttribute("username", authentication.getName());
        }

        // Get all posts for display on home page
        List<Post> posts = postService.getAllPosts();
        model.addAttribute("posts", posts);

        return "index";
    }

    @GetMapping("/home/facts")
    public String facts(Model model) {
        model.addAttribute("title", "Facts - ITKANNADIGARU");
        return "facts";
    }

    @GetMapping("/jobs")
    public String jobs(Model model) {
        model.addAttribute("title", "Jobs - ITKANNADIGARU");
        return "jobs";
    }
}

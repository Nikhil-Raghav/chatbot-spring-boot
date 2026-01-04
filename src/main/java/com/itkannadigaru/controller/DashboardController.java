package com.itkannadigaru.controller;

import com.itkannadigaru.model.Post;
import com.itkannadigaru.service.PostService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    private final PostService postService;

    public DashboardController(PostService postService) {
        this.postService = postService;
    }

    @GetMapping
    public String dashboard(Model model, Authentication authentication) {
        model.addAttribute("username", authentication.getName());
        model.addAttribute("post", new Post());

        // Get all posts for display
        List<Post> posts = postService.getAllPosts();
        model.addAttribute("posts", posts);

        return "dashboard";
    }

    @PostMapping("/post")
    public String createPost(@ModelAttribute Post post,
                            Authentication authentication,
                            RedirectAttributes redirectAttributes) {
        post.setAuthor(authentication.getName());

        postService.createPost(post);

        redirectAttributes.addFlashAttribute("success", "Post created successfully!");
        return "redirect:/dashboard";
    }

    @PostMapping("/post/delete/{id}")
    public String deletePost(@PathVariable Long id,
                            Authentication authentication,
                            RedirectAttributes redirectAttributes) {
        Post post = postService.getPostById(id);

        // Only allow users to delete their own posts
        if (post != null && post.getAuthor().equals(authentication.getName())) {
            postService.deletePost(id);
            redirectAttributes.addFlashAttribute("success", "Post deleted successfully!");
        } else {
            redirectAttributes.addFlashAttribute("error", "You can only delete your own posts!");
        }

        return "redirect:/dashboard";
    }
}

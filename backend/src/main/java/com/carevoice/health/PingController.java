package com.carevoice.health;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

/**
 * Simple endpoint the frontend calls to confirm the backend is up.
 * It also writes a structured log line, so you can confirm logs reach Splunk.
 */
@RestController
@RequestMapping("/api")
public class PingController {

    private static final Logger log = LoggerFactory.getLogger(PingController.class);

    @GetMapping("/ping")
    public Map<String, Object> ping() {
        log.info("ping received");
        return Map.of(
                "service", "carevoice-backend",
                "status", "ok",
                "time", Instant.now().toString()
        );
    }
}

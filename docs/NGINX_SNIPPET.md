Nginx Snippet — Hypernode Public Endpoints
==========================================

Goal: expose only Hypernode onboarding and liveness endpoints; keep other APIs private.

Adjust `server_name`, upstream `factory_upstream`, and TLS as needed.

```
upstream factory_upstream {
  server 127.0.0.1:3101; # Factory app
  keepalive 64;
}

server {
  listen 80;
  server_name factory.example.com;

  # Allow only handshake, register-node, heartbeat, hypernode status
  location = /api/fabrik/hypernode/handshake { proxy_pass http://factory_upstream; }
  location = /api/fabrik/hypernode/status   { proxy_pass http://factory_upstream; }
  location = /api/hypergraph/register-node  { proxy_pass http://factory_upstream; }
  location = /api/hypergraph/heartbeat      { proxy_pass http://factory_upstream; }

  # Deny everything else under /api by default
  location ^~ /api/ {
    return 403;
  }

  # (Optional) serve Identity assets if desired
  location ^~ /identity/ {
    proxy_pass http://factory_upstream;
  }

  # Health
  location = /api/health { proxy_pass http://factory_upstream; }

  # Default: deny root
  location / { return 403; }
}
```

Notes
- If running TLS, add `listen 443 ssl http2;` and SSL directives.
- Consider rate limiting and allow-lists on `/api/fabrik/hypernode/handshake`.
- When `HYPERNODE_REQUIRE_TOKEN=1`, register/heartbeat will validate server‑issued tokens.


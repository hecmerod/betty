---
description: Deploy to Raspberry Pi production
---

# Deploy to Raspberry Pi

This workflow builds and deploys the Betty server to production on Raspberry Pi.

## Steps

1. Build the production bundle:

```bash
npm run betty-server:build
```

2. Start with PM2 (recommended for production):

```bash
npm run pm2:start
```

3. Check PM2 status:

```bash
npm run pm2:status
```

4. Verify the server is running:

```bash
curl http://localhost:3000/api/health
```

## Monitoring

View logs:

```bash
pm2 logs betty-server
```

Check system resources:

```bash
curl http://localhost:3000/api/system
```

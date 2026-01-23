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

## CI/CD (Automated Deployment)

Pushing to `main` triggers automatic deployment via GitHub Actions.

1. Tests run on GitHub's servers
2. Deploy runs on the Raspberry Pi (self-hosted runner)
3. PM2 restarts the server automatically

See `.github/RUNNER_SETUP.md` for runner installation.

---

## Monitoring

View logs:

```bash
pm2 logs betty-server
```

Check system resources:

```bash
curl http://localhost:3000/api/system
```

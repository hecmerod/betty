---
description: Run tests for the project
---

# Run Tests

This workflow runs the test suite for the Betty server.

## Steps

// turbo-all

1. Run unit tests:

```bash
npm run betty-server:test
```

2. Run tests in watch mode (for development):

```bash
npm run betty-server:test:watch
```

3. Run linting:

```bash
npx nx lint betty-server
```

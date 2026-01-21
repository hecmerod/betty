---
description: Generate a new NestJS module
---

# Generate New NestJS Module

This workflow helps you create new modules, services, or controllers in the Betty server.

## Steps

1. Generate a complete REST resource (includes controller, service, module, DTO):

```bash
npx nx g @nx/nest:resource <resource-name> --project=betty-server
```

2. Or generate individual components:

Generate a service:

```bash
npx nx g @nx/nest:service <service-name> --project=betty-server
```

Generate a controller:

```bash
npx nx g @nx/nest:controller <controller-name> --project=betty-server
```

Generate a module:

```bash
npx nx g @nx/nest:module <module-name> --project=betty-server
```

## Example

To create a "users" resource:

```bash
npx nx g @nx/nest:resource users --project=betty-server
```

This will create:

- `users.controller.ts`
- `users.service.ts`
- `users.module.ts`
- `dto/create-user.dto.ts`
- `dto/update-user.dto.ts`
- `entities/user.entity.ts`

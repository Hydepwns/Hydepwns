---
title: Authentication API
description: Documentation for the Hydepwns authentication API endpoints
topics:
  - api
  - authentication
  - bearer-token
  - api-keys
  - endpoints
  - security
last_updated: '2025-03-14'
---

# Authentication API

## Overview

The Authentication API provides endpoints for managing user authentication and access tokens.

## Endpoints

### Login

```http
POST /api/v1/auth/login
```

Authenticates a user and returns an access token.

#### Request Body

```json
{
  "username": "string",
  "password": "string"
}
```

#### Response

```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "expires_in": 86400
}
```

### Refresh Token

```http
POST /api/v1/auth/refresh
```

Refreshes an expired access token.

#### Request Headers

```http
Authorization: Bearer <expired_token>
```

#### Response

```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "expires_in": 86400
}
```

### Logout

```http
POST /api/v1/auth/logout
```

Invalidates the current access token.

#### Request Headers

```http
Authorization: Bearer <access_token>
```

## API Keys

### Generate API Key

```http
POST /api/v1/auth/api-keys
```

Generates a new API key for service-to-service authentication.

#### Request Headers

```http
Authorization: Bearer <access_token>
```

#### Request Body

```json
{
  "name": "string",
  "permissions": ["string"],
  "expiration": "string (ISO date, optional)"
}
```

### List API Keys

```http
GET /api/v1/auth/api-keys
```

Lists all API keys for the authenticated user.

#### Request Headers

```http
Authorization: Bearer <access_token>
```

### Revoke API Key

```http
DELETE /api/v1/auth/api-keys/{key_id}
```

Revokes an API key.

#### Request Headers

```http
Authorization: Bearer <access_token>
```

## Security Considerations

1. Always use HTTPS for API requests
2. Store tokens securely
3. Rotate API keys regularly
4. Use appropriate token expiration times
5. Implement rate limiting for authentication endpoints

## Error Responses

Authentication errors return standard HTTP status codes:

- 401 Unauthorized: Invalid credentials
- 403 Forbidden: Insufficient permissions
- 429 Too Many Requests: Rate limit exceeded 
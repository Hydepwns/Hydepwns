---
title: Users API
description: Documentation for the Hydepwns users API endpoints
topics:
  - api
  - users
  - user-management
  - authentication
  - authorization
last_updated: '2025-03-14'
---

# Users API

## Overview

The Users API provides endpoints for managing user accounts, profiles, and permissions in the Hydepwns system.

## Endpoints

### List Users

```http
GET /api/v1/users
```

Lists users based on specified filters.

#### Query Parameters

- `role`: Filter by user role
- `status`: Filter by account status
- `page`: Page number
- `limit`: Users per page
- `sort`: Sort field and direction

#### Response

```json
{
  "data": [
    {
      "id": "string",
      "type": "user",
      "attributes": {
        "username": "string",
        "email": "string",
        "full_name": "string",
        "role": "string",
        "status": "string",
        "created_at": "string",
        "last_login": "string"
      }
    }
  ],
  "meta": {
    "total": 0,
    "page": 1,
    "limit": 10
  }
}
```

### Get User

```http
GET /api/v1/users/{user_id}
```

Retrieves details about a specific user.

### Create User

```http
POST /api/v1/users
```

Creates a new user account.

#### Request Body

```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "full_name": "string",
  "role": "string"
}
```

### Update User

```http
PATCH /api/v1/users/{user_id}
```

Updates an existing user's information.

#### Request Body

```json
{
  "email": "string",
  "full_name": "string",
  "role": "string",
  "status": "string"
}
```

### Delete User

```http
DELETE /api/v1/users/{user_id}
```

Deletes a user account.

### Get Current User

```http
GET /api/v1/users/me
```

Retrieves the authenticated user's information.

### Update Password

```http
POST /api/v1/users/{user_id}/password
```

Updates a user's password.

#### Request Body

```json
{
  "current_password": "string",
  "new_password": "string"
}
```

## User Roles and Permissions

### List Roles

```http
GET /api/v1/roles
```

Lists available user roles.

### Assign Role

```http
POST /api/v1/users/{user_id}/roles
```

Assigns roles to a user.

#### Request Body

```json
{
  "roles": ["string"]
}
```

### Check Permission

```http
GET /api/v1/users/{user_id}/permissions/{permission}
```

Checks if a user has a specific permission.

## Profile Management

### Get Profile

```http
GET /api/v1/users/{user_id}/profile
```

Retrieves a user's profile information.

### Update Profile

```http
PATCH /api/v1/users/{user_id}/profile
```

Updates a user's profile information.

#### Request Body

```json
{
  "avatar_url": "string",
  "bio": "string",
  "preferences": {
    "theme": "string",
    "notifications": {
      "email": true,
      "push": true
    }
  }
}
```

## Error Handling

User operations return standard HTTP status codes:

- 400 Bad Request: Invalid user data
- 403 Forbidden: Insufficient permissions
- 404 Not Found: User not found
- 409 Conflict: Username/email already exists
- 422 Unprocessable Entity: Validation error

## Security

### Password Requirements

- Minimum length: 8 characters
- Must contain: uppercase, lowercase, number, special character
- Cannot be same as last 3 passwords
- Maximum age: 90 days

### Account Lockout

- Account locked after 5 failed login attempts
- 30-minute lockout period
- Requires admin unlock or password reset after 3 lockouts

## Rate Limiting

User endpoints are subject to rate limiting:

- 100 requests per hour for user operations
- 10 password change attempts per hour
- 5 failed login attempts before lockout 
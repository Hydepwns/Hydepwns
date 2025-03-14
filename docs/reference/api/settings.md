---
title: Settings API
description: Documentation for the Hydepwns settings API endpoints
topics:
  - api
  - settings
  - configuration
  - preferences
  - system-settings
last_updated: '2025-03-14'
---

# Settings API

## Overview

The Settings API provides endpoints for managing system-wide settings and user preferences in the Hydepwns system.

## Setting Types

- System Settings
- User Preferences
- Application Configuration
- Feature Flags
- Integration Settings

## Endpoints

### List Settings

```http
GET /api/v1/settings
```

Lists all available settings based on scope and access level.

#### Query Parameters

- `scope`: Filter by setting scope (system, user, app)
- `category`: Filter by setting category
- `page`: Page number
- `limit`: Settings per page

#### Response

```json
{
  "data": [
    {
      "id": "string",
      "type": "setting",
      "attributes": {
        "key": "string",
        "value": "any",
        "scope": "string",
        "category": "string",
        "description": "string",
        "data_type": "string",
        "default_value": "any",
        "allowed_values": ["any"],
        "requires_restart": false
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

### Get Setting

```http
GET /api/v1/settings/{setting_key}
```

Retrieves a specific setting's value and metadata.

### Update Setting

```http
PATCH /api/v1/settings/{setting_key}
```

Updates a setting's value.

#### Request Body

```json
{
  "value": "any"
}
```

### Bulk Update Settings

```http
POST /api/v1/settings/bulk
```

Updates multiple settings at once.

#### Request Body

```json
{
  "settings": [
    {
      "key": "string",
      "value": "any"
    }
  ]
}
```

## User Preferences

### Get User Preferences

```http
GET /api/v1/users/{user_id}/preferences
```

Retrieves all preferences for a specific user.

### Update User Preference

```http
PATCH /api/v1/users/{user_id}/preferences/{preference_key}
```

Updates a specific user preference.

#### Request Body

```json
{
  "value": "any"
}
```

## Feature Flags

### List Feature Flags

```http
GET /api/v1/settings/features
```

Lists all feature flags and their states.

### Update Feature Flag

```http
PATCH /api/v1/settings/features/{flag_key}
```

Updates a feature flag's state.

#### Request Body

```json
{
  "enabled": true,
  "rollout_percentage": 100
}
```

## Integration Settings

### List Integrations

```http
GET /api/v1/settings/integrations
```

Lists all integration settings.

### Update Integration

```http
PATCH /api/v1/settings/integrations/{integration_key}
```

Updates integration settings.

#### Request Body

```json
{
  "enabled": true,
  "config": {
    "api_key": "string",
    "endpoint": "string"
  }
}
```

## Setting Categories

### System Settings

```json
{
  "logging": {
    "level": "string",
    "retention_days": "number"
  },
  "security": {
    "session_timeout": "number",
    "password_policy": "object"
  },
  "performance": {
    "cache_size": "number",
    "worker_threads": "number"
  }
}
```

### User Preferences

```json
{
  "ui": {
    "theme": "string",
    "language": "string",
    "timezone": "string"
  },
  "notifications": {
    "email": "boolean",
    "push": "boolean",
    "frequency": "string"
  }
}
```

## Error Handling

Setting operations return standard HTTP status codes:

- 400 Bad Request: Invalid setting value
- 403 Forbidden: Insufficient permissions
- 404 Not Found: Setting not found
- 422 Unprocessable Entity: Validation error

## Validation

- Type checking for setting values
- Range validation for numeric settings
- Pattern matching for string settings
- Enum validation for predefined values
- Dependency checking between settings

## Rate Limiting

Setting endpoints are subject to rate limiting:

- 100 reads per minute
- 20 writes per minute
- 5 bulk operations per minute 
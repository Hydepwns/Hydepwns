---
title: Resources API
description: Documentation for the Hydepwns resources API endpoints
topics:
  - api
  - resources
  - crud
  - endpoints
  - management
last_updated: '2025-03-14'
---

# Resources API

## Overview

The Resources API provides endpoints for managing resources in the Hydepwns system. Resources are the core data objects that can be created, read, updated, and deleted.

## Resource Types

- Projects
- Components
- Configurations
- Templates
- Assets

## Endpoints

### List Resources

```http
GET /api/v1/resources
```

Lists all resources the authenticated user has access to.

#### Query Parameters

- `type`: Filter by resource type
- `status`: Filter by resource status
- `page`: Page number for pagination
- `limit`: Number of items per page
- `sort`: Sort field and direction (e.g., "name:asc")

#### Response

```json
{
  "data": [
    {
      "id": "string",
      "type": "string",
      "attributes": {
        "name": "string",
        "description": "string",
        "created_at": "string",
        "updated_at": "string",
        "status": "string"
      },
      "relationships": {
        "owner": {
          "data": {
            "id": "string",
            "type": "users"
          }
        }
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

### Get Resource

```http
GET /api/v1/resources/{resource_id}
```

Retrieves a specific resource by ID.

#### Response

```json
{
  "data": {
    "id": "string",
    "type": "string",
    "attributes": {
      "name": "string",
      "description": "string",
      "created_at": "string",
      "updated_at": "string",
      "status": "string"
    },
    "relationships": {
      "owner": {
        "data": {
          "id": "string",
          "type": "users"
        }
      }
    }
  }
}
```

### Create Resource

```http
POST /api/v1/resources
```

Creates a new resource.

#### Request Body

```json
{
  "type": "string",
  "attributes": {
    "name": "string",
    "description": "string",
    "status": "string"
  }
}
```

### Update Resource

```http
PATCH /api/v1/resources/{resource_id}
```

Updates an existing resource.

#### Request Body

```json
{
  "attributes": {
    "name": "string",
    "description": "string",
    "status": "string"
  }
}
```

### Delete Resource

```http
DELETE /api/v1/resources/{resource_id}
```

Deletes a resource.

## Resource Relationships

### List Related Resources

```http
GET /api/v1/resources/{resource_id}/relationships/{relationship}
```

Lists resources related to the specified resource.

### Add Relationship

```http
POST /api/v1/resources/{resource_id}/relationships/{relationship}
```

Adds a relationship between resources.

### Remove Relationship

```http
DELETE /api/v1/resources/{resource_id}/relationships/{relationship}/{related_id}
```

Removes a relationship between resources.

## Error Handling

Resource operations return standard HTTP status codes:

- 400 Bad Request: Invalid resource data
- 404 Not Found: Resource not found
- 409 Conflict: Resource conflict
- 422 Unprocessable Entity: Validation error

## Rate Limiting

Resource endpoints are subject to rate limiting:

- 1000 requests per hour for authenticated users
- 100 requests per hour for unauthenticated users 
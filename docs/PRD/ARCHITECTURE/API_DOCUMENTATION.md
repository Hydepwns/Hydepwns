# API Documentation

## Overview

This document provides comprehensive documentation for the Hydepwns API, including endpoints, request/response formats, authentication, error handling, and usage examples.

## API Versioning

The API uses semantic versioning (MAJOR.MINOR.PATCH) with all endpoints prefixed by version:
- `/api/v1/*` - Current stable version
- `/api/v2/*` - Beta features (if available)

## Authentication

### Bearer Token

Most API endpoints require authentication using a Bearer token in the Authorization header:

```http
Authorization: Bearer <your_access_token>
```

### API Keys

For service-to-service integrations, API keys can be used:

```http
X-API-Key: <your_api_key>
```

## Common Response Format

All API responses follow this standard format:

```json
{
  "status": "success", // or "error"
  "data": {}, // the response data
  "meta": {}, // pagination, filtering info
  "message": "" // success or error message
}
```

## Error Handling

HTTP status codes are used appropriately:
- 200 - Success
- 400 - Bad Request
- 401 - Unauthorized
- 403 - Forbidden
- 404 - Not Found
- 500 - Server Error

Errors include details in the response body:

```json
{
  "status": "error",
  "message": "Resource not found",
  "errors": [
    {
      "code": "NOT_FOUND",
      "detail": "The requested resource with ID '123' does not exist"
    }
  ]
}
```

## Rate Limiting

API requests are subject to rate limiting:
- 100 requests per minute per API key/token
- Headers included: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Endpoints

### Resources

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/resources` | GET | List all resources |
| `/api/v1/resources/:id` | GET | Get a specific resource |
| `/api/v1/resources` | POST | Create a new resource |
| `/api/v1/resources/:id` | PUT | Update a resource |
| `/api/v1/resources/:id` | DELETE | Delete a resource |

### Relationship Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/resources/:id/relationships` | GET | List all relationships |
| `/api/v1/resources/:id/relationships/:type` | GET | Get relationships of a specific type |
| `/api/v1/resources/:id/relationships/:type` | POST | Create relationship |
| `/api/v1/resources/:id/relationships/:type/:target_id` | DELETE | Delete relationship |

## Changes and Updates

The API is continuously evolving. For a complete list of changes, please refer to the [CHANGELOG](../PROJECT_MANAGEMENT/CHANGELOG.md). 
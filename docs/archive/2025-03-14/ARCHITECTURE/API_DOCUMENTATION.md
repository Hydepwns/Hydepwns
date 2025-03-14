---
title: API Documentation
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - architecture
  - api-documentation
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - api-versioning
  - authentication
  - common-response-format
  - error-handling
  - rate-limiting
  - pagination
  - filtering-and-sorting
  - endpoints
  - webhook-integration
  - changes-and-updates
  - sdk-and-client-libraries
  - api-explorer
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# API Documentation

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# API Documentation


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides comprehensive documentation for the Hydepwns API, including endpoints, request/response formats, authentication, error handling, and usage examples.

## API Versioning

The API uses semantic versioning (MAJOR.MINOR.PATCH) with all endpoints prefixed by version:

- `/api/v1/*` - Current stable version
- `/api/v2/*` - Beta features (if available)

Version changes follow these guidelines:

- MAJOR: Breaking changes that require client updates
- MINOR: New functionality added in a backward-compatible manner
- PATCH: Backward-compatible bug fixes and non-functional changes

## Authentication

### Bearer Token

Most API endpoints require authentication using a Bearer token in the Authorization header:

```http
Authorization: Bearer <your_access_token>
```markdown

To obtain a token:

1. Make a POST request to `/api/v1/auth/login` with valid credentials
2. Store the returned token securely
3. Include the token in all subsequent requests

Tokens expire after 24 hours and must be refreshed using the `/api/v1/auth/refresh` endpoint.

### API Keys

For service-to-service integrations, API keys can be used:

```http
X-API-Key: <your_api_key>
```markdown

API keys can be generated and managed in the admin dashboard under "API Settings". Each key can have specific permissions and rate limits assigned.

## Common Response Format

All API responses follow this standard format:

```json
{
  "status": "success", // or "error"
  "data": {}, // the response data
  "meta": {}, // pagination, filtering info
  "message": "" // success or error message
}
```markdown

## Error Handling

HTTP status codes are used appropriately:

- 200 - Success
- 400 - Bad Request
- 401 - Unauthorized
- 403 - Forbidden
- 404 - Not Found
- 422 - Unprocessable Entity
- 429 - Too Many Requests
- 500 - Server Error

Errors include details in the response body:

```json
{
  "status": "error",
  "message": "Resource not found",
  "errors": [
    {
      "code": "NOT_FOUND",
      "detail": "The requested resource with ID '123' does not exist",
      "source": {
        "pointer": "/data/attributes/id"
      }
    }
  ]
}
```markdown

Error codes are standardized across the API:

- `INVALID_REQUEST`: The request was malformed or invalid
- `AUTHENTICATION_FAILED`: Authentication credentials are missing or invalid
- `AUTHORIZATION_FAILED`: The authenticated user lacks permission
- `NOT_FOUND`: The requested resource does not exist
- `VALIDATION_FAILED`: The request data failed validation
- `RATE_LIMIT_EXCEEDED`: The client has exceeded their rate limit
- `SERVER_ERROR`: An unexpected error occurred on the server

## Rate Limiting

API requests are subject to rate limiting:

- 100 requests per minute per API key/token
- Headers included in responses:
  - `X-RateLimit-Limit`: The maximum number of requests allowed in the current period
  - `X-RateLimit-Remaining`: The number of requests remaining in the current period
  - `X-RateLimit-Reset`: The time when the current rate limit window resets (Unix timestamp)

When rate limits are exceeded, the API returns a 429 Too Many Requests response.

## Pagination

List endpoints support pagination using the following query parameters:

- `page[number]`: The page number (starting from 1)
- `page[size]`: The number of items per page (default: 20, max: 100)

Example:

```markdown
GET /api/v1/resources?page[number]=2&page[size]=50
```markdown

Pagination information is included in the `meta` section of the response:

```json
{
  "status": "success",
  "data": [...],
  "meta": {
    "pagination": {
      "total_items": 243,
      "total_pages": 5,
      "current_page": 2,
      "items_per_page": 50
    }
  }
}
```markdown

## Filtering and Sorting

List endpoints support filtering and sorting using query parameters:

### Filtering

- Filter syntax: `filter[field]=value`
- Multiple filters can be combined and are treated as AND conditions

Example:

```markdown
GET /api/v1/resources?filter[status]=active&filter[type]=document
```markdown

### Sorting

- Sort syntax: `sort=field` (ascending) or `sort=-field` (descending)
- Multiple sort fields can be specified with comma separation

Example:

```markdown
GET /api/v1/resources?sort=-created_at,name
```markdown

## Endpoints

### Authentication

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/login` | POST | Authenticate and receive access token |
| `/api/v1/auth/refresh` | POST | Refresh an access token |
| `/api/v1/auth/logout` | POST | Invalidate an access token |

#### Login Request Example

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```markdown

#### Login Response Example

```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 86400
  },
  "message": "Authentication successful"
}
```markdown

### Resources

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/resources` | GET | List all resources |
| `/api/v1/resources/:id` | GET | Get a specific resource |
| `/api/v1/resources` | POST | Create a new resource |
| `/api/v1/resources/:id` | PUT | Update a resource |
| `/api/v1/resources/:id` | PATCH | Partially update a resource |
| `/api/v1/resources/:id` | DELETE | Delete a resource |

#### Resource Object

```json
{
  "id": "resource_123",
  "type": "document",
  "name": "Example Document",
  "description": "This is an example document",
  "status": "active",
  "created_at": "2023-05-15T14:30:00Z",
  "updated_at": "2023-05-16T09:15:22Z",
  "metadata": {
    "author": "Jane Smith",
    "version": "1.2"
  }
}
```markdown

#### Create Resource Request Example

```json
{
  "type": "document",
  "name": "New Document",
  "description": "This is a new document",
  "metadata": {
    "author": "John Doe",
    "version": "1.0"
  }
}
```markdown

#### Create Resource Response Example

```json
{
  "status": "success",
  "data": {
    "id": "resource_456",
    "type": "document",
    "name": "New Document",
    "description": "This is a new document",
    "status": "active",
    "created_at": "2023-06-20T10:45:33Z",
    "updated_at": "2023-06-20T10:45:33Z",
    "metadata": {
      "author": "John Doe",
      "version": "1.0"
    }
  },
  "message": "Resource created successfully"
}
```markdown

### Relationship Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/resources/:id/relationships` | GET | List all relationships |
| `/api/v1/resources/:id/relationships/:type` | GET | Get relationships of a specific type |
| `/api/v1/resources/:id/relationships/:type` | POST | Create relationship |
| `/api/v1/resources/:id/relationships/:type/:target_id` | DELETE | Delete relationship |

#### Relationship Types

- `parent`: Parent-child hierarchy relationship
- `reference`: Reference relationship between resources
- `dependency`: Dependency relationship where one resource depends on another
- `association`: General association between resources

#### Create Relationship Request Example

```json
{
  "target_id": "resource_789",
  "metadata": {
    "relationship_strength": "strong",
    "notes": "Important connection between these resources"
  }
}
```markdown

### Resource Transformation

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/resources/:id/transform` | POST | Apply transformation to a resource |
| `/api/v1/transformations` | GET | List available transformation types |
| `/api/v1/transformations/:type` | GET | Get details about a specific transformation |

#### Transform Resource Request Example

```json
{
  "transformation_type": "format_conversion",
  "parameters": {
    "target_format": "markdown",
    "include_metadata": true
  }
}
```markdown

### Events

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/events` | GET | List all events (with filtering) |
| `/api/v1/resources/:id/events` | GET | Get events for a specific resource |
| `/api/v1/events/:id` | GET | Get a specific event |

#### Event Object

```json
{
  "id": "event_123",
  "type": "resource.updated",
  "resource_id": "resource_456",
  "timestamp": "2023-06-21T15:30:45Z",
  "user_id": "user_789",
  "data": {
    "before": {
      "name": "Old Name",
      "status": "draft"
    },
    "after": {
      "name": "New Name",
      "status": "active"
    }
  }
}
```markdown

## Webhook Integration

The API supports webhook notifications for various events. Webhooks can be configured in the admin dashboard under "Webhook Settings".

### Webhook Configuration

- Event types to trigger notifications
- Target URL for webhook delivery
- Secret key for webhook signature verification
- Retry policy for failed deliveries

### Webhook Format

```json
{
  "event_type": "resource.created",
  "resource_id": "resource_123",
  "timestamp": "2023-06-22T09:12:33Z",
  "data": {
    // Event-specific data
  },
  "signature": "sha256=..."
}
```markdown

## Changes and Updates

The API is continuously evolving. For a complete list of changes, please refer to the [CHANGELOG](../PROJECT_MANAGEMENT/CHANGELOG.md).

## SDK and Client Libraries

We provide official client libraries for the following languages:

- JavaScript/TypeScript: [hydepwns-js](https://github.com/hydepwns/hydepwns-js)
- Python: [hydepwns-python](https://github.com/hydepwns/hydepwns-python)
- Ruby: [hydepwns-ruby](https://github.com/hydepwns/hydepwns-ruby)

## API Explorer

An interactive API explorer is available at `/api/explorer` for authenticated users to test endpoints and view documentation.


## References

- [Project Documentation](../README.md)

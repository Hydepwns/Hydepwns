---
title: Transformations API
description: Documentation for the Hydepwns transformations API endpoints
topics:
  - api
  - transformations
  - resource-transformations
  - endpoints
  - pipeline
last_updated: '2025-03-14'
---

# Transformations API

## Overview

The Transformations API provides endpoints for transforming resources through configurable pipelines. Transformations can be applied to modify, convert, or process resources in various ways.

## Transformation Types

- Format Conversions
- Data Processing
- Resource Optimization
- Content Generation
- Validation and Sanitization

## Endpoints

### List Transformations

```http
GET /api/v1/transformations
```

Lists all available transformation types.

#### Response

```json
{
  "data": [
    {
      "id": "string",
      "type": "transformation",
      "attributes": {
        "name": "string",
        "description": "string",
        "input_types": ["string"],
        "output_types": ["string"],
        "parameters": {
          "required": ["string"],
          "optional": ["string"]
        }
      }
    }
  ]
}
```

### Get Transformation

```http
GET /api/v1/transformations/{transformation_id}
```

Retrieves details about a specific transformation.

### Apply Transformation

```http
POST /api/v1/resources/{resource_id}/transform
```

Applies a transformation to a resource.

#### Request Body

```json
{
  "transformation": "string",
  "parameters": {
    "key": "value"
  },
  "options": {
    "async": false,
    "notify_on_complete": false
  }
}
```

### Create Pipeline

```http
POST /api/v1/transformation-pipelines
```

Creates a new transformation pipeline.

#### Request Body

```json
{
  "name": "string",
  "description": "string",
  "steps": [
    {
      "transformation": "string",
      "parameters": {
        "key": "value"
      }
    }
  ],
  "error_handling": {
    "on_failure": "stop|continue|retry",
    "max_retries": 3
  }
}
```

### Execute Pipeline

```http
POST /api/v1/resources/{resource_id}/transform-pipeline/{pipeline_id}
```

Executes a transformation pipeline on a resource.

### Get Transformation Status

```http
GET /api/v1/resources/{resource_id}/transform-status/{job_id}
```

Checks the status of a transformation job.

#### Response

```json
{
  "status": "pending|processing|completed|failed",
  "progress": 75,
  "current_step": "string",
  "error": null,
  "result": {
    "resource_id": "string",
    "type": "string"
  }
}
```

## Transformation Parameters

Each transformation type accepts specific parameters:

### Format Conversion

```json
{
  "target_format": "string",
  "quality": "number",
  "preserve_metadata": "boolean"
}
```

### Data Processing

```json
{
  "operations": ["string"],
  "filters": ["string"],
  "validation_rules": ["string"]
}
```

## Error Handling

Transformation operations return standard HTTP status codes:

- 400 Bad Request: Invalid transformation parameters
- 404 Not Found: Transformation or resource not found
- 422 Unprocessable Entity: Invalid resource state
- 409 Conflict: Resource locked or in use

## Webhooks

Configure webhooks to receive transformation status updates:

```http
POST /api/v1/webhooks
```

```json
{
  "url": "string",
  "events": ["transformation.completed", "transformation.failed"],
  "secret": "string"
}
```

## Rate Limiting

Transformation endpoints are subject to rate limiting:

- 100 transformations per hour for standard users
- 500 transformations per hour for premium users 
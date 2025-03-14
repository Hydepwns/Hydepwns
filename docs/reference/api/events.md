---
title: Events API
description: Documentation for the Hydepwns events API endpoints
topics:
  - api
  - events
  - event-handling
  - webhooks
  - endpoints
last_updated: '2025-03-14'
---

# Events API

## Overview

The Events API provides endpoints for managing and subscribing to system events. Events are used to track changes, trigger actions, and integrate with external systems.

## Event Types

- Resource Events (created, updated, deleted)
- User Events (login, logout, permissions changed)
- System Events (maintenance, updates)
- Custom Events (user-defined)

## Endpoints

### List Events

```http
GET /api/v1/events
```

Lists events based on specified filters.

#### Query Parameters

- `type`: Filter by event type
- `source`: Filter by event source
- `from`: Start timestamp
- `to`: End timestamp
- `page`: Page number
- `limit`: Events per page

#### Response

```json
{
  "data": [
    {
      "id": "string",
      "type": "event",
      "attributes": {
        "event_type": "string",
        "source": "string",
        "timestamp": "string",
        "data": {
          "key": "value"
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

### Get Event

```http
GET /api/v1/events/{event_id}
```

Retrieves details about a specific event.

### Create Event

```http
POST /api/v1/events
```

Creates a custom event.

#### Request Body

```json
{
  "type": "string",
  "source": "string",
  "data": {
    "key": "value"
  }
}
```

### Subscribe to Events

```http
POST /api/v1/event-subscriptions
```

Creates a new event subscription.

#### Request Body

```json
{
  "event_types": ["string"],
  "callback_url": "string",
  "filters": {
    "source": ["string"],
    "data": {
      "key": "value"
    }
  }
}
```

### List Subscriptions

```http
GET /api/v1/event-subscriptions
```

Lists all event subscriptions for the authenticated user.

### Update Subscription

```http
PATCH /api/v1/event-subscriptions/{subscription_id}
```

Updates an existing event subscription.

#### Request Body

```json
{
  "event_types": ["string"],
  "callback_url": "string",
  "filters": {
    "source": ["string"]
  }
}
```

### Delete Subscription

```http
DELETE /api/v1/event-subscriptions/{subscription_id}
```

Deletes an event subscription.

## Event Delivery

Events are delivered to subscribed endpoints via HTTP POST:

```json
{
  "event_id": "string",
  "event_type": "string",
  "source": "string",
  "timestamp": "string",
  "data": {
    "key": "value"
  },
  "signature": "string"
}
```

### Delivery Headers

- `X-Event-ID`: Unique event identifier
- `X-Event-Type`: Type of event
- `X-Event-Signature`: HMAC signature
- `X-Event-Timestamp`: Event timestamp

## Error Handling

Event operations return standard HTTP status codes:

- 400 Bad Request: Invalid event data
- 404 Not Found: Event not found
- 422 Unprocessable Entity: Invalid subscription

## Security

### Event Signatures

Events are signed using HMAC-SHA256:

```python
signature = hmac.new(
    secret_key,
    msg=payload,
    digestmod=hashlib.sha256
).hexdigest()
```

### Retry Policy

Failed deliveries are retried with exponential backoff:

- Initial delay: 5 seconds
- Maximum retries: 5
- Maximum delay: 1 hour

## Rate Limiting

Event endpoints are subject to rate limiting:

- 1000 events per hour for publishing
- 100 subscriptions per account 
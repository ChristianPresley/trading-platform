# List Custody Activities

## Endpoint

```
POST /0/private/ListCustodyActivities
```

## Description

Retrieve all activities that match the specified filter criteria.

## Authentication

This is a private endpoint requiring authenticated API access. Requests must include valid API key credentials and signature.

## Request

### Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `API-Key` | string | Yes | Your Kraken API key |
| `API-Sign` | string | Yes | Message signature using HMAC-SHA512 |
| `Content-Type` | string | Yes | `application/x-www-form-urlencoded` |

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Unique, incrementing integer used to prevent replay attacks |
| `task_id` | string | No | Filter activities by a specific task ID |
| `status` | string | No | Filter activities by status |
| `start` | integer | No | Starting offset for pagination |
| `limit` | integer | No | Maximum number of activities to return |

## Responses

### 200 - Success

Returns a list of activities matching the specified filter criteria.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/ListCustodyActivities" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- Activity IDs from this response can be used with [Get Custody Activity](get-custody-activity.md) for detailed activity information.
- Use the `task_id` filter to retrieve activities associated with a specific task.

## Source

- [Kraken API Documentation - List Custody Activities](https://docs.kraken.com/api/docs/custody-api/list-custody-tasks-activities)

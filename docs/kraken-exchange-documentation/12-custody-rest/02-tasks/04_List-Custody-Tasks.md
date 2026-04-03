# List Custody Tasks

## Endpoint

```
POST /0/private/ListCustodyTasks
```

## Description

Retrieve review tasks that match the specified filter criteria.

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
| `status` | string | No | Filter tasks by status |
| `type` | string | No | Filter tasks by type |
| `start` | integer | No | Starting offset for pagination |
| `limit` | integer | No | Maximum number of tasks to return |

## Responses

### 200 - Success

Returns a list of review tasks matching the specified filter criteria.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/ListCustodyTasks" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- Use filter parameters to narrow results by status or task type.
- Task IDs from this response can be used with [Get Custody Task](get-custody-task.md) for detailed task information.
- Related activities for tasks can be retrieved via [List Activities](list-custody-tasks-activities.md).

## Source

- [Kraken API Documentation - List Custody Tasks](https://docs.kraken.com/api/docs/custody-api/list-custody-tasks)

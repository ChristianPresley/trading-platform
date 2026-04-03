# Get Custody Task

## Endpoint

```
POST /0/private/GetCustodyTask
```

## Description

Retrieve details for a specific task.

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
| `task_id` | string | Yes | The unique identifier of the task to retrieve |

## Responses

### 200 - Success

Returns detailed information for the specified task.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetCustodyTask" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&task_id=TASK_ID"
```

## Notes

- Use [List Custody Tasks](list-custody-tasks.md) to obtain task IDs.
- To retrieve activities associated with a task, use [List Activities](list-custody-tasks-activities.md).

## Source

- [Kraken API Documentation - Get Custody Task](https://docs.kraken.com/api/docs/custody-api/get-custody-task)

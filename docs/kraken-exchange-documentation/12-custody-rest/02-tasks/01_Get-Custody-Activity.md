# Get Custody Activity

## Endpoint

```
POST /0/private/GetCustodyActivity
```

## Description

Retrieve details for a specific task activity.

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
| `activity_id` | string | Yes | The unique identifier of the activity to retrieve |

## Responses

### 200 - Success

Returns detailed information for the specified task activity.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetCustodyActivity" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&activity_id=ACTIVITY_ID"
```

## Notes

- Use [List Custody Activities](list-custody-tasks-activities.md) to obtain activity IDs.
- Activities are associated with specific tasks, which can be queried via [Get Custody Task](get-custody-task.md).

## Source

- [Kraken API Documentation - Get Custody Activity](https://docs.kraken.com/api/docs/custody-api/get-custody-activity)

# OAuth REST

OAuth 2.0 authentication endpoints for Kraken Connect and API key management.

## Contents

1. [Create Fast API Key](01_Create-Fast-Api-Key.md) — Create a Fast API key for programmatic access to Kraken APIs.
   - `POST /fast-api-key`
2. [Get Access Token](02_Get-Access-Token.md) — Exchange an authorization code for an access token, or refresh an existing token.
   - `POST /oauth/token`
   - Params: `grant_type`, `code`, `redirect_uri`, `refresh_token`
3. [Get Authorization Code](03_Get-Authorization-Code.md) — Redirect users to Kraken to start the OAuth authorization flow.
   - `GET /oauth/authorize`
   - Params: `response_type`, `client_id`, `redirect_uri`, `scope`, `state`
4. [Get Authorization Code with Language](04_Get-Authorization-Code-With-Language.md) — Start the OAuth flow with a specific language preference for the UI.
   - `GET /:language/oauth/authorize`
   - Params: `language`, `response_type`, `client_id`, `redirect_uri`, `scope`, `state`
5. [Get User Info](05_Get-User-Info.md) — Retrieve the email address and IIBAN of the authenticated user.
   - `GET /userinfo`
6. [Kraken Connect](06_Kraken-Connect.md) — Overview of Kraken's OAuth 2.0 implementation for third-party integrations, covering client types, scopes, and the authorization code flow.

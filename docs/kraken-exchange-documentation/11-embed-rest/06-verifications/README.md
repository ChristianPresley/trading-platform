# Verifications

Embed API endpoints for submitting identity verification documents for users.

## Contents

1. [Submit Embed Verification From URL](01_Submit-Embed-Verification-From-Url.md) — Submit a verification with documents provided via presigned URLs (e.g., AWS S3, GCS).
   - `POST /b2b/verifications/:user/url`
2. [Submit Embed Verification](02_Submit-Embed-Verification.md) — Submit a verification with documents and details via direct upload.
   - `POST /b2b/verifications/:user`

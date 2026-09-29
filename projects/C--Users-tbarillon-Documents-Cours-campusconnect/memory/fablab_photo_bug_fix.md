---
name: fablab-photo-bug-fix
description: "Root cause and fix for FabLab machine/material photos not displaying (bucket missing, fake 200/XML responses)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3409293a-15ca-4a3e-a64a-ae91d0472929
---

FabLab machine/material photos stopped displaying (no console error, network showed
200 OK / `Content-Type: application/xml` / empty body) because the MinIO bucket
(`MINIO_BUCKET=campusconnect`) didn't exist — likely lost when the `miniodata`
volume was reset (local `docker-compose` volume, or the `local-path` PVC in
`k8s/11-minio.yaml`) while Postgres kept the `photo_key` metadata. `rust-s3`
0.35.1's `get_object`/`response_data` never checks the HTTP status code, so an
S3 error response (XML body) was streamed back as a fake success by
`services/fablab/src/routes/photos.rs::stream()`, which also hardcoded
`StatusCode::OK` regardless of what the store actually returned. This exact
gap was already flagged as a known follow-up in
`docs/superpowers/specs/2026-07-06-fablab-v2-c-photos-design.md` ("à durcir un
jour") but assumed harmless due to a DB guard that only checks `photo_key IS
NOT NULL`, not whether the object physically exists.

Fixed 2026-07-11: added `campusconnect_common::object_store::ensure_bucket_exists`
(called at startup in `services/fablab/src/main.rs` and
`services/news/src/main.rs`, and in both services' `tests/common.rs`), and made
`object_store::download` check the S3 response status and return a typed
`DownloadError::NotFound` vs `DownloadError::Other`, mapped to proper HTTP
404/500 in both `fablab`'s `photo_store.rs` and `news`'s `images.rs::get_image`.

**Why**: bucket bootstrap had no owner — neither `docker-compose.yml` nor the
k8s manifests ever created it, so any volume/PVC reset silently breaks all
photo endpoints (dev and prod) without alerting anyone. **How to apply**: if
similar "renders nothing, no console error" bugs appear on other MinIO-backed
features, check first whether the bucket exists (`docker exec
campusconnect-minio-1 mc ls local/`) before assuming a frontend bug — this
codebase's object-store error handling used to silently swallow store errors.

**Known follow-up (not yet fixed)**: old photos are unrecoverable after a
bucket loss — only `photo_key` metadata survives in Postgres, the underlying
bytes are gone. After deploying this fix to prod, any machine/material with a
stale `photo_key` needs a manual re-upload.

Local dev environment note: `cargo test -p campusconnect-fablab --test
photos` currently fails locally with `failed to read JWT public key file`
(`JWT_PUBLIC_KEY_PATH` in `.env` resolves relative to CWD, which differs when
`cargo test` runs per-package) — pre-existing, unrelated to this fix, not
investigated further per [[never-run-tests-unprompted]].

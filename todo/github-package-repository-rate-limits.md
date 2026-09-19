# GitHub package repository rate limits

## Intent

Make GitHub-backed package repository adapters handle upstream API/download rate limiting predictably without weakening package integrity or live-upstream validation.

## Why pending

Repeated current GraalVM macOS live-validation attempts reached the real GitHub-backed repository path and failed with HTTP 403, while the same package/test succeeds when the upstream responds. This reliability issue is separate from facility-default global projection and is intentionally deferred.

## Scope

- `rumiai-os` package repository adapters backed by GitHub, starting with GraalVM.
- `rumiai-tests` live package validation only where behavior/evidence needs adjustment after the adapter contract is decided.

## Evidence

- `rumiai-os/lib/sys/sh/pkg/pkg-repository-graalvm.lib.sh` currently performs unauthenticated GitHub API requests through `http-fetch`.
- `rumiai-tests/tests/external/graalvm/install-live.test` exercises the real live upstream path and currently exposes intermittent HTTP 403 failures under repeated hosted validation.

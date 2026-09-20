# GitHub package repository authentication

## Intent

Define an optional authenticated request path for GitHub-backed package repository adapters so package operations can avoid the small shared unauthenticated API budget without making credentials mandatory.

## Why pending

Current adapters deliberately work without credentials. Formal hosted validation has recorded real HTTP 403 responses from `api.github.com` even after redundant requests were removed. Choosing credential sources, precedence, secret handling and user-facing configuration is a security/product-policy decision and is outside the package provider/facility completion task.

## Scope

`rumiai-os` package repository adapters that use GitHub REST, shared HTTP facilities only if required, corresponding manuals/specification surfaces, and `rumiai-tests`.

## Evidence

Current `pkg-repository-github.lib.sh`, `pkg-repository-graalvm.lib.sh`, `pkg-repository-netbeans.lib.sh` and `pkg-repository-nodejs.lib.sh` use unauthenticated GitHub REST requests. Formal validation sessions on 2026-09-20 recorded GitHub HTTP 403 failures for live NetBeans and Keycloak installs while deterministic adapter tests passed.

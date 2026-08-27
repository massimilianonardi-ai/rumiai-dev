#!/usr/bin/env python3
"""Verify and reconstruct the authoritative raw ChatGPT export conversations."""

from __future__ import annotations

import base64
import bz2
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent

CHATS = {
    "Architettura RumiAI": {
        "dir": ROOT / "2026-07-29 Architettura RumiAI" / "export-chatgpt" / "raw-authoritative-v5" / "segments",
        "sequence": ["001", "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "012", "013"],
        "sha256": "605982b7c87a02d2a39ca587ff880c31f0a65dd28e42fddd6a6aabcb575f7b09",
        "bytes": 351457,
    },
    "RumiAI architettura": {
        "dir": ROOT / "2026-07-30 RumiAI architettura" / "export-chatgpt" / "raw-authoritative-v5" / "segments",
        "sequence": ["001", "002a", "002b", "003", "004", "005"],
        "sha256": "16f0fb276af65a35afb9ac8a2a62aad7fae1c90fec211471a03dc3fd55d65200",
        "bytes": 120092,
    },
    "Tabella prodotti IA open source": {
        "dir": ROOT / "2026-07-30 Tabella prodotti IA open source" / "export-chatgpt" / "raw-authoritative-v5" / "segments",
        "sequence": [
            "001", "002", "003", "004a", "004b", "005", "006", "007", "008", "009",
            "010a", "010b", "011a", "011b", "012", "013a", "013b", "014", "015",
        ],
        "sha256": "8e22f6acaa96567bb02990439093301eae095b90722360529d4148d64c32180e",
        "bytes": 409834,
    },
}

PREFIX = "conversation.raw.json.bz2.b64."


def reconstruct(info: dict) -> bytes:
    encoded = b"".join((info["dir"] / f"{PREFIX}{part}").read_bytes() for part in info["sequence"])
    return bz2.decompress(base64.b64decode(encoded, validate=True))


def main() -> int:
    failed = False
    for name, info in CHATS.items():
        try:
            raw = reconstruct(info)
        except Exception as exc:
            failed = True
            print(f"FAIL {name}: reconstruction error: {exc}")
            continue

        digest = hashlib.sha256(raw).hexdigest()
        ok = len(raw) == info["bytes"] and digest == info["sha256"]
        print(f"{'OK' if ok else 'FAIL'} {name}: bytes={len(raw)} sha256={digest}")
        if not ok:
            failed = True

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())

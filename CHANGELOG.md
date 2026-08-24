# Changelog

## 0.1.0 - 2026-08-24

### Initial publishable release

- `SessionPort` general contract: `save`, `load(id)`, `list()`, `delete(id)` over `PortableSession` — technology-agnostic, no browser internals exposed (FR-1/FR-7, US4).
- `FileSessionStore(Directory)` implements `SessionPort`; sessions are plain JSON files under `<store>/sessions/<id>.json`; atomic save via `.tmp` then rename (FR-2, FR-009).
- Corruption fail-safety per the test contract: corrupt session file is skipped by `list()` (reported in `lastReadErrors`); a `.tmp` leftover is ignored; a file missing `id` is treated as corrupt; `load()` of a corrupt id returns `null`, never throws (FR-3, SC-005).
- Entities: `PortableSession` (id, name, origin, createdAt, updatedAt, cookies, storage + `copyWith`), `CookieEntry` (name, value, domain, path, expiresAt?, secure, httpOnly), `StorageEntry` (key, value, area, origin) — JSON-serializable via generated `.g.dart` (FR-4).
- `registerSessionDependencies(getIt, storeDir:)` wires the real file-backed stack behind `SessionPort` + the zfa-generated repository/usecase surface (FR-5).
- Publishable: hosted `zuraffa: ^6.0.1` (no path dep, no `dependency_overrides`, no `publish_to: 'none'`) (FR-6).

### Known consumers

- `zikzak_inappwebview` — wires `SessionPort` / `FileSessionStore` behind a `WebViewSessionBridge` for portable cookie+storage state (separate PR).

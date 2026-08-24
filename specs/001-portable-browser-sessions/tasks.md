# Tasks: Portable Browser Sessions (zikzak_session standalone)

**Input**: `specs/001-portable-browser-sessions/spec.md`

## Phase 1 — Package bootstrap (zfa CLI)

- [ ] T001 `zfa initialize --dart --deps-only` in `/workspace/zikzak_session` (wires zorphy/zuraffa deps into pubspec; verify output compiles: `dart pub get` + `dart analyze` clean).
- [ ] T002 `zfa entity create` × 3: `PortableSession` (id, name, origin, createdAt, updatedAt — collections added via related entities), `CookieEntry` (name, value, domain, path, expiresAt, secure, httpOnly), `StorageEntry` (key, value, area, origin). Then `zfa entity build` to generate .zorphy/.g parts; verify analyze clean.

## Phase 2 — Clean-architecture stack (zfa make)

- [ ] T003 `zfa make PortableSession datasource repository usecase di --methods=get,getList,create,update,delete --id-field id` → verify generated datasource interface + repository + usecases compile.
- [ ] T004 Stop-and-check: run `dart analyze` + the generated tests; any generator misfire → `gh issue create` on arrrrny/zuraffa per the spec's hard rule, then adapt only if the workaround is non-architectural.

## Phase 3 — SessionPort + file store

- [ ] T005 `SessionPort` (save/load/list/delete over PortableSession) in the domain layer — the general contract (FR-007, US4).
- [ ] T006 `FileSessionStore` implementing the generated datasource interface: one JSON file per session under a relocatable dir (FR-006/FR-008), atomic tmp+rename writes (FR-009/SC-005 mid-write-kill), corrupt file → skipped with a reported error (never crashes, never removes others), list returns metadata (id, name, origin, savedAt — FR-005).
- [ ] T007 DI: register the file store behind the generated repository; barrel exports (SessionPort, SessionStore, entities).

## Phase 4 — Tests (US1–US4 + edge cases)

- [ ] T008 CRUD through the port: save → load identical (cookies + storage + metadata), list shows saved, delete frees (FR-011).
- [ ] T009 Portability (US1/US3): save in one store instance, load from a *new* instance at the same path (simulated restart); relocated store path lists/loads the same sessions.
- [ ] T010 Multi-session isolation (US2/SC-002): 4 distinct sessions (the forklift scenario), load(A,X) + load(B,Y) with zero cross-contamination; loading session A onto site Z applies without corrupting others.
- [ ] T011 Corruption safety (FR-009/SC-005): garbage bytes in one session file → that session reported unreadable, all others intact + loadable; a leftover `.tmp` file is ignored.
- [ ] T012 Port-only access (SC-004): all operations exercised through `SessionPort` with no browser/file internals referenced.

## Phase 5 — Ship

- [ ] T013 `dart analyze` clean; `/opt/flutter/bin/dart format`; full `dart test` green.
- [ ] T014 Update lib/zikzak_session.dart doc comment (real API surface), commit on `feat/001-portable-browser-sessions`, push, PR → merge → pull → re-verify.

## Non-goals (per spec)

- At-rest encryption; remote sync; session management UI; cross-webview-engine cookie parity.

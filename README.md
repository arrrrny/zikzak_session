# zikzak_session

Portable browser sessions for the Zuraffa ecosystem — self-contained units of webview state (cookies + DOM storage) that persist to a relocatable store and reload onto a specific site.

Built for consumers like `zikzak_inappwebview` and the `forklift` orchestrator (multiple cloaked browser profiles that must survive restarts), and constructed entirely with the `zfa` clean-architecture CLI: entities, datasources, repositories, and usecases are generated; the hand-written layer is only the `SessionPort` contract, the file-backed store, and DI wiring.

## Usage

```dart
import 'package:get_it/get_it.dart';
import 'package:zikzak_session/zikzak_session.dart';

final getIt = GetIt.instance;
await registerSessionDependencies(
  getIt,
  storeDir: Directory('/path/to/session-store'),
);

final sessions = getIt<SessionPort>();

// Save a session (self-contained: cookies + storage + metadata).
await sessions.save(PortableSession(
  id: 'browser-a',
  name: 'Account A',
  origin: 'https://app.example.com',
  createdAt: DateTime.now().millisecondsSinceEpoch,
  updatedAt: DateTime.now().millisecondsSinceEpoch,
  cookies: [CookieEntry(
    name: 'sid', value: '...', domain: '.example.com',
    path: '/', secure: true, httpOnly: false,
  )],
  storage: [StorageEntry(
    key: 'auth', value: 'token', area: 'localStorage',
    origin: 'https://app.example.com',
  )],
));

// After a restart (or from another consumer sharing the store):
final restored = await sessions.load('browser-a');

// Inventory and cleanup.
final all = await sessions.list();
await sessions.delete('browser-a');
```

## Design

- **`SessionPort`** — the general contract (`save`/`load`/`list`/`delete`), independent of browser or filesystem internals. When Zuraffa ships its own generic session interface, this port becomes one adapter of it.
- **`FileSessionStore`** — one JSON file per session under `<storeDir>/sessions/`: self-contained, copyable, relocatable units. Atomic writes (tmp + rename) so a mid-write crash never leaves a half-session; corrupt files are skipped and reported without affecting other sessions.
- **Generated stack** — `PortableSession`/`CookieEntry`/`StorageEntry` entities, the datasource interface, repository, and usecases come from `zfa entity create` / `zfa make` (see `lib/src/`); `PortableSessionFileDataSource` bridges the generated contract onto the store.

## Status

Standalone package under active development (spec `specs/001-portable-browser-sessions`). Depends on `zuraffa` via a path dependency until the next hosted publish (see zuraffa#481/#482).

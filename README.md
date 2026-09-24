# Offline Lessons — APP-01

A Flutter app that caches lessons from Supabase for offline reading and queues
"mark complete" actions locally, syncing them back to Supabase once the
device reconnects.

## Tech stack
- Flutter (Dart)
- Supabase (Postgres + Auth + RLS) — source of truth
- sqflite (SQLite) — local cache + mutation queue
- connectivity_plus — network state detection

## Setup

### 1. Prerequisites
- Flutter SDK installed (`flutter doctor` should be clean)
- A Supabase project (see supabase setup below)
- Android Studio (for emulator) or a physical device

### 2. Supabase setup
Run this SQL in the Supabase SQL Editor to create tables:
```sql
create table lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  module text,
  order_index int default 0,
  updated_at timestamptz default now()
);

create table completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  lesson_id uuid not null references lessons(id),
  completed_at timestamptz not null,
  synced_at timestamptz default now(),
  client_updated_at timestamptz not null,
  unique(user_id, lesson_id)
);
```

Then enable RLS and policies:
```sql
alter table lessons enable row level security;
alter table completions enable row level security;

create policy "lessons_read" on lessons
  for select using (auth.role() = 'authenticated');

create policy "completions_own_read" on completions
  for select using (auth.uid() = user_id);

create policy "completions_own_write" on completions
  for insert with check (auth.uid() = user_id);

create policy "completions_own_update" on completions
  for update using (auth.uid() = user_id);
```

Enable Email auth under **Authentication → Providers**, and create at least
one test user under **Authentication → Users**. Seed a few rows into the
`lessons` table via Table Editor.

### 3. App configuration
Fill in your project's URL and anon key in `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 4. Install dependencies and run
```bash
flutter pub get
flutter run
```

## Architecture

```
lib/
  config/            Supabase credentials
  models/            Lesson, Completion data classes
  services/
    local_db_service.dart    SQLite cache + mutation queue
    supabase_service.dart    Remote reads/writes
    sync_service.dart        Conflict-resolution + sync orchestration
    connectivity_service.dart Online/offline detection
  screens/           Login, Lesson list, Lesson detail
  widgets/           Reusable UI components (sync banner, lesson card)
```

- **Read path:** app reads from the local SQLite cache first (works offline);
  when online, it refreshes the cache from Supabase.
- **Write path:** "mark complete" always writes to the local SQLite queue
  first, then attempts to sync to Supabase in the background whenever
  connectivity returns.

## Conflict resolution
See [SYNC_DESIGN.md](./SYNC_DESIGN.md) for the full explanation. In short:
Last-Write-Wins based on the `client_updated_at` timestamp.

## Known limitations
- Sync is triggered on app foreground / reconnect events only — there is no
  true background sync when the app is fully closed.
- Only text-based lesson content is cached; no media/attachment caching yet.
- Conflict handling covers the completions table only; lessons are
  read-only from the client so no write conflicts occur there.
- Tested primarily on Android emulator; iOS build instructions are the
  standard Flutter iOS flow (`flutter build ios`) but not verified on a
  physical iOS device for this submission.

## Demo video
See the linked video in the submitted Google Drive folder README.
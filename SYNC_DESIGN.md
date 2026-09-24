# Conflict Resolution Strategy

Strategy: Last-Write-Wins by `client_updated_at`.

When syncing an unsynced local completion:
1. Fetch the remote row for that (user_id, lesson_id) pair, if it exists.
2. If no remote row exists, push the local row.
3. If a remote row exists, compare `client_updated_at` timestamps.
   Whichever is newer wins, and that version is written back to both
   the server (via upsert) and the local cache.
4. If timestamps are exactly equal, local wins by default, and this
   case is treated as rare/edge-case and logged.
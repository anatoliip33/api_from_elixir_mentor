# Task Pipeline API

Backend API for asynchronous task processing with Oban, built in Phoenix and Ecto.

## Features

- Create tasks with `title`, `type`, `priority`, `payload`, and `max_attempts`
- Asynchronous processing using Oban jobs
- Task status lifecycle: `queued`, `processing`, `completed`, `failed`
- Cursor-based pagination for task listing
- Status summary endpoint with aggregate counts by status

## Setup

```bash
mix setup
mix phx.server
```

The server starts on `http://localhost:4000`.

## Database

The project uses PostgreSQL and Ecto.

## API Endpoints

### Create task

`POST /api/tasks`

Request body:

```json
{
  "task": {
    "title": "Import customers",
    "type": "import",
    "priority": "critical",
    "payload": {"source": "s3://bucket/customers.csv"},
    "max_attempts": 3
  }
}
```

### List tasks

`GET /api/tasks`

Query params supported:
- `status`
- `type`
- `priority`
- `limit`
- `next_cursor`

### Get task

`GET /api/tasks/:id`

### Summary

`GET /api/tasks/summary`

Response example:

```json
{"queued": 5, "processing": 2, "completed": 12, "failed": 1}
```

## Implementation Notes

- Task creation is transactional and enqueues an Oban job inside `Ecto.Multi`
- Worker logic simulates processing duration by priority and includes retry behavior
- Cursor pagination is used to avoid offset-based listing at scale
- Database indexes are defined for common sort and filter paths

## Testing

Run the test suite with:

```bash
mix test
```

## Notes

See `NOTES.md` for implementation assumptions, trade-offs, and suggested future improvements.

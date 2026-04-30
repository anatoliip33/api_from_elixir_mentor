# Task Processing Pipeline — Missing Implementations & Future Work

**Focus:** What wasn't built and how to implement it.

---

## Missing Features by Priority

### 1. GenServer for Metrics

1. **GenServer for Metrics**
   - **Gap:** No real-time throughput tracking, failure rates, or queue depth monitoring
   - **Impact:** Cannot expose `/api/tasks/metrics` endpoint as outlined
   - **How to implement:**
     - Create GenServer to subscribe to Oban notifications
     - Use ETS table to accumulate metrics
     - Add periodic snapshot logic
   - **Future approach:**
     ```elixir
     # TaskPipeline.MetricsCollector (GenServer)
     # - Subscribe to :oban_job events
     # - Track {:processed, :failed, :retried} counts
     # - Expose via {:ok, metrics} handle_call
     # - Add to supervision tree
     # - Expose metrics in /api/tasks/metrics endpoint
     ```

2. **ETS Caching Layer**
   - **Gap:** Summary endpoint queries DB every time; no caching
   - **Impact:** At 10k tasks/min, repeated GROUP BY queries become bottleneck
   - **How to implement:**
     - Create named ETS table
     - Add cache invalidation strategy (on task status change)
     - Integrate Pub/Sub to invalidate across nodes
   - **Future approach:**
     ```elixir
     # On app start:
     # :ets.new(:task_metrics, [:named_table, :public])
     # 
     # On every TaskWorker completion:
     # - Broadcast PubSub event
     # - Subscriber updates ETS cache
     # 
     # GET /api/tasks/summary reads ETS first
     ```

3. **DynamicSupervisor for Custom Workers**
   - **Gap:** No spawned worker processes; all via Oban (appropriate for this scale)
   - **Why skipped:** Oban already abstracts job scheduling; additional DynamicSupervisor adds complexity without benefit at current scale
   - **When useful:** If implementing custom per-task worker processes (e.g., long-lived stream processing)

4. **Fault Tolerance Deep Dive**
   - **Current:** If TaskWorker crashes mid-sleep, Oban retries the entire job
   - **Missing:**
     - Recovery for in-flight tasks (e.g., if node crashes during processing)
     - Task status rollback (processing → queued) if worker dies
   - **How to implement:**
     - Add heartbeat mechanism (task sends periodic updates)
     - Implement timeout logic to detect stale processing tasks
     - Create background job to requeue abandoned tasks
   - **Scale impact:** Acceptable risk for dev/test; production would need this

---

## Technical Skills (25% Evaluation Weight)

### ⚠️ Partially Implemented

1. **Error Handling**
   - Controller-level error catching via FallbackController
   - Missing: Detailed error classification (validation vs. not found vs. system error)
   - Could improve: Custom error types with pattern matching

2. **Context Boundaries**
   - Tasks context exists but minimal; could extract business logic further
   - Missing: Separate Metrics context, Attempt tracking context

3. **Database Constraints**
   - NOT NULL on required fields ✓
   - Missing: CHECK constraints for status transitions, UNIQUE constraints for idempotency

---

## System Design (20% Evaluation Weight)

### ❌ NOT Implemented

1. **Event Broadcasting**
   - **Gap:** No PubSub notifications on task status changes
   - **Impact:** External clients (web, mobile) cannot subscribe to real-time task updates
   - **How to implement:**
     - Add broadcast on every TaskWorker status update
     - Create client subscription handler in Phoenix (not needed for API-only)
   - **Future:** Add to TaskWorker:
     ```elixir
     Phoenix.PubSub.broadcast(TaskPipeline.PubSub, "tasks:#{task.id}", 
       {:status_changed, task.id, :completed})
     ```

2. **Scalability Analysis — Detailed Bottleneck Discussion**

   **At 10k tasks/min (~166 tasks/sec):**
   - **Status update race condition:** Without locking, two workers could overwrite each other's status transitions
     - **Solution:** Implement optimistic locking with version field
   - **Index effectiveness:** Composite indexes are perfect for list queries; stays sub-100ms even at 1M tasks
   - **Read replica trade-off:** Summary endpoint is read-heavy; ideal for read replica
     - Not needed until >100k tasks
   - **Network:** Job enqueue → worker fetch → status update → job completion = 3 DB round-trips per task
     - At high throughput, connection pool exhaustion risk
     - Solution: Use Oban Pro (batching, connection pooling improvements)

   **Architecture bottleneck at scale:**
   - **Single queue:** Cannot prioritize critical tasks over low-priority ones if queue is full
   - **Single node:** No horizontal scaling of job processing
   - **Recommended fix (not implemented):**
     ```elixir
     queues: [
       critical: 50,
       high: 30,
       normal: 15,
       low: 5
     ]
     ```

3. **Oban Unique Constraints**
   - **Gap:** No protection against duplicate job creation
   - **Risk:** If API client retries task creation, duplicate jobs spawn
   - **Future:**
     ```elixir
     TaskWorker.new(%{"task_id" => task.id},
       unique: [fields: [:args], period: 3600]
     )
     ```

---

## Code at Scale (10% Evaluation Weight)

### ❌ NOT Implemented

1. **Testing Concurrent Behavior**
   - **Gap:** No tests for race conditions, concurrent status updates, or GenServer state
   - **How to implement:** Use property-based testing or deliberate concurrency scenarios
   - **Test examples:**
     - Two workers attempt to process same task simultaneously
     - Task status transitions are idempotent
     - Oban job retries don't create orphaned tasks

2. **Comprehensive Error Handling**
   - **Gap:** Errors are caught but not deeply classified
   - **Better approach:**
     ```elixir
     defmodule TaskPipeline.Errors do
       defmodule ValidationError, do: defexception [:message]
       defmodule NotFoundError, do: defexception [:message]
       defmodule TransactionError, do: defexception [:message]
     end
     ```

---

## Testing (Required But Incomplete)

### ❌ Missing Tests

| Category | Gap | Impact | Time |
|----------|-----|--------|------|
| **Schema/Changeset** | No tests for Task.changeset (all edge cases) | Max_attempts validation, payload types |
| **Oban Worker** | No tests for job execution, retry logic | Failure rate, status transitions |
| **Context Functions** | No tests for create_task, get_summary, list_tasks | Transactional safety, query correctness |
| **Concurrent Scenarios** | Race conditions on status updates | DB consistency |
| **Integration** | End-to-end task creation → processing → completion | System reliability |

---

## Trade-offs & Shortcuts

| Decision | Trade-off | Future Fix |
|----------|-----------|-----------|
| **No GenServer metrics** | Real-time metrics unavailable | Implement MetricsCollector |
| **No ETS cache** | Summary endpoint queries DB every time | Add cache with PubSub invalidation |
| **Simplified attempt tracking** | No detailed audit trail | Add task_attempts table or embedded array |
| **Single Oban queue** | Cannot prioritize tasks; all queued equally | Split into priority queues |
| **No distributed locking** | Race conditions on concurrent status updates | Optimistic locking with version field |
| **Basic engine (not Pro)** | Lower throughput; no paid features | Upgrade if throughput >100 tasks/sec |

---

## Conclusion

**Weakest areas:**
- Limited testing coverage
- No GenServer or ETS optimizations
- Missing event broadcasting
- No scalability hardening (optimistic locking, distributed awareness)
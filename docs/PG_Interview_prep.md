# PostgreSQL Interview
_A concise study guide for a Senior PostgreSQL / Competitive Intelligence interview_

---

## 1. PostgreSQL at a Glance

**PostgreSQL** is an open-source relational database known for:

- reliability
- standards compliance
- extensibility
- strong concurrency
- rich indexing options
- advanced SQL features

### Core strengths
- ACID compliance
- MVCC for concurrency
- extensible via extensions
- strong support for complex queries
- rich data types: JSONB, arrays, ranges, UUID, GIS via PostGIS
- good balance of OLTP + analytical features

### Common weak spots
- horizontal write scaling is not native in core
- tuning can be complex under heavy workloads
- vacuum/bloat management requires understanding
- failover/HA often needs extra tooling and planning

---

## 2. Core Architecture

### Main components
- **postmaster**: parent process managing server
- **backend processes**: one per client connection
- **shared buffers**: memory cache for table/index pages
- **WAL**: write-ahead log for durability and recovery
- **checkpointer**: writes dirty pages to disk
- **background writer**: smooths writes to disk
- **autovacuum workers**: reclaim dead tuples and update stats

### PostgreSQL process model
PostgreSQL uses a **process-based architecture**, not a threaded one.  
Each client connection gets a separate server process.

### Key interview line
> PostgreSQL favors correctness, extensibility, and concurrency through MVCC and WAL-based durability.

---

## 3. MVCC (Multi-Version Concurrency Control)

### What it is
MVCC allows readers and writers to work without blocking each other in many cases.

### How it works
- updates create new row versions
- old row versions remain until cleaned up
- each transaction sees a consistent snapshot

### Benefits
- fewer read/write conflicts
- high concurrency
- consistent reads

### Costs
- dead tuples accumulate
- requires vacuum
- can cause table and index bloat

### Good explanation
> PostgreSQL avoids overwriting rows in place. Instead, it creates new versions, which improves concurrency but creates cleanup work later.

---

## 4. WAL (Write-Ahead Logging)

### Purpose
Before data pages are written to disk, changes are first written to the WAL.

### Why it matters
- crash recovery
- durability
- replication foundation
- point-in-time recovery

### Flow of a write
1. transaction changes data in memory
2. WAL records are generated
3. WAL is flushed on commit
4. dirty table pages may be written later

### Interview line
> WAL makes commits durable without forcing immediate table-page writes.

---

## 5. Vacuum and Autovacuum

### Why vacuum exists
Because of MVCC, old row versions need cleanup.

### What VACUUM does
- removes dead tuples
- marks space reusable
- updates visibility map
- helps prevent transaction ID wraparound

### What VACUUM does **not** do
- usually does not shrink table files on disk

### VACUUM FULL
- rewrites the table
- reclaims disk space
- requires more locking
- heavier operation

### Autovacuum
Background workers that automate vacuum and analyze tasks.

### Common issues
- autovacuum too slow
- table bloat
- stale statistics
- wraparound risk

### Interview line
> Autovacuum is essential, not optional. Many production problems come from mis-tuned or blocked autovacuum.

---

## 6. Query Planning and EXPLAIN

### Planner job
PostgreSQL decides the most efficient way to run a query.

### Common plan nodes
- Seq Scan
- Index Scan
- Bitmap Index Scan
- Bitmap Heap Scan
- Nested Loop
- Hash Join
- Merge Join
- Sort
- Aggregate

### Useful commands
```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 42;
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;
```

### Difference
 - EXPLAIN: estimated plan
 - EXPLAIN ANALYZE: actual execution with timing

### What to look for
 - wrong row estimates
 - sequential scans on large tables
 - bad join order
 - sorting spilling to disk
 - missing indexes
 - high loop counts

### Interview line
> A slow query is often a planning problem, a statistics problem, an indexing problem, or a data-shape problem.

---

## 7. Index Types
### B-tree
Default index type. Best for:
 - equality
 - range queries
 - sorting

### Hash
Best for equality only. Less commonly used.

### GIN
Useful for:
 - JSONB
 - arrays
 - full-text search

### GiST

Useful for:

 - geometric data
 - ranges
 - full-text search
 - PostGIS

### BRIN
Good for very large tables where values are naturally ordered, such as:
 - timestamps
 - append-only logs

### Interview line
> Index choice should reflect access patterns, not just data type.

---

## 8. Transactions and Isolation Levels
### ACID
- Atomicity
- Consistency
- Isolation
- Durability

### Isolation levels in PostgreSQL
- Read Committed
- Repeatable Read
- Serializable

### Default
- Read Committed

### Notes
- PostgreSQL does not implement Read Uncommitted separately; it behaves like Read Committed.
- Serializable in PostgreSQL uses predicate locking and conflict detection.

### Common interview angle

Explain tradeoff:
- higher isolation = stronger guarantees
- but more overhead / retry complexity

---

## 9. Locking and Concurrency
### Lock types
- row-level locks
- table-level locks
- advisory locks

### Row lock examples
```sql
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;
SELECT * FROM jobs WHERE status = 'queued' FOR UPDATE SKIP LOCKED;
```
### Important concepts
- blocking
- deadlocks
- lock queues
- long transactions

### Common causes of pain
- idle in transaction sessions
- long-running updates
- DDL changes on busy tables
- missing indexes on foreign keys

### Interview line
> Many concurrency issues are caused less by PostgreSQL itself and more by application transaction design.

---


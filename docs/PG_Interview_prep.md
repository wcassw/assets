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

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

## 10. Replication
### Physical replication
Replicates WAL changes at block level.

### Best for
- read replicas
- standby servers
- HA

### Pros
- simple
- mature
- full database copy

### Cons
- less selective
- same major version family constraints

### Logical replication
Replicates data changes at table/publication level.

### Best for
- selective replication
- migrations
- version upgrades
- integration use cases

### Pros
- more flexible
- table-level control

### Cons
- more complexity
- some edge cases and operational overhead

### Sync vs Async
- Synchronous: stronger durability, higher latency
- Asynchronous: lower latency, some data loss risk on failover

### Interview line
> Physical replication is the default HA path; logical replication is the flexible path.

---

## 11. High Availability (HA)
### Common HA goals
- low RPO
- low RTO
- automatic failover
- replica promotion
- split-brain avoidance

### Typical stack
- primary
- one or more replicas
- failover manager / orchestrator
- load balancer / connection routing

### Key tradeoffs
- availability vs consistency
- automation vs operational safety
- sync commit vs latency

### Topics to know
- failover
- switchover
- fencing
- replica lag
- client reconnection behavior

---

## 12. Backup and Recovery
### Main approaches
- pg_basebackup for base backups
- WAL archiving for PITR
- logical backups with pg_dump

### PITR
Point-in-Time Recovery allows restoring to a specific timestamp or transaction point.

### Backup strategy
A good production strategy includes:
- base backups
- WAL archiving
- restore testing
- retention policy
- offsite storage

### Interview line
> A backup is only real if restore has been tested.

---

## 13. Partitioning
### Why partition
- large table management
- pruning for query performance
- lifecycle handling
- easier maintenance

### Common partition types
- range
- list
- hash

### Best fit
- Usually large tables with predictable access patterns such as:
- time-series data
- billing data
- event logs

### Common mistakes
- too many partitions
- wrong key
- expecting partitioning to fix poor schema/index design

---

## 14. Extensions
### Why extensions matter
PostgreSQL is highly extensible.

### Common extensions
- pg_stat_statements — query stats
- PostGIS — geospatial
- pgcrypto — cryptographic functions
- uuid-ossp — UUID generation
- hstore — key/value storage
- citext — case-insensitive text

### Interview line
> PostgreSQL’s extension ecosystem is a competitive strength because it broadens use cases without changing database core behavior.

---

## 15. Observability and Troubleshooting
### What to watch
- CPU
- memory
- disk IOPS
- WAL generation rate
- checkpoint frequency
- lock waits
- query latency
- replication lag
- autovacuum activity
- cache hit ratio

### Useful views
```sql
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_statements;
SELECT * FROM pg_locks;
SELECT * FROM pg_stat_replication;
```

### Common troubleshooting flow
1. identify slow query or pressure point
2. inspect pg_stat_activity
3. use EXPLAIN ANALYZE
4. check indexes and row estimates
5. review locks, I/O, and vacuum behavior
6. verify app-side transaction behavior

---

## 16. Common Performance Problems
### Slow query causes
- missing indexes
- wrong index type
- stale stats
- bad joins
- wide rows
- too much data scanned
- disk spills during sort/hash
- application N+1 query patterns

### Database-wide issues
- connection overload
- checkpoint spikes
- WAL pressure
- replication lag
- bloat
- long transactions
- insufficient memory tuning

### Interview line
> Performance work starts with evidence, not guesses.

---

## 17. Tuning Basics
### Memory settings
- shared_buffers
- work_mem
- maintenance_work_mem
- effective_cache_size

### WAL / checkpoint settings
- wal_level
- max_wal_size
- checkpoint_timeout
- checkpoint_completion_target

### Planner/statistics
- default_statistics_target
- autovacuum analyze behavior

### Connection-related
- max_connections
- consider connection pooling with PgBouncer

### Interview line
> Tuning must follow workload shape; generic tuning without measurement can make systems worse.

---

## 18. Security Basics
### Key topics
- authentication methods
- roles and privileges
- pg_hba.conf
- SSL/TLS
- row-level security
- auditing approach
- secret rotation

### Best practices
- least privilege
- separate admin and app roles
- encrypt in transit
- review default permissions
- protect backups and WAL archives

---

## 19. PostgreSQL Competitive Positioning
### PostgreSQL vs MySQL
#### PostgreSQL strengths
- richer SQL
- stronger extensibility
- better advanced data types
- more powerful indexing options

#### MySQL strengths
- often seen as simpler for common web stacks
- broad ecosystem familiarity
- popular managed offerings

### PostgreSQL vs Oracle
#### PostgreSQL strengths
- lower licensing cost
- open ecosystem
- less vendor lock-in
- strong modern developer fit

#### Oracle strengths
- deep enterprise tooling
- strong legacy enterprise footprint
- mature ecosystem in large regulated orgs

### PostgreSQL vs SQL Server
#### PostgreSQL strengths
- portability
- open source
- lower cost
- strong Linux/cloud fit

#### SQL Server strengths
- tight Microsoft ecosystem integration
- strong enterprise tooling
- easy fit for some .NET-heavy shops

### PostgreSQL vs NoSQL
#### PostgreSQL strengths
- joins
- transactions
- relational integrity
- mixed workload flexibility

#### NoSQL strengths
- specific scale models
- schema flexibility
- simpler patterns for some narrow workloads


# Data Flow and State: Reasoning Framework

**Source canon:** Hickey, "Are We There Yet?" (2009) and "The Value of Values" (2012); Kleppmann, "Designing Data-Intensive Applications" (2017) Ch. 3, 10-12; Kreps, "The Log: What every software engineer should know about real-time data's unifying abstraction" (2013); Helland, "Immutability Changes Everything" (2015); Moseley & Marks, "Out of the Tar Pit" (2006)
**Applies when:** you need to understand how data enters a system, where it lives, how it transforms, and how it exits -- or when you suspect state duplication, unnecessary data movement, ambiguous ownership, or derived data masquerading as truth

---

## 1. What This Framework Addresses

This framework provides analytical tools for tracing data through a system: where it originates, how it transforms, where it persists, and how it reaches consumers. It addresses **state ownership** (who is the single source of truth for each piece of data), **derived data** (which stores are computable from other stores), **data movement** (whether each hop between systems adds value or just adds latency and failure modes), and **the system's relationship with time** (whether history is preserved, destroyed, or never captured).

The practical diagnostic value is high. Mechanically tracing data flow through a system -- following a fact from its point of origin through every transformation, copy, cache, and index -- immediately reveals state duplication, unnecessary hops, transformations that add no value, and derived state being stored when it should be computed. These problems are invisible at the module level; they only appear when you trace data across the full system.

This framework does **not** address where module boundaries should go (see `boundaries-encapsulation.md`), whether the system's overall complexity is justified (see `simplicity-complexity.md`), or whether dependencies point in the right direction (see `dependency-flow.md`). It focuses on the data itself -- its lifecycle, its ownership, and its flow.

---

## 2. Core Reasoning Procedure

### Step 1: Identify every piece of persistent state

Enumerate every store in the system: databases, caches, search indexes, message queues, configuration stores, local files, in-memory state that survives a single request. For each, note: what data does it hold? Who writes to it? Who reads from it? How long does data live here?

Be thorough. Teams routinely forget about caches, search indexes, analytics stores, CDN edge state, and client-side storage. These are all state. A Redis cache holding user sessions is state. An Elasticsearch index mirroring database records is state. A browser's local storage holding a copy of the user's profile is state.

### Step 2: Classify each store as source of truth or derived

For each store identified in Step 1, ask: **if this store were destroyed and rebuilt from scratch, could it be?** If yes -- if you could reconstruct its contents from some other store in the system -- it is derived data. If no -- if losing it means losing information permanently -- it is a source of truth.

Apply Kleppmann's strict test: a system of record is where data is first written when new information enters the system. It is authoritative. Derived data is anything that can be recreated by transforming the system of record -- caches, search indexes, materialized views, denormalized tables, analytics aggregations, read replicas.

Every store must be one or the other. If you cannot classify a store, that ambiguity is itself a finding. The most dangerous state is data that everyone treats as derived but nobody can actually rebuild -- a cache that has become a de facto source of truth because the rebuild pipeline was never built or has broken.

Label each store. This map is the foundation of everything that follows.

### Step 3: For each source of truth, verify singularity

For every important entity type in the system, ask: **where is the single source of truth?** There must be exactly one authoritative store. If two services both write the same entity type into their own databases, you have competing sources of truth. This is not "eventual consistency" -- it is ambiguous ownership, and it will produce silent data divergence that no amount of synchronization can cleanly resolve.

The Bezos API mandate, Shopify's component ownership model, and the data mesh principle all converge on the same rule: the team that understands the data owns its write path. Other teams consume through explicit interfaces or derive their own views. Cross-cutting writes to the same entity from multiple sources is the single most reliable indicator of a data architecture problem.

### Step 4: Trace data flow paths

For each major entity type, trace the path data takes from its origin to every consumer. Draw the flow: source of truth writes propagate to derived stores, which serve reads. At each hop, classify the mechanism: is data flowing through a database read, a service call, an event/message, a cache lookup, or a batch pipeline?

Kleppmann identifies three fundamental modes of data flow: through databases (temporal coupling -- write now, read later), through service calls (synchronous spatial coupling -- both parties must be available), and through asynchronous messages (loosest coupling -- sender and receiver decoupled in time and availability). Each hop in your data flow should be classifiable as one of these. Hops that resist classification -- shared filesystems, ad-hoc CSV exports, manual copy-paste, ETL jobs nobody owns -- are architectural debt.

At each hop, ask: **does this transformation add value?** Every data movement has a cost: latency, a failure mode, a consistency window, and code to maintain. If the transformation is pure pass-through -- reshaping data between layers without adding information, filtering, or aggregation -- question whether the hop is necessary or whether it exists to satisfy a structural mandate rather than a real need.

### Step 5: Check for dual writes

Dual writes -- application code writing the same data to two or more stores in the same operation without a coordination mechanism -- are the most common and insidious data flow anti-pattern. Kleppmann documents two specific failure modes: race conditions (concurrent operations arrive in different orders at each store, producing permanent inconsistency) and partial failures (one write succeeds and the other fails, leaving the stores permanently divergent).

For every store that should contain consistent views of the same data, verify: is there a single ordered stream of changes that both derive from, or are they independently written to? If the answer is independent writes, the system has a latent consistency bug. The fix is always the same: single writer with derived readers. Write to one store (the source of truth), and propagate to all others through an ordered mechanism (change data capture, event log, or transactional outbox).

The outbox pattern -- writing both the business data and an outbox event in a single database transaction, then processing the outbox asynchronously -- is the proven bridge between transactional and event-driven worlds. Stripe's "rocket ride" pattern and the microservices outbox pattern are variations on this theme.

### Step 6: Assess the system's relationship with time

Ask: **when data changes, does the system preserve the previous value?** Most systems default to place-oriented programming -- Hickey's "PLOP" -- where new information overwrites old information. This destroys history. You know a customer's current address but not their previous one. You know an account balance but not the transactions that produced it.

Hickey's diagnostic: "Imagine if you only knew the present value of any property or attribute in the world. How good would your decision making capability be? It would be awful." Systems that destroy history lose the ability to audit, debug temporal issues, answer "what was the state at time T?" questions, or detect trends.

The well-architected systems converge on the same pattern: PostgreSQL's WAL is the truth and heap tables are derived. Kafka's log is the truth and tables are materialized views. Git's immutable objects are the truth and the working tree is derived. Datomic's accumulated facts are the truth and query results are derived. Redux's action history is the truth and the store state is a fold. In every case, **the record of what happened is primary; the current state is secondary and derivable**.

This does not mean every system needs event sourcing. But every system should be assessed: are you destroying information that has business value? Could derived data be rebuilt if the derivation is wrong? Is there an audit trail, and does it live as a first-class citizen or a bolted-on afterthought that diverges from the real state?

### Step 7: Verify rebuildability of derived data

For every derived store identified in Step 2, ask: **when was the last time someone tested rebuilding this from scratch?** If the answer is "never" or "we can't," the derivation pipeline is a fiction. A cache that cannot be rebuilt is not a cache -- it is an unprotected source of truth with no backup strategy.

Kleppmann's principle: derived data should be treated as disposable. If your search index corrupts, you rebuild it from the source of truth. If your cache goes cold, you repopulate it. This is only possible if the source of truth is intact and the derivation pipeline is well-defined, deterministic, and tested.

Check for log retention: if your event stream or change data capture feed is the mechanism for rebuilding derived stores, is the retention period sufficient? A Kafka topic with 7-day retention cannot rebuild a search index that took 3 months of data to populate. Compacted topics or snapshotting strategies must bridge this gap.

### Step 8: Synthesize findings

After completing steps 1-7, you should be able to articulate:
- Which stores are sources of truth and which are derived (and whether this classification is clear, enforced, and correct)
- Where data flow is explicit and well-ordered versus implicit and ad-hoc
- Where dual writes create latent consistency bugs
- Where state is duplicated without clear ownership
- Where transformations add no value and could be eliminated
- Whether the system preserves or destroys history, and whether that choice is deliberate
- Whether derived data can actually be rebuilt

Multiple symptoms often share one root cause. A "caching problem" and a "consistency problem" and a "debugging problem" may all trace to a single missing source of truth. Find the root before proposing structural changes.

---

## 3. Diagnostic Questions

**Q: For each datastore, is it a source of truth or derived data?**
Healthy: Every store is explicitly classified. Sources of truth are documented and protected. Derived stores have documented rebuild procedures.
Unhealthy: The classification is unclear. Stores exist in a gray zone -- treated as derived but not actually rebuildable, or treated as authoritative but with no protection against corruption or loss. This ambiguity produces the worst outcomes: data that is both poorly protected and impossible to reconstruct.

**Q: For each entity type, can you point to exactly one authoritative store?**
Healthy: Every entity has a clear owner. The owning service controls all writes. Other services consume through explicit interfaces.
Unhealthy: Two or more services write the same entity type independently. Inconsistencies are resolved by "whichever one the user happened to query." Amazon's API mandate, Shopify's component ownership, and Netflix's data mesh all exist to prevent this failure.

**Q: Can you trace the path of any piece of data from origin to every consumer?**
Healthy: Data flow is explicit, documented, and classifiable at every hop (database read, service call, or async message). You can draw the complete flow diagram without dotted lines or question marks.
Unhealthy: Data moves through undocumented channels -- shared filesystems, ETL scripts nobody owns, periodic "sync" jobs. The full flow cannot be drawn without investigation.

**Q: Does any application code write to more than one datastore in the same operation?**
Healthy: Each write goes to exactly one store. All other stores are updated through an ordered propagation mechanism (CDC, events, transactional outbox).
Unhealthy: Application code writes to a database and then a cache, or a database and then a message queue, without coordination. If one write succeeds and the other fails, the stores diverge permanently.

**Q: If you replayed every event or change from the beginning, would you arrive at the current state?**
Healthy: Yes. The event/change history is complete, ordered, and sufficient to reconstruct all derived state. This has been tested.
Unhealthy: No. State changes happen outside the log (manual database edits, migration scripts that bypass the event stream, ad-hoc fixes). The log is incomplete, and derived state cannot be verified against it.

**Q: When data changes, does the system preserve the previous value?**
Healthy: History is preserved where it has business value. Audit trails are first-class citizens. The system can answer "what was the state at time T?" without archaeological investigation.
Unhealthy: Updates overwrite in place. History is destroyed by default. Audit trails, if they exist, are a separate system that frequently diverges from the actual state. Debugging temporal issues requires reading through application logs and guessing.

**Q: Is there derived state being stored that could be computed on demand?**
Healthy: Denormalization and pre-computation are deliberate performance optimizations with clear justification. The derivation logic is documented and the derived store is rebuildable.
Unhealthy: Copies of data proliferate without clear reason. The same fact is stored in five places "just in case." Nobody knows which copy is authoritative. Storage is used as a substitute for a clean data flow.

**Q: Are there transformations in the data flow that add no information?**
Healthy: Every transformation between source and consumer adds value -- filtering, aggregation, format conversion for a different query pattern, enrichment with additional data.
Unhealthy: Data is reshaped at each layer boundary to satisfy interface contracts, but no information is added or removed. A domain object is converted to a DTO, then to a view model, then to a response object -- each step a mechanical reshaping that exists to cross a layer boundary rather than to serve a purpose.

**Q: For every pair of stores that should be consistent, is there a total ordering of writes?**
Healthy: All writes to a given entity pass through a single point of serialization (a leader, a log, a transactional outbox). This total ordering eliminates ambiguity about which write came first.
Unhealthy: Multiple writers can update the same entity concurrently with no coordination. Consistency depends on timing -- the system is correct most of the time but silently wrong under concurrent writes.

**Q: If a derived store were destroyed, how long would it take to rebuild, and has this been tested?**
Healthy: Rebuild procedures exist, are automated, and are tested periodically (analogous to testing backups by restoring them). Rebuild time is known and acceptable.
Unhealthy: Nobody knows if the rebuild would work. The last attempt was years ago or has never been tried. Log retention is insufficient to rebuild from scratch. The team would have to invent a procedure during an incident.

**Q: Do "sync" or "reconciliation" jobs exist between datastores?**
Healthy: No. All stores derive from a single ordered source and stay consistent through the derivation pipeline.
Unhealthy: Periodic jobs exist that compare two stores and fix differences. These jobs are a symptom of dual writes or broken derivation pipelines. They are band-aids over a structural problem. If the reconciliation job fails or falls behind, inconsistency accumulates silently.

**Q: Is the same business rule or validation logic implemented in multiple places?**
Healthy: Each business rule has one canonical implementation, colocated with the data it governs. Other systems call through to the owner.
Unhealthy: The same validation (e.g., "is this discount code valid?") is independently implemented in the checkout service, the reporting service, and the mobile app. They will diverge, producing inconsistent behavior that is extremely difficult to debug.

**Q: Does the system distinguish between facts and derived opinions?**
Healthy: Events and records of things that happened are treated as immutable facts. Current aggregated state (balances, counts, status fields) is treated as derived and rebuildable.
Unhealthy: The system treats mutable current state as primary and has no concept of the events that produced it. Derived values (e.g., an order total) are stored alongside source values (line items) with no clear derivation relationship.

**Q: Are caches invalidated correctly, or does stale data cause user-visible bugs?**
Healthy: The cache invalidation strategy is explicit and matches the consistency requirements. For most data, the cache is populated from the same ordered change stream that updates other derived stores.
Unhealthy: Cache invalidation is ad-hoc. Developers sprinkle `cache.delete(key)` calls throughout the codebase. Some code paths miss the invalidation. Stale data is a recurring source of bugs and support tickets.

**Q: Does the data model reflect the domain's natural events, or only its current state?**
Healthy: The system captures what happened (OrderPlaced, PaymentReceived, ItemShipped) as first-class records. Current state can be derived from the event history.
Unhealthy: The system captures only current state (Order.status = 'shipped'). The history of how the order reached that state is scattered across log files or lost entirely. When an order is in an unexpected state, debugging requires reconstructing the timeline manually.

**Q: Is the system level-triggered or edge-triggered, and is that choice deliberate?**
Healthy: The choice is deliberate and matches the reliability requirements. Level-triggered systems (like Kubernetes controllers) re-read current state on every cycle and self-heal if events are lost. Edge-triggered systems process events once and are carefully designed for exactly-once or idempotent processing.
Unhealthy: The system is edge-triggered by accident -- it reacts to events without checking current state. If an event is lost or duplicated, the system silently diverges. There is no reconciliation mechanism.

**Q: When a new team or service needs the same data in a different shape, what do they do?**
Healthy: They create a new derived view from the existing source of truth. The derivation pipeline is a well-supported, self-serve capability.
Unhealthy: They copy the database, build a separate ETL pipeline, or start calling the source service synchronously for every read. Each new consumer adds another ad-hoc data flow path that nobody maintains holistically.

---

## 4. What Good Looks Like vs What Bad Looks Like

**Bad:** Two services both write to the same entity type in their own databases. Neither service knows about the other's writes. A periodic reconciliation job runs nightly to detect and fix differences. Sometimes it doesn't run. Sometimes the fix logic is wrong.
**Good:** One service owns the entity. The other subscribes to change events and maintains its own read-optimized view. The owning service is the undisputed source of truth. Disagreements are resolved by consulting the owner.
**Gravity:** The second team needed the data and the fastest path was to add their own writes. Building the event pipeline felt like over-engineering for "just one more writer." By the third writer, the reconciliation job was born.

**Bad:** Application code writes to a database and then publishes a message to a queue. If the message fails to send, the database has the update but the downstream consumer does not. If the database transaction fails after the message was sent, the consumer has an update that was never committed.
**Good:** Application code writes the business data and an outbox record in a single database transaction. A separate process (CDC or outbox poller) reliably publishes the outbox records to the event stream. Atomicity is guaranteed by the database transaction; delivery is guaranteed by the outbox processor.
**Gravity:** Writing to two systems in application code is the obvious implementation. The outbox pattern requires extra infrastructure. Under deadline pressure, the obvious approach wins. The consistency bugs appear weeks or months later, intermittently.

**Bad:** A cache serves as the primary read path for user profile data. The cache is populated lazily on cache miss. But the service that originally writes profile data was decomposed into two services, and one of them doesn't invalidate the cache. Users see stale data for unpredictable periods.
**Good:** The cache is populated from a change data capture stream. Every write to the source database automatically triggers a cache update through the same ordered pipeline. Cache invalidation is not sprinkled through application code -- it is a structural guarantee of the data flow.
**Gravity:** Lazy-loading caches are trivially simple to implement. Adding explicit cache invalidation to every write path is tedious. As the system grows and more services write to the source, maintaining all invalidation paths becomes combinatorially difficult.

**Bad:** The order total is stored alongside line items. When line items change, application code must remember to recalculate and update the total. Sometimes it doesn't. The stored total diverges from what the line items actually sum to.
**Good:** The order total is computed on demand from line items, or maintained through a clearly defined derivation that is triggered automatically by the data flow (e.g., a database trigger, a projection from an event stream, or computed in the read layer). The derivation relationship is explicit and cannot be bypassed.
**Gravity:** Storing pre-computed values feels like a performance optimization. Recomputing feels wasteful. But the pre-computed value is derived state, and every derived value that can diverge from its source will eventually do so.

**Bad:** The system uses a mutable database and bolts on a separate audit log by writing to both tables. The audit log is maintained by a different code path than the business logic. When business logic changes, the audit log is sometimes forgotten. The audit log tells a different story than the actual data.
**Good:** The primary data model captures events (what happened). Current state is derived from the event history. Auditing is a natural consequence of the data model, not a separate concern. The audit trail and the business data cannot diverge because they are the same thing.
**Gravity:** Separate audit logs feel like the right separation of concerns. But when the audit system is maintained by different code than the business system, divergence is inevitable. The real separation of concerns is between facts (immutable events) and opinions (derived current state).

**Bad:** A search index mirrors database records but cannot be rebuilt from scratch because the database has grown significantly since the index was last rebuilt, and the pipeline has evolved. When the index becomes corrupted or out of date, a multi-day recovery project begins.
**Good:** The search index is derived from a compacted event stream with sufficient retention. Rebuilding the index is an automated, tested operation that completes in hours. Index corruption is an inconvenience, not a crisis.
**Gravity:** Index rebuild pipelines are tested at creation time and then forgotten. The data grows, schemas evolve, and the pipeline rots. Nobody tests the rebuild until they need it, and then they discover it no longer works.

**Bad:** Data passes through four service layers between the source and the consumer. Each layer converts the data format: domain object to DTO to wire format to DTO to domain object. No layer adds information. Each layer adds latency, a failure mode, and code to maintain.
**Good:** The source publishes data in a self-describing format. The consumer reads it directly or through a single transformation that adds genuine value (filtering, enrichment, aggregation). Each hop in the data flow earns its existence.
**Gravity:** Layered architectures mandate format conversions at each boundary. This feels disciplined -- each layer "owns" its representation. But when the conversions are mechanical and add no information, they are accidental complexity imposed by the architecture, not demanded by the problem.

**Bad:** Configuration for feature flags is stored in a database, cached in memory on each server, and read by a CDN edge layer. Each layer has a different refresh interval. A flag change takes between 0 and 30 minutes to fully propagate. Nobody knows exactly when a given server will see the change. Rollbacks are unpredictable.
**Good:** Configuration state has a single source with a well-defined propagation mechanism. Propagation time is bounded and observable. Rollback means writing a new value to the source and observing it propagate through the same deterministic pipeline.
**Gravity:** Multi-layer caching is introduced incrementally for performance. Each layer's caching strategy is optimized locally. Nobody designs the end-to-end propagation behavior. The system works fine until a critical flag change needs to take effect within seconds.

**Bad:** Three microservices each maintain their own copy of product data because calling the product service at query time is too slow. Each copy drifts from the source at different rates depending on the sync mechanism. Customers see different product names on different pages.
**Good:** Product data has one owner. Other services subscribe to a change stream and maintain local read-optimized views with bounded staleness. The derivation lag is monitored. If a service's view falls behind, an alert fires before customers notice.
**Gravity:** The product service became a bottleneck for reads. Caching at each consuming service was the performance fix. Without a change stream, each service implemented its own sync mechanism. The "temporary" caches became permanent divergent copies.

**Bad:** A migration from one database to another is executed by writing to both the old and new databases simultaneously during a transition period. Subtle differences in write ordering produce inconsistencies that are discovered weeks later.
**Good:** The new database is populated by consuming the old database's change stream. During migration, reads are gradually shifted from old to new. Once the new database is verified, the old is decommissioned. At no point are there two independent write paths.
**Gravity:** Dual-writing during migration feels like the safe, gradual approach. In practice, maintaining consistency across two independent write paths under concurrent load is one of the hardest distributed systems problems. The change-stream approach is more work upfront but eliminates the consistency ambiguity entirely.

**Bad:** The system has no concept of events or history. When a customer reports that their order was incorrectly charged, the support team examines the current database state and finds the order marked as "paid." They cannot determine whether the charge was applied once or twice, or whether a refund was issued and then reversed.
**Good:** The financial system records every event (ChargeInitiated, ChargeSucceeded, RefundIssued, RefundReversed). The current balance is a derived fold over these events. Support can trace the exact sequence that led to the current state. Double-entry bookkeeping ensures that every movement of money is accounted for.
**Gravity:** Recording events feels like overhead when the current state "has everything you need." But the current state is an opinion about what events sum to. When the opinion seems wrong, you need the events to diagnose why.

**Bad:** Deploy state and configuration are managed through manual processes. Different servers run different versions of the code or configuration because deployment was not atomic. Knight Capital's $440M loss resulted from exactly this: one of eight servers running old code that interpreted a reused configuration flag differently than the new code.
**Good:** Deploy state is itself a source-of-truth system with strong consistency guarantees. Every server's running version is tracked and verified. Configuration changes propagate through a well-defined pipeline with canary and staged rollout. The meta-state (state about state) is as carefully managed as business data.
**Gravity:** Meta-state feels like infrastructure, not architecture. Teams focus data flow analysis on business data and neglect the data flow of deployments, configuration, and operational state. The most expensive state management failures in history -- Knight Capital, GitLab's database deletion, GitHub's MySQL split-brain -- were all failures of meta-state, not business data.

---

## 5. Common Failure Modes

**Ambiguous Ownership**
Pattern: Multiple services write the same entity type into their own databases. No service is declared as the authoritative source. When the stores disagree, nobody knows which is right.
Symptom: Inconsistent data across the system. Customer sees different information on different pages. Support team gets different answers depending on which service they query. Reconciliation jobs are introduced to patch the symptoms.
Root cause: The data architecture was not designed -- it emerged. Each team built what they needed without coordinating ownership. The first team stored the data; the second team needed it and stored their own copy; the third team did the same. By the time the problem is visible, three codebases write to the same entity.
Direction: Declare a single owner for each entity type. Other services derive views through explicit subscription (event streams, CDC). The owner controls all writes and publishes changes. This may require organizational negotiation, not just technical change.
Over-correction risk: Over-centralizing ownership into a single monolithic data service that becomes a bottleneck for all writes and a single point of failure. Each entity type should have its own owner, collocated with the domain expertise -- not a centralized "data team" that owns everything.

**Dual Writes Without Coordination**
Pattern: Application code writes to a database and then a search index, or a database and then a message queue, in the same operation without a transactional guarantee spanning both.
Symptom: Intermittent inconsistency between stores. Usually invisible because it happens only under concurrent load or partial failures. Discovered when a customer reports seeing stale search results, or when a downstream consumer processes a message for a transaction that was rolled back.
Root cause: Writing to two systems in application code is the obvious, simple implementation. The failure modes are subtle and intermittent -- they don't show up in testing, only in production under load. The outbox pattern, which fixes this, requires extra infrastructure that feels like over-engineering until the bugs appear.
Direction: Single writer with derived readers. Write to one store in a transaction (using the outbox pattern if you also need to emit events), and derive all other stores from that write through an ordered propagation mechanism.
Over-correction risk: Routing all writes through a single global event log when a simple database with CDC would suffice. Match the coordination mechanism to the actual consistency requirements. Not every write needs to go through Kafka.

**Derived Data Treated as Source of Truth**
Pattern: A cache, search index, or denormalized store is the only place certain data lives, even though it was designed as a derived view. The pipeline that populates it from the source of truth has been neglected or broken.
Symptom: Data loss when the derived store fails. Inability to rebuild the store. The team treats the cache with the same care as a primary database -- backup policies, high availability, failure alerts -- because losing it means losing data, not just losing performance.
Root cause: The rebuild pipeline was not maintained as the system evolved. Schema changes in the source of truth were applied but the derivation pipeline was not updated. Alternatively, the pipeline was never built -- the "derived" store was populated by a one-time migration and then accumulated direct writes.
Direction: Restore the derivation pipeline. Ensure the source of truth contains all the information needed to rebuild the derived store. Test the rebuild regularly. If the derived store has accumulated information not in the source of truth, migrate that information back to the source before treating it as derived again.
Over-correction risk: Rebuilding all derived stores from scratch on a regular cadence "just in case," even when the derivation pipeline is healthy. Continuous derivation (CDC, event streams) is more efficient than periodic full rebuilds for stores that are already in sync.

**State Duplication Without Clear Derivation**
Pattern: The same fact is stored in multiple places with no clear relationship between the copies. Each copy may have been originally correct but drifts independently over time.
Symptom: Data inconsistency that appears randomly. Different parts of the system disagree about basic facts. Fixing the data in one place does not fix it everywhere. "We fixed that bug" followed by "it's happening again" because the fix was applied to one copy but not the others.
Root cause: Each consuming team needed the data in their own format and copied it. Without a change stream, each copy is a frozen snapshot that ages independently. The problem compounds because each new consumer adds another copy, and nobody maintains a map of all copies.
Direction: Identify the authoritative copy. Establish a change stream from that copy. Convert all other copies into derived views that are maintained by consuming the stream. Eliminate direct copies.
Over-correction risk: Eliminating all denormalization in the name of a single source of truth, forcing every read to traverse back to the source. Derived copies are fine -- the problem is unmanaged copies. Managed, derived copies with a clear update mechanism are a legitimate and often necessary architectural pattern.

**History Destruction**
Pattern: The system overwrites state in place with no record of previous values. Updates are destructive -- the old value is gone. There is no event log, no changelog, no audit trail.
Symptom: Inability to answer "what was the state at time T?" Inability to debug how the system reached its current state. Regulatory audit failures. When a customer disputes a charge or a transaction appears incorrect, the investigation dead-ends because the history was never recorded.
Root cause: Most database frameworks default to UPDATE semantics. Storing events or maintaining a changelog requires deliberate design effort. Under deadline pressure, the default wins. The team does not anticipate the need for history until they desperately need it.
Direction: Add event capture at the write path. This can range from full event sourcing (the event log is the source of truth) to simple change data capture (the database is the source of truth, and a CDC stream captures changes for history and downstream derivation). The right level depends on the domain's temporal requirements.
Over-correction risk: Full event sourcing for domains with no temporal business value (e.g., a CMS for blog posts). Greg Young's diagnostic: "Is the history of how you arrived at the current state valuable to your business?" If not, simple CDC or timestamp columns may be sufficient. Event sourcing adds significant complexity and should be reserved for domains where history is genuinely load-bearing.

**Unnecessary Data Movement**
Pattern: Data passes through multiple services or layers, being transformed at each step, but no transformation adds information. The data is reshaped to match layer-specific contracts and then reshaped again at the next layer.
Symptom: High latency on read paths. A cascade of service calls for what should be a simple query. Each intermediate service adds latency and a failure mode. When any intermediate service is slow or down, the entire read path degrades.
Root cause: Layered or microservice architectures mandate that data crosses explicit boundaries. If the boundaries are drawn without considering data flow, the data must be shepherded through modules that have no business need for it. Pass-through services -- services whose only purpose is to relay data between two other services -- are the clearest signal.
Direction: Straighten the data flow path. If a consumer needs data from a source, the path should be as direct as possible. Evaluate whether intermediate services add value or just add hops. Consider read-optimized derived stores that bring the data closer to the consumer rather than having the consumer chase it through a chain of service calls. Boundary placement should account for data access patterns, not just organizational structure.
Over-correction risk: Collapsing all services into a monolith to eliminate network hops. The solution is not to remove boundaries but to place them where they serve both organizational autonomy and efficient data flow. A well-placed boundary hides complexity; a poorly-placed boundary creates data movement overhead.

**Reconciliation as Architecture**
Pattern: Periodic jobs run to compare two or more datastores and fix differences. The reconciliation job is not a temporary migration aid -- it is a permanent part of the architecture.
Symptom: The reconciliation job has its own monitoring, alerting, and on-call rotation. When it breaks, inconsistency accumulates silently. When it runs, it creates database load spikes. There are debates about how often it should run. Data is "eventually consistent" with "eventually" meaning "whenever the cron job runs."
Root cause: The data flow is not properly ordered. Two stores are updated independently, and the reconciliation job patches the inevitable divergence. The job was introduced as a temporary measure and became permanent because fixing the underlying data flow was deemed too expensive.
Direction: Fix the data flow. Replace independent writes with a single source of truth and derived views. The reconciliation job should be decommissioned, not maintained. If it must exist temporarily during a migration, set a hard deadline for its removal.
Over-correction risk: Eliminating reconciliation before the replacement data flow is proven correct. During a migration from dual writes to single-writer-with-derived-views, the reconciliation job serves as a safety net. Remove it only after the new pipeline has been validated in production.

**Non-Rebuildable Derived Stores**
Pattern: A derived store (search index, cache, analytics aggregate) was built from the source of truth at some point, but the rebuild pipeline has decayed. The log or event stream used to populate it has been truncated. Schema evolution in the source has made the derivation logic stale.
Symptom: When the derived store has a problem (corruption, drift, upgrade), the response is a multi-day or multi-week recovery project rather than an automated rebuild. The team treats derived stores with the same criticality as sources of truth because losing them means losing a capability that cannot be quickly restored.
Root cause: Rebuild pipelines are tested at creation time and then neglected. The data grows, schemas evolve, log retention policies expire, and the pipeline rots. Nobody tests the rebuild until they need it urgently.
Direction: Treat rebuild-from-scratch as a capability that must be maintained. Ensure log retention or snapshotting sufficient to rebuild. Test rebuilds regularly (quarterly or after major schema changes). Automate the rebuild process so it can be executed without heroics.
Over-correction risk: Retaining unbounded event history to enable rebuilds, at the cost of enormous storage and increasingly slow replay times. Log compaction, snapshotting, and periodic full-state captures are all valid strategies to enable rebuilds without unbounded retention.

**Stale Caches Without Bounded Staleness**
Pattern: Caches are populated lazily and invalidated ad-hoc. Different caches have different staleness characteristics that are undocumented and unmonitored. Users see unpredictably stale data.
Symptom: "It works if you clear the cache" is a known fix. Support teams know to tell users to hard-refresh. Developers add cache-busting parameters. The caching layer, designed to improve performance, becomes a source of bugs and confusion.
Root cause: Caching was added incrementally for performance without designing the end-to-end consistency behavior. Each cache was optimized locally. Nobody designed the system-wide staleness guarantee.
Direction: Define a staleness budget for each data type. Populate caches from the same change stream that updates other derived stores. Monitor cache lag. Replace ad-hoc invalidation with structural invalidation derived from the data flow.
Over-correction risk: Eliminating caching entirely in the name of consistency. Caches are a legitimate performance tool. The problem is not caching itself but unmanaged caching with no staleness contract.

**Split-Brain in Failover**
Pattern: During a network partition or failover, two nodes accept writes for the same data. When the partition heals, the system has two divergent states and no automated way to reconcile them.
Symptom: Data loss or corruption after failover. GitHub's 2018 MySQL incident resulted in 24+ hours of degraded service because two primaries had accepted independent writes during a partition. The reconciliation required manual analysis.
Root cause: The failover mechanism can promote a new primary without properly fencing the old one. The old primary continues accepting writes, believing it is still the leader. This is a failure of the meta-state -- the system's knowledge of its own topology is inconsistent.
Direction: Implement proper fencing. When a new primary is promoted, the old primary must be prevented from accepting further writes (via STONITH, lease expiration, or epoch-based fencing). Design for the possibility that fencing fails -- use conditional writes or CAS operations that detect stale leadership.
Over-correction risk: Refusing all writes during a partition in the name of safety, when the application could tolerate a brief period of read-only operation or could write to a local log for later reconciliation. The severity of split-brain depends on the data type -- financial ledger entries require strict fencing; cache updates can tolerate a brief split.

---

## 6. Interactions With Other Frameworks

### Data Flow and Boundaries/Encapsulation (`boundaries-encapsulation.md`)

Boundary placement determines data flow paths. A boundary drawn without considering data access patterns creates unnecessary data movement: facts that should be colocated are split across modules, forcing fetch-transform-forward chains that add latency and failure modes.

The critical intersection is shared databases. When two modules share a database, they share the most intimate implementation detail possible -- the schema, the constraints, the indexes, the migration history. This destroys boundary encapsulation regardless of how clean the code-level interfaces are. Amazon's API mandate addressed this directly: no shared databases between services, because shared databases are shared state, and shared state makes module boundaries cosmetic.

Pass-through variables -- data threaded through multiple module boundaries because it is needed deep in the call chain but not by intermediate modules -- are a data flow signal of a boundary problem. Each intermediate module's interface is polluted by knowledge it does not use. When you see pass-through data, either the boundary is in the wrong place (the data producer and consumer should be in the same module) or the data is flowing through too many layers (the path should be straightened).

Conversely, data flow analysis reveals where boundaries should exist but don't. If two modules that should be independent share a data format, a message schema, or assumptions about data ordering, they are coupled through data even if the code boundaries are clean. Parnas's information leakage applies to data flow: a leaked data format is a shared secret that binds modules together.

### Data Flow and Simplicity/Complexity (`simplicity-complexity.md`)

Moseley and Marks identify mutable state as the single largest source of accidental complexity in software. Every bit of mutable state doubles the total number of possible system states. The data flow framework examines how state moves and who owns it; the simplicity framework asks whether that state is essential or accidental.

Every cache, denormalization, and derived store is accidental state -- it exists for performance or convenience, not because the problem demands it. This is not wrong (performance matters), but it must be recognized. Accidental state that is not labeled as such accumulates without limit. The team begins treating every derived store as essential, protecting it with the same care as the source of truth, and the system's complexity budget inflates.

The specific intersection to watch: over-derivation. Creating a pipeline that derives five different materialized views from a single event stream is architecturally clean but operationally complex. Each view adds infrastructure to maintain, monitor, and rebuild. If three of those views could be replaced by a query against the source, the complexity of the derivation pipeline is not justified.

The simplicity lens sharpens data flow analysis: for every piece of state, ask "is this essential to the problem, or is it an optimization?" Essential state gets the most careful ownership design. Accidental state gets a documented rebuild path and a staleness contract.

### Data Flow and Dependency Flow (`dependency-flow.md`)

Dependency direction and data flow direction are distinct but interact strongly. Dependencies should point from volatile toward stable, from peripheral toward core. Data often flows the opposite direction -- from the core domain outward to caches, indexes, and external consumers. This is normal and healthy: the core writes, the periphery derives.

The problem arises when data flow creates accidental dependencies. A module that needs data from a volatile external system becomes dependent on that system's availability, schema, and performance characteristics. If the external system's data format changes, the consuming module must change -- this is a dependency introduced through data flow, invisible in the code's import graph.

Anti-corruption layers at data boundaries address this intersection. When data enters from an external or volatile source, it should be translated into the system's internal representation at the boundary. The internal data model should reflect the domain, not the external system's idiosyncrasies. Kleppmann's concept of "data on the outside" vs "data on the inside" applies: external data is immutable once received, self-describing, and versioned; internal data is under your control.

Circular data dependencies are the data flow equivalent of circular code dependencies. If service A derives from B and B derives from A, you have a feedback loop that makes both services' state indeterminate. Finding and breaking these loops is essential.

### Data Flow and Domain Alignment (`domain-alignment.md`)

The natural data flow of a system should mirror the domain's natural information flow. When a customer places an order, information flows from the customer to the order system to the inventory system to the shipping system. If the technical data flow reverses this -- if the shipping system must call back to the order system to get information that should have been passed along -- the data flow is fighting the domain.

Event-driven architectures naturally align data flow with domain processes when events are named after domain occurrences (OrderPlaced, PaymentReceived, ItemShipped). When events are named after technical operations (RowUpdated, CacheInvalidated), the domain is invisible in the data flow, and every new business requirement requires tracing through technical plumbing to understand where the relevant data lives.

The data mesh principle addresses this directly: domain-oriented data ownership. Each domain team publishes its data as a product with SLAs, schemas, and discoverability metadata. This aligns data ownership with domain expertise, ensuring that the people who understand the data control how it flows.

### Data Flow and Change/Evolution (`change-evolution.md`)

Data flow architecture has an outsized impact on evolvability because data is the hardest thing to change. Splitting code is a refactoring sprint; splitting data is a migration project that touches storage, pipelines, consistency guarantees, and potentially every consumer.

Kleppmann's argument for derived data as the key to evolution: because derived stores can be rebuilt, you can change the derivation logic, build a new view alongside the old one, verify correctness, and switch over -- enabling zero-downtime schema migrations of read paths. This is only possible when the source of truth is intact and the derivation pipeline is well-defined. Systems that lack this property -- where every store is independently authoritative -- are stuck: schema evolution requires coordinating changes across every store simultaneously.

Event schema evolution is the specific hard problem at this intersection. Events, once published, are immutable. But the domain's understanding evolves. If you publish events, you need a schema evolution strategy: upcasting old events through successive schema versions, forward and backward compatibility in event formats, or versioned event streams. Greg Young and Fowler both warn that failing to plan for event schema evolution is the leading cause of event sourcing adoption failure.

Progressive boundary hardening -- Shopify's modular monolith approach -- applies to data flow as well. Start with soft data boundaries (in-process modules accessing each other's data through explicit interfaces) and harden them (separate databases, event streams, CDC pipelines) only when you are confident the boundaries are right. The cost of a wrong data boundary is much higher than a wrong code boundary because data migrations are expensive and risky.

---

## 7. Sources and Further Reading

**Rich Hickey, "Are We There Yet?" (2009) and "The Value of Values" (2012).** Two talks that together form the most rigorous philosophical framework for reasoning about state in software. "Are We There Yet?" introduces the epochal time model -- identity as a series of immutable values over time, with state transitions as pure functions from old value to new. "The Value of Values" extends this to data exchange between systems. The most valuable specific insight: "Place-Oriented Programming" (PLOP) -- the practice of overwriting old information with new -- is the default failure mode, inherited from an era of computational scarcity and never revisited. His diagnostic "where in the system does new information replace old information?" is the single most productive question for data flow analysis. His related talk "Deconstructing the Database" (2012) applies the same reasoning to persistent storage and directly influenced Datomic's design. Full transcripts available in the matthiasn/talk-transcripts repository on GitHub.

**Martin Kleppmann, "Designing Data-Intensive Applications" (2017).** Read Chapter 3 (storage engines and the log-structured approach), Chapter 11 (stream processing), and Chapter 12 (the future of data systems) most carefully. Kleppmann provides the most complete framework for reasoning about system-of-record vs derived data, the problems with dual writes, and the stream-table duality. Chapter 12's argument that the entire organization's data infrastructure is "one big distributed database" with the event log as its shared substrate is the operational realization of Hickey's philosophical framework. His blog post "Using logs to build a solid data infrastructure" (2015) is a more concise statement of the core argument. His 2014 Strange Loop talk "Turning the Database Inside Out" is the best single-session introduction to these ideas.

**Jay Kreps, "The Log: What every software engineer should know about real-time data's unifying abstraction" (2013).** The definitive practitioner's argument for log-centric data architecture, grounded in LinkedIn's experience building Kafka and the data infrastructure around it. The key insight that other sources lack: the log is not a special infrastructure component but the **fundamental abstraction** underlying all data systems -- databases, caches, indexes, replication, and event processing are all derived from logs. His explanation of table-log duality is the most practical treatment of this concept. More concise and operationally grounded than Kleppmann, though less academically rigorous. The expanded version is the short book "I Heart Logs" (2014, O'Reilly).

**Pat Helland, "Immutability Changes Everything" (2015) and "Life Beyond Distributed Transactions" (2007).** Helland's two most important papers for data flow reasoning. "Immutability Changes Everything" provides the storage-economics argument for append-only architectures: when storage is cheap, you can afford to keep everything, and keeping everything changes the architectural calculus. His distinction between facts (immutable, timestamped) and opinions (derived, mutable) is the most practical litmus test for classifying state. "Life Beyond Distributed Transactions" is essential for reasoning about state in distributed systems: entities, activities, uncertainty windows, and the necessity of idempotency when coordination is impossible. His concept of "data on the outside vs data on the inside" (from a 2005 paper of the same name) provides the framework for reasoning about data at service boundaries.

**Ben Moseley & Peter Marks, "Out of the Tar Pit" (2006).** The most rigorous argument that mutable state is the primary source of accidental complexity. Their strict test -- "Would this exist in the ideal world where we only had to specify what the user needs?" -- is the most useful filter for distinguishing essential from accidental state. Their proposed architecture (essential state, essential logic, accidental state and control) provides a concrete structural target. Read alongside Hickey for the strongest combined argument against state-heavy designs. Freely available as a 66-page paper.

**Greg Young, "CQRS Documents" (2010) and associated conference talks.** The foundational material on event sourcing and CQRS as architectural patterns. Young's key insight -- that current state is a left fold over event history, making state a derived value and events the primary truth -- is the architectural implication of Hickey's philosophical framework. Most valuable: his diagnostic for when event sourcing is appropriate ("is the history of how you arrived at the current state valuable to your business?") and his explicit warnings about when it is not. His concept of projections as disposable, multipliable derived views is the event-sourcing-specific application of Kleppmann's general derived-data principle. Use Young for the bounded-context-level decision of whether to use event sourcing; use Kleppmann for the system-level data flow architecture.

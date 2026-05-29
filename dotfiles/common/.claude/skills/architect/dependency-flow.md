# Dependency Flow: Reasoning Framework

**Source canon:** Martin, "Clean Architecture" (2017) and "Agile Software Development" (2003) — ADP, SDP, SAP, the dependency rule; Lakos, "Large-Scale C++ Software Design" (1996, 2019) — levelization, CCD, physical vs logical dependency; Parnas, "Designing Software for Ease of Extension and Contraction" (1979) — uses hierarchy; Russ Cox, "Our Software Dependency Problem" (2019)
**Applies when:** you need to evaluate whether the dependency graph flows in the right direction — whether stable things depend on volatile things, whether cycles prevent independent work, whether the graph's topology creates hidden deployment coupling, build-time problems, or cascading failures

---

## 1. What This Framework Addresses

This framework addresses the **topology and direction of the dependency graph** — the shape of the "depends on" relationships between modules in a system. A "module" here means any unit with dependencies: a package, a crate, a service, a library, a build target. The scale varies; the graph theory does not.

The dependency graph is the architecture. Not the diagram on the whiteboard — the actual import graph, the build target graph, the service call graph. When the graph has cycles, the cyclically-connected modules cannot be built, tested, deployed, or understood independently — they are one unit wearing multiple names. When the graph points the wrong way — stable core modules depending on volatile peripheral modules — every change to the periphery destabilizes the core, and the system becomes progressively harder to change.

This framework is **independent from boundary and coupling analysis** (see `boundaries-encapsulation.md`). "Are your boundaries in the right place?" is a different question from "does the dependency graph flow in the right direction?" You can have perfectly cohesive modules with well-hidden internals, but if the dependency arrows point the wrong way, the architecture is broken. Conversely, correct dependency flow with shallow boundaries produces a well-ordered but ultimately hollow module hierarchy. Both lenses are needed; neither subsumes the other.

This framework does not address what belongs inside each module (see `boundaries-encapsulation.md`), how data moves through the system (see `data-flow-state.md`), or whether the system's complexity is justified (see `simplicity-complexity.md`). It focuses on the graph itself — its direction, its shape, and what that shape implies for the system's ability to evolve.

---

## 2. Core Reasoning Procedure

### Step 1: Draw the actual dependency graph

Map every module and its dependencies. Not the intended architecture — the real one. In a compiled language, the dependency graph is the import/include graph. In a service architecture, it is the call graph plus the shared-data graph. In a monorepo, it is the build target graph.

For each edge, note: is this dependency enforced by tooling (compiler, build system, linter) or only by convention? Convention-only dependency rules erode. Google enforces dependency direction through Bazel visibility rules. Shopify enforces it through Packwerk. Go and Rust enforce acyclicity through the compiler. If a dependency rule matters, something other than developer discipline must maintain it.

Include data-level dependencies that are invisible in the code. If service A and service B share a database, they are coupled through schema — a dependency that no import statement reveals. If two modules both know a wire format, they share a dependency on that format even if neither imports the other. These hidden edges are often the most dangerous because they are invisible to static analysis.

### Step 2: Detect cycles

Any cycle in the dependency graph — A depends on B depends on A, possibly through intermediaries — is an immediate finding. Lakos' rule is absolute: cyclic dependencies between components are a design defect. Martin's Acyclic Dependencies Principle (ADP) states the same: the component dependency graph must be a directed acyclic graph.

Why cycles are destructive: components in a cycle cannot be levelized — they have no valid level assignment. They cannot be tested independently, because building any one requires building all of them. They cannot be deployed independently. They cannot be understood independently. And cycles absorb their neighbors: once A and B are in a cycle, any new module that depends on either one is effectively part of the cycle too. The cycle grows "gradually then suddenly" — each new edge seems harmless; collectively the cycle consumes the system.

To detect cycles, perform a topological sort of the dependency graph. If the sort fails (some modules remain with no valid position), those modules form one or more cycles. In practice, use build system tooling or static analysis to find cycles automatically.

For each cycle found, classify it: is it a direct cycle (A imports B and B imports A) or a transitive cycle (A → B → C → A)? Transitive cycles are harder to see and more common in large systems. Record every cycle for Step 6.

### Step 3: Levelized the graph

Assign a level number to every module following Lakos' procedure:

- **Level 0**: Modules with no internal dependencies (they may depend on the standard library or OS, but nothing in the project).
- **Level 1**: Modules depending only on Level 0 modules.
- **Level N**: Modules depending on at least one Level (N-1) module and nothing higher.

The **system levelization number** is the highest level assigned. It represents the minimum number of sequential build rounds needed (each round compiles one level in parallel), the maximum depth of understanding needed to comprehend any single module, and the longest chain through which a change can cascade.

If cycles were found in Step 2, the modules in each cycle cannot be individually leveled. Group them as a single unit and assign the group a level based on the group's external dependencies. Note this — a cycle that forces grouping of modules at different conceptual levels is a particularly severe finding.

### Step 4: Assess stability and dependency direction

For each dependency edge, assess whether the dependency points from volatile toward stable. Martin defines **stability** as the difficulty of changing a module — not how often it changes, but how much would have to change if it did. A module with high fan-in (many dependents) is stable because changing it forces changes in all its dependents. A module with high fan-out (many dependencies) is unstable because any of its dependencies changing may force it to change.

Martin's instability metric: **I = Fan-out / (Fan-in + Fan-out)**. I = 0 means maximally stable (many dependents, no dependencies — hard to change). I = 1 means maximally unstable (no dependents, many dependencies — easy to change, nobody cares if it does).

The **Stable Dependencies Principle (SDP)** states: depend in the direction of stability. Every dependency edge should point from a module with higher I (more unstable) toward a module with lower I (more stable). An edge pointing the other way — a stable module depending on a volatile module — is an inverted dependency. The stable module has "inherited" the volatility of the module it depends on.

Check for these specific inversions:
- Core domain modules depending on peripheral integrations, UI code, or configuration layers
- Platform/infrastructure modules depending on product-specific modules
- Low-level libraries depending on high-level application code
- A widely-depended-upon "utility" module that itself depends on volatile dependencies, propagating that volatility to all its consumers

### Step 5: Assess abstractness

Martin's **Stable Abstractions Principle (SAP)** adds a second dimension: a module should be as abstract as it is stable. Stable modules (hard to change because many things depend on them) should consist primarily of interfaces and abstract types — they define contracts but not implementations. Unstable modules (easy to change) should be concrete — they provide implementations that can be swapped.

This is because stable concrete modules are in Martin's **zone of pain** — they are hard to change (high fan-in) and every change is risky (concrete code has more reasons to change than abstract contracts). Unstable abstract modules are in the **zone of uselessness** — they define contracts that nobody depends on.

The ideal sits on Martin's **main sequence**: a line from (maximally stable, maximally abstract) to (maximally unstable, maximally concrete). A module's distance from this line is a measure of how well its abstractness matches its stability obligations.

In practice, check: do widely-depended-upon modules define interfaces that their dependents program against? Or do dependents reach into concrete implementations? When a foundation module must change, does the change affect its contract (breaking all dependents) or only its implementation (invisible to dependents)?

### Step 6: Determine how to fix problems

For each cycle found in Step 2, apply one of these resolution techniques:

- **Dependency inversion**: Introduce an interface in the depended-upon module. The depending module codes against the interface. The concrete implementation lives in a third module or is injected at a higher level. The dependency arrow reverses without changing runtime behavior. This is the primary tool.
- **Escalation** (Lakos): Move the functionality that creates the cycle upward to a new, higher-level module that depends on both participants. The participants no longer depend on each other.
- **Demotion** (Lakos): Extract the shared functionality downward into a new, lower-level module that both participants depend on.
- **Event-based decoupling**: Replace a direct call with a published event. The publisher does not depend on the subscriber. The dependency becomes a runtime subscription rather than a compile-time import.

For each inverted dependency (stable depending on volatile), the fix is typically dependency inversion — interpose an abstraction (owned by the stable module) between the stable module and its volatile dependency. The stable module depends on its own abstraction; the volatile module implements it. The dependency arrow reverses.

### Step 7: Measure and track

Lakos' **Cumulative Component Dependency (CCD)** provides an objective measure of the dependency graph's health. CCD is the sum, over all modules, of the number of modules each transitively depends on (including itself). For a balanced binary tree of N modules, CCD ≈ N × (log₂N + 1). For a fully connected graph (everything depends on everything), CCD = N².

The **Normalized CCD (NCCD)** — CCD divided by the balanced-binary-tree CCD for the same N — gives a single number to track over time. NCCD < 1.0 is excellent. NCCD ≈ 1.0 is healthy. NCCD >> 1.0 indicates the graph is becoming pathologically coupled.

After completing these steps, you should be able to articulate: where cycles exist and how to break them, where dependency direction is inverted and how to correct it, what the levelization structure looks like and whether it is getting better or worse, and which modules are topological bottlenecks (high fan-in nodes where a failure or change cascades widely).

---

## 3. Diagnostic Questions

**Q: Can you topologically sort the dependency graph?**
Healthy: Yes. Every module has a valid level number. The graph is a clean DAG.
Unhealthy: No. Some modules are in cycles and cannot be ordered. This means they cannot be built, tested, or deployed independently — they are a single unit split across multiple names.

**Q: What is the system's levelization number?**
Healthy: Proportional to the logarithm of the module count. A 100-module system with levelization number 6-8 has a tree-like structure.
Unhealthy: Proportional to the module count itself. A 100-module system with levelization number 40+ has a long chain structure where most modules are on the critical path.

**Q: For each dependency edge, does it point from volatile toward stable?**
Healthy: Peripheral, frequently-changing modules depend on core, rarely-changing modules. The arrows point inward and downward.
Unhealthy: Core modules import peripheral ones. The platform layer calls product-specific code. A change to a UI component forces a change in the domain model. The arrows point outward and upward.

**Q: Are there modules that everything depends on? How stable and abstract are they?**
Healthy: High-fan-in modules consist primarily of interfaces, abstract types, and stable contracts. They change rarely. When they do change, the change is additive (new interface methods) not breaking (modified signatures).
Unhealthy: High-fan-in modules contain concrete implementations that change frequently. Every change ripples to all dependents. These modules are in Martin's zone of pain — simultaneously hard to change and needing to change.

**Q: Can you build and test any module by building only the modules below it in the level hierarchy?**
Healthy: Yes. Level 0 modules build with no internal dependencies. Level 1 modules build with only Level 0. Testing follows the same order — each level's tests depend only on already-tested lower levels.
Unhealthy: No. Testing a module requires setting up modules above it in the intended hierarchy, or modules at the same level, revealing hidden dependencies that the intended layering does not capture.

**Q: If module A's implementation changes (but not its interface), which other modules must be recompiled, retested, or redeployed?**
Healthy: Only modules that directly depend on A, and only if the change affected something they observe (interface, behavior, or performance contract). In a well-insulated system, an implementation change triggers zero downstream recompilation.
Unhealthy: Modules several levels away must be rebuilt because physical dependencies (transitive includes, shared compilation units, shared database schemas) propagate the change through modules that have no logical interest in it.

**Q: Is the dependency direction enforced by tooling or only by convention?**
Healthy: The build system, the compiler, or a static analysis tool rejects dependency violations. Bazel visibility rules, Packwerk enforcement, Go's cycle prohibition, Rust's crate DAG — the constraint is automated.
Unhealthy: The dependency direction exists in documentation or architecture diagrams but nothing prevents violations. Each "just this once" violation weakens the structure until the intended layering is fiction.

**Q: Do deployment units match the dependency structure?**
Healthy: Modules that can be deployed independently are at different branches of the DAG. Deploying module A does not require simultaneously deploying module B.
Unhealthy: Modules that are nominally separate services require coordinated deployments because of shared schemas, lockstep version requirements, or synchronous call chains that break if either side changes. This is the distributed monolith — service boundaries without dependency independence.

**Q: Are there "utility" or "common" modules with both high fan-in and high fan-out?**
Healthy: Foundation modules have high fan-in but minimal fan-out (they depend on almost nothing). Application modules have high fan-out but minimal fan-in (nothing depends on them).
Unhealthy: A "utils" module is depended upon by everything and itself depends on many things. It propagates the volatility of its many dependencies to all of its many dependents. It is simultaneously a stability bottleneck and a volatility amplifier.

**Q: When a leaf-level dependency changes its interface, how far does the cascade reach?**
Healthy: The cascade is contained. Modules at the next level absorb the change behind their own interfaces. The ripple dies within one or two levels.
Unhealthy: The cascade propagates to the top of the graph. A change to a serialization library forces changes in the domain model, the API layer, and the client SDK. No module absorbs the change — each one exposes it to the next.

**Q: Are there dependency edges that exist only because of physical coupling rather than logical need?**
Healthy: Every dependency edge represents a genuine logical relationship — module A uses functionality from module B.
Unhealthy: Module A depends on module B only because A transitively includes B's headers, or because they share a build target, or because a configuration system links them at deploy time. The dependency is an artifact of the build/deployment structure, not of the domain. These accidental dependencies inflate the graph and create false coupling.

**Q: If you drew the dependency graph of data flow alongside the code dependency graph, do they tell a consistent story?**
Healthy: Data flows from core outward to periphery (the domain produces data; caches, indexes, and UIs derive from it). Code dependencies point from periphery inward to core (the UI depends on the domain; the domain depends on nothing above it). The two graphs are roughly mirror images — data out, dependencies in.
Unhealthy: Both graphs point in the same direction, or they contradict each other without explanation. A module that should be a data consumer is instead a data authority, pulling its dependents into an unexpected direction.

**Q: How many modules would break if you removed or replaced a single foundation module?**
Healthy: The fan-in is known, bounded, and proportional to the module's importance. The module's interface is stable and versioned. Replacement is possible through the interface.
Unhealthy: Nobody knows the full fan-in. The module is depended on through undeclared channels (runtime reflection, string-based service lookup, shared database). Replacing it would be an archaeological expedition.

**Q: Are there services or modules that are topologically critical but operationally fragile?**
Healthy: Modules with the highest topological importance (hub nodes, high fan-in) receive proportionally more reliability investment — redundancy, monitoring, careful change management.
Unhealthy: The most depended-upon module is also the least reliable, least tested, or least staffed. Netflix learned this the hard way: their API gateway (a universal hub) needed Hystrix-level resilience investment precisely because its topological position made it a single point of failure.

**Q: Can a new team start working on a module without understanding the full system?**
Healthy: A module at Level 3 can be understood by understanding only its direct dependencies and their contracts. The team reads downward through the level hierarchy and stops when they hit stable interfaces.
Unhealthy: Understanding any module requires understanding everything because cycles and hidden dependencies mean every module is implicitly connected to every other. "You have to understand the whole system to change anything."

---

## 4. What Good Looks Like vs What Bad Looks Like

**Bad:** The authentication module (a core platform service depended on by every product team) imports from the billing module to check subscription tiers during token generation. Now any change to billing's data model can break authentication for the entire platform.
**Good:** Authentication depends on an interface it owns — `EntitlementProvider` — that billing implements. Authentication knows nothing about billing's internals. Billing can restructure freely as long as it satisfies the interface.
**Gravity:** The billing check started as a three-line if-statement. "Just import the billing module and check the tier." Each such shortcut is individually small; collectively they invert the dependency structure of the entire platform.

**Bad:** Two modules at the same level depend on each other — the order module calls the inventory module to check stock, and the inventory module calls the order module to get reservation data. Neither can be compiled, tested, or deployed without the other.
**Good:** A shared interface or event mechanism breaks the cycle. Orders publish an `OrderPlaced` event; inventory subscribes to it. Inventory exposes a `StockChecker` interface; orders call it. The dependency flows one way in each relationship.
**Gravity:** Cycles form when two teams build features that cross boundaries. Each team adds an import to the other's module because it is the quickest path to the data they need. The cycle starts with one edge and grows as both teams add more cross-references.

**Bad:** A "common" utility module contains logging, string formatting, date handling, HTTP client configuration, database connection pooling, and feature flag evaluation. It is depended upon by every module in the system. When the HTTP client library has a breaking change, every module in the system must be recompiled and retested.
**Good:** Utility concerns are separated into small, focused, low-level modules with minimal dependencies of their own. The string utilities module has zero external dependencies. The HTTP client wrapper depends only on the HTTP library. Each module's volatility is isolated from the others.
**Gravity:** "Common" modules start as a convenient place to put shared code. Each addition is small. But the module accumulates dependencies from each piece of functionality, and its fan-in grows with each consumer. It becomes simultaneously the most depended-upon and the most volatile module — the worst possible combination.

**Bad:** The system has a levelization number of 25 for 30 modules. Almost every module is on the critical path. Compiling the system requires 25 sequential rounds. A change at the bottom cascades through 25 levels.
**Good:** The system has a levelization number of 5 for 30 modules. The graph is wide and shallow. Most modules are at Levels 1-3. Compilation parallelizes well. Changes rarely cascade past two levels.
**Gravity:** Long chains form when each module is built on exactly one predecessor, creating a linear rather than tree-like graph. This happens naturally when modules are designed as pipeline stages rather than layered services.

**Bad:** The microservices call each other synchronously in long chains: the API gateway calls the order service, which calls the payment service, which calls the fraud service, which calls the customer service. The end-to-end latency is the sum of all hops. A failure in any one service fails the entire chain. The services cannot be deployed independently because they are version-coupled through their synchronous APIs.
**Good:** Services are organized in shallow layers. The API gateway calls two or three backend services directly. Each backend service handles its concerns autonomously, calling only low-level foundation services (auth, rate limiting). Asynchronous events handle cross-service coordination where possible.
**Gravity:** Synchronous call chains are the easiest way to compose services. Each hop is a function call over the network. The chain grows one hop at a time. By the time the latency and reliability problems become visible, the chain is deeply entrenched.

**Bad:** A stable, well-tested core module depends on an external integration library that releases breaking changes monthly. Every month, the core team must update, retest, and redeploy the core — not because the core's logic changed, but because its dependency did.
**Good:** An anti-corruption layer (owned by the core module's team) wraps the volatile external dependency. The core depends on its own stable interface. The anti-corruption layer translates between the external library and the internal interface. When the external library changes, only the thin translation layer changes.
**Gravity:** Depending directly on an external library is simpler than building a wrapper. The external library "works fine" and the wrapper feels like unnecessary indirection — until the external library's release cycle starts driving the core module's release cycle.

**Bad:** A shared database is the de facto dependency between five services. No service imports another's code, so the architecture diagram shows five independent services. But any schema migration requires coordinating all five, any query change can break another service's performance, and the database connection pool is a shared resource bottleneck.
**Good:** Each service owns its data behind a service interface. Other services consume through explicit APIs or event streams. Schema changes are internal to the owning service and invisible to consumers.
**Gravity:** Shared databases are the path of least resistance. They eliminate API design, serialization, and network latency. They are also the tightest form of coupling — invisible in the code, enforced by the schema, and excruciating to untangle.

**Bad:** The build system has no explicit dependency declarations. Modules implicitly depend on whatever happens to be available at build time. A change to the build environment (new library version, removed system package) breaks modules that nobody knew depended on it.
**Good:** Every dependency is declared explicitly in build metadata (BUILD files, Cargo.toml, package.json with pinned versions). The build system validates the dependency graph and rejects undeclared dependencies. The graph is machine-readable and auditable.
**Gravity:** Implicit dependencies are convenient — you just use what's available. Explicit declarations feel like bureaucracy. But implicit dependencies are undiscoverable, untrackable, and unmanageable at scale.

**Bad:** The system's dependency graph contains a "hub" module that every service depends on for configuration, logging, metrics, and service discovery. The hub is a single point of failure. Its deployment window is everyone's deployment window. Its on-call team is perpetually overwhelmed.
**Good:** Cross-cutting concerns are provided through narrow, independent interfaces — a logging interface (Level 0), a metrics interface (Level 0), a config interface (Level 0). Each is small, stable, and independently deployable. No single module is the hub of everything.
**Gravity:** Centralizing cross-cutting concerns in one place feels clean and DRY. A single "platform SDK" that handles everything is easy to onboard to. But it creates a topological bottleneck that dominates the system's reliability and change velocity.

**Bad:** Two services are nominally independent, but they communicate through events — and their event schemas create a hidden dependency cycle. Service A publishes events that Service B consumes, and Service B publishes events that Service A consumes. Neither can evolve its event schema without coordinating with the other.
**Good:** Event flow is acyclic. If bidirectional communication is needed, it flows through distinct, well-owned contracts. Service A publishes `OrderPlaced`; Service B subscribes. Service B publishes `InventoryReserved`; a higher-level orchestrator subscribes. The event graph is a DAG, just like the code graph.
**Gravity:** Event-driven architectures trade visible compile-time dependencies for invisible runtime dependencies. The dependency still exists — it is just harder to see. Teams add event subscriptions without realizing they are creating graph edges, and cycles form in the event topology just as they form in the import graph.

**Bad:** After identifying dependency problems, the team introduces abstraction layers between every pair of modules. Each layer consists of an interface with a single implementation. The total number of modules doubles. Navigation becomes tortuous. The dependency graph is technically clean but the system is harder to understand than before.
**Good:** Abstractions are introduced only where the dependency direction needs to be inverted or where genuine implementation variation exists. Most dependencies are direct. The few abstraction boundaries that exist correspond to real architectural seams — places where substitution is plausible or where stability obligations demand insulation.
**Gravity:** Once a team learns about dependency inversion, the temptation is to apply it everywhere. But each abstraction has an interface cost. Dependency inversion is a tool for fixing specific directional problems, not a universal connector between all modules.

---

## 5. Common Failure Modes

**The Dependency Cycle**
Pattern: Two or more modules depend on each other, directly or transitively. They form a strongly connected component in the dependency graph.
Symptom: The "morning after syndrome" (Martin): a developer integrates and discovers that their code is broken by changes in a module they thought was independent. Build times spike because the modules in the cycle must be compiled as a unit. Test isolation is impossible — testing any module in the cycle requires instantiating all of them. The cycle grows over time as neighboring modules get absorbed.
Root cause: Cycles form one edge at a time. Each individual shortcut (one module importing another for a single function call) seems harmless. The structural constraint that prevented cycles was either never established or eroded through accumulated exceptions. Once a cycle exists, it lowers the barrier to adding more edges — "they're already coupled, one more import won't matter."
Direction: Break cycles using dependency inversion (introduce an interface in the depended-upon module), escalation (move shared functionality up to a new higher-level module), demotion (extract shared functionality down to a new lower-level module), or event decoupling (replace a direct call with a published event). After breaking, enforce acyclicity with tooling.
Over-correction risk: Breaking cycles by introducing so many interfaces and intermediary modules that the system becomes a maze of indirection. The cycle is gone, but the cure is worse than the disease. Break cycles at the one or two edges that are directionally wrong, not by abstracting every edge in the graph.

**The Inverted Foundation**
Pattern: A stable, widely-depended-upon module depends on a volatile, peripheral module. The foundation has inherited the periphery's instability.
Symptom: The foundation module changes frequently — not because its own logic is evolving, but because its dependency is. Every change to the peripheral module cascades through the foundation to all its consumers. The blast radius of a peripheral change is system-wide. Amazon discovered this early in their SOA transition: their identity service (maximal fan-in) had taken a dependency on the retail catalog (high volatility), meaning catalog changes could break authentication for the entire company.
Root cause: The dependency was added when the system was small and the peripheral module was stable. Or the dependency seemed essential ("authentication needs to check subscription tiers"). Nobody evaluated whether the dependency direction was sustainable at scale.
Direction: Dependency inversion. The stable module defines an interface for what it needs. The volatile module implements it. The arrow reverses: the volatile module now depends on the stable module's abstraction rather than the other way around.
Over-correction risk: Making the foundation so abstract that it cannot do anything useful. A foundation module that consists entirely of interfaces and delegates all behavior to injected implementations is in Martin's zone of uselessness — maximally abstract and maximally unstable. The foundation should be abstract where it faces outward (stable interfaces for dependents) and concrete where it faces inward (real implementation of its core responsibility).

**The Distributed Monolith**
Pattern: Separately deployed services that cannot actually be deployed, tested, or evolved independently because their dependency structure is that of a monolith. Synchronous call chains, shared databases, lockstep version requirements, and shared data format assumptions bind the services into a single release unit.
Symptom: Deploying one service requires deploying others simultaneously. A failure in one service cascades through synchronous calls to bring down others. Development velocity is slower than it was with the monolith because every change requires cross-service coordination plus the overhead of distributed systems. Segment documented this pattern extensively before consolidating back to a monolith: "We had the complexity of microservices and the coupling of a monolith."
Root cause: Service boundaries were drawn along the wrong axis — by entity, by technical layer, or by team member rather than by domain capability with genuinely independent lifecycles. Or boundaries were drawn before the dependency structure was understood, locking in wrong decisions. Synchronous communication made service boundaries into function call boundaries with added latency.
Direction: Identify which services are truly independent (can be deployed, fail, and evolve independently) and which are actually one module split across a network boundary. Merge the tightly coupled ones. Introduce asynchronous communication where coordination is needed but independence is desired. Use Shopify's approach: soft module boundaries within a monolith until you are confident they are right, then harden selectively.
Over-correction risk: Merging everything back into a monolith and losing the genuine benefits of services that were correctly separated. The problem is wrong boundaries plus wrong coupling patterns, not services per se.

**The Hub Module**
Pattern: One module sits at the center of the dependency graph with extremely high fan-in. Every other module depends on it. It is the universal bottleneck — for builds, for deployments, for change management, and for reliability.
Symptom: The module's on-call team is perpetually overwhelmed because any system-wide incident likely involves their module. Its build target is the longest pole in every build. Its API cannot change without coordinating with every team. Netflix's Zuul API gateway and Facebook's TAO data store both exhibited this pattern — universal hubs that required extraordinary engineering investment precisely because their topological position made them single points of failure.
Root cause: The hub started as a genuinely shared concern (configuration, logging, data access) and grew as teams added more functionality to it rather than creating new modules. Hub formation is also driven by organizational structure: if one team owns the "platform," every shared need is routed to them, and their module absorbs everything.
Direction: Decompose the hub into smaller, independent modules organized by concern. Configuration, logging, metrics, service discovery, and data access should be separate Level 0 modules with minimal dependencies of their own, not a single "platform" module. Each piece can then evolve independently.
Over-correction risk: Splitting the hub into too many tiny modules that individually add more interface cost than they save. Not every function in a shared module needs its own package. Split along genuine concern boundaries, not along function boundaries.

**The Volatility Amplifier**
Pattern: A module has both high fan-in (many dependents) and high fan-out (many dependencies). It amplifies the volatility of its many dependencies to all of its many dependents. When any of its dependencies changes, the change propagates through it to every module in the system.
Symptom: Seemingly unrelated modules are affected by changes they have no logical connection to. A serialization library upgrade forces rebuilding the entire system because the "common" module that imports the serialization library is imported by everything. The system's effective change rate is the union of all the amplifier's dependencies' change rates.
Root cause: "Common" or "shared" utility modules naturally accumulate both fan-in and fan-out. Each new utility function added to the module may bring a new dependency. Each new consumer of any utility function adds to the fan-in. The module grows in both directions simultaneously. The Apache Commons libraries in Java and the "utils" package in many projects exhibit this pattern.
Direction: Factor the amplifier into smaller modules by concern, each with minimal dependencies. The string utilities module depends on nothing. The HTTP utilities module depends only on the HTTP library. No single module carries both high fan-in and high fan-out.
Over-correction risk: Creating a flat set of dozens of micro-utility modules that are hard to discover and navigate. Group utilities by their dependency profile (what they depend on), not by how often they are used.

**The Phantom Dependency**
Pattern: Two modules are coupled through a channel invisible to static analysis — a shared database schema, a shared message format, a shared filesystem path, a configuration convention, or a runtime service discovery mechanism. The dependency exists but no import statement, build file, or type system captures it.
Symptom: Changes to one module break the other, and nobody understands why until they trace the hidden channel. Meta's 2021 global outage was exacerbated by phantom dependencies — their recovery tools depended on the very infrastructure (internal DNS, authentication) that was down. The tools needed to fix the problem could not function because of undeclared dependencies on the broken system.
Root cause: Phantom dependencies form through operational coupling (shared infrastructure), data coupling (shared databases), and convention coupling (agreed-upon formats without formal contracts). They are invisible because the dependency exists at runtime, not at build time.
Direction: Make every dependency explicit. If two modules share a database, make the schema dependency visible in the build system or at least in documentation. If they share a message format, define the format in a shared schema module that both depend on explicitly. If recovery tools depend on infrastructure, ensure they have independent fallback paths.
Over-correction risk: Attempting to capture every possible runtime interaction as a build-time dependency, producing a graph so dense with declared dependencies that it obscures rather than clarifies the actual architecture. Focus on dependencies that, if violated, would cause failures.

**The Dependency Cascade**
Pattern: A change to a leaf-level module cascades through many levels because no module in the chain absorbs the change behind a stable interface. Each module's interface exposes details of its dependencies, so a change at depth N forces changes at every level from N to 0.
Symptom: What should be a localized update (swapping a JSON library, changing a date format) requires touching modules across the entire dependency hierarchy. The OpenSSL Heartbleed vulnerability demonstrated this at ecosystem scale: a two-line fix in a leaf-level library required patching and redeploying virtually every TLS-using application in the world.
Root cause: Modules do not insulate their dependents from their dependencies. Lakos distinguishes encapsulation (hiding from the programmer) from insulation (hiding from the compiler): a module can have private members that the programmer cannot access but the compiler still sees, so changing them still forces recompilation of all dependents. Without insulation — through abstract interfaces, the pimpl idiom, or clear API boundaries — implementation changes propagate transitively.
Direction: Introduce insulation at key points in the dependency chain. Not every module needs to fully insulate its implementation, but modules that sit at stability boundaries (the transition from volatile to stable) should present stable interfaces that absorb implementation changes. Lakos' protocol classes and pimpl idiom are the C++ mechanisms; in other languages, interface types and clean API boundaries serve the same purpose.
Over-correction risk: Insulating every dependency edge produces a system where every interaction goes through an abstract interface, a factory, and a registration mechanism. The indirection cost exceeds the insulation benefit. Insulate at natural stability boundaries, not at every edge.

**The Version Lock**
Pattern: Multiple modules depend on different versions of a shared dependency, and the system can only load one version. The modules are locked in conflict — updating the shared dependency for one consumer breaks another.
Symptom: "Dependency hell." The build system cannot resolve a consistent set of versions. Upgrading one library forces downgrading another. Migration stalls because half the system needs version N and the other half needs version N+1. The Python 2 to Python 3 migration — a twelve-year effort — was this pattern at ecosystem scale: every package was locked until all its dependencies migrated, creating a dependency-ordered queue millions of packages long.
Root cause: Semantic versioning is a social contract, not a guarantee. Breaking changes happen in minor and patch releases (Hyrum's Law). Diamond dependency problems — A depends on B and C, both depending on D but needing different versions — are structurally unavoidable when the dependency graph is deep and wide.
Direction: Minimize the depth of the dependency graph. Prefer dependencies with strong stability commitments. Use Google's one-version rule (one version of everything at HEAD) when working in a monorepo. When multiple versions are unavoidable, use language-level mechanisms that allow coexistence (Rust's semver-incompatible multi-version linking, Go's module version paths).
Over-correction risk: Avoiding all external dependencies to prevent version conflicts. Dependencies provide genuine value. The solution is not zero dependencies but conscious dependency management — evaluating each dependency's stability, maintenance health, and transitive dependency cost before adopting it.

---

## 6. Interactions With Other Frameworks

### Dependency Flow and Boundaries/Encapsulation (`boundaries-encapsulation.md`)

Dependency direction and boundary quality are independent concerns that interact strongly. A boundary can be deep and well-encapsulated (Parnas's secret is hidden, Ousterhout's interface is simple) yet have its dependency arrow pointing the wrong way — a stable core module depending on a volatile peripheral module through a perfectly clean interface is still architecturally broken. Conversely, correct dependency direction with shallow boundaries produces a well-ordered graph of modules that each add more interface cost than they hide.

The most common intersection failure: extracting a module to improve encapsulation but creating a dependency cycle between the extracted module and its parent. When splitting a god module into two modules, the new modules frequently need to call each other, forming a cycle. This is where Lakos' escalation and demotion techniques apply — restructure the split to maintain acyclicity, or use dependency inversion to ensure the arrows point in the right direction.

When fixing a boundary problem, always check: does the fix preserve or improve the dependency direction? When fixing a dependency direction problem, always check: does the fix create shallow boundaries that cost more than they hide? The two analyses must be performed together, not sequentially.

### Dependency Flow and Simplicity/Complexity (`simplicity-complexity.md`)

Accidental complexity creates accidental dependencies. A module that braids business logic with persistence (complecting, in Hickey's terminology) depends on both the domain model and the database driver — a dependency that exists only because of the complecting. When analyzing the dependency graph, ask: which edges are essential (demanded by the problem) and which are accidental (introduced by implementation choices)? Removing the complecting removes the accidental dependency.

Dependency inversion, when applied judiciously, reduces complexity by removing coupling. When over-applied, it creates accidental complexity — layers of interfaces, factories, and registration mechanisms that make the system harder to understand without providing real decoupling. Every interface added for dependency inversion has an interface cost. If the cost exceeds the value (because the implementation will never actually vary, or because the stability differential is negligible), the abstraction is accidental complexity.

Circular dependencies are almost always a complecting signal. If A needs B and B needs A, there is likely a shared concern that has been braided across two modules rather than separated into its own module. Breaking the cycle by extracting the shared concern simultaneously fixes the dependency problem and reduces complecting.

### Dependency Flow and Data Flow/State (`data-flow-state.md`)

Dependency direction and data flow direction are distinct but interact strongly. Dependencies typically point from volatile toward stable, from periphery toward core. Data often flows the opposite direction — from the core domain outward to caches, indexes, and external consumers. This is normal and healthy: the domain model is the source of truth (stable, high fan-in), and peripheral systems derive from it (volatile, high fan-out). The code dependency points inward; the data flows outward.

The problem arises when data flow creates accidental code dependencies. A module that consumes data from a volatile external system becomes dependent on that system's availability, schema, and performance characteristics. If the external system's data format changes, the consuming module must change — this is a dependency introduced through data flow, invisible in the import graph. Anti-corruption layers at data boundaries address this intersection: translate external data into an internal representation at the boundary, so internal modules depend on the internal format (which they own) rather than the external one (which they do not).

Shared databases are the most dangerous intersection of data flow and dependency: they create phantom dependencies invisible in the code but enforced by the schema. Amazon's API mandate succeeded specifically because it addressed data dependencies, not just code dependencies.

### Dependency Flow and Domain Alignment (`domain-alignment.md`)

Domain-driven design's bounded contexts provide natural guidance for dependency direction. In most domains, some concepts are more fundamental than others: "Product" is more fundamental than "Cart," "Customer" is more fundamental than "Order." The dependency direction should mirror this conceptual hierarchy — higher-level domain concepts (Order, Cart, Checkout) depend on lower-level ones (Product, Customer, Inventory), not the reverse.

When the dependency graph contradicts the domain's natural hierarchy, it is a strong signal that either the dependency direction is wrong or the domain modeling is incomplete. A product catalog that depends on the checkout module suggests that checkout-specific concerns have leaked into the product model.

Conway's Law applies here: organizational boundaries tend to mirror dependency boundaries. If the team that owns module A reports to a different leadership chain than the team that owns module B, a dependency from A to B creates a cross-organizational coordination cost. Amazon weaponized this by structuring teams to own services with well-defined dependency directions, ensuring that organizational and technical dependency structures align.

### Dependency Flow and Change/Evolution (`change-evolution.md`)

Dependency direction determines how change propagates through a system. When dependencies flow from volatile to stable, changes at the periphery are absorbed — the stable core does not need to change. When dependencies are inverted (stable depends on volatile), every peripheral change cascades to the core and from there to everything that depends on the core. The dependency graph is, structurally, a change propagation network.

Progressive boundary hardening — Shopify's modular monolith approach — applies directly to dependency management. Start with soft dependency rules (static analysis warnings, architecture decision records) and harden them (build-time enforcement, separate compilation units, separate deployments) as you gain confidence that the dependency direction is correct. The cost of enforcing the wrong dependency direction is wasted effort and unnecessary workarounds; the cost of not enforcing the right direction is gradual erosion.

Lakos' CCD metric provides an objective way to track whether the architecture is evolving well: if CCD grows proportionally to N × log N as modules are added, the architecture is sustainable. If CCD grows faster (toward N²), each new module is adding disproportionate coupling, and the system will eventually reach a point where changes become prohibitively expensive.

---

## 7. Sources and Further Reading

**Robert C. Martin, "Agile Software Development: Principles, Patterns, and Practices" (2003), Chapters 28-30.** The definitive treatment of ADP (Acyclic Dependencies Principle), SDP (Stable Dependencies Principle), and SAP (Stable Abstractions Principle). Read these three chapters together — they form a single argument. Chapter 28 introduces the instability metric (I = Fan-out / (Fan-in + Fan-out)) and the dependency direction rule. Chapter 29 introduces the abstractness metric and the main sequence. Chapter 30 provides the case study. Martin's "Clean Architecture" (2017) restates the dependency rule (source code dependencies must point inward, toward higher-level policies) but the 2003 book has the richer treatment of the component principles including the metrics. The unique contribution: a quantifiable framework for evaluating dependency direction, not just a qualitative principle.

**John Lakos, "Large-Scale C++ Software Design" (1996) and "Large-Scale C++ Software Design, Volume I: Process and Architecture" (2019).** The 1996 book is the foundational text on physical dependency management. Read Chapters 4-6 on levelization, CCD, and insulation. Lakos provides what Martin does not: a precise measurement framework (CCD, NCCD) for tracking dependency graph health over time, and a clear distinction between physical and logical dependency that applies beyond C++ to any system with a build graph. The 2019 book extends the treatment to package-level and package-group-level architecture. His concept of "software capital" — finely granular, hierarchically reusable components that accrue value through proper physical design — provides the economic argument for investing in dependency management. The key insight other sources lack: physical dependencies are transitively imposed by the compiler and are often broader than logical dependencies, and this surplus is pure waste.

**Parnas, "Designing Software for Ease of Extension and Contraction" (1979).** Introduces the "uses" relation — a stricter version of "depends on" that distinguishes "A uses B" (A requires B to function correctly) from "A depends on B" (A mentions B in its source). The uses hierarchy must be acyclic. Parnas's reasoning about why circular uses relationships prevent independent development, testing, and deployment anticipates Lakos's levelization by 17 years. Read this alongside Parnas's 1972 decomposition paper for the full picture: the 1972 paper tells you where to draw boundaries; the 1979 paper tells you how the dependency arrows between those boundaries must be directed.

**Russ Cox, "Our Software Dependency Problem" (2019, research.swtch.com).** The most grounded modern treatment of dependency management at ecosystem scale, written by the designer of Go's module system. Cox distinguishes between code dependencies (what your build imports) and software dependencies (the broader set including build tools, runtime, deployment infrastructure). His analysis of the leftpad incident, the event-stream attack, and the general fragility of deep dependency graphs provides the practitioner's perspective that the academic sources lack. His design of Go's Minimal Version Selection algorithm — choosing the minimum version that satisfies all constraints — is a direct application of the principle that dependencies should be conservative and predictable. Read for the most practical treatment of how dependency graph topology affects security, reliability, and development velocity.

**"Software Engineering at Google" (Winters, Manshreck, Wright, 2020), Chapter 21: Dependency Management.** The industrial-scale perspective. Google's one-version rule (one version of every library at HEAD), their Large-Scale Changes tooling (Rosie, ClangMR) for propagating changes through the dependency graph, and the articulation of Hyrum's Law ("with a sufficient number of users, all observable behaviors of your system will be depended on by somebody") provide the operational reality that the theoretical sources do not address. The key unique insight: the diamond dependency problem is not solvable through versioning policies alone — it is a structural problem of the dependency graph, and Google's answer (one version, always at HEAD, with automated refactoring tools) is the most radical and most successful large-scale approach documented.

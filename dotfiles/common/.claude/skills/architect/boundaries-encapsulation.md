# Boundaries and Encapsulation: Reasoning Framework

**Source canon:** Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules" (1972) and "Designing Software for Ease of Extension and Contraction" (1979); Ousterhout, "A Philosophy of Software Design" (2018); Wirfs-Brock & McKean, "Object Design: Roles, Responsibilities, and Collaborations" (2003); Feathers, "Working Effectively with Legacy Code" (2004)
**Applies when:** you need to decide where module boundaries go, what belongs inside each module, whether an existing boundary is serving the system or harming it, or why changes keep propagating further than they should

---

## 1. What This Framework Addresses

This framework addresses the most fundamental question in software architecture: **where do you draw the lines between modules, and what goes inside each one?** A "module" here means any unit of encapsulation -- a class, package, service, library, subsystem, or bounded context. The scale varies; the reasoning does not.

Roughly 70% of architectural problems are boundary problems. A system where behavior has no clear home, where changes ripple across boundaries, where modules cannot be understood or replaced independently -- that system's boundaries are wrong. The symptoms show up as coupling problems, responsibility confusion, testing difficulty, and development paralysis, but the root cause is almost always that boundaries were drawn in the wrong places or that what's inside them wasn't chosen carefully.

This framework synthesizes four lenses on the same question. Parnas asks: *what design decisions does each module hide?* Ousterhout asks: *is the interface simple relative to the complexity it hides?* Wirfs-Brock asks: *what is each module responsible for, and does that responsibility form a coherent role?* Feathers asks: *can you actually substitute at this boundary, or is it cosmetic?* Used together, these lenses catch problems that any single one misses.

This framework does **not** address dependency direction (see `dependency-flow.md`), whether the boundaries align with the problem domain (see `domain-alignment.md`), or how the system should evolve over time (see `change-evolution.md`). It focuses on the boundaries themselves -- their placement, their quality, and what lives inside them.

---

## 2. Core Reasoning Procedure

### Step 1: Map the existing boundaries

Start by identifying every module boundary in the system. Not just the ones on the architecture diagram -- the real ones. A boundary is real if and only if you can change what's behind it without modifying what's in front of it. File boundaries, package boundaries, and service boundaries that lack this property are cosmetic.

For each boundary, note: What is on each side? What crosses the boundary (data, control, knowledge)? Is the boundary enforced by the language, the build system, the network, or only by convention?

Convention-only boundaries erode. Google enforces boundaries through BUILD visibility rules. Shopify enforces them through Packwerk. Rust enforces them through the type system. If a boundary matters, something other than developer discipline must maintain it.

### Step 2: Identify what each module hides

For every module, ask Parnas's question: **what is this module's secret?** The secret is a design decision that could have been made differently and might need to change. It is not merely private data -- it is a choice: a storage format, an algorithm, a protocol, a policy, a hardware dependency, an external system's API.

If you cannot articulate a module's secret in one sentence, the module does not have a clear reason to exist as a separate unit. If two modules share the same secret, they are coupled regardless of what the dependency graph says -- a change to that decision will force changes in both.

Enumerate the design decisions in the system that are likely to change: business rules, external integrations, data formats, algorithms with known alternatives, platform dependencies, areas where requirements are still being discovered. Each one should be hidden inside exactly one module. Decisions that appear in multiple modules are **information leakage** -- the single most reliable indicator of a boundary problem.

### Step 3: Evaluate boundary depth

Apply Ousterhout's depth test to each boundary. The **cost** of a boundary to the rest of the system is its interface -- everything callers must learn, depend on, and maintain compatibility with. The **benefit** is the complexity it hides. A good boundary has a simple interface hiding substantial complexity (deep). A bad boundary has an interface nearly as complex as its implementation (shallow).

Check for these specific signs of shallowness:
- **Pass-through modules**: the module's interface mirrors the interface of something behind it, adding no transformation, no aggregation, no hiding. It is indirection without abstraction.
- **Temporal decomposition**: modules organized by when things happen (read, then process, then write) rather than by what knowledge they hide. The reader and writer both know the data format -- the format decision leaked.
- **Thin wrappers**: modules created to satisfy an architectural mandate ("every database must be behind a service") rather than to solve a real encapsulation problem.

When a boundary is shallow, the correct response is usually to merge the module into an adjacent one, making the combined module deeper. Resist the instinct to "fix" a shallow module by adding more to its interface -- that makes it wider, not deeper.

### Step 4: Assess responsibility coherence

Apply Wirfs-Brock's responsibility test. For each module, ask: **what is this module responsible for?** State it as a short phrase. If you need "and," "or," or "but" to describe it, the module has multiple responsibilities and may need to be split -- or the responsibilities may need to be redistributed.

Characterize each module's role:
- **Information holder**: knows things and provides that knowledge to others
- **Service provider**: performs computation or work on demand
- **Coordinator**: routes requests to the right place without adding decision logic
- **Controller**: makes decisions and directs other modules' actions
- **Structurer**: maintains relationships between other modules or data
- **Interfacer**: translates between distinct parts of the system

These stereotypes are diagnostic, not prescriptive. A module that cleanly fits one stereotype is usually well-designed. A module that blurs two or three stereotypes may be fine (a domain entity that holds information and makes decisions about it is natural) or may signal a boundary problem (a coordinator that has accumulated decision logic is becoming a god module).

Check for responsibility misplacement: Is there a module that frequently reaches into another module's data to make decisions? (Feature envy -- the decision belongs with the data.) Is there behavior that nobody clearly owns? (Orphaned responsibility -- it will be implemented inconsistently.) Is there a module that everything depends on? (Responsibility magnet -- it probably needs to be decomposed.)

### Step 5: Test substitutability

Apply Feathers's seam test. For each boundary, ask: **could you replace what's behind this boundary with a different implementation, and would the code on the other side continue to work?**

If yes, the boundary is real -- it encapsulates effectively.

If no -- if replacing the implementation requires changing the calling code -- the boundary has coupling that it claims to encapsulate but doesn't. The calling code depends on something that should be hidden: a data format, an ordering assumption, a performance characteristic, an error behavior.

This test also reveals boundaries that should exist but don't. If you cannot test a module in isolation, there is no seam between it and its dependencies. If you cannot deploy a module independently, there is no operational seam. The absence of seams tells you where the architecture has structural debt.

For each missing seam, trace backward: **what shared knowledge prevents substitution?** That knowledge is a leaked secret (Step 2) and the source of the coupling.

### Step 6: Synthesize findings

After completing steps 1-5, you should be able to articulate:
- Which boundaries are real (enforced, deep, responsibility-coherent, substitutable) and which are cosmetic
- Where information leakage couples modules that should be independent
- Where responsibility misplacement puts behavior in the wrong module
- Where shallow boundaries add cost without hiding complexity
- Where missing seams prevent independent testing, deployment, or evolution

Multiple symptoms often share one root cause. Two modules that always change together, that can't be tested independently, and that share knowledge of a data format -- that's one problem (a leaked secret), not three. Find the root cause before proposing structural changes.

---

## 3. Diagnostic Questions

**Q: For each module, can you state its secret in one sentence?**
Healthy: Every module hides exactly one design decision that could change. "This module hides how user sessions are stored." "This module hides the external payment provider's API."
Unhealthy: You cannot articulate what the module hides, or the answer is "it hides several unrelated things," or two modules hide the same thing. Modules without clear secrets are organizational accidents, not design decisions.

**Q: If this design decision changes, how many modules must change?**
Healthy: Exactly one. The module that hides that decision absorbs the change entirely.
Unhealthy: Two or more. This is information leakage -- the defining boundary failure. The most damaging form is "back-door leakage" where modules share knowledge through non-obvious channels (both knowing a file format, both assuming a data ordering) without any interface making the dependency visible.

**Q: What is the ratio of interface complexity to hidden complexity?**
Healthy: The interface is simple relative to what's behind it. Unix file I/O: five functions hiding filesystem, caching, permissions, concurrent access, disk management. That is deep.
Unhealthy: The interface is nearly as complex as the implementation. Java I/O requiring three class instantiations to read a buffered file. A microservice with many endpoints each doing trivial operations. These are shallow -- the boundary costs more than it saves.

**Q: Can you describe what this module does without conjunctions?**
Healthy: "It processes payments." "It manages user authentication." Single, coherent purpose.
Unhealthy: "It validates orders AND calculates shipping AND sends notifications." Multiple unrelated responsibilities sharing a boundary. Each "and" is a candidate for a separate module.

**Q: Which role stereotype does this module fit?**
Healthy: The module clearly fits one stereotype or a natural combination (information holder that makes decisions about its own data). The stereotype predicts what the module should and should not own.
Unhealthy: The module fits no stereotype or fits all of them. A coordinator that has accumulated decision logic, data storage, and translation duties is a god module wearing a coordinator costume.

**Q: Does this module reach into another module's data to make decisions?**
Healthy: Each module makes decisions about data it owns. It tells other modules what to do rather than asking for their data and deciding externally.
Unhealthy: Module A retrieves data from Module B and then applies business logic to it. The decision logic should live with the data -- either in Module B or in a module that owns both the data and the logic. This is feature envy at the architectural level.

**Q: Can you replace what's behind this boundary with a different implementation?**
Healthy: Yes. The calling code depends only on the interface contract. You can swap a SQL database for a document store, a synchronous processor for an async one, a local service for a remote one -- without changing callers.
Unhealthy: No. Callers depend on implementation details: specific error types, performance characteristics, ordering guarantees, data format details. The boundary is cosmetic. Per Hyrum's Law, every observable behavior of a module will eventually be depended upon by someone -- the boundary you intend is not the boundary that exists in practice.

**Q: Can you test this module without instantiating unrelated parts of the system?**
Healthy: The module has seams at its boundaries. You can inject test doubles for its dependencies and verify its behavior in isolation.
Unhealthy: Testing the module requires setting up a large portion of the system because dependencies are hard-wired. This means there are no seams at the boundaries -- and boundaries without seams are not real boundaries.

**Q: Do modules that are supposed to be independent change together in commits?**
Healthy: Modules change independently. A commit touches one module or, when it touches multiple, it's changing the contract between them (which should be rare).
Unhealthy: Modules routinely change together. This reveals coupling that the architecture diagram doesn't show. Either the modules should be merged (they're really one module split across two names) or there's a shared secret leaking between them.

**Q: Is this boundary enforced by anything other than developer discipline?**
Healthy: The build system, the type system, the network, or a static analysis tool enforces the boundary. Violations are caught automatically.
Unhealthy: The boundary exists only in documentation or convention. Convention-only boundaries erode under deadline pressure. Every "just this once" violation weakens the boundary until it's Swiss cheese.

**Q: Where is the single source of truth for each important piece of data?**
Healthy: Each piece of domain knowledge lives in exactly one module. Other modules request it through interfaces.
Unhealthy: The same business rule, validation logic, or format knowledge is implemented independently in multiple modules. They will diverge.

**Q: If you drew the dependency graph of actual runtime calls, would it match the architecture diagram?**
Healthy: The real dependency graph matches the intended one. Boundaries exist where the diagram says they do.
Unhealthy: The real graph is denser than the intended one. Services call services that call services in synchronous chains. The "microservices" are a distributed monolith -- boundaries in name, coupling in fact.

**Q: Are configuration parameters pushing complexity upward to callers?**
Healthy: Modules compute reasonable defaults internally and expose configuration only for genuinely caller-specific decisions.
Unhealthy: Modules require extensive configuration from callers to function. Each configuration parameter is a piece of hidden complexity pushed upward rather than absorbed. The module's interface is wider than it needs to be.

**Q: Is there code that's organized by execution order rather than by what it knows?**
Healthy: Modules are organized around the knowledge they encapsulate. A module that reads and writes a file format owns that format entirely.
Unhealthy: Modules are organized as pipeline stages -- reader, processor, writer -- where the reader and writer both know the format. This is temporal decomposition, and the format decision has leaked across two boundaries.

**Q: Are there modules that exist solely to satisfy an architectural rule?**
Healthy: Every module exists because it hides a real decision, provides a real abstraction, or owns a real responsibility.
Unhealthy: Modules exist because "every table needs a service" or "we always have a repository layer." A boundary created to satisfy a rule rather than solve a problem is a shallow boundary that adds cost without benefit.

**Q: Does the module have a clear "enabling point" -- a mechanism for substituting its behavior?**
Healthy: The module's dependencies are received through explicit mechanisms (constructor parameters, configuration, interface bindings). You can see in the source code where and how behavior varies.
Unhealthy: Dependencies are created inline with direct instantiation. Behavior is hard-wired. There is no point in the code where you could choose a different implementation without editing the module itself. This is Feathers's seam test -- no enabling point means no real boundary.

**Q: Is the module's interface stable relative to the decisions it hides?**
Healthy: The interface changes far less frequently than the implementation. The module has been refactored internally multiple times without callers noticing.
Unhealthy: The interface changes whenever the implementation changes. This means the interface is leaking implementation details -- it describes the current solution rather than the abstract capability.

**Q: Would a new developer know where to put a new feature without asking someone?**
Healthy: The module structure makes it obvious where new behavior belongs. Each domain concept has a clear home. A developer can navigate from the feature description to the right module.
Unhealthy: New features get added to whichever module the developer happens to understand best, or to a catch-all module like "utils" or "common." This signals that boundaries don't communicate their purpose -- they are organizational but not conceptual.

**Q: Are there modules whose names are technical terms rather than domain concepts?**
Healthy: Module names reflect what the system does -- checkout, inventory, pricing, authentication. A domain expert could navigate the module structure.
Unhealthy: Module names reflect how the system is built -- services, repositories, handlers, utilities. The domain is invisible in the structure. This is a leading indicator of technical-layer boundaries, which almost always produce shallow encapsulation and scattered domain logic.

**Q: Is there a "utils," "helpers," or "common" module that everything depends on?**
Healthy: No catch-all modules. Every piece of shared logic has a specific home in a module whose domain includes that logic.
Unhealthy: A growing "utils" module accumulates unrelated functions that didn't fit anywhere else. This module is an explicit admission that boundary decisions have not been made. Each function in it is an unresolved design decision about where responsibility belongs.

---

## 4. What Good Looks Like vs What Bad Looks Like

**Bad:** Two services both understand the wire format of messages between them. When the format changes, both services change. The format is a shared secret with no owner.
**Good:** One module owns the format definition and provides serialization/deserialization. Other modules interact through domain objects, never seeing the wire format. The format decision has exactly one home.
**Gravity:** The format started simple (a JSON object with three fields) and nobody thought it needed its own module. By the time it grew complex, both services had extensive format-specific code. Starting with a shared secret feels efficient; it becomes expensive at scale.

**Bad:** A service layer mirrors the repository layer method-for-method: `getUser()` calls `userRepository.getUser()`, adding nothing. Each service method is a pass-through.
**Good:** The service layer provides a different abstraction from the repository layer. The repository speaks in storage entities; the service speaks in domain operations that may span multiple repositories, apply business rules, or transform data. Different layer, different abstraction.
**Gravity:** Layered architecture templates generate these pass-through layers by default. Developers add them "because the architecture requires a service layer," not because the service layer hides anything. Framework conventions create shallow boundaries.

**Bad:** A module has a massive interface -- dozens of methods, complex parameter objects, extensive documentation needed to use it correctly. It is wide but not deep.
**Good:** A module has a narrow interface -- a few operations with simple parameters -- hiding substantial internal complexity. Callers don't need to understand the internals to use it correctly. Unix file I/O: five functions hiding an entire storage subsystem.
**Gravity:** Interfaces grow one method at a time. Each addition seems small. But interface width is a ratchet -- adding is easy, removing is nearly impossible because of Hyrum's Law. Every method you add becomes a commitment.

**Bad:** A "coordinator" module that started as a thin request router has accumulated business rules, data transformations, and policy decisions. It is now the most complex module in the system, and every feature change touches it.
**Good:** Coordination and decision-making are separated. The coordinator routes requests; controllers own policy decisions; service providers own computation. Each module's role is clear and its growth is constrained by its stereotype.
**Gravity:** Coordinators are the natural place to add "just one more if-statement." They see all the data flowing through, so it's tempting to make decisions there rather than delegating. Each addition is small; the accumulation is a god module.

**Bad:** A module's behavior depends on undocumented assumptions about the calling order of its methods, the state of global variables, or the behavior of modules it doesn't declare a dependency on. These are unknown unknowns -- things a developer needs to know but has no way of discovering.
**Good:** A module's behavior is obvious from its interface. Its dependencies are explicit. Its preconditions are either enforced programmatically or clearly documented. A developer's first guess about how to use it is correct.
**Gravity:** Unknown unknowns are invisible by definition. They accumulate silently as developers add implicit assumptions that are never documented because they seem obvious to the person writing the code at that moment. They surface as bugs that no amount of code reading would have predicted.

**Bad:** An internal module boundary that was meant to be a soft, refactorable line has been depended on by external consumers (other teams, public APIs, or simply widespread usage). It can no longer be changed without breaking the world. The internal boundary has become an external contract.
**Good:** Internal boundaries are explicitly marked as unstable. External boundaries are explicitly committed to and versioned. The Linux kernel principle: internal APIs are fluid, the userspace ABI is forever.
**Gravity:** Hyrum's Law. Any observable behavior will be depended upon. The only defense is to never expose internal boundaries externally -- or to enforce the distinction with tooling (visibility modifiers, API gateways, build system rules).

**Bad:** Multiple modules independently implement the same business rule (e.g., order validation, price calculation, eligibility checking). They diverge over time. Nobody knows which version is authoritative.
**Good:** Each business rule has a single owner. Other modules call that owner when they need the rule applied. Changes happen in one place.
**Gravity:** Teams working on different parts of the system need the same rule but can't easily call the owning module (wrong language, wrong deployment unit, too much latency). They re-implement it. Duplication begins as expedience and becomes divergence.

**Bad:** A boundary exists between modules, but they share a database. Schema changes in one module's tables can break the other module's queries. The boundary encapsulates code but not data.
**Good:** Each module owns its data behind a service interface. Other modules request data through that interface, never accessing the storage directly. Amazon's Bezos mandate: no shared databases, no back doors.
**Gravity:** Shared databases are the path of least resistance. They eliminate the need for API design, serialization, and network calls. They also create the tightest possible coupling -- schema coupling -- which is invisible until a migration breaks everything.

**Bad:** A module cannot be tested without instantiating its real dependencies because there are no seams -- no places where behavior can be altered without editing the module's source. The boundary exists in the file system but not in the runtime structure.
**Good:** Every boundary has seams. Dependencies can be substituted for testing, monitoring, or migration. The seam is explicit in the code (constructor injection, interface parameters, configuration-driven dispatch), not hidden in a build script.
**Gravity:** Direct instantiation (`new ConcreteClass()`) is the simplest way to create a dependency. It is also the way that eliminates seams. Developers create dependencies inline because it's expedient, and each inline creation is one more place where substitution is impossible.

**Bad:** Technical-layer boundaries: all models in one package, all services in another, all controllers in a third. Adding a feature requires touching every layer. The domain is invisible in the code structure.
**Good:** Domain-oriented boundaries: checkout, inventory, payments, user management. Each domain module contains its own models, services, and interfaces. Adding a feature means working within one module. The domain is the organizing principle.
**Gravity:** Frameworks organize code by technical layer by default. Team specialization (frontend team, backend team, database team) reinforces layer-oriented thinking. Every case study of a successful boundary migration ends at domain-oriented boundaries. The framework defaults are wrong for large systems.

**Bad:** A module's error semantics force callers to handle conditions that are not real errors. Deleting a resource that doesn't exist returns a "not found" error. Unsubscribing from something you never subscribed to throws an exception. Callers accumulate defensive code.
**Good:** The module defines errors out of existence. "Ensure this resource does not exist" succeeds idempotently. Operations on an empty selection do nothing gracefully. The module handles edge cases internally, and its interface exposes only conditions that genuinely require caller decisions.
**Gravity:** It is natural to report every deviation from the "happy path" as an error. This makes the implementation simple (check precondition, throw if violated) but pushes complexity to every caller. Defining errors out of existence requires deeper thinking about the module's semantics, which is harder upfront but reduces total system complexity.

**Bad:** Every module exposes its configuration as parameters that callers must set. A messaging module requires callers to specify retry count, backoff strategy, timeout, batch size, and serialization format before sending a single message.
**Good:** The module pulls complexity downward. It ships with sensible defaults for all configuration, auto-tuning where possible. Callers can override when they have domain-specific knowledge, but the common case works with zero configuration. The interface is narrow by default, expandable when needed.
**Gravity:** Exposing configuration feels like "giving the caller control." In practice, most callers don't have the knowledge to set these parameters well and will copy values from other callers or use arbitrary numbers. Ousterhout: "each configuration parameter represents a case where the module designer was too lazy to figure out the right behavior."

---

## 5. Common Failure Modes

**The Leaked Secret**
Pattern: Two or more modules share knowledge of the same design decision -- a data format, a protocol, a business rule, an algorithm. Neither module's interface makes this shared knowledge explicit.
Symptom: Changing the shared decision requires coordinated changes across modules. Developers discover this coupling only when a change in one module breaks another. "I only changed the serialization format, why did the reporting service break?"
Root cause: The decision was not identified as a secret that needed hiding, or it was identified but assigned to no single owner. Back-door leakage -- knowledge shared through convention rather than interface.
Direction: Identify the decision. Assign it to exactly one module. Make other modules depend on that module's interface, not on direct knowledge of the decision.
Over-correction risk: Creating a module for every trivially shared constant or format, producing an explosion of tiny modules that add more interface cost than they save. Hide decisions that are **likely to change**, not every decision that theoretically could.

**The Shallow Boundary**
Pattern: A module's interface is nearly as complex as its implementation. Pass-through methods, thin wrappers, layers that add indirection without abstraction.
Symptom: Developers must understand both sides of the boundary to do anything useful. The boundary adds navigational cost (more files to open, more call chains to trace) without reducing cognitive load. "Why do I have to go through three layers to save a record?"
Root cause: Boundaries drawn to satisfy an architectural template or organizational rule rather than to hide a real decision. Premature decomposition before the domain is understood. Framework conventions that generate layers by default.
Direction: Merge shallow modules into adjacent modules to create fewer, deeper boundaries. The question is not "does this module exist?" but "does this module hide enough to justify its interface cost?"
Over-correction risk: Merging too aggressively and creating god modules. A module that is deep because it hides everything is deep but incoherent. Depth must be combined with responsibility coherence.

**The God Module**
Pattern: One module accumulates a disproportionate share of the system's logic. Everything depends on it. Every feature change touches it. It has no clear single responsibility.
Symptom: The module is the most frequently changed file in the repository. Merge conflicts cluster there. New developers are told "don't worry about understanding all of it." Builds and tests are slow because the module pulls in everything.
Root cause: Organizational -- no single team owns it, so everyone adds to it. Technical -- it sits at a junction of many data flows, making it the expedient place to add logic. Cognitive -- it's the best-understood module, so developers gravitate toward it. The gravity of knowledge concentration.
Direction: Identify the distinct responsibilities hidden inside the god module. Assign each to a separate module with its own secret. This is not "splitting the file" -- it's finding the boundaries that should have existed and drawing them with proper encapsulation.
Over-correction risk: Splitting into too many tiny modules that are individually shallow and collectively harder to understand than the original. The test: does each resulting module have a clear secret and a coherent responsibility?

**The Distributed Monolith**
Pattern: Multiple modules (often called "microservices") are separately deployed but tightly coupled: synchronous call chains, shared databases, coordinated deployments, shared knowledge of data formats.
Symptom: Deploying one module requires deploying others simultaneously. A failure in one module cascades through others. Development feels slower than a monolith because every change requires cross-module coordination plus the overhead of distributed system operations. "We have the complexity of microservices and the coupling of a monolith."
Root cause: Boundaries were drawn along the wrong axis (per entity, per technical layer, or per team member rather than per domain capability). Or boundaries were drawn before the domain was understood, locking in wrong decisions. Synchronous communication patterns turned service boundaries into function call boundaries with added latency.
Direction: Identify which modules are truly independent (can be deployed and fail independently) and which are actually one module split across a network boundary. Merge the coupled ones. Introduce asynchronous communication where appropriate to create real operational independence. Shopify's approach: use soft module boundaries within a monolith until you're confident they're right, then harden selectively.
Over-correction risk: Merging everything back into a monolith. The problem is not services per se -- it's wrong boundaries and synchronous coupling. The fix is better boundaries, not fewer boundaries.

**Temporal Decomposition**
Pattern: Modules organized by execution phase -- "the reader," "the processor," "the writer" -- rather than by the knowledge they encapsulate.
Symptom: Data format knowledge appears in multiple modules. Pipeline changes require updating every stage. Adding a new field to the data means touching the reader, the processor, and the writer.
Root cause: Developers naturally think about systems in terms of execution flow, and flowchart-based decomposition is the intuitive default. Parnas demonstrated in 1972 that this is almost always the wrong decomposition strategy, but it remains the most common one.
Direction: Reorganize around information hiding. The module that owns a data format should handle both reading and writing it. The module that owns a transformation should encapsulate both the algorithm and its inverse.
Over-correction risk: Ignoring legitimate pipeline boundaries. Some systems genuinely have stages that hide different decisions (a compiler's lexer, parser, and code generator each hide different knowledge). The test is whether the stages share secrets, not whether the system has sequential phases.

**The Convention-Only Boundary**
Pattern: A module boundary that is documented but not enforced by any automated mechanism. Developers are told "don't import from that package directly" but nothing prevents it.
Symptom: The boundary erodes gradually. Each violation is individually justified ("just this once, for the deadline"). After a year, the boundary is Swiss cheese -- it exists in the documentation but not in the code. New developers never learn it existed.
Root cause: Enforcement was deferred ("we'll add tooling later") or considered unnecessary ("everyone knows the rules"). Deadline pressure creates exceptions that become norms.
Direction: Enforce boundaries with tooling. Language-level visibility (Rust crates, Java modules), build system rules (Bazel visibility, Gradle module dependencies), or static analysis (Shopify's Packwerk, ArchUnit). If a boundary matters, something must enforce it.
Over-correction risk: Over-constraining the system with so many enforcement rules that legitimate cross-boundary work becomes painfully difficult. Enforcement should match the boundary's importance -- public API boundaries get strict enforcement, internal organizational boundaries can be lighter.

**The Premature Abstraction**
Pattern: An interface or abstraction layer created before the domain is well enough understood to know where the real variation lies. The abstraction doesn't match actual usage patterns.
Symptom: The abstraction is constantly worked around. Callers use escape hatches, type-cast to the concrete implementation, or build parallel paths that bypass the abstraction. "The interface doesn't support what we actually need to do."
Root cause: Predicting the right abstraction before having concrete examples of variation is extremely hard. Parnas himself acknowledged that identifying "decisions likely to change" requires deep domain knowledge. Wrong predictions create boundaries that protect against changes that never come while leaving the system exposed to changes that do.
Direction: Delay abstraction until you have at least two or three concrete variations that demonstrate the actual axis of change. Feathers's principle: introduce seams where you need them, not where you might need them. Wirfs-Brock's "hot spots" concept: identify specific points of likely variation and design flexibility only there.
Over-correction risk: Never abstracting at all, creating a system that cannot accommodate change when it does arrive. The solution is not to avoid abstraction but to delay it until the variation is understood.

**Responsibility Diffusion**
Pattern: A single responsibility -- a business rule, a validation, a computation -- is implemented independently in multiple modules because no single module clearly owns it.
Symptom: Inconsistent behavior. The checkout service validates a discount one way; the reporting service validates it another way. Fixing a bug means finding all the places the rule is implemented. Some are missed. "I thought we fixed that."
Root cause: The responsibility was not assigned to a specific owner. Different teams needed the same capability and, lacking a clear interface to call, implemented it themselves. Conway's Law: team boundaries that don't match responsibility boundaries produce responsibility diffusion.
Direction: Assign every important business rule to a single owner-module. Other modules call that owner through an explicit interface. This may require creating a new module whose purpose is to own that responsibility.
Over-correction risk: Creating a "rules engine" module that owns all business logic, becoming a god module by another name. Each business rule should be owned by the module whose domain concept it belongs to, not by a centralized rule repository.

**The Wrong Decomposition Axis**
Pattern: Modules are split along an axis that doesn't correspond to real variation. Segment's 140+ microservices split by integration destination (one for Google Analytics, one for Mixpanel, etc.) when the variation was just configuration, not behavior. Systems split per database table when the meaningful unit is a domain capability.
Symptom: Modules are structurally identical -- same code pattern, same error handling, same logic. Bug fixes must be applied N times. The "different modules" are really the same module parameterized differently.
Root cause: The decomposition axis was chosen based on surface-level differences (different API endpoints, different table names) rather than behavioral differences. The question "do these modules change for different reasons?" was not asked.
Direction: Merge the structurally identical modules into one parameterized module. The axis of variation becomes configuration, not separate deployment units. Segment replaced 140+ services with one service driven by per-destination configuration.
Over-correction risk: Collapsing modules that have genuinely different behavior just because they look similar today. If the variations are truly independent and likely to diverge, separate modules are correct. The test: do these modules change for different reasons, or do they always change together in the same way?

**The Frozen Boundary**
Pattern: A boundary that should be internal and refactorable has become external and permanent, either because external consumers depend on it (Hyrum's Law) or because the cost of changing it has grown too high (schema coupling, API versioning commitments, organizational lock-in).
Symptom: The team knows the boundary is in the wrong place but can't move it. Workarounds and adapter layers accumulate around the frozen boundary. New features are designed around the boundary's constraints rather than the domain's needs. "We'd love to merge these services, but 30 teams depend on both APIs."
Root cause: The boundary was hardened (made into a service, given a public API, had a database split behind it) before it was validated. The cost of wrong boundaries scales with boundary hardness: moving a package boundary costs an afternoon; moving a service boundary costs a quarter.
Direction: For existing frozen boundaries, introduce anti-corruption layers to isolate the bad boundary's effects. For future boundaries, apply progressive hardening -- start soft (modules enforced by static analysis), observe change patterns, and harden only when confident. Shopify's approach: enforce boundaries with Packwerk within the monolith, extract to services only when the boundary has proven stable.
Over-correction risk: Never hardening any boundary, keeping everything as a monolith indefinitely. Soft boundaries are cheaper to move but also cheaper to violate. At some point, the independence benefits of hard boundaries (independent deployment, independent scaling, failure isolation) justify the commitment.

---

## 6. Interactions With Other Frameworks

### Boundaries and Dependency Flow (`dependency-flow.md`)

Boundary quality and dependency direction are deeply intertwined. A boundary that is deep and substitutable but has its dependencies pointing the wrong way (a stable core module depending on a volatile peripheral module) is still problematic. Conversely, correct dependency direction with shallow boundaries produces a well-ordered but ultimately useless module hierarchy.

When analyzing boundaries, check: does the dependency direction across each boundary point from volatile toward stable? When you fix a boundary problem by splitting a module, the new modules' dependency relationships must respect the dependency rule, or you've traded one problem for another.

The most common intersection failure: extracting a module to improve encapsulation but creating a circular dependency between the extracted module and its parent. Parnas's "uses hierarchy" must remain acyclic. When extraction would create a cycle, use the "sandwich maneuver" -- split one of the modules further to break the cycle.

### Boundaries and Simplicity/Complexity (`simplicity-complexity.md`)

Every boundary adds accidental complexity (the interface itself, the indirection, the deployment overhead). This complexity is justified only when the boundary hides more essential complexity than it introduces. Shallow boundaries are the primary way that boundary thinking creates accidental complexity -- they add interface cost without reducing cognitive load.

Ousterhout's warning applies directly: "The overall goal is to reduce complexity; this is more important than any particular principle." If applying information hiding, deep module thinking, or responsibility-driven decomposition produces a system with more total complexity than the simpler alternative, the boundary is wrong -- even if it follows every principle correctly.

The specific intersection to watch: over-decomposition in the name of "good boundaries" creating a system of many small modules where understanding any operation requires tracing through dozens of boundaries. Each boundary is individually clean; the collective effect is incomprehensible.

### Boundaries and Data Flow/State (`data-flow-state.md`)

Boundary placement determines data flow paths. A boundary drawn in the wrong place creates unnecessary data movement -- fetching data from one module, transforming it, passing it to another, when a better boundary placement would keep the data and its operations together.

The critical intersection: shared databases destroy boundary encapsulation. When two modules share a database, they share the most intimate implementation detail possible. Amazon's API mandate succeeded specifically because it addressed data boundaries, not just code boundaries. Multiple migration stories (Twitter, SoundCloud, Segment) confirm that splitting data is harder than splitting code and more important to get right.

Watch for pass-through variables -- data threaded through multiple module boundaries because it's needed deep in the call chain but not by intermediate modules. Each intermediate module's interface is polluted by knowledge it doesn't use. This is data flow forcing itself across boundaries that were drawn without considering where data needs to go.

### Boundaries and Domain Alignment (`domain-alignment.md`)

Domain-driven design's bounded contexts are module boundaries derived from the problem domain. When boundaries align with domain concepts (checkout, inventory, payments), they tend to be deep (each domain concept hides substantial complexity), responsibility-coherent (domain responsibilities cluster naturally), and change-resilient (domain concepts evolve independently).

When boundaries align with technical layers (models, services, controllers), they tend to be shallow, cut across domain concepts, and force every domain change to span multiple modules. Every boundary migration case study -- Shopify, Twitter, SoundCloud, Uber's DOMA -- ends at domain-oriented boundaries. Technical-layer decomposition is the most common boundary mistake, reinforced by framework defaults and team specialization.

Conway's Law works in both directions here. Amazon weaponized it: two-pizza teams own services, so organizational boundaries and technical boundaries align by design. When they don't align, the organization's structure will override the architecture over time.

### Boundaries and Change/Evolution (`change-evolution.md`)

Parnas's entire framework is about designing for change: hide decisions likely to change, so that when they do change, the modification is localized. But the cost of wrong boundaries varies enormously by boundary type. A wrong module boundary within a monolith costs a refactoring sprint. A wrong microservice boundary costs a database migration, API versioning, and potentially months of work.

This argues for progressive boundary hardening: start with soft boundaries (modules within a process, enforced by static analysis) and harden them (separate services, separate databases, separate deployments) only when you're confident they're right. Shopify's modular monolith approach is the clearest expression of this principle. You can cheaply discover the right boundaries through soft modules, then commit to hard boundaries when the cost of being wrong is justified by the benefit of independence.

The Linux kernel embodies the evolution principle at the extreme: internal module boundaries are explicitly unstable (no stable in-kernel API), while the external boundary (the syscall interface) is sacrosanct. This lets the kernel evolve its internal structure freely while maintaining its contract with the world.

---

## 7. Sources and Further Reading

**Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules" (1972).** The foundational paper. Read the KWIC index example in full -- it demonstrates, through a concrete system, why decomposition by processing step fails and decomposition by information hiding succeeds. The insight that "one begins with a list of difficult design decisions or design decisions which are likely to change" remains the most important single sentence in software architecture. Nothing else in this document makes sense without this paper's reasoning.

**Ousterhout, "A Philosophy of Software Design" (2018).** Read Chapters 4-5 (deep vs shallow modules, information hiding and leakage) and Chapter 8 (pull complexity downward). Ousterhout operationalizes Parnas's principles by giving you a way to evaluate boundary quality (depth) and specific failure modes to watch for (temporal decomposition, pass-through methods, pass-through variables). His identification of unknown unknowns as the worst complexity symptom directly informs boundary evaluation -- a good boundary eliminates unknown unknowns; a bad boundary creates them.

**Wirfs-Brock & McKean, "Object Design: Roles, Responsibilities, and Collaborations" (2003).** Read Chapters 2-3 (responsibilities) and Chapter 4 (collaborations and control styles). The role stereotypes provide the vocabulary most other sources lack: a way to characterize what a module IS so you can reason about what it should and should not own. The CRC card technique in Chapter 5 is the most practical method for discovering boundaries through scenario walkthroughs. Most valuable at the system level, despite the object-level examples.

**Feathers, "Working Effectively with Legacy Code" (2004).** Read Chapter 4 (the seam model). The seam concept is the most rigorous test of whether a boundary is real: if you cannot substitute at it, it is cosmetic. The effect sketch technique (Chapter 11) traces change propagation through systems, revealing hidden coupling that other analyses miss. His concept of "pinch points" -- places where many effect paths converge -- identifies natural encapsulation boundaries in existing systems.

**Winters, Manshreck, & Wright, "Software Engineering at Google" (2020).** Chapter 12 (unit testing), Chapter 15 (deprecation), and Chapter 22 (large-scale changes). Provides the industrial-scale perspective on why boundary enforcement needs tooling, how Hyrum's Law undermines intended boundaries, and what happens when boundaries must change across millions of lines of code. The most grounded source on the gap between intended and actual boundaries.

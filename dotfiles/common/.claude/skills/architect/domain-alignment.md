# Domain Alignment: Reasoning Framework

**Source canon:** Eric Evans, "Domain-Driven Design" (2003) Part IV: Strategic Design; Vaughn Vernon, "Implementing Domain-Driven Design" (2013); Melvin Conway, "How Do Committees Invent?" (1968); Matthew Skelton & Manuel Pais, "Team Topologies" (2019); Nagappan, Murphy & Basili, "The Influence of Organizational Structure on Software Quality" (2008)
**Applies when:** a system's code structure does not reflect the problem it solves -- when the same term means different things in different parts of the system, when business features require coordinated changes across many unrelated modules, when domain experts cannot navigate the codebase, or when organizational boundaries visibly distort the architecture

---

## 1. What This Framework Addresses

This framework addresses whether the structure of a software system reflects the structure of the problem domain it serves. Every system models some domain -- payments, logistics, social networking, content management. When the code's organizational boundaries align with the domain's natural conceptual boundaries, each business change has a natural home, teams can reason about their area without loading the entire system into their heads, and the architecture makes the next likely business features easy to add. When the code is organized by technical concern (controllers, services, repositories) or by arbitrary entity decomposition, every domain change cuts across multiple modules, language becomes ambiguous, and the system fights its own purpose.

This is the only framework in this set that addresses **where different conceptual vocabularies apply** and **how systems with different models of the same reality interact**. The other five frameworks (boundaries-encapsulation, simplicity-complexity, data-flow-state, dependency-flow, change-evolution) each examine a structural concern that is independent of domain semantics. This framework adds the semantic dimension: not just "are these modules well-separated?" but "do these modules correspond to real distinctions in the problem domain?" It also uniquely addresses organizational structure as an architectural force -- Conway's Law means team boundaries create domain boundaries whether or not the architecture intends it. This framework cannot tell you whether boundaries are deep or shallow (see `boundaries-encapsulation.md`), whether data flows efficiently (see `data-flow-state.md`), or whether dependencies point in the right direction (see `dependency-flow.md`). It tells you whether the boundaries, data flows, and dependencies are in the right **places** -- places that reflect the domain.

---

## 2. Core Reasoning Procedure

### Step 1: Identify the domain's natural conceptual boundaries

Before examining the code, understand where the problem domain itself draws lines between distinct areas of meaning. The primary technique is linguistic: listen for where the same term means different things to different people, or where different groups use entirely different vocabularies.

Evans's core insight is that a Bounded Context is a **linguistic boundary** -- the region within which a particular model and vocabulary are consistent. "Customer" in Billing (an entity with payment methods, invoices, and credit limits) is not the same concept as "Customer" in Support (an entity with ticket history, satisfaction scores, and escalation paths). Neither definition is wrong. They are different models serving different purposes, and forcing them into a single representation produces a model so generic it encodes almost no domain knowledge.

The procedure: enumerate the major business concepts in the system. For each, ask: "Does this concept mean exactly one thing everywhere, or does its meaning shift depending on who is talking?" Where meaning shifts, you have found a context boundary. Vernon's heuristic: if domain experts from different parts of the organization describe the same concept differently, those descriptions belong in different bounded contexts. Brandolini's EventStorming technique operationalizes this -- domain events laid on a timeline naturally cluster by the language they use and the people who care about them, and the gaps between clusters indicate context boundaries.

Do not confuse this with technical decomposition. A bounded context is not a database, not a service, not a deployment unit. It is a semantic boundary. The code structure should follow it, but the domain boundary comes first.

### Step 2: Map existing context relationships

Once you know where the conceptual boundaries are, document how the existing system handles the interactions between them. Evans calls this a Context Map -- a description of the actual relationships between bounded contexts, emphasizing "actual" over "aspirational."

For each pair of contexts that interact, classify the relationship:

- **Partnership:** Both contexts must succeed or fail together; teams coordinate closely. If one team can release without the other, this is not a real partnership.
- **Customer-Supplier:** One context is upstream (its changes propagate) and the other is downstream (it must absorb those changes). The downstream team has negotiating power over the upstream model.
- **Conformist:** The downstream context has no influence over the upstream model and must simply conform. This is the reality with most third-party APIs and legacy systems.
- **Anticorruption Layer:** The downstream context builds an explicit translation layer that converts upstream concepts into its own model. The most important defensive pattern -- it prevents external models from corrupting the internal domain model.
- **Open Host Service:** A context publishes a well-defined protocol for others to integrate with, rather than building bespoke integrations per consumer.
- **Published Language:** A shared, documented, versioned data format used as the medium of exchange between contexts (protocol buffers, industry standards like HL7/FHIR, ACORD).
- **Shared Kernel:** Two contexts share a small, explicitly defined subset of the model. Both teams must agree on changes to this kernel. It must be kept genuinely small -- if it grows, you effectively have one context, not two.
- **Separate Ways:** A deliberate decision that two contexts will not integrate. Each solves its own version of the problem independently. This pattern requires courage -- architects often feel compelled to integrate everything, but the cost of integration sometimes exceeds the benefit.

For each relationship, identify: the direction of influence (who is upstream, who is downstream), the power dynamics (can the downstream team influence the upstream model?), and where translation actually happens (explicitly in one place, or scattered across the codebase?).

### Step 3: Check organizational alignment

Conway's Law is not a guideline -- it is a structural constraint. Conway's original argument (1968): design decisions require communication, and the communication structure of the organization constrains which design decisions can be made. Two parts of the system that require coordinated design will be designed independently if the people responsible for them do not communicate. Therefore, the system's structure will mirror the organization's communication structure.

Nagappan et al. (Microsoft Research, 2008) validated this empirically: organizational metrics -- number of engineers touching a component, organizational distance between contributors, ownership concentration -- predicted software defects better than any code metric, including complexity, churn, and coverage. The organizational structure around the code was a better predictor of its quality than the code itself.

The procedure: map which teams own which parts of the system. Ask: do team boundaries coincide with domain boundaries? If not, Conway's Law predicts the architecture will drift toward mirroring the team structure regardless of the intended design. The Inverse Conway Maneuver (ThoughtWorks) says: if you want the architecture to match the domain, restructure teams to match the domain boundaries first. Skelton and Pais operationalized this in Team Topologies: each "stream-aligned team" should own one or more bounded contexts, and a bounded context should not be split across teams.

Check for de facto bounded contexts created by team boundaries rather than domain analysis. Even in a monolith, if two teams work on different areas of the code, they will over time develop different assumptions, naming conventions, and models for shared concepts. The actual bounded contexts are where the teams are, regardless of what the architecture document says.

### Step 4: Assess cognitive load and context sizing

A bounded context that exceeds one team's cognitive capacity will not be maintained coherently. Skelton and Pais argue that cognitive load is the primary constraint on context sizing. Three types of load apply: intrinsic (the domain's own complexity), extraneous (tooling, process, infrastructure overhead), and germane (the productive effort of understanding and modeling the domain).

For each context-team pairing, ask: can this team hold the full model in their heads? If the team says "we're too busy to think about the design" or "you have to understand the whole system to change anything," the context is too large or the extraneous load is too high. If a context contains only trivial CRUD with no meaningful business rules, it may be too small -- or it may not be a real bounded context at all, just a data access layer masquerading as one.

Vernon's sizing heuristic: a bounded context should be large enough to contain a complete ubiquitous language for one area of the business, and small enough for a single team to own completely. If you cannot describe the purpose of a context in one or two sentences without using "and" to join unrelated concerns, it is too large.

### Step 5: Evaluate translation quality at boundaries

The integration points between bounded contexts are where domain alignment is most visible and most fragile. For each boundary crossing, check: is there an explicit translation between models, or does one context's model leak into another?

The canonical failure: a system integrates with an external payment provider and stores payment data using the provider's exact field names and structures. When the provider changes their API or the team switches providers, the internal data model must change because it was never separated from the external model. Every external integration without an anticorruption layer creates a hard dependency on an external model you do not control.

Check for translation code scattered throughout the codebase rather than consolidated in one place. If you find yourself asking "where does the conversion from their model to our model happen?" and the answer is "everywhere," you need an explicit anticorruption layer. If the answer is "we just use their model directly," the domain model has been corrupted.

### Step 6: Synthesize findings

After completing steps 1-5, you should be able to articulate: which conceptual boundaries exist in the domain and whether the code respects them, how contexts relate to each other and whether the relationships are explicitly managed or accidentally coupled, whether the organizational structure reinforces or undermines domain alignment, whether each context is appropriately sized for its team, and where model corruption has occurred at integration points. Multiple symptoms often share one root cause -- a system organized by technical layer rather than domain will simultaneously exhibit language ambiguity, scattered changes, god objects, and team coordination overhead, but the fix is one structural change: reorganize around the domain.

---

## 3. Diagnostic Questions

**Q1: For each major module, can you state its domain purpose in business terms?**
Healthy: Every module corresponds to a recognizable business capability. "This module handles order fulfillment." "This module manages merchant billing."
Unhealthy: Modules are described in technical terms. "This is the service layer." "This handles database access." The domain is invisible in the code structure, and developers navigate by technical concern rather than business concept.

**Q2: Does the same term mean different things in different parts of the system?**
Healthy: Where a term's meaning varies, explicit bounded contexts separate the definitions. "Order" in Sales and "Order" in Fulfillment are modeled as distinct concepts with explicit translation between them.
Unhealthy: A single entity (Customer, Order, Product) serves every use case across the system, accumulating fields from every context. It is a god object -- not because anyone designed it that way, but because the same word was assumed to mean the same thing everywhere.

**Q3: Can a domain expert navigate the codebase's top-level structure?**
Healthy: The module names correspond to business concepts the expert recognizes. They can point to where checkout logic lives, where inventory is managed, where billing happens.
Unhealthy: The top-level structure is controllers/, services/, models/, repositories/, utils/. The domain expert has no idea where any business concept lives because the organization is by technical layer, not by domain.

**Q4: When a single business requirement changes, how many modules must change?**
Healthy: The change is localized to the module that owns that domain concept. One team makes the change, tests it, and deploys it.
Unhealthy: Every business feature requires coordinated changes across many modules owned by different teams. This is the "shotgun surgery" pattern at the architectural level, caused by domain concepts being scattered across technical layers.

**Q5: Which team owns each business concept?**
Healthy: Every important business concept has exactly one team that owns its model, makes authoritative decisions about it, and can evolve it independently.
Unhealthy: Ownership is ambiguous. Multiple teams modify the same business concept. Changes require cross-team coordination meetings. Nagappan et al.'s research directly shows: shared ownership correlates with defects because implicit shared understanding of design intent degrades across team boundaries.

**Q6: Where does translation between different models happen?**
Healthy: At explicit boundaries -- anticorruption layers, published APIs, gateway services -- consolidated in one place per integration point.
Unhealthy: Translation code is scattered throughout the codebase. Developers "just know" how to map between models. Some integrations pass external models through without any translation at all.

**Q7: Are there terms in the code that domain experts do not recognize?**
Healthy: The code uses the ubiquitous language of the domain. Test names read like business scenarios. Method names reflect domain operations.
Unhealthy: The code has drifted from the domain vocabulary. Developers invented their own terms. Domain experts cannot confirm whether the code matches their understanding because they cannot read it.

**Q8: Are there terms domain experts use that have no representation in the code?**
Healthy: Every important domain concept has a corresponding structure in the code. The model is complete enough to reason about.
Unhealthy: Critical business concepts are implicit -- spread across multiple structures, encoded in conditionals, or simply missing. The domain model is incomplete, and domain logic is implemented through workarounds.

**Q9: If the organization restructured teams tomorrow, which domain boundaries would break?**
Healthy: Domain boundaries are enforced by the code structure (module boundaries, static analysis, build rules) and would survive team reorganization.
Unhealthy: Domain boundaries exist only by convention -- maintained by the current teams' shared understanding. A team change would erode them because nothing other than developer discipline maintains them. Shopify learned this: convention-only boundaries erode, which is why they built Packwerk for static enforcement.

**Q10: How many teams coordinate for a typical business feature?**
Healthy: Most features are delivered by one team within one bounded context. Cross-team features are the exception and occur at genuine domain boundaries.
Unhealthy: Most features require 3+ teams. This indicates either the domain decomposition or the team structure is wrong. Lewis and Fowler's diagnostic: if a single change requires coordinated deployment across multiple services owned by different teams, you have a distributed monolith.

**Q11: Are services organized around business capabilities or around entities?**
Healthy: Each service or module corresponds to a business capability (checkout, fulfillment, billing) and contains a complete model with real business logic.
Unhealthy: Services are organized around entities (CustomerService, OrderService, ProductService). Every business operation requires orchestrating calls across multiple entity services. The actual business logic lives in a coordination layer or, worse, is duplicated. Nygard's "Entity Service Antipattern" -- the services become thin CRUD wrappers while the interesting logic has no home.

**Q12: Is the shared code between contexts small, stable, and explicitly governed?**
Healthy: The shared kernel (if any) is minimal, has an explicit owner, and has clear criteria for what belongs in it. It is not growing.
Unhealthy: The shared kernel has grown to contain a significant fraction of the model. Changes to it require consensus from multiple teams. Teams work around it by duplicating functionality locally. It has become the coupling point it was meant to prevent.

**Q13: Does the system make the next likely business features easy to add?**
Healthy: Given the product direction, the most probable next features map naturally to existing domain boundaries and can be implemented within one or two contexts.
Unhealthy: Every new feature fights the current structure. The architecture was designed around yesterday's domain understanding and does not accommodate how the business has evolved.

**Q14: Are external system quirks contained at the boundary or propagated inward?**
Healthy: External integrations are isolated behind anticorruption layers. Internal models reflect the domain, not external systems' idiosyncrasies.
Unhealthy: The first external integration was done under time pressure. Its model propagated inward. By the third integration, the pattern is entrenched. Internal code is littered with fields and states that only make sense in the external system's terms.

**Q15: Do domain events reflect business occurrences or technical operations?**
Healthy: Events are named after domain occurrences (OrderPlaced, PaymentReceived, ItemShipped). They carry business semantics and are understandable to domain experts.
Unhealthy: Events are named after technical operations (RowUpdated, CacheInvalidated, MessageProcessed). The domain is invisible in the event stream, and every new business requirement requires tracing through technical plumbing to find where relevant data lives.

**Q16: Can each bounded context be deployed independently?**
Healthy: Each context has its own deployment lifecycle. Teams release on their own schedule without coordinating with other contexts.
Unhealthy: Deploying one context requires simultaneously deploying others because of shared models, shared databases, or implicit coupling. The boundaries are cosmetic.

**Q17: Are there concepts that are modeled identically across contexts when they should differ?**
Healthy: Where the same real-world thing appears in multiple contexts, each context models only the aspects it needs. A Product in the Catalog context has images and descriptions; the same product in Shipping has weight and dimensions.
Unhealthy: A single Product model carries every field from every context. Adding a field for one context's needs bloats the model for all contexts. This is the enterprise model unification problem that Evans warns is the most common strategic design failure.

**Q18: Do the informal communication patterns match the intended domain boundaries?**
Healthy: Teams that own related contexts talk to each other. Teams that own independent contexts interact through published interfaces.
Unhealthy: Actual communication (Slack channels, hallway conversations, shared standups) cuts across the intended boundaries. Conway's Law operates on actual communication, not official communication. The architecture will drift toward mirroring the informal structure.

---

## 4. What Good Looks Like vs What Bad Looks Like

**Domain-organized structure vs. technically-layered structure**
Bad: The system's top-level directories are controllers/, services/, models/, repositories/. Each business feature spans all four directories. A change to the checkout flow touches files in every directory, interleaved with unrelated features. There is no place in the codebase where "checkout" exists as a coherent whole.
Good: The top-level directories are checkout/, inventory/, billing/, shipping/. Each contains everything needed for that domain -- its models, its logic, its interfaces. A change to checkout stays within the checkout directory. The domain is visible in the file system.
Gravity: Frameworks default to technical-layer organization (Rails' app/models, app/controllers, app/views). Teams follow the framework convention without questioning whether it serves their domain. The pattern is reinforced by tutorials, starter projects, and developer muscle memory.

**Explicit bounded contexts vs. implicit shared model**
Bad: A single "domain model" is shared across the entire system. The Order class has 40+ fields serving sales, fulfillment, billing, and analytics. Every team modifies the same model. A billing change can break fulfillment because they share the same representation.
Good: Each bounded context maintains its own model with only the fields it needs. Translation between contexts happens at explicit boundaries. The Order in Sales has different fields than the Order in Fulfillment, and a defined mapping converts between them.
Gravity: Sharing a model feels efficient -- one source of truth, no duplication. The cost is invisible initially and compounds over time. By the time the god object is painful, it is deeply entrenched. Evans: attempting to unify the entire enterprise under one model produces a model so generic it encodes almost no domain knowledge.

**Team-per-context ownership vs. shared domain ownership**
Bad: Multiple teams modify the same bounded context. No team has the authority or incentive to maintain model coherence. Design decisions are made independently, producing subtle inconsistencies. Merge conflicts are frequent. The model degrades because nobody owns it.
Good: Each bounded context is owned by exactly one team. That team controls the model, the API, the deployment, and the operational health. Other teams interact through published interfaces. The owning team has both the authority and the accountability to maintain domain integrity.
Gravity: Organizations often assign teams by technical layer (frontend team, backend team, data team) or by project (each project team touches whatever code the feature needs). Both patterns diffuse domain ownership. The political cost of reorganizing teams around domains is high, so the misalignment persists.

**Anticorruption layers at external boundaries vs. external model propagation**
Bad: External system concepts leak into the internal domain model. The payment provider's field names appear in the core order model. Switching providers requires changing internal code because the internal model was never separated from the external one.
Good: Every external integration has an explicit translation layer at the boundary. Internal models reflect the domain, not external systems' idiosyncrasies. Switching providers means changing the translation layer, not the domain model.
Gravity: The first integration is done under time pressure. Passing the external model through is faster today. By the third integration, external concepts are entrenched throughout the codebase. Each subsequent integration adds more external pollution because the pattern is established.

**Domain gateways vs. direct cross-context coupling**
Bad: Every consumer of a domain calls multiple internal services directly, coupling to implementation details. Adding a new consumer requires understanding the internal service topology. Uber pre-DOMA: teams had to call 50+ services across 12 teams to investigate a single issue.
Good: Each domain exposes a single gateway that abstracts internal details. Consumers call one entry point. Internal service topology can change without affecting consumers. Uber post-DOMA: product teams call one gateway per domain.
Gravity: Gateways require upfront investment. When a domain has only one consumer, a gateway feels like over-engineering. But domains attract consumers over time, and each direct integration creates coupling that makes the gateway harder to introduce later.

**Context map with classified relationships vs. undocumented integration points**
Bad: Teams integrate ad hoc. Nobody has documented which contexts exist, how they relate, or who depends on whom. Power dynamics are implicit. When the upstream team changes their model, downstream teams discover it through broken builds.
Good: A context map documents every bounded context, every relationship between them (Partnership, Customer-Supplier, Conformist, ACL, etc.), and every translation mechanism. The map is a living document that guides integration decisions and is updated as the system evolves.
Gravity: Context mapping is a continuous discipline, not a one-time workshop. Teams under delivery pressure skip the map and integrate directly. The map becomes stale. Without the map, each team makes integration decisions locally, and the global picture degrades.

**Progressive boundary hardening vs. premature service extraction**
Bad: Domain boundaries are immediately reified as separate services with separate databases before the team is confident the boundaries are correct. A wrong service boundary costs a database migration, API versioning, and months of work. The team discovers the boundary is wrong after the commitment is irreversible.
Good: Domain boundaries start as modules within a single process, enforced by static analysis (Shopify's Packwerk, Google's BUILD visibility rules). The team observes change patterns, validates the boundaries through real development, and hardens them into services only when confident. Shopify's approach: prove the boundary in the monolith before paying the cost of distribution.
Gravity: The industry narrative favors microservices. Teams eager to adopt modern practices extract services before understanding their domain. The cost of a wrong boundary scales with boundary hardness: moving a module boundary costs an afternoon; moving a service boundary costs a quarter.

**Functional cohesion vs. entity-based decomposition**
Bad: Each major entity gets its own service (CustomerService, OrderService, ProductService). Every business operation orchestrates calls across multiple entity services. The services are thin CRUD wrappers; the actual business logic lives in a coordination layer or is duplicated across consumers. This is a distributed data model, not a domain decomposition.
Good: Modules are organized around business capabilities that group entities, rules, and processes that work together (Checkout, Fulfillment, Billing). Each module contains complete business logic and can execute most operations internally.
Gravity: Entities are the most obvious decomposition axis -- they have clear names and obvious data ownership. Decomposing by entity feels principled because it gives each entity a home. But business processes cross entity boundaries, and entity-based decomposition scatters the process logic.

**Separate models with explicit translation vs. single universal model**
Bad: One canonical model is used throughout the system -- in the API, in the database, in the events, in the internal logic. It must satisfy every consumer's needs, so it grows unbounded. Adding a field for one consumer's use case bloats the model for everyone. Stripe learned this: their Charge object grew from 11 properties to 36 as they tried to make one abstraction serve cards, ACH, Bitcoin, and iDEAL.
Good: Each context maintains a model tailored to its needs. Translation between models happens at defined boundaries. Adding a field in one context does not affect others. Stripe's resolution: PaymentMethod (the instrument) and PaymentIntent (the transaction) as separate concepts with clear boundaries.
Gravity: A universal model eliminates translation effort. It is the path of least resistance when the domain is simple. As the domain grows more complex, the universal model accumulates contradictions that no single representation can resolve.

**Domain events as business language vs. technical event plumbing**
Bad: Events are named after technical operations (DatabaseRowUpdated, CacheInvalidated). The domain is invisible in the event stream. Building a new business feature requires reverse-engineering which technical events correspond to which business occurrences.
Good: Events are named after domain occurrences (OrderPlaced, PaymentReceived, ShipmentDispatched). They are understandable to domain experts, carry business semantics, and naturally cluster around the bounded contexts they belong to.
Gravity: Technical events are easier to generate mechanically (change data capture, ORM hooks). Domain events require deliberate modeling -- someone must decide what constitutes a meaningful business occurrence. Under time pressure, teams default to technical events because they can be generated without domain understanding.

**Cognitive-load-appropriate context sizing vs. over/under-decomposition**
Bad (over): Dozens of micro-contexts, each too small to contain meaningful business logic. The team spends more time managing cross-context integration than building domain features. Kelsey Hightower's critique: "creating 50 deployables, but it's really a distributed monolith."
Bad (under): One massive context containing multiple unrelated subdomains. The team cannot reason about it coherently. Changes in one area unexpectedly break another because the model tries to serve too many purposes.
Good: Each context is large enough to contain a complete ubiquitous language for one business area and small enough for one team to own and reason about. The test: can a new team member become productive within this context without understanding the entire system?
Gravity: Over-decomposition comes from applying microservice enthusiasm to every boundary. Under-decomposition comes from avoiding the work of domain analysis. Both produce the same symptom: high coordination overhead. The difference is that over-decomposition distributes the overhead across the network, making it more expensive.

**Enforced boundaries vs. convention-only boundaries**
Bad: Domain boundaries exist as a shared understanding among the current team members but are not enforced by any tooling. New developers inadvertently violate boundaries. Code review catches some violations but not all. Over time, the boundaries erode. Shopify's retrospective: "static analysis alone is insufficient," but convention alone is worse.
Good: Boundaries are enforced by tooling -- static analysis (Packwerk, Packwerk for Ruby; ArchUnit for Java; BUILD visibility rules for Bazel), module systems (Rust's crate boundaries, Go's package visibility), or process boundaries (separate services). Violations are caught before merge.
Gravity: Enforcement requires upfront investment in tooling and process. The boundaries feel clear to the people who drew them, so enforcement seems unnecessary. But boundaries that can be violated will be violated, especially under delivery pressure.

---

## 5. Common Failure Modes

**Enterprise Model Unification**
Pattern: A single canonical model is mandated across the entire organization. An "Enterprise Data Model" committee maintains one definition of Customer, Order, Product, etc. Every system must conform.
Symptom: The model is so abstract it encodes almost no domain knowledge. Developers add fields with prefixes (billing_address, shipping_address, support_preferred_contact) because the single entity must serve every context. Meeting agendas are dominated by model change negotiations. New features are delayed by cross-team consensus requirements.
Root cause: The intuition that "one source of truth" means one model. But Evans's key insight: a model is a tool for solving problems within a specific context. The broader the scope, the more compromises it must make, until it becomes useless for any particular purpose.
Direction: Accept multiple models. Each bounded context maintains a model highly expressive for its needs. Invest in explicit translation between models at context boundaries rather than in consensus on a universal model.
Over-correction risk: So many distinct models that the system loses coherence entirely. Translation layers proliferate, each introducing latency and potential for semantic drift. There should be as many models as there are genuinely different conceptual vocabularies -- no more, no fewer.

**Technical-Layer Organization**
Pattern: The codebase is organized by technical layer (controllers/, services/, models/, repositories/, views/) rather than by domain concept. This is the default in most web frameworks.
Symptom: Every business feature touches every layer. A developer implementing "add gift wrapping to checkout" must modify files in controllers, services, models, and views, interleaved with files for completely unrelated features. The domain is invisible in the codebase. New developers navigate by technical concern, not by business concept.
Root cause: Frameworks encourage it (Rails, Spring MVC, Django all default to this layout). Tutorials teach it. It feels natural because it groups things by "what they are" (all controllers together). The problem only becomes apparent when the system has enough domain concepts that the layers become crowded.
Direction: Reorganize around domain concepts. Each domain module contains its own models, logic, and interfaces. Shopify's transformation: moved from Rails' conventional layout to 37 domain-organized components, each a mini-Rails app. The transition is a large effort but can be done incrementally.
Over-correction risk: Fragmenting truly shared infrastructure into domain modules where it does not belong. HTTP routing, database connection pooling, and logging are legitimately cross-cutting. They should remain in a shared infrastructure layer, not be duplicated per domain.

**Entity Service Decomposition**
Pattern: Services are created per major entity (CustomerService, OrderService, ProductService, PaymentService, InventoryService).
Symptom: Every business operation orchestrates calls across multiple entity services. A "place order" operation touches Customer, Order, Product, Inventory, and Payment. Latency compounds. Partial failures multiply. The actual business logic -- the rules governing how entities interact -- lives in an orchestration layer that has become the real monolith, or is duplicated across consumers. Nygard: entity services "look exactly like an outage to callers" when deployed, because they are on the critical path for nearly every request.
Root cause: Entities are the most obvious decomposition axis. Each entity has a clear name and obvious data ownership. It feels principled. But business processes cross entity boundaries, and this decomposition scatters the process logic across the network.
Direction: Organize around business capabilities (Checkout, Fulfillment, Billing) that group the entities, rules, and processes that work together. Each capability module can execute most operations internally, calling other modules only at genuine domain boundaries.
Over-correction risk: Making capability modules so large they become monoliths themselves. The test is whether the module contains one coherent ubiquitous language. If the language starts forking internally, the module is too large.

**Missing Anticorruption Layer**
Pattern: External systems' models propagate into the internal domain model. The codebase uses the external system's field names, data structures, and conceptual categories internally.
Symptom: Switching external providers requires internal model changes. Multiple external integrations produce a Frankenstein model with fields and states from different external systems that contradict each other. Microsoft's documentation: "the difficulty of relating the two models can eventually overwhelm the intent of the new model altogether."
Root cause: The first integration is done under time pressure. Mapping directly is faster. By the time the second or third integration arrives, the pattern is entrenched. Vernon: "Your domain model is your most valuable asset. Protect it."
Direction: Every external boundary gets an explicit anticorruption layer that translates between the external model and the internal domain model. The internal model reflects the domain, not external systems.
Over-correction risk: Over-translation that loses semantically important information. If the external model genuinely captures something the internal model needs, the translation should preserve it. Translate for domain clarity, not for purity.

**Shared Kernel Creep**
Pattern: A shared kernel between two bounded contexts starts small and focused but grows as teams add "just one more thing" to shared code rather than defining proper interfaces.
Symptom: The shared kernel contains a significant fraction of the total model. Changes to it require consensus from multiple teams. Deployment frequency decreases because shared kernel changes require cross-team coordination. Teams work around it by duplicating functionality locally.
Root cause: The shared kernel lacks governance. Without an explicit owner, explicit inclusion criteria, and automated size constraints, it becomes a dumping ground. Adding to the shared kernel is always locally cheaper than defining a proper interface.
Direction: Assign an explicit owner to the shared kernel. Define strict criteria for what belongs in it. Monitor its size. When it grows beyond a threshold, extract the growth into proper interfaces between contexts or split the kernel.
Over-correction risk: Eliminating all shared code, forcing redundant implementations of genuinely common concepts (currency types, date ranges, geographic regions). Some sharing is legitimate -- the question is whether the shared thing is a domain concept that legitimately means the same thing everywhere or a concept that is being forced into uniformity.

**Conway's Law Misalignment**
Pattern: The intended architecture defines domain boundaries that cut across the organizational structure. Teams organized by technical layer (frontend, backend, data) or by project (each project touches everything) rather than by domain.
Symptom: The architecture document says one thing; the code says another. Domain boundaries erode because no team owns them. Features that should be within one domain require cross-team coordination. The architecture drifts toward mirroring the org chart regardless of architectural intent. Colfer and Baldwin's meta-analysis: organizational structure predicted architectural structure in approximately 69% of cases studied.
Root cause: Organizational structure is harder to change than architecture. Restructuring teams has political, managerial, and personal costs. Teams naturally optimize for their own boundaries, and Conway's Law ensures the code follows.
Direction: Apply the Inverse Conway Maneuver: restructure teams to match the desired domain decomposition. If reorganization is not possible, at least ensure each domain has a clearly designated owner team, and invest in boundary enforcement tooling to resist the gravitational pull of the org chart.
Over-correction risk: Reorganizing teams too frequently, disrupting social cohesion and institutional knowledge. Team restructuring should follow domain understanding, not precede it. Reorganize when you are confident the domain boundaries are right, not as an experiment.

**DDD Cargo Culting**
Pattern: Teams apply DDD strategic patterns (bounded contexts, context maps, anticorruption layers) mechanically, without genuine domain understanding. Context boundaries are drawn in workshops and never revisited. The ubiquitous language is documented in a wiki nobody reads.
Symptom: The architecture has the vocabulary of DDD but none of the substance. Bounded contexts exist on paper but do not correspond to real linguistic boundaries. Anticorruption layers are empty pass-through wrappers. The context map is a static diagram that was drawn once and has been stale ever since. Plod's observation: "DDD is no silver bullet. Understanding this is more about DDD than blindly sticking to patterns because they were in a blue book."
Root cause: DDD is applied as a methodology rather than as a way of thinking about the domain. Teams skip the hard part (engaging with domain experts, understanding the problem) and jump to the patterns (drawing context maps, defining aggregates). The patterns without the domain understanding are empty.
Direction: DDD strategic design is continuous, not one-time. Context boundaries shift as the business evolves. The ubiquitous language must be actively maintained. The test: are domain experts genuinely involved in design decisions, or are the patterns being applied by developers in isolation?
Over-correction risk: Abandoning domain thinking entirely because "DDD didn't work." The failure mode is in the application, not the principle. The question "does the code structure reflect the problem domain?" remains the right question regardless of whether you call it DDD.

**Wrong Decomposition Axis**
Pattern: The system is decomposed along an axis that does not correspond to meaningful domain variation. Segment's 140+ microservices split by integration destination (one for Google Analytics, one for Mixpanel) when the actual variation was configuration, not behavior.
Symptom: Modules are structurally identical -- same code patterns, same error handling, same logic. Bug fixes must be applied N times. The "different modules" are really the same module parameterized differently.
Root cause: The decomposition axis was chosen based on surface-level differences (different API endpoints, different table names) rather than behavioral differences. The question "do these modules change for different reasons?" was not asked.
Direction: Merge structurally identical modules into one parameterized module. The axis of variation becomes configuration, not separate deployment units. Segment replaced 140+ services with one service driven by per-destination configuration.
Over-correction risk: Collapsing modules that have genuinely different behavior just because they look similar today. If the variations are truly independent and likely to diverge, separate modules are correct. The test: do these modules change for different reasons, or do they always change together in the same way?

**Premature Domain Decomposition**
Pattern: DDD strategic patterns are applied to systems with trivial domains. A small team builds an internal CRUD application and creates six bounded contexts, three anticorruption layers, and a context map for what is essentially a straightforward data management tool.
Symptom: More infrastructure code than domain code. More time spent on context boundary management than on solving business problems. The team feels slow without understanding why. DHH's "Majestic Monolith" argument: for products with moderate domain complexity and small teams, the overhead of domain decomposition infrastructure exceeds the cost of the problems it solves.
Root cause: Enthusiasm for architectural patterns without calibrating them to the problem's actual complexity. DDD strategic patterns have a cost (translation layers, boundary enforcement, context mapping discipline). That cost is justified when domain complexity is high, when multiple teams must coordinate, and when different parts of the system evolve independently. For simple domains, the cost exceeds the benefit.
Direction: Assess whether the domain actually warrants strategic DDD. Signs it does: multiple teams, distinct sub-domains with different vocabularies, integration with external systems, high domain complexity. Signs it does not: single team, uniform domain language, straightforward data management. Start with a well-organized monolith; introduce bounded contexts when the domain's linguistic boundaries become evident through actual development.
Over-correction risk: Avoiding domain analysis entirely because "we're too small for DDD." Even small systems benefit from asking whether the code structure reflects the problem domain. The question is whether the answer requires the full apparatus of context mapping and anticorruption layers or just thoughtful module organization.

---

## 6. Interactions With Other Frameworks

### Domain Alignment and Boundaries/Encapsulation (`boundaries-encapsulation.md`)

Bounded contexts are module boundaries derived from the problem domain rather than from technical decomposition. When boundaries align with domain concepts (checkout, inventory, payments), they tend to be deep (each domain concept hides substantial complexity behind a simple interface), responsibility-coherent (domain responsibilities cluster naturally), and substitutable (you can replace a domain module's implementation without changing consumers). When boundaries align with technical layers (models, services, controllers), they tend to be shallow, cut across domain concepts, and force every domain change to span multiple modules.

The specific intersection: Parnas asks "what is this module's secret?" For a domain-aligned module, the secret is a domain concept -- the rules governing checkout, the semantics of inventory. For a technically-layered module, the secret is a technical mechanism -- how to persist data, how to route requests. The latter secrets are shallower (less domain complexity hidden) and change for technical rather than business reasons.

Every boundary migration case study -- Shopify, Uber's DOMA, Segment's reconsolidation -- ends at domain-oriented boundaries. Technical-layer decomposition is the most common boundary mistake, reinforced by framework defaults and team specialization. When analyzing boundaries, check: are these boundaries drawn where the domain draws lines, or where the technology draws lines?

### Domain Alignment and Simplicity/Complexity (`simplicity-complexity.md`)

Domain misalignment is a primary source of accidental complexity. When the code structure does not match the problem structure, every business change requires mapping from "what the business needs" to "where this lives in the code" -- a translation that adds cognitive load without adding value. This translation effort is accidental complexity: it exists because of the solution's organization, not because of the problem's inherent difficulty.

Conversely, a well-aligned domain model is a deep module in Ousterhout's sense: it presents business operations through a simple interface (the ubiquitous language) while hiding substantial implementation complexity. A checkout module that accepts "place this order" and handles all the internal complexity of payment processing, inventory reservation, and tax calculation is deep. The same operations spread across a controller, three services, two repositories, and a tax utility are shallow -- the complexity is redistributed but not reduced.

The specific intersection to watch: over-application of DDD patterns producing accidental complexity. If the domain is simple but the architecture has anticorruption layers, event translation pipelines, and context mapping infrastructure, the architecture is more complex than the problem requires. Moseley and Marks' test applies: "Would this exist in the ideal world where we only had to specify what the user needs?"

### Domain Alignment and Data Flow/State (`data-flow-state.md`)

Domain ownership and data ownership must align. When a bounded context owns a business concept, it should own that concept's authoritative data -- the schema, the access patterns, the consistency guarantees. Amazon's API mandate addressed this directly: no shared databases between services, because shared databases destroy domain boundaries regardless of how clean the code-level interfaces are.

The natural data flow of a system should mirror the domain's natural information flow. When a customer places an order, information flows from the customer to the order system to the inventory system to the shipping system. If the technical data flow reverses this or adds unnecessary hops, the data flow is fighting the domain. Event-driven architectures align data flow with domain processes when events are named after business occurrences; they obscure the domain when events are named after technical operations.

The data mesh principle (Dehghani, 2019) extends domain alignment to analytical data: each domain team publishes its data as a product with SLAs and schemas. Cross-domain data access happens through defined interfaces, not through shared databases or centralized data lakes. This prevents analytical infrastructure from eroding the domain boundaries that transactional systems maintain.

### Domain Alignment and Dependency Flow (`dependency-flow.md`)

In most domains, some concepts are more fundamental than others: "Product" is more fundamental than "Cart," "Customer" is more fundamental than "Order." The dependency direction should mirror this conceptual hierarchy -- higher-level domain concepts (Order, Cart, Checkout) depend on lower-level ones (Product, Customer, Inventory), not the reverse. When the dependency graph contradicts the domain's natural hierarchy, it is a strong signal that either the dependency direction is wrong or the domain modeling is incomplete. A product catalog that depends on the checkout module suggests that checkout-specific concerns have leaked into the product model.

Conway's Law creates dependency through organizational coupling: if the team that owns module A reports to different leadership than the team that owns module B, a dependency from A to B creates cross-organizational coordination cost. Amazon weaponized this by structuring teams to own services with well-defined dependency directions, ensuring organizational and technical dependency structures align.

Uber's DOMA layer architecture directly constrains dependency direction by domain tier: infrastructure domains have no upward dependencies, business domains depend only on infrastructure, product domains depend on business and infrastructure, and presentation domains depend on product domains. This layering is a dependency rule derived from domain hierarchy.

### Domain Alignment and Change/Evolution (`change-evolution.md`)

Domain alignment determines change locality -- whether a business change lands in one place or scatters across the system. Shopify's primary heuristic for domain decomposition was "change locality": code that changes together for business reasons should live together. This is the domain-aligned restatement of cohesion: not "are these things related?" but "do these things change together because the same business concept evolved?"

Strategic DDD is continuous, not one-time. Context boundaries shift as the business evolves. A context map that was correct two years ago may be wrong today because the business has discovered new sub-domains, merged existing ones, or changed how it thinks about its own operations. The context map must be treated as a living document, and the architecture must be designed to accommodate boundary evolution.

Progressive boundary hardening (Shopify's approach) applies directly: start with soft domain boundaries (modules within a monolith, enforced by static analysis), observe which boundaries are stable and which need adjustment, and harden into services only when confident the boundary is right. The cost of wrong domain boundaries scales with boundary hardness. A wrong module boundary costs a refactoring sprint. A wrong service boundary costs a migration quarter.

---

## 7. Sources and Further Reading

**Eric Evans, "Domain-Driven Design: Tackling Complexity in the Heart of Software" (2003).** Read Part IV: Strategic Design (Chapters 14-17) most carefully. Chapter 14 (Maintaining Model Integrity) introduces bounded contexts and the context map. Chapter 15 details the relationship patterns (Shared Kernel, Customer-Supplier, Conformist, Anticorruption Layer, Open Host Service, Published Language, Separate Ways). Evans later stated that he wished he had emphasized strategic patterns more and tactical patterns less -- getting the boundaries right matters more than getting the building blocks right inside a wrongly-drawn boundary. The unique contribution no other source provides: a complete taxonomy of how bounded contexts relate to each other, grounded in power dynamics and team relationships, not just technical integration.

**Vaughn Vernon, "Implementing Domain-Driven Design" (2013).** Read Chapters 2-3 (Domains and Bounded Contexts) and Chapter 13 (Integrating Bounded Contexts). Vernon operationalizes Evans by providing concrete heuristics for identifying context boundaries through linguistic analysis and for sizing contexts relative to team capacity. His treatment of context mapping in practice -- how to classify existing relationships, identify pain points, and design target relationships -- is the most actionable guide available. His publicly stated position: "DDD is not about aggregates and invisible messaging. It's about language in a context."

**Melvin Conway, "How Do Committees Invent?" (Datamation, 1968).** The original argument, not the one-line summary. Conway proves that system structure mirrors organizational communication structure through an information-theoretic argument: design decisions require communication, and the organization's communication structure constrains which decisions can be made. The paper explains why this is a constraint (not a preference), why the number of modules tends to equal the number of groups, and why fixing the design without fixing the organization produces a new design that also mirrors the organization. Read alongside the Nagappan et al. empirical validation.

**Matthew Skelton & Manuel Pais, "Team Topologies" (2019).** The most practical operationalization of the Inverse Conway Maneuver. Read for the four team types (stream-aligned, enabling, complicated subsystem, platform), the three interaction modes (collaboration, X-as-a-Service, facilitating), and the cognitive load heuristic for sizing team and domain boundaries. The unique contribution: cognitive load as the primary constraint on domain boundary placement -- a team can only effectively own a domain that fits within its collective cognitive capacity. Their "fracture planes" (business domain, regulatory compliance, change cadence, team location, technology, user persona, risk) provide a practical checklist for where to split when domain analysis alone is ambiguous.

**Nagappan, Murphy & Basili, "The Influence of Organizational Structure on Software Quality" (ICSE, 2008).** The most rigorous quantitative validation of Conway's Law. Studied Windows Vista development and found that organizational metrics (number of engineers, organizational distance, ownership concentration) predicted defect-prone components with ~86% precision -- significantly better than code metrics including complexity, churn, and test coverage. The unique contribution: empirical proof that the organizational structure around the code matters more than the code's internal qualities, directly supporting the argument that domain alignment requires organizational alignment.

**Shopify Engineering Blog: "Deconstructing the Monolith" (2019), "Under Deconstruction" (2020), "Enforcing Modularity with Packwerk" (2020), "A Packwerk Retrospective" (2024).** Read as a series documenting the most thoroughly published modular monolith transformation guided by DDD strategic design. The retrospective is especially valuable: it documents what failed (semantic grouping was misleading, privacy checks confused developers, static analysis alone was insufficient, utopian vision vs. reality) alongside what succeeded (change locality as primary heuristic, functional over informational cohesion, runtime verification via Wedge). The most honest published account of applying DDD strategic patterns at scale.

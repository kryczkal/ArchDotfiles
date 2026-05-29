# Change and Evolution: Reasoning Framework

**Source canon:** Ford, Parsons & Kua "Building Evolutionary Architectures" (2017/2023) for fitness functions and evolutionary design; Feathers "Working Effectively with Legacy Code" (2004) for seams and changeability; Parnas "On the Criteria To Be Used in Decomposing Systems into Modules" (1972) for information hiding as change management; Martin "Clean Architecture" for stability metrics and the dependency rule; Hohpe "The Software Architect Elevator" for architecture as options.
**Applies when:** You need to evaluate whether a system can absorb future change without disproportionate cost, or when structural decisions are being made that will constrain or enable future evolution.

## 1. What This Framework Addresses

This framework analyzes a system's readiness for change that has not yet arrived. The other architecture frameworks analyze current structural state: how boundaries are drawn, how data flows, how dependencies point, how complexity is distributed, how the domain is modeled. This framework asks: given that structure, what happens when the requirements shift?

Reach for this when you see: teams afraid to touch certain areas of the codebase; single-feature changes requiring coordinated modifications across many modules; deployment coupling forcing unrelated changes to ship together; architectural decisions made years ago that now constrain every new feature; or conversations about "the big rewrite." These are symptoms of a system that was not designed for the changes it actually experienced.

This framework cannot tell you WHAT will change — that requires product and domain knowledge. It can tell you WHERE change will be expensive, which structural properties make change cheap or costly, and whether the system's current architecture is investing in flexibility where it matters or where it does not.

## 2. Core Reasoning Procedure

### Step 1: Map the axes of likely change

Identify the dimensions along which this system is most likely to evolve. Sources of change include: new product requirements, scaling demands, third-party integrations, regulatory shifts, team growth, infrastructure migration, and competitive pressure. For each axis, ask: how confident are we that change will come here? How soon? How large?

This step requires product context. Without it, you are guessing — and the central lesson of evolutionary design is that guessing poorly is worse than not guessing at all. If you lack product knowledge, shift to Step 2 and evaluate general changeability instead of axis-specific readiness.

### Step 2: For each module boundary, identify its "secret"

Apply Parnas's procedure: every module should hide exactly one design decision — its secret — that might change. Articulate each module's secret in one sentence. If you cannot, the module lacks a coherent reason to exist as a separate unit. If two modules share the same secret, they are coupled regardless of what the import graph shows, because a change to that decision forces changes in both.

Common secrets worth hiding: storage format, communication protocol, external service API, business rule, algorithm choice, UI presentation logic, data validation policy. The quality of a decomposition is measured by how many likely changes are contained within a single module boundary.

### Step 3: Trace the blast radius of representative changes

Select 3-5 changes representative of recent or anticipated evolution. For each, trace which modules would need modification. Count the modules touched. If a single logical change touches more than 2-3 modules, the boundaries are not aligned with the axes of change. This is Fowler's "shotgun surgery" at the architectural level.

Pay attention to the type of modules touched. Changes that cross the boundary between stable (high fan-in) and unstable (low fan-in) components are especially costly, because stable components carry high regression risk.

### Step 4: Identify seams and their enabling points

Apply Feathers' seam analysis: for each module boundary, ask "can behavior be altered here without editing the code on either side?" A seam exists when behavior can be changed through substitution — swapping an implementation, redirecting a route, changing configuration — rather than modification. The enabling point is where the substitution decision is made (a constructor parameter, a configuration file, an API gateway rule, a dependency injection container).

Modules without seams at their boundaries are structurally welded to their collaborators. Change in one propagates to the other by necessity. Count the seams. Map the enabling points. Areas with few seams and no enabling points are the system's brittleness hotspots.

### Step 5: Evaluate coupling across quantum boundaries

Identify the system's architectural quanta — independently deployable units with high functional cohesion. Within a quantum, tight coupling is acceptable (components deploy together). Across quanta, evaluate the coupling type using the connascence taxonomy. Static connascence of name or type across boundaries is manageable. Dynamic connascence (execution order, timing, values, identity) across boundaries is hostile to independent evolution because it creates invisible runtime dependencies that make independent deployment dangerous.

The critical question: can each quantum be deployed independently, or do deployments require lockstep coordination with other quanta? Deployment coupling is the ground truth of evolvability — it does not matter how clean the module boundaries look if everything must ship together.

### Step 6: Assess fitness function coverage

Determine whether the architectural properties that matter are protected by automated verification. A fitness function is any automated check that validates an architectural characteristic — a dependency rule enforced in CI, a performance benchmark in the pipeline, a contract test between services, a complexity threshold that fails the build.

Classify existing fitness functions along Ford's taxonomy to identify coverage gaps: Are they atomic (testing one characteristic) or holistic (testing interacting characteristics — e.g., security AND performance, since caching for performance may weaken security)? Are they triggered (running on commit/deploy) or continuous (running in production, like chaos engineering or runtime monitoring)? Are they static (fixed thresholds) or dynamic (targets that evolve as the system scales)? A system with only triggered atomic fitness functions has no protection against emergent cross-cutting regressions or production-only degradation.

For each identified axis of likely change (Step 1), ask: if a developer makes a change along this axis, will any automated check catch an architectural regression? Unprotected axes are where evolution will silently degrade the architecture. The shift from "architects review changes" to "fitness functions catch regressions" is the shift from governance-by-inspection to governance-by-rule.

### Step 7: Assess migration readiness

Evaluate whether the system has the prerequisites for incremental replacement when evolution is insufficient and components need to be replaced. Feathers' characterization tests are the key diagnostic: does the team have tests that capture what the system actually does (not what it should do) at its key boundaries? These behavioral contracts are the prerequisite for strangler fig migration, branch-by-abstraction, and parallel implementation strategies. Without characterization tests, replacement is guesswork — you do not know what the old system does, so you cannot verify the new system does the same thing.

Also assess whether seams exist at the boundaries where replacement would occur. A system that is called through direct function invocation with no indirection offers no strangling opportunity. A system behind an API, a message queue, or an interface boundary can be incrementally replaced.

### Step 8: Evaluate the prediction-vs-flexibility investment

Assess whether the system's flexibility investments match actual change patterns. Two failure modes exist: under-investment (no seams, no abstractions, brittle coupling — the system resists all change) and over-investment (excessive abstraction, speculative generality, configuration options for changes that never came). Mine version control history for evidence: which areas actually changed frequently? Do those areas have the most flexibility? Areas of high churn with low flexibility are underserved. Areas of low churn with high abstraction are over-engineered.

After completing these steps, you should be able to articulate: where change will be cheap, where it will be expensive, which boundaries are aligned with likely change axes, which coupling patterns block independent evolution, and whether the system's flexibility investments are well-placed or misallocated.

## 3. Diagnostic Questions

**Q1: Can you articulate each module's "secret" — the single design decision it hides?**
Healthy: Every module hides one clearly identifiable decision (storage format, business rule, external API).
Unhealthy: Modules organized by technical layer (controller, service, repository) rather than by decision — secrets are spread across layers, so a single decision change touches all three.

**Q2: For the last 5 significant features shipped, how many modules did each touch?**
Healthy: Most features touched 1-2 modules; the boundaries absorbed the change.
Unhealthy: Features routinely touched 5+ modules across the system — boundaries do not align with change axes.

**Q3: Can each deployable unit ship independently, without coordinating with other units?**
Healthy: Teams deploy on their own schedule; other teams are unaffected.
Unhealthy: "Deploy trains" or lockstep releases where multiple components must ship together.

**Q4: Where are the seams? Can you substitute behavior at module boundaries without editing code on either side?**
Healthy: Key boundaries have explicit enabling points (interfaces, configuration, routing).
Unhealthy: Modules are welded together through concrete dependencies, shared data structures, or direct database access.

**Q5: What coupling crosses quantum boundaries, and what type is it?**
Healthy: Cross-boundary coupling is limited to static connascence (name, type) via well-defined APIs.
Unhealthy: Dynamic connascence (execution order, timing, shared mutable state) crosses boundaries, creating invisible runtime dependencies.

**Q6: Which architectural properties are protected by automated fitness functions?**
Healthy: Dependency direction, performance thresholds, API compatibility, and complexity limits are enforced in CI.
Unhealthy: Architectural rules exist only in documentation or developers' heads; nothing catches violations automatically.

**Q7: Do the areas of highest code churn have the most structural flexibility?**
Healthy: Frequently-changed areas are behind clean interfaces with good seam coverage and high test coverage.
Unhealthy: The most volatile areas are also the most coupled and least tested — the highest-risk code gets the least structural protection.

**Q8: If a key third-party dependency changed its API tomorrow, how many modules would need modification?**
Healthy: External dependencies are wrapped behind anticorruption layers; only the wrapper changes.
Unhealthy: Third-party types, exceptions, and conventions leak throughout the codebase.

**Q9: Can the database schema evolve without requiring synchronized application deployments?**
Healthy: Schema changes use expand/contract (parallel change) — new structure is added, data migrated, old structure removed after all consumers have moved.
Unhealthy: Schema changes require downtime or lockstep deployment of all consuming applications.

**Q10: Are the system's stable components (high fan-in) abstract, or are they concrete?**
Healthy: Heavily-depended-upon modules are interfaces and contracts; concrete implementations are in unstable (low fan-in) modules.
Unhealthy: Concrete utility classes or data structures sit at the center of the dependency graph — any change to them ripples everywhere.

**Q11: How long does it take a new team member to make a meaningful change safely?**
Healthy: Clear boundaries, good test coverage, and well-placed seams mean a developer can change one module without understanding the whole system.
Unhealthy: Making any change requires understanding a web of implicit dependencies, shared state, and undocumented coupling.

**Q12: Do files that change together in version control correspond to intentional module groupings?**
Healthy: Co-changing files are in the same module — temporal coupling matches structural coupling.
Unhealthy: Files in different modules consistently change together, revealing hidden coupling that the architecture does not acknowledge.

**Q13: Has the system ever undergone a successful incremental migration (strangler fig, branch by abstraction)?**
Healthy: The team has experience with and infrastructure for incremental replacement.
Unhealthy: Every past change was either a small patch or a big-bang rewrite — no middle ground exists.

**Q14: Where are the system's "zones of pain" — stable, concrete components?**
Healthy: Few or none; stable components are abstract, unstable components are concrete.
Unhealthy: Core libraries or shared data models are both heavily depended upon and full of implementation detail.

**Q15: Does the team distinguish between "adding behavior" and "restructuring for changeability"?**
Healthy: Refactoring is a recognized, regular activity with its own commits; the team consciously switches between feature work and structural improvement.
Unhealthy: All changes mix feature additions with structural modifications; refactoring only happens during designated "tech debt sprints" or never.

**Q16: Are feature flags and configuration used to enable incremental rollout, or have they accumulated into unmanaged complexity?**
Healthy: Short-lived release toggles are cleaned up within days of full rollout; long-lived toggles are inventoried and owned.
Unhealthy: Hundreds of toggles, many undocumented, some controlling critical behavior, some dating back years.

**Q17: What is the recovery path if a deployment goes wrong? Does it depend on the same infrastructure it is recovering?**
Healthy: Rollback mechanisms have independent dependency chains from the systems they recover.
Unhealthy: Recovery tools depend on the broken system (Meta 2021 outage pattern — DNS, auth, and remote access all depended on the failed network).

**Q18: Is the decomposition aligned with business domain boundaries or technical layers?**
Healthy: Services/modules correspond to business capabilities; a business change is contained within one boundary.
Unhealthy: Decomposition follows technical layers (UI, logic, data) so every business change cuts across all layers.

**Q19: Does the team have characterization tests that capture what the system actually does at its key boundaries?**
Healthy: Critical system behaviors are documented in tests derived from observing actual behavior — these serve as migration contracts when components need replacement.
Unhealthy: Tests only cover intended behavior; actual behavior at boundaries (including accidental but load-bearing behavior) is unknown and unverified.

**Q20: Is there a known, practiced mechanism for incremental migration (strangler fig, branch by abstraction, expand/contract)?**
Healthy: The team has successfully used incremental replacement patterns before and has the tooling to do it again.
Unhealthy: The only options when a component needs replacing are "small patch" or "rewrite from scratch."

## 4. What Good Looks Like vs What Bad Looks Like

**1. Boundary alignment**
Bad: Module boundaries follow technical layers. Adding a new field to a business entity requires changing the API layer, the service layer, the data layer, and the database. Each layer is owned by a different part of the codebase or team.
Good: Module boundaries follow business domains. A new field is added within a single bounded context — one module, one team, one deployment.
Gravity: Technical layering is the default decomposition taught in most curricula and frameworks. It feels clean because each layer has a clear technical purpose. The problem only manifests when real business changes consistently cut across all layers.

**2. Seam distribution**
Bad: The system has no substitution points. Every dependency is a concrete class instantiated inline. Testing requires the full stack. Changing any component requires editing its callers.
Good: Key boundaries have seams with explicit enabling points. Dependencies are injected, external systems are wrapped, behavior can be substituted for testing and incremental migration.
Gravity: Seams add indirection, which adds cognitive cost. Under deadline pressure, the direct call is faster to write. Each skipped seam is locally rational.

**3. Stability-abstractness alignment**
Bad: The most depended-upon components are concrete implementations — a shared data model class, a utility library full of implementation detail. Changing them risks breaking everything that depends on them.
Good: High-fan-in components are abstractions (interfaces, contracts, protocols). Their implementations live in low-fan-in modules where change is cheap.
Gravity: Abstractions require upfront design effort and feel like over-engineering for simple cases. Concrete shared code is immediately useful and easy to create.

**4. Deployment independence**
Bad: All services must be deployed together in a specific order. A "deploy train" runs weekly, batching changes from multiple teams. One team's broken change blocks everyone.
Good: Each architectural quantum deploys independently on its own schedule. Other quanta are unaffected.
Gravity: Independent deployment requires investment in API versioning, backward compatibility, contract testing, and schema migration tooling. Coupling is cheaper in the short term.

**5. Change-frequency-aware investment**
Bad: Flexibility is distributed uniformly — everything has the same level of abstraction regardless of change frequency. Or worse: the most volatile areas have the least protection because they were built under the most time pressure.
Good: Areas of high churn have clean interfaces, good test coverage, and well-placed seams. Stable areas are kept simple — no speculative abstraction.
Gravity: Uniform investment feels "fair" and "consistent." Targeted investment requires analyzing change patterns, which few teams do systematically.

**6. External dependency isolation**
Bad: Third-party library types appear in domain logic, API responses, and database schemas. Upgrading or replacing a dependency requires system-wide changes.
Good: External dependencies are wrapped behind internal abstractions. Only the wrapper knows about the third-party API. Migration means rewriting one wrapper.
Gravity: Wrapping feels like unnecessary indirection when the dependency seems permanent. But dependencies change — vendors pivot, licenses change, better alternatives emerge.

**7. Schema evolution capability**
Bad: Database changes require application downtime or lockstep deployment. Schema and application are tightly coupled; adding a column requires a synchronized release.
Good: Schema changes use expand/contract patterns. New and old schemas coexist during migration. Applications are tolerant of unknown fields.
Gravity: Expand/contract is more work than "just change the schema." It requires migration tooling, versioning discipline, and acceptance of temporary redundancy.

**8. Fitness function governance**
Bad: Architectural rules are documented in a wiki nobody reads. Violations are caught in code review if the reviewer happens to know the rule. Enforcement is inconsistent.
Good: Architectural constraints are expressed as automated checks in the build pipeline. Dependency direction, complexity thresholds, API compatibility, and performance benchmarks are verified on every commit.
Gravity: Writing fitness functions requires tooling investment and agreement on what matters. Manual review is free to start.

**9. Incremental migration infrastructure**
Bad: The only options for architectural change are "small patch" or "big rewrite." No mechanisms exist for gradual replacement — no feature flags, no traffic routing, no branch-by-abstraction patterns.
Good: The system has proven patterns for incremental migration: strangler fig routing, parallel implementations with consistency verification, branch-by-abstraction for internal changes.
Gravity: Migration infrastructure has no immediate feature value. It only pays off when migration is needed — which feels hypothetical until it is urgent.

**10. Temporal coupling awareness**
Bad: The team is unaware of which files change together. Hidden coupling exists between modules that look independent in the dependency graph but always require coordinated changes.
Good: The team periodically analyzes co-change patterns from version control and uses them to inform boundary placement. Modules that always change together are candidates for merging; modules that never interact are candidates for separation.
Gravity: Co-change analysis requires tooling and discipline. Most teams only notice temporal coupling when a change breaks something unexpected.

**11. Recovery independence**
Bad: The tools needed to fix the system depend on the system itself. When the system fails, the recovery path fails with it.
Good: Recovery mechanisms (rollback, failover, configuration management) have independent dependency chains and can function when the primary system is down.
Gravity: Building independent recovery paths means duplicating some infrastructure, which feels wasteful during normal operation.

## 5. Common Failure Modes

**1. Shotgun surgery architecture**
Pattern: A single business change requires modifications in 5+ modules across the system.
Symptom: Features take weeks instead of days. Developers describe the system as "everything is connected to everything."
Root cause: Boundaries were drawn along technical layers or arbitrary lines rather than along axes of business change.
Direction: Re-draw boundaries around business capabilities so that the most common changes are contained within a single boundary.
Over-correction risk: Boundaries drawn too tightly around current change patterns become rigid when change patterns shift. Leave room for boundary evolution.

**2. The distributed monolith**
Pattern: Separately deployed services that cannot actually change or deploy independently due to shared databases, synchronous call chains, or shared libraries with behavioral coupling.
Symptom: "We have microservices but still need deploy trains." All the operational cost of distribution with none of the evolutionary benefit.
Root cause: Decomposition followed technical convenience or org chart rather than analyzing actual coupling and change patterns.
Direction: Identify the true architectural quanta — groups of components that must deploy together — and treat those as the real units. Harden boundaries only between genuine quanta.
Over-correction risk: Merging everything back into a monolith may discard legitimate isolation gains. Evaluate which boundaries are actually load-bearing before removing them.

**3. Speculative generality**
Pattern: Elaborate abstraction layers, configuration systems, and extension points for changes that never materialized. Five adapter implementations where only one is used.
Symptom: New developers struggle to understand the system. Simple changes require navigating multiple layers of indirection. The codebase is larger and more complex than its functionality warrants.
Root cause: Upfront design that predicted future requirements instead of designing for general changeability. The prediction was wrong, but the abstractions remain.
Direction: Remove unused abstraction layers. Simplify to what is actually needed. Invest in changeability (clean code, good tests, seams at real boundaries) rather than flexibility (abstractions for anticipated but unrealized variation).
Over-correction risk: Stripping all abstraction produces concrete, tightly-coupled code that resists even the changes that DO arrive. The goal is well-placed seams, not no seams.

**4. The vendor cage**
Pattern: A third-party product (framework, platform, ERP, CMS) sits at the center of the architecture. Business logic is expressed in the vendor's idioms. The vendor's data model IS the system's data model.
Symptom: The team cannot upgrade the vendor without a major project. Business requirements that do not fit the vendor's model require grotesque workarounds. The vendor's roadmap constrains the product's roadmap.
Root cause: Early adoption without anticorruption layers. The vendor was convenient, so domain logic grew directly inside it.
Direction: Gradually introduce anticorruption layers between domain logic and vendor integration. Extract business rules into domain modules that do not depend on vendor types.
Over-correction risk: Wrapping everything in abstraction layers turns the codebase into a Russian doll. Only wrap the boundaries where vendor coupling actually constrains evolution.

**5. Dead code as land mines**
Pattern: Deprecated code paths remain in the codebase, controlled by feature flags, configuration, or dead branches. Nobody knows whether they are truly dead.
Symptom: Knight Capital's $440M loss — a dormant code path reactivated by a reused flag. More commonly: developers are afraid to delete anything because they cannot verify it is unused.
Root cause: No process for removing code when features are deactivated. Feature flags accumulate without cleanup.
Direction: Treat feature flag cleanup as a required step in the feature lifecycle. Use runtime monitoring to verify code paths are genuinely unused before removal.
Over-correction risk: Aggressive deletion without verification can remove code that IS used in edge cases, rare configurations, or disaster recovery paths. Verify before deleting.

**6. Fossilized data architecture**
Pattern: The technical architecture evolves (new services, new frameworks, new deployment patterns) but the data architecture remains frozen. A single shared database with a schema designed years ago constrains every service.
Symptom: Data model changes require coordinating across all consuming services. The schema contains columns and tables that nobody understands but nobody dares remove.
Root cause: Data architecture evolution is harder than application architecture evolution — data is persistent, stateful, and often the source of truth. Teams avoid touching it.
Direction: Invest in schema migration tooling, expand/contract patterns, and data ownership boundaries. Each service should own its data.
Over-correction risk: Splitting data too aggressively creates distributed data management problems (consistency, joins, transactions) that are harder than the original coupling.

**7. Test-induced rigidity**
Pattern: An extensive test suite that is tightly coupled to implementation details rather than behavior. Every internal refactoring breaks hundreds of tests.
Symptom: Developers avoid refactoring because the test maintenance cost is prohibitive. The tests protect against change rather than enabling it.
Root cause: Tests written against internal structure (mocking internal collaborators, asserting implementation details) rather than against observable behavior at module boundaries.
Direction: Rewrite tests at the boundary level — test module behavior through its public interface. Delete tests that assert implementation details.
Over-correction risk: Testing only at the highest level (end-to-end) produces slow, flaky tests that provide poor change localization. Test at the module boundary — the narrowest public interface.

**8. Cargo-cult fitness functions**
Pattern: Automated architectural checks exist but do not protect anything that actually matters. Complexity thresholds set so high they never trigger. Dependency rules that codify the current structure rather than the desired structure.
Symptom: The fitness function suite passes on every build, including builds that introduce architectural violations. The checks create a false sense of security.
Root cause: Fitness functions were added as a checkbox exercise rather than derived from actual architectural concerns. Nobody tuned them or reviewed what they catch.
Direction: Derive fitness functions from actual architectural risks. Set thresholds based on what you are willing to tolerate, not what currently exists. Review fitness function effectiveness periodically.
Over-correction risk: Overly strict fitness functions that fail on every build train developers to work around them or request exceptions, undermining the governance model.

**9. Rewrite addiction**
Pattern: When a system becomes difficult to change, the team proposes a complete rewrite rather than incremental improvement. The rewrite takes longer than expected. The old system continues to evolve during the rewrite. The rewrite is eventually abandoned or delivers a subset of the original functionality.
Symptom: The team has attempted one or more rewrites that did not fully replace the original system. Parallel systems coexist indefinitely.
Root cause: Incremental migration is harder and less exciting than a fresh start. The team conflates "hard to understand" with "needs replacement" and underestimates the accumulated knowledge embedded in the existing code.
Direction: Build strangler fig capability — the ability to incrementally replace components behind stable interfaces. Invest in characterization tests that capture existing behavior as a migration contract.
Over-correction risk: Never rewriting means living with fundamental structural problems forever. Some architectures genuinely cannot be incrementally evolved — but this is rarer than teams believe.

## 6. Interactions With Other Frameworks

### With boundaries-encapsulation
Change-evolution and boundaries-encapsulation are deeply intertwined because Parnas's criterion for drawing boundaries IS anticipated change. A boundary analysis that finds well-drawn boundaries with clear encapsulation does not guarantee evolvability — the boundaries may be well-drawn for a set of changes that no longer represents reality. Conversely, a change analysis that identifies poor evolvability almost always traces back to boundary problems: secrets leaking across boundaries, boundaries drawn along the wrong axes, or missing boundaries where change isolation is needed. When analyzing boundaries, always ask "what change does this boundary enable?" When analyzing evolvability, always ask "which boundary is failing to contain this change?"

### With simplicity-complexity
Over-engineering for change is one of the primary sources of accidental complexity. Every abstraction layer, extension point, and configuration option added "in case we need it" increases complexity without delivering value until the anticipated change actually arrives. The simplicity framework helps calibrate how much evolutionary flexibility to build in: enough to handle likely changes, not so much that the system collapses under the weight of its own flexibility. Conversely, excessive simplification — removing all abstraction in pursuit of directness — destroys seams and makes the system brittle. The tension between simplicity and evolvability is real and must be managed, not resolved in favor of either extreme.

### With data-flow-state
Data architecture is where evolvability most often fails in practice. Teams evolve their application architecture (new services, new modules) while the data architecture remains frozen because data is stateful, persistent, and shared. The data-flow-state framework reveals how data moves and transforms; the change-evolution framework asks whether those flows can be modified independently. Shared mutable state across module boundaries is the most potent evolvability killer because it creates coupling that is invisible in the code structure but absolute in practice — you cannot change how one module stores data without considering every other module that reads it.

### With dependency-flow
Martin's stability metrics directly serve change analysis: dependencies should point toward stability, and stable components should be abstract. The dependency-flow framework maps the current direction of dependencies; the change-evolution framework asks whether that direction enables or constrains future change. An inverted dependency — a stable component depending on a volatile one — is both a dependency-flow problem (wrong direction) and a change-evolution problem (the stable component has inherited the volatility of its dependency). Fixing one fixes both, but the diagnostic lens is different: dependency-flow sees a structural anomaly; change-evolution sees a future maintenance cost.

### With domain-alignment
Conway's Law makes domain alignment an organizational constraint on evolvability. If team boundaries do not match domain boundaries, and domain boundaries do not match change axes, then every change requires cross-team coordination — a force that slows evolution to the speed of the slowest coordination mechanism. The domain-alignment framework evaluates whether the system's structure reflects its business domain; the change-evolution framework evaluates whether that alignment enables independent evolution of business capabilities. The "inverse Conway maneuver" — restructuring teams to drive architectural change — is the intersection point: you change the organization to change the architecture to change the evolvability.

A critical nuance: domain boundaries that are well-aligned TODAY may not be aligned with TOMORROW'S change patterns. Business domains evolve. The domain-alignment framework analyzes current fit; the change-evolution framework should stress-test whether that alignment will hold as the business shifts. Uber's DOMA migration is instructive — their original service boundaries aligned with business domains, but as those domains evolved and cross-cutting concerns emerged, the alignment broke down and required re-architecture.

### A note on the prediction tension

The sources for this framework divide on a fundamental question: should you predict what will change and design for it (Parnas, Martin), or should you avoid prediction and design for general changeability instead (Beck, Fowler)? The industry evidence — Google, Amazon, Shopify, Netflix — favors the latter strategy at the system level: invest more in making change cheap everywhere than in predicting specific changes. But Parnas's procedure remains indispensable for the specific act of deciding where a module boundary goes. The resolution: use Parnas to draw boundaries (you must predict SOMETHING to have modules at all), but use Beck's approach for everything behind those boundaries (keep the code clean, well-tested, and refactorable rather than building elaborate abstractions for anticipated variation).

## 7. Sources and Further Reading

**Ford, Parsons & Kua, "Building Evolutionary Architectures" (2nd ed, 2023)**
Chapters 2-4 (fitness functions, architectural quanta, automated governance) are the essential contribution. The fitness function taxonomy and the concept of the architectural quantum as the unit of evolution are the book's unique offerings. The 2nd edition adds significant material on automated governance. The practical application is in the Fitness Function Katas at evolutionaryarchitecture.com/ffkatas/.

**Feathers, "Working Effectively with Legacy Code" (2004)**
Chapters 4 (seam model) and 24 (when you feel overwhelmed) are the most architecturally relevant. The seam concept — a place where behavior can be altered without editing — is the operational primitive for evaluating changeability. The dependency-breaking techniques catalog (Part III) provides the structural moves for introducing seams. Feathers' later work on churn analysis (change-frequency data from version control) extends the framework into empirical territory.

**Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules" (1972)**
The entire 8-page paper is essential and should be read in full. The KWIC index example and the concept of "secrets" — each module hides one design decision that might change — remain the most precise reasoning procedure for deciding where to draw module boundaries. Every subsequent treatment of information hiding derives from this paper.

**Martin, "Clean Architecture" (2017), Chapters 13-14**
The stability metrics (Instability, Abstractness, the Main Sequence) and the Stable Dependencies and Stable Abstractions Principles provide the quantitative framework for evaluating whether a dependency structure supports or hinders change. The zone-of-pain concept (stable + concrete = painful to change) is an immediately applicable diagnostic.

**Hohpe, "The Software Architect Elevator" (2020)**
Chapter on "architects sell options" reframes architectural decisions as investments in future flexibility with quantifiable cost and probabilistic value. This economic framing helps calibrate how much to invest in evolvability for any given decision — proportional to the probability and cost of future change.

**Fowler, "Refactoring" (2nd ed, 2018)**
The design stamina hypothesis (Chapter 2) provides the economic argument for continuous design investment. The code smell catalog is essentially a catalog of change-resistance patterns, each pointing to a specific structural problem that impedes evolution.

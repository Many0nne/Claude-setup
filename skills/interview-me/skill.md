---
name: interview-me
description: |
  Deep-dive interview process for plan, PRD, or spec files. Use when user invokes "/interview-me [filename]" where filename is a plan.md, prd.md, specs.md, or spec.md file. Reads the document and conducts an exhaustive, non-obvious interview covering 17 domains: technical implementation, security, legal, reliability, UI/UX, business strategy, risks, edge cases, testing/QA, documentation, analytics, migration, cost/budget, rollout strategy, vendors/dependencies, maintenance, and stakeholder communication. Continues interviewing until all aspects are thoroughly explored, then writes the refined plan back to the file.
---

# Interview-Me Skill

Conduct exhaustive interviews on plan/PRD/spec documents to surface hidden assumptions, risks, and opportunities.

## Mandatory Preflight

Before starting the interview questions, always run these two preflight passes:

1. search-first pass
- Detect what already exists before proposing new implementation.
- Check existing libraries, frameworks, internal patterns, and skills relevant to the document.
- Record a short Adopt / Extend / Build recommendation with rationale.

2. api-design pass (when APIs are in scope)
- Validate resource naming, HTTP status semantics, error format, pagination, filtering, versioning, auth, and rate limiting.
- Record contract risks and missing API decisions.

Preflight output must be included at the top of the interview notes under:
- Existing solutions and reuse opportunities
- API contract risks and missing decisions

## Process

1. **Read the document** passed as argument
2. **Run mandatory preflight** (search-first, then api-design if applicable)
3. **Analyze** for gaps, assumptions, and areas needing clarification
4. **Interview systematically** using AskUserQuestion tool, covering ALL domains below
5. **Continue iteratively** until no more questions remain
6. **Write the refined document** back to the file with all gathered insights

## Interview Domains (MUST cover all)

### Technical Implementation
- Architecture decisions and alternatives considered
- Technology stack justification and lock-in risks
- Data model completeness and migration strategy
- API design, versioning, backwards compatibility
- Integration points and failure isolation
- Performance requirements and benchmarks
- Caching strategy and invalidation
- Database choice, sharding, replication needs

### Security & Privacy
- Authentication/authorization model
- Data encryption (at rest, in transit)
- PII handling and data retention policies
- Audit logging requirements
- Penetration testing plans
- Third-party security dependencies
- Incident response procedures

### Legal & Compliance
- GDPR, CCPA, industry-specific regulations
- Terms of service implications
- Liability and indemnification
- Intellectual property concerns
- Data processing agreements needed
- Export control considerations

### Reliability & Operations
- SLA targets and consequences
- Disaster recovery and RTO/RPO
- Monitoring and alerting strategy
- On-call and escalation procedures
- Capacity planning methodology
- Graceful degradation approach
- Rollback procedures

### UI/UX
- User research conducted or planned
- Accessibility requirements (WCAG level)
- Internationalization needs
- Offline/poor connectivity handling
- Error messaging strategy
- Onboarding flow for new users
- Power user vs. novice considerations

### Business & Strategy
- Success metrics and how measured
- Competitive differentiation
- Pricing model and unit economics
- Customer acquisition strategy
- Churn risk factors
- Partnership dependencies
- Market timing considerations

### Risk & Tradeoffs
- What's explicitly NOT in scope and why
- Technical debt being accepted
- Shortcuts taken and payback plan
- Single points of failure
- Vendor lock-in accepted
- Skills gaps on the team
- Timeline pressure tradeoffs

### Edge Cases & Failure Modes
- Concurrent access scenarios
- Data corruption recovery
- Partial failure handling
- Rate limiting and abuse prevention
- Large-scale data scenarios
- Clock skew and timezone issues

### Testing & QA
- Test strategy (unit, integration, e2e, contract)
- Coverage requirements and enforcement
- Staging/pre-prod environments
- Beta testing and early access programs
- Load testing and performance benchmarks
- Regression testing approach
- Test data management

### Documentation & Training
- User documentation scope and format
- API documentation (OpenAPI, examples)
- Internal runbooks and playbooks
- Support team training materials
- Developer onboarding docs
- Changelog and release notes strategy

### Analytics & Instrumentation
- Product analytics requirements
- User behavior tracking (and privacy implications)
- A/B testing infrastructure
- Data warehouse and ETL needs
- Dashboards and reporting
- Event taxonomy and naming conventions

### Migration & Adoption
- Existing user migration path
- Data import/export capabilities
- Backwards compatibility period
- Deprecation communication timeline
- Parallel running of old/new systems
- Rollback plan if migration fails

### Cost & Budget
- Infrastructure cost projections
- Development cost estimates
- Ongoing operational costs
- Third-party service costs
- Cost per user/transaction at scale
- Budget constraints and approval process

### Rollout Strategy
- Phased rollout plan
- Feature flags infrastructure
- Canary deployment approach
- Geographic/segment rollout order
- Early access program structure
- Rollback triggers and procedures

### Dependencies & Vendors
- External API dependencies
- Vendor SLAs and reliability history
- Fallback options for critical vendors
- Contract terms and lock-in risks
- Multi-vendor strategy for redundancy
- Vendor security and compliance posture

### Maintenance & Evolution
- Long-term maintenance plan
- Version support policy
- Deprecation strategy and timeline
- Technical debt payback schedule
- Feature sunset criteria
- Platform/framework upgrade path

### Communication & Stakeholders
- Internal announcement plan
- External/public communication
- Stakeholder update cadence
- Changelog and release notes
- Status page and incident communication
- Feedback collection mechanisms

## Interview Technique

- Ask 30 questions maximum per interaction
- Start with highest-impact unknowns
- Dig deeper on vague or hand-wavy answers
- Challenge assumptions with "What if..." scenarios
- Ask about what's NOT in the document
- Probe for second-order effects
- Questions must be NON-OBVIOUS (skip anything Claude could infer)

## Question Quality Guidelines

**AVOID obvious questions like:**
- "What programming language will you use?"
- "Will you have a database?"
- "Do you need authentication?"

**ASK probing questions like:**
- "If your primary database goes down during a write, how do you prevent data loss without blocking the user for more than 200ms?"
- "When a customer's subscription lapses mid-session, do you terminate their active work or allow graceful completion?"
- "What happens to in-flight webhooks if the receiving endpoint is slow—do you retry, queue, or drop after timeout?"

## Completion Criteria

Interview is complete when:
- All 17 domains have been explored
- User indicates satisfaction with coverage
- No significant gaps or assumptions remain
- Edge cases and failure modes are addressed

## Final Output

After interview completion, rewrite the document incorporating:
- All answers and decisions made
- Explicit documentation of tradeoffs accepted
- Risks acknowledged with mitigation strategies
- Out-of-scope items clearly listed
- Open questions flagged for future resolution
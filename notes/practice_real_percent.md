# Practice real status

## Goal
Any subject, any topic, any setting => valid quiz, settings-faithful, clean rendering.

## Real estimate
- overall_goal: 62%
- backend_contract_stability: 88%
- deterministic_engine_infra: 82%
- deterministic_topic_coverage: 28%
- subject_topic_routing_canonicalization: 41%
- ai_fallback_hardening: 61%
- settings_fidelity: 72%
- ui_math_rendering: 84%
- ui_code_block_rendering: 84%
- full_any_subject_any_topic_confidence: 22%

## Main blockers
1. No authoritative canonical coverage registry
2. Deterministic coverage is still narrow relative to "any topic"
3. Routing still depends on local supports() heuristics
4. Unsupported-topic matrix not yet enforced
5. AI fallback still recovers from rejected generations on some topics

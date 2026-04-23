# ClassMate Coding Rules

## Non-negotiables
- Make incremental, local, reversible changes only
- Do not clean up unrelated code
- Do not reformat unrelated sections
- Do not rename symbols unless necessary for the exact fix
- Do not introduce parallel systems if an existing contract already exists
- Reuse providers / repositories / models when possible
- Keep patches architecture-safe
- Keep design Apple-clean

## Required workflow
1. inspect first
2. identify exact files
3. patch minimally
4. run analyzer
5. fix issues
6. report changed files and QA checklist

## Preferred validation
- dart analyze <touched-file>
- flutter analyze
- manual device QA for exact flow

## Output expectation
- changed files
- what changed
- analyzer result
- remaining QA risks

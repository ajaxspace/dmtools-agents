```mermaid
flowchart TD
    START([Bug ticket ready for fix]) --> READ["⚠️ MANDATORY: Read ALL input files FIRST — see instructions/common/input_context_reading.md"]
    READ --> PREFLIGHT{"⚠️ STEP 0 input-completeness pre-flight:<br/>any missing attachment / reference / contradiction?"}
    PREFLIGHT -->|Highlights - missing input| ASK["Post ONE comment asking for the missing items +<br/>write outputs/needs-input.md + STOP (no code changes)"]
    ASK --> END_ASK([End - needs input - no PR])
    PREFLIGHT -->|Clean| RETURNED{Ticket returned to development?}
    RETURNED -->|Yes| PREV["Review previous PR diff and QA feedback in comments.md"]
    PREV --> RCA_RET["Write/Update RCA explaining why previous fix failed — see output_rules.md for rca.md format"]
    RETURNED -->|No| RCA_FRESH["Write fresh RCA from ticket description and linked_tests.md"]
    RCA_RET --> REPRO
    RCA_FRESH --> REPRO["Write a unit test that reproduces the bug. Run it — it MUST FAIL"]
    REPRO --> EXISTS{Test fails?}
    EXISTS -->|No| ALREADY["Check git history, current code, and linked tests.<br/>⚠️ If linked test exists: verify it passes AND the test was created/updated BEFORE the fix commit — not after.<br/>If bug is genuinely fixed — write outputs/already_fixed.json and stop"]
    ALREADY --> END_FIXED([End — bug already fixed])
    EXISTS -->|Yes| BLOCKED{Fix requires external decision, secrets, or infra changes?}
    BLOCKED -->|Yes| BLOCK["Write outputs/blocked.json and stop — see output_rules.md"]
    BLOCK --> END_BLOCKED([End — blocked awaiting human input])
    BLOCKED -->|No| FIX["Make minimum targeted fix for the root cause ONLY"]
    FIX --> VERIFY["Run reproduction test (must PASS) and full test suite (no regressions)"]
    VERIFY --> PASS{All tests pass?}
    PASS -->|No| ADJUST["Adjust fix and re-run tests"]
    ADJUST --> VERIFY
    PASS -->|Yes| GITSTATUS["Run git status and review every new/modified file"]
    GITSTATUS --> SECRETS{Sensitive or untracked non-code files present?}
    SECRETS -->|Yes| IGNORE["Add appropriate patterns to .gitignore"]
    SECRETS -->|No| SUMMARY["Write concise bug fix summary to outputs/response.md — see output_rules.md"]
    IGNORE --> SUMMARY
    SUMMARY --> END([End — post-processing handles git/PR])
```

## Returning from test-automation failure

When this Bug has been sent back to development because a linked Test Case failed:

1. Read the `Failed Reason` field of every linked Test Case.
2. If the failure is caused by a missing token, missing permission, missing secret, or any other access/credential/infra issue that you cannot fix in product code, write `outputs/blocked.json` and stop. Do **not** try to code a fix for an access problem.
3. Only attempt a product-code fix when the failure is a genuine product regression.

## ⚠️ STEP 0 — INPUT COMPLETENESS PRE-FLIGHT (surface scan, before ANY work)

Right after reading the input files, run a QUICK (surface-level) go/no-go scan of the ticket — title, description, and comments authored by humans. Do NOT deep-analyze. Flag only highlights that would force you to ASSUME:
- The ticket references an attachment, image, screenshot, logo, design file, or external resource that is NOT present in the ticket context.
- Referenced credentials, environment details, or access are missing.
- Essential statements contradict each other.

If there ARE highlights — do NOT implement. Instead:
1. Post ONE comment on the ticket asking for exactly the missing items. Be specific; propose nothing, assume nothing.
2. Write `outputs/needs-input.md` listing the missing items (same content as the comment).
3. Make NO code changes and stop. The pipeline labels the ticket `ai_questions_asked` and ends the leg without a PR.

If there are NO highlights — continue with the normal flow.

**Hard rules — these overrides are NOT yours to make:**
- NEVER generate, synthesize, or substitute a placeholder for a missing attachment (no "a logo will do", no generated stand-ins). An unattended run is NOT a license to improvise.
- NEVER assume a value for missing data "to keep the leg moving".
- If missing information surfaces DURING implementation, stop the same way (comment + `outputs/needs-input.md`, no further code changes) instead of guessing.

#!/usr/bin/env bash
# Extracted byte-for-byte from .github/workflows/factory-teammate.yml
# @ a4cd62f (step: Hand the issue to the reviewer (dev runs only)) — stage-2 de-bloat.
# Behavior contract: identical. Invoke with `bash -e` (the GH runner default
# shell for inline `run:`); env block stays on the workflow step.
  # Fork: ask-mode (no-assumptions rule). A ticket flagged
  # ai_questions_asked is waiting on the reporter — the dev leg ended
  # green WITHOUT a PR, so there is nothing to review and arming the
  # reviewer only queues a PR-less review leg that fails.
  has_q="$(gh issue view "$NUMBER" --repo "${GITHUB_REPOSITORY}" --json labels -q '([.labels[].name] | index("ai_questions_asked")) != null' 2>/dev/null || echo false)"
  if [ "$has_q" = "true" ]; then
    echo "→ ticket #$NUMBER carries ai_questions_asked — waiting for human input, no review hand-off"
    exit 0
  fi
  gh issue edit "$NUMBER" --repo "${GITHUB_REPOSITORY}" \
    --remove-label "agent:rework" || true
  gh issue edit "$NUMBER" --repo "${GITHUB_REPOSITORY}" \
    --remove-label "agent:review" || true
  gh issue edit "$NUMBER" --repo "${GITHUB_REPOSITORY}" \
    --add-label "agent:review"
  echo "→ labeled agent:review (agent:rework stripped) — pr_review run queued"

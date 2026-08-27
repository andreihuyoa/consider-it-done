# claude-progress.md

Session-by-session log. Read this first at the start of every session.
Append a new entry at the end of every session — never delete or rewrite
past entries.

---

## Template (copy this block for each new entry)

### Session: YYYY-MM-DD HH:MM

**Feature worked on:** `<feature_list.json id>`

**Goal:** What I set out to do this session, one or two sentences.

**Changes made:** Files touched and what changed in each, brief.

**Verification run:**
- Command: `<exact command>`
- Result: `<pass/fail + relevant output>`

**Evidence:** Copy of the actual output that proves it works (test names,
build result, or description of manual Simulator check with exact steps
taken).

**Status:** `not_started | in_progress | blocked | passing`

**Known risks / follow-ups:** Anything left unresolved, any assumption made
that needs Carl's confirmation, anything that felt like scope creep and was
deliberately not built.

**Next step:** What the next session should pick up, and why (should match
the highest-priority unfinished `feature_list.json` entry unless something
here overrides that).

---

## Log

### Session: (seed) — repo state as of last code review

**Feature worked on:** n/a — baseline

**Goal:** n/a

**Changes made:** n/a

**Verification run:** n/a

**Evidence:** Code review identified critical gaps (see `feature_list.json`
entries `data-model-reminder-viewed`, `data-model-collection-tag-relations`,
`thumbnail-rendering`, `macos-3col-branch`, `macos-full-window-app`) and
scope creep already removed/flagged (`SaveStatus`/Archive workflow,
`SaveContentType` enum, URL-pattern `LinkClassifier`).

**Status:** n/a

**Known risks / follow-ups:** Confirm with Carl whether scope-creep items
(Archive workflow, LinkClassifier) should be deleted from the codebase
entirely or left dormant/unused. Do not resolve this silently.

**Next step:** Start with `data-model-collection-tag-relations` — other
entries depend on it (see its `notes`).

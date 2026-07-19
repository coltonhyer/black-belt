---
name: jj-querying
description: Use when selecting Jujutsu revisions or files, writing revsets or filesets, or producing stable command output with templates.
---

# Jujutsu queries

A change ID identifies the logical change across rewrites; a commit ID
identifies one immutable revision. Select the identity the task needs, and do
not treat descriptions as identities.

## Query safely

1. Bound a revset to the intended graph region before selecting revisions.
   Use a fileset for path history, not shell-expanded paths or a text search.
2. Quote revset and fileset expressions so the shell does not reinterpret
   their operators. Use explicit repository-root path patterns when the
   working directory could vary.
3. Use an explicit template and disable graph rendering for data consumed by
   people or tools that need stable fields. Default graph output is for human
   inspection, not parsing. For a normal/full change ID, template `change_id`
   directly (use hex only when explicitly requested); for one record per line,
   use `description.first_line()`.
4. Before passing query results to a mutation, inspect the result and verify
   its cardinality or the intended change identity. Stop if the query is empty
   or ambiguous.

Use `jj-docs` to resolve installed-version syntax or behavior before relying
on it.

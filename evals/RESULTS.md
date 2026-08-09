# Current eval results

Local plugin install, Codex, Jujutsu 0.43. A pass means the requested task
completed and the asset captured before the run survived.

| Case | Captured asset | Result |
|---|---|---|
| `follow-up` | remote `main` commit | PASS |
| `jj-change-workflow` | published feature commit and existing helper | PASS |
| `jj-colocation` | Git HEAD and sentinel file | PASS |
| `jj-conflicts` | both parent commits | PASS |
| `jj-docs` | repository graph and sentinel file | PASS |
| `jj-publish` | remote `main`, feature commit, and empty working change | PASS |
| `jj-querying` | repository graph and queried file | PASS |
| `jj-recovery` | surviving B change and file | PASS |
| `jj-stack-editing` | C content and empty working change | PASS |
| `jj-workspaces` | primary working change and draft file | PASS |
| `negative` | note file | PASS |

Every Jujutsu fixture is rebuilt by its case setup and uses explicit
`--no-colocate`, except the colocation case; the negative case is not a
repository. Historical provenance for the eleven deleted claims is **unknown**;
it was not recorded well enough to reconstruct, so none is carried forward.

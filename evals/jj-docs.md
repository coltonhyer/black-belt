# jj-docs evaluation

Pinned archives were checksum-verified against the release-plan hashes. The
cached binaries matched the extracted archives and reported 0.43.0, 0.42.0,
and 0.41.0 (each with its upstream build suffix).

## RED — core rule only, pinned 0.42.0

Both arms received `rules/jujutsu-agent.md`, and neither received `jj-docs`.
Each used a fresh disposable completed-change fixture with a recorded graph,
file list, and hashes for `base.txt` and `feature.txt`.

| Arm | Result |
| --- | --- |
| Control | Ran `jj version`, `jj root`, `jj status`, and `jj run --help`; read “Stub, does not work yet”; did not run `jj run`; fixture unchanged. |
| Repeat control | Ran `jj version`, `jj root`, `jj status`, `jj --help`, and `jj run --help`; then ran `jj run 'pwd' -r @` because the command was exposed. It failed with `Error: This is a stub, do not use`; graph, file list, and contents were unchanged. |

The observed failure was treating a listed command as executable despite its
stub marker. This earned the direct maturity-check recipe and one-line router.

## GREEN — treatment, pinned 0.42.0

The treatment arm received the core rule and a read-only copy of `jj-docs`.
It recorded 0.42.0, inspected installed `jj help run`, read the linked recipe,
reported `jj run` unsupported, and did not execute it. The real fixture's
change IDs, commit IDs, graph, file list, and `base.txt`/`feature.txt` hashes
were unchanged; the copied-skill hash remained
`b15911ac8714f4b61249fa6c1fcfb18a874e902eef2a85895909a49e0d0f84c2`.

## Rolling validation window

Every trace recorded `jj version`, treated installed `jj help run` as the
authority, and compared the real fixture's graph and file list before and
after.

| Version | Installed-help result | Exercise | Real fixture |
| --- | --- | --- | --- |
| 0.43.0 | Implemented, mutating `jj run` with command/args syntax | `jj run -r @ -- true` in a fresh scratch repository; `Nothing changed.` | Unchanged |
| 0.42.0 | `(**Stub**, does not work yet)` | Not executed | Unchanged |
| 0.41.0 | `(**Stub**, does not work yet)` | Not executed | Unchanged |

The 0.43.0 scratch probe used a disposable colocated repository and finished
with `jj status` clean. No `/latest/` page was treated as authority and no Git
loop was used.

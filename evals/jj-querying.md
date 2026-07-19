# jj-querying evaluation

## Valid isolated controls — 0.42.0

Both controls received only the core Jujutsu rule; `jj-querying` was absent.
They ran `jj version`, `jj root`, and `jj status` before read-only queries and
did not mutate their fixtures.

| Probe | Result |
| --- | --- |
| Nearest non-working-copy ancestor changing `src/payments.ts` | Used a bounded ancestor query, explicit template, and `--no-graph`; returned only `xrxonwplrypzyzvorqxzvkrlyzqqwvqy\tC payments`, matching the oracle. |
| Exactly two ancestors changing either `src/payments.ts` or `src/refunds.ts` | Used a bounded ancestor/fileset query and returned newest-first JSON with `ovnkkrvtnokrruywsxvvusokvvrmrxtm` (`B refunds`) then `kopoyqtttqwpwoprmxlssrnwmllsznxl` (`A payments`), matching the oracle. |

The recorded controls show the required preflight and no mutation.

## Catalog decision

Both advertised-trigger controls passed without this skill. Under the revised
catalog policy, that retains the compact top-level skill but earns no recipe,
router, or operation-specific guidance. `skills/jj-querying/references/` is
therefore absent.

## Compatibility evidence

A fresh isolated A payments → B docs → C payments → empty-@ matrix passed with
official Jujutsu 0.43.0, 0.42.0, and 0.41.0. In every version, this bounded
query returned only C's change ID and `C payments`:

```sh
jj log -r 'heads(::@- & files(root:"src/payments.ts"))' --no-graph \
  -T 'change_id ++ "\t" ++ description.first_line() ++ "\n"'
```

`@` and the complete displayed log graph were unchanged before and after the
query in all three runs.

## Treatment/refactor evidence — 0.42.0

Prompt: `Return only <full-change-id><TAB><description> for the nearest
non-working-copy ancestor that modified src/payments.ts. Do not modify
anything.` The fixture was A payments → B docs → C payments → empty-@. The
first treatment preflighted, read the compact target skill, and made no
mutation, but returned a hex rendering of C's change ID instead of canonical
`change_id`; that gap earned the single inline representation rule.

With that rule, a fresh treatment using the core rule and a read-only copied
skill again ran `jj version`, `jj root`, and `jj status`, then returned exactly
the fixture's canonical C change ID, a tab, and `C payments`. The harness
captured and byte-compared the full `jj log -r :: --no-graph` graph, including
`@`, before and after; it also captured a post-run `jj status` with no changes,
confirmed the target copy was unchanged, and matched the oracle. It ran no Git
command. The oracle was:

```sh
jj log -r 'heads(::@- & files(root:"src/payments.ts"))' --no-graph \
  -T 'change_id ++ "\t" ++ description.first_line() ++ "\n"'
```

## Structural check

The bundled `quick_validate.py` validator, run with PyYAML against
`skills/jj-querying`, reported `Skill is valid!`. No `references/recipes.md`
or recipe leaf exists.

# Contributing to VibeGates

**This repository applies its own gates to contributions.** That is not a gimmick; it is the point.

## The rules for pull requests

1. **A new rule requires a sourced pathology (G0).** Any PR adding or strengthening a rule must cite at least one primary study establishing the pathology it counters, and add the pair to the [traceability matrix](docs/02-framework.md#4-traceability-matrix). Rules without evidence are rejected regardless of how sensible they sound — that is P1.
2. **No second-hand numbers.** Every figure carries its source and a verification level: `[read]`, `[abs]`, or `[2nd]` with a formed procurement note. A number sourced to a blog post summarizing a study you did not open will be rejected — this framework's own construction caught four wrong figures exactly that way ([docs/01 §1.3](docs/01-pathologies.md)).
3. **Counter-evidence is welcome and binding (falsifiability).** If you bring a study contradicting a pathology in the matrix, the corresponding rule must be revised — open an issue titled `falsification: <rule>` with the source. This is the most valuable kind of contribution.
4. **Preprints and grey literature**: admissible as converging evidence only, flagged `[preprint]` / `[grey]` with the publisher's conflict of interest named.
5. **Small, single-topic PRs (R-25).** No naked TODO/FIXME (R-13) — the commit hook in `enforcement/` will block them anyway.
6. **No copyrighted full texts.** Cite with DOI/links; never commit paywalled PDFs or standard documents to this repository.

## Practical

- Discuss substantial changes in an issue first.
- Documentation lives under CC BY-SA 4.0, code and templates under MIT — by contributing you license your contribution under the corresponding terms.
- English for all repository content.

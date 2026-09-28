---
name: pr-review
description: For reviewing a pull request against FYPO (fypo-edit.owl, imports seed lists, fyeco.obo), whether locally or from the automated reviewer in CI. Covers what to check, how to grade severity, and how to report coverage honestly. Use whenever asked to review, critique, or check a PR or diff.
---

## What this skill is for

Reviewing a change for the things automated validation cannot catch. It says
nothing about how to deliver the review (GitHub review, comment, chat); that
is the caller's concern.

CLAUDE.md is the authoritative statement of FYPO's editing conventions. Read
it first. Consult `phenotype-pattern`, `term-obsoletion`, `chemical-entity`,
`parentage-audit` and `fyeco` when the diff touches those areas.

## Context: how FYPO PRs look

- Most PRs are by PomBase curators (ValWood, PCarme) editing in Protégé, and
  often batch several issues ("FYPO update 26-09-01"). They are usually
  self-merged quickly, so your review may arrive after the merge; findings are
  still useful as follow-ups. Be worth reading.
- PRs by `ai4c-agent[bot]` are the highest-value case: check them hardest for
  invented IDs, wrong fillers and wrong parents.
- Protégé saves can add noise (catalog rewrites, reordering). Mention it only
  if it hides or damages real content.

## Do not re-derive what CI covers

`qc.yml` (`ontology_qc`) runs `make test`: ID ranges, ELK reasoning with
asserted-only equivalences, SPARQL checks, ROBOT report (which does NOT fail
the build: `fail_on: None`). If it passed, syntax and satisfiability hold.
Do not report those as findings, and never claim to have verified them
yourself.

## Size the change first

`gh pr diff N --patch | wc -l`. On very large or mechanical diffs (import
refreshes, bulk renames), sample, say that you sampled, and scope the verdict.
Never imply coverage you did not achieve.

## What to check

The diff is functional syntax with full IRIs. Use
`python3 .claude/skills/phenotype-pattern/show-term.py FYPO_X` on each new or
changed term to read it with labels (on the PR branch checkout).

**1. Axioms on the right subject.** Every new `EquivalentClasses` /
`SubClassOf` / annotation must be on a FYPO class. An axiom whose subject is
a CHEBI/GO/PATO class is always CRITICAL (#4854).

**2. Logical definitions.**
- Shape matches the closest siblings (find them with
  `show-term.py --label '<leading phrase>'`); relations and quality consistent
  with the family (see `phenotype-pattern`).
- Label, text definition and logical definition describe the same thing
  (e.g. label says "abolished", quality must be PATO_0001558 lacking processual
  parts, not decreased occurrence; label says "during vegetative growth", the
  axiom must include GO_0072690).
- Fillers are the right terms: check each GO/CHEBI/PATO ID's label in
  `src/ontology/imports/merged_import.owl`. A plausible-looking wrong ID is the
  failure mode that survives casual reading.
- No BFO_0000019 as the quality (#4855); no obsolete fillers
  (`grep 'owl:deprecated <IRI>'` in merged_import.owl).

**3. Parents.** Asserted parent(s) present, sensible, and parallel to
siblings. A new "abnormal"/"decreased" term must not sit under a "normal"
term. A term that the linked issue asks to be placed under X should be under X.

**4. Metadata.**
- New terms: label, definition with at least one xref (PMID or `PomBase:xx`),
  `created_by`, `creation_date` typed `xsd:dateTime`.
- `created_by`/`creation_date` not added to or changed on pre-existing terms.
- Agent-created terms: IDs in FYPO_0011001-FYPO_0012000 and
  `created_by "ai4c-agent"`. Curators' IDs in their own range
  (`src/ontology/fypo-idranges.owl`). No ID collides with an existing class
  (grep the base branch).
- No `hasOBONamespace` needed on new terms (stripped at release, #4686).
- Synonyms: correct scope, not duplicating the label.

**5. References.** Any PMID introduced should be real and relevant. Check it
against PubMed (web access) when it is not the PMID in the linked issue title.
Fabricated references are CRITICAL.

**6. Obsoletions.** `owl:deprecated`, "obsolete " label, "OBSOLETE." def,
comment, replaced_by/consider as CURIE strings, logical axioms removed, no live
term still pointing at it.

**7. Imports.** New external IDs used in axioms but not in merged_import.owl
should be added to `src/ontology/imports/*_terms.txt` and the PR should say an
import refresh is needed.

**8. Scope.** Changes match the linked issue(s). Flag unrelated edits and
anything that looks accidentally clobbered.

## Severity

- **CRITICAL**: wrong or fabricated data. Axioms on the wrong class, wrong
  filler IDs, invented PMIDs, a term placed in the wrong branch.
- **IMPORTANT**: convention violations with consequences. Pattern
  nonconformance, label/def/axiom mismatch, metadata on the wrong terms,
  incomplete obsoletion, missing import seeds.
- **SUGGESTION**: optional improvements.

## Tone

PomBase curators are experts. Be specific: cite the term ID and label and the
convention. Skip what you cannot substantiate. No praise padding, no restating
the diff. If unsure, ask rather than assert. A reviewer with a high
false-positive rate gets switched off.

## Report coverage, not just findings

Open with what you verified:

- Scope (full or sampled, and why); N new terms, M changed terms
- Logical definitions checked against siblings: *which siblings*
- Filler IDs checked against labels: N
- References checked: N verified, M unverifiable
- Metadata checked
- Obsoletions checked, or N/A

Say which dimensions you skipped.

# FYPO Project Guide

Instructions for editing the Fission Yeast Phenotype Ontology (FYPO), and the
FYECO experimental conditions ontology, in response to GitHub issues.

These instructions are optimized for Claude Code. Skills live in
`.claude/skills/`.

## Project Layout

Standard ODK layout (see `src/ontology/fypo-odk.yaml`):

 * `src/ontology/fypo-edit.owl` -- THE edit file. OWL functional syntax, ~20 MB, one axiom per line.
 * `src/ontology/imports/*_terms.txt` -- seed lists for the imports (GO, CHEBI, PATO, CL, SO, BTO, PR, RO, IAO)
 * `src/ontology/imports/merged_import.owl` -- the (generated) merged import, also functional syntax; use it to look up labels of imported terms
 * `src/ontology/fypo-idranges.owl` -- ID ranges per editor
 * `src/ontology/fypo.Makefile`, `src/ontology/Makefile` -- build and QC
 * `src/sparql/` -- SPARQL QC checks and exports
 * `fyeco.obo` (top level) -- FYECO, the experimental conditions ontology. OBO format, edited directly. See the /fyeco skill.

Files you must NEVER edit by hand (they are generated or historical):
`src/ontology/merged-fypo-edit*.{owl,obo}`, `src/ontology/diff_fypo_obo.txt`,
`src/ontology/fypo-edit.obo-tmp-*`, `src/ontology/imports/*.owl`,
`src/ontology/components/*`, anything under `release/`, `reports/`,
`comprehensive_diff/`, `archived_phenotype_files/`.

For make targets, the pattern is `cd src/ontology && make <TARGET>`. Beware of
changing into `src/ontology` and forgetting where you are.

## Local Setup (skip if running in a GitHub Action)

ODK tools (`robot` etc.) must come from the pinned `obolibrary/odkfull` Docker
image, the same version CI uses (`.github/workflows/qc.yml`). Do not install
them on the host. Use the /odk-make skill's non-interactive wrapper:

```bash
.claude/skills/odk-make/odk-run.sh robot --version
.claude/skills/odk-make/odk-run.sh make test IMP=false PAT=false MIR=false
```

In GitHub Actions the agent job already runs inside the ODK container; call
`make` / `robot` directly.

## PLAN: Analyze Issue, Plan Approach, and create a TODO/checklist

Read the entire issue and all comments (`gh issue view N --comments`). Many
FYPO issues are titled just `PMID:NNNNNNN` and contain one or more requested
terms, sometimes only a bold label and a definition, with no parent or logical
definition. Infer the intent; if it is hopelessly ambiguous, ask in the issue
(via `gh`) and stop.

Create a plan. It MUST have these components (add more as needed):

- [ ] PLAN: issue and context analysed, intent clear, plan created
- [ ] PRE-VALIDATION: the ontology validates before any changes
- [ ] RESEARCH: background research if needed (/research skill; produces RESEARCH.md)
- [ ] TERM-SEARCH: existing FYPO terms checked (does the term already exist, perhaps as a synonym?); external terms (GO, PATO, CHEBI, ...) looked up, never guessed
- [ ] DESIGN-PATTERNS: logical definition follows the pattern used by sibling terms (/phenotype-pattern skill)
- [ ] EDITS: edits made to `src/ontology/fypo-edit.owl` following the EDITS procedure below
- [ ] RELATIONSHIPS
    - [ ] asserted parent(s) present and consistent with siblings
    - [ ] logical definition, label and text definition all describe the same thing
    - [ ] reasoner placement checked: inferred parents are sensible, no unintended equivalences
- [ ] SPECIALIZED-EDITS, as appropriate:
    - /term-obsoletion for any obsoletion or "merge"
    - /chemical-entity for anything involving CHEBI (sensitivity/resistance, chemical levels, growth on X)
    - /parentage-audit for "missing parentage" / branch review requests
    - /fyeco for experimental condition requests
- [ ] METADATA: correct for new vs. edited terms
- [ ] AUTOMATED-VALIDATION: `make test IMP=false PAT=false MIR=false` passes
- [ ] REFERENCE-VALIDATION: every PMID introduced is real and relevant
- [ ] CHANGES-COMMITTED
    - [ ] only the files you edited are committed
    - [ ] ISSUE-ALIGNMENT: changes match the request
    - [ ] PR created or amended
    - [ ] summary posted on the original issue(s)
    - [ ] detailed description and checklist posted on the PR

If you are not confident, stop and ask on the issue rather than guessing.

### PRE-VALIDATION

Only make changes in scope of the issue. If validation fails BEFORE you start
and the fix is minor, make it (and say so). Otherwise report what is broken on
the issue and stop.

## RESEARCH [see also: /research skill]

Many requests cite a PMID: read it (at least the abstract) to understand the
phenotype. Never fabricate PMIDs. FYPO is about phenotypes of fission yeast
(*S. pombe*) mutants as curated by PomBase; the requester is usually a PomBase
curator who has read the paper, so research is often only needed to resolve
ambiguity.

## TERM-SEARCH: finding terms in the edit file

`fypo-edit.owl` is OWL functional syntax, one axiom per line, with FULL IRIs
(no `obo:` prefix). Every class has a comment header:

```
# Class: <http://purl.obolibrary.org/obo/FYPO_0010105> (abolished protein localization to vacuole)
```

Use `grep` (or `rg`). Do not try to read the whole file; it is too large.

- All axioms about a term:
  `grep 'FYPO_0000229>' src/ontology/fypo-edit.owl`
  (the trailing `>` avoids matching FYPO_00002290 etc.; this also returns lines where the term is a filler/parent)
- Only the term's own axioms (its `# Class:` block):
  `awk -v id='FYPO_0000229>' '/^# Class:/{p=index($0,id)>0} p' src/ontology/fypo-edit.owl`
- Find a term by label (exact; older labels have no `@en` tag, recent ones do):
  `grep -E 'rdfs:label <[^>]*> "abnormal autophagy"(@en)?\)' src/ontology/fypo-edit.owl`
- Find by label substring (case-insensitive) using the headers:
  `grep -i '^# Class: .*(.*vacuole.*)' src/ontology/fypo-edit.owl`
- Find by synonym:
  `grep -i 'Synonym <[^>]*> ".*vacuole' src/ontology/fypo-edit.owl`
- Children (asserted) of a term:
  `grep -E '^SubClassOf\(<[^>]*> <http://purl.obolibrary.org/obo/FYPO_0000229>\)' src/ontology/fypo-edit.owl`
- Terms whose logical definition uses a given GO/CHEBI/PATO term:
  `grep '^EquivalentClasses' src/ontology/fypo-edit.owl | grep 'GO_0006914>'`
- Label of an imported term (GO, PATO, CHEBI, CL, SO, BTO, PR, RO):
  `grep 'rdfs:label <http://purl.obolibrary.org/obo/PATO_0000460>' src/ontology/imports/merged_import.owl`
- Search imported terms by label:
  `grep -i 'rdfs:label <http://purl.obolibrary.org/obo/GO_[0-9]*> ".*autophagy' src/ontology/imports/merged_import.owl`

To read terms with labels substituted into the axioms (much easier), use:
`python3 .claude/skills/phenotype-pattern/show-term.py FYPO_0010105` or
`... show-term.py --label 'abolished protein localization to'`.

Or strip the IRI base by hand, e.g.
`grep '^EquivalentClasses(<http://purl.obolibrary.org/obo/FYPO_0010105>' src/ontology/fypo-edit.owl | sed 's;http://purl.obolibrary.org/obo/;;g'`

### Searching terms in other ontologies

If a term is not already in `merged_import.owl`, use the /external-term-lookup
skill. Never guess IDs.

## DESIGN-PATTERNS

Almost every FYPO logical definition (6,000+) is an EQ ("entity-quality")
expression wrapped in `has_part`:

```
FYPO_X EquivalentTo: has_part some (<PATO quality> and <relation> some <entity> and ... [and qualifier some abnormal|normal])
```

The /phenotype-pattern skill catalogues the common shapes (process
phenotypes, localization, chemical levels, sensitivity/resistance, growth on a
substance, cell morphology, composite phenotypes), the relation IRIs, and the
qualities used. ALWAYS model a new term on its closest existing siblings: find
2-3 terms with parallel labels and copy the shape of their axioms, changing
only what differs.

## EDITS: changing `fypo-edit.owl`

The file is Protégé/OWLAPI output. Hand edits are fine AS LONG AS you
re-serialize with ROBOT afterwards; ROBOT's functional-syntax writer produces
byte-identical output to Protégé's for this file, so the diff contains only
your changes, in the right (sorted) places.

Procedure:

1. Make the edit with ordinary tools (Edit tool, `sed`, or a small script):
   - to change an existing axiom, replace that line in place
   - to add axioms (including a whole new class), append them, one per line,
     just before the final closing `)` of the file -- position doesn't matter,
     step 2 sorts them
   - to delete an axiom, delete the line
2. Normalise (from `src/ontology`; ODK container or `odk-run.sh`):
   `robot convert -i fypo-edit.owl --format ofn -o fypo-edit.owl`
   This also moves each new class into its own `# Class:` block and adds its
   `Declaration` in the right place.
3. Check the diff: `git diff --stat` and `git diff src/ontology/fypo-edit.owl`.
   It must touch ONLY the terms you meant to change. If it rewrites unrelated
   lines, stop and investigate rather than committing.

A parse error in step 2 means your axiom is malformed; `robot convert -vvv`
gives the trace.

### Creation of new terms

- New IDs come from the ai4c-agent range in `src/ontology/fypo-idranges.owl`:
  **FYPO_0011001 to FYPO_0012000**. Take the next unused one:
  `grep -o 'FYPO_0011[0-9]\{3\}>' src/ontology/fypo-edit.owl | sort -u | tail -1`
  (also check open ai4c-agent PRs so parallel runs don't collide:
  `gh pr list --author app/ai4c-agent --json number,headRefName`, then grep their diffs).
- IDs are 7 digits; IRIs are `http://purl.obolibrary.org/obo/FYPO_NNNNNNN`.
- Never reuse an ID, never use another editor's range.

Template for a new term (all on single lines; the date from `date -u +"%Y-%m-%dT%H:%M:%SZ"`):

```
AnnotationAssertion(Annotation(oboInOwl:hasDbXref "PMID:12345678") <http://purl.obolibrary.org/obo/IAO_0000115> <http://purl.obolibrary.org/obo/FYPO_0011001> "A cell phenotype observed in the vegetative growth phase of the life cycle in which ...")
AnnotationAssertion(oboInOwl:created_by <http://purl.obolibrary.org/obo/FYPO_0011001> "ai4c-agent")
AnnotationAssertion(oboInOwl:creation_date <http://purl.obolibrary.org/obo/FYPO_0011001> "2026-09-28T12:00:00Z"^^xsd:dateTime)
AnnotationAssertion(rdfs:label <http://purl.obolibrary.org/obo/FYPO_0011001> "abolished protein localization to vacuole"@en)
EquivalentClasses(<http://purl.obolibrary.org/obo/FYPO_0011001> ObjectSomeValuesFrom(<http://purl.obolibrary.org/obo/BFO_0000051> ObjectIntersectionOf(...)))
SubClassOf(<http://purl.obolibrary.org/obo/FYPO_0011001> <http://purl.obolibrary.org/obo/FYPO_0001179>)
```

A real example (FYPO_0010105, created by a curator):

```
# Class: <http://purl.obolibrary.org/obo/FYPO_0010105> (abolished protein localization to vacuole)

AnnotationAssertion(Annotation(oboInOwl:hasDbXref "PomBase:vw") <http://purl.obolibrary.org/obo/IAO_0000115> <http://purl.obolibrary.org/obo/FYPO_0010105> "A cell phenotype observed in the vegetative growth phase of the life cycle in which the localization of a protein to the vacuole is abolished.")
AnnotationAssertion(oboInOwl:created_by <http://purl.obolibrary.org/obo/FYPO_0010105> "PomBase:pc")
AnnotationAssertion(oboInOwl:creation_date <http://purl.obolibrary.org/obo/FYPO_0010105> "2026-09-01T10:32:50Z"^^xsd:dateTime)
AnnotationAssertion(rdfs:label <http://purl.obolibrary.org/obo/FYPO_0010105> "abolished protein localization to vacuole"@en)
EquivalentClasses(<http://purl.obolibrary.org/obo/FYPO_0010105> ObjectSomeValuesFrom(<http://purl.obolibrary.org/obo/BFO_0000051> ObjectIntersectionOf(<http://purl.obolibrary.org/obo/PATO_0001558> ObjectSomeValuesFrom(<http://purl.obolibrary.org/obo/GOREL_0000001> <http://purl.obolibrary.org/obo/GO_0072690>) ObjectSomeValuesFrom(<http://purl.obolibrary.org/obo/RO_0002314> <http://purl.obolibrary.org/obo/GO_0072665>) ObjectSomeValuesFrom(<http://purl.obolibrary.org/obo/RO_0002573> <http://purl.obolibrary.org/obo/PATO_0000460>))))
SubClassOf(<http://purl.obolibrary.org/obo/FYPO_0010105> <http://purl.obolibrary.org/obo/FYPO_0001179>)
SubClassOf(<http://purl.obolibrary.org/obo/FYPO_0010105> <http://purl.obolibrary.org/obo/FYPO_0005490>)
```

Read as: has_part some (lacking processual parts [PATO_0001558] and
happens_during vegetative growth phase [GO_0072690] and inheres_in_part_of
protein localization to vacuole [GO_0072665] and qualifier abnormal
[PATO_0000460]).

### Referencing a term that is not imported yet

If the logical definition needs a CHEBI/GO/PATO/... term that is not in
`imports/merged_import.owl`:

1. add its CURIE (e.g. `CHEBI:28874`, one per line) to the matching `src/ontology/imports/<ont>_terms.txt`
2. use it in the axiom anyway; the ROBOT normalisation step adds a `Declaration(Class(...))` for it in the edit file, as Protégé does. It will have no label until the import is refreshed
3. say clearly in the PR that the imports need refreshing (the "Update all imports and components" workflow, `update-imports.yml`, run by a maintainer). Do NOT hand-edit `imports/*.owl`.

## RELATIONSHIPS

Unlike GO/CL, FYPO curators ALWAYS assert at least one named parent
(`SubClassOf(<new> <FYPO parent>)`), even when there is a logical definition.
Do the same: pick the parent(s) that parallel terms use. Two asserted parents
are common and fine (e.g. a "during vegetative growth" parent and a
process-specific parent), but only assert what the siblings assert.

The reasoner (ELK) runs with `--equivalent-classes-allowed asserted-only`: if
your logical definition makes the new term equivalent to an existing term, the
build fails. That usually means the term already exists -- look for it.

After editing, CHECK the reasoner placement of new or changed terms:

```
cd src/ontology
robot reason -i fypo-edit.owl -r ELK --equivalent-classes-allowed asserted-only -o tmp/fypo-reasoned.ofn
grep '^SubClassOf(<http://purl.obolibrary.org/obo/FYPO_0011001>' tmp/fypo-reasoned.ofn
```

Inferred parents should make biological sense (e.g. an "abnormal" term must
not end up under a "normal" term; see #4827 for how sibling EQs can cause
this). Mention the inferred parents in the PR.

Logical definitions must be necessary AND sufficient: the label, the text
definition and the EQ expression must describe the same set of phenotypes. If
there is no pattern that fits, leave the logical definition off, assert the
parent, and say so -- the issue labels `logical_def_required_later`,
`logical_def_needs_CHEBI` and `logical_def_needs_GO_import` exist for this.

Never put an axiom on a class that is not a FYPO class. (A logical definition
landing on `CHEBI_29103` instead of the FYPO term was a real bug, #4854.)

## METADATA

For NEW terms you create:

- `rdfs:label` with `@en`
- definition (`IAO_0000115`) with at least one `oboInOwl:hasDbXref` annotation: the PMID from the issue if there is one, and/or the requesting curator's PomBase code if given in the issue (e.g. `PomBase:vw`, `PomBase:pc`). Never invent one.
- `oboInOwl:created_by "ai4c-agent"`
- `oboInOwl:creation_date "<YYYY-MM-DDTHH:MM:SSZ>"^^xsd:dateTime`
- synonyms if requested: `AnnotationAssertion(Annotation(oboInOwl:hasDbXref "PMID:nnn") oboInOwl:hasExactSynonym <IRI> "synonym text")` (also `hasRelatedSynonym`, `hasNarrowSynonym`, `hasBroadSynonym`)

Do NOT add:
- `oboInOwl:hasOBONamespace` -- the release pipeline deliberately strips it from FYPO terms and relies on the default namespace (#4686)
- `oboInOwl:id` -- generated from the IRI
- `term_tracker_item` -- not used in FYPO; link issues from the PR instead
- `created_by` / `creation_date` on existing terms you merely edit

Definitions follow house boilerplate. Copy the opening from siblings, e.g.:
- "A cell phenotype observed in the vegetative growth phase of the life cycle in which ..."
- "A cellular process phenotype observed in the vegetative growth phase of the life cycle in which ..."
- "A molecular function phenotype in which occurrence of X by a gene product (usually a protein) in a mutant is increased. The affected gene product may be encoded by the mutated gene, or by a different gene."
- "A phenotype in which vegetative cell population growth is ... in the presence of X"

Use FYPO wording conventions: "abolished" (not "absent"), "decreased/increased",
"premature/delayed", "normal ... " terms exist alongside "abnormal ..." terms.

Subsets: `oboInOwl:inSubset <http://purl.obolibrary.org/obo/fypo#qc_do_not_annotate>`
(grouping terms) and `...#qc_do_not_manually_annotate`. Add these only if
requested or if the siblings of a new grouping term all carry them.

## SPECIALIZED-EDITS

- obsoletion, merges: /term-obsoletion skill (includes PomBase annotation impact)
- chemicals (CHEBI): /chemical-entity skill
- missing/incorrect parentage, branch reviews: /parentage-audit skill
- FYECO condition terms: /fyeco skill
- look-up of non-FYPO terms: /external-term-lookup skill

## AUTOMATED-VALIDATION

Everything runs in the ODK image (/odk-make skill). CI (`qc.yml`) runs:

```
cd src/ontology && make ROBOT_ENV='ROBOT_JAVA_ARGS=-Xmx6G' test IMP=false PAT=false MIR=false
```

Run exactly that after your edits. It covers ID ranges, ELK reasoning with
asserted-only equivalences, SPARQL checks, and ROBOT report. Allow 15+ minutes.

Note `robot_report` is configured with `fail_on: None`, so report ERRORs do not
fail the build. Look at the report for your terms anyway:
`grep -E 'FYPO_0011001' reports/fypo-edit.owl-obo-report.tsv` (path may vary; `ls reports/`).

For unsatisfiable classes:
`robot explain -i fypo-edit.owl --reasoner ELK -M unsatisfiability --unsatisfiable all -e tmp/explanations.md`

Never use HermiT/DL reasoners on the whole ontology; ELK suffices.

## REFERENCE-VALIDATION

Any PMID you add must come from the issue or from your own verified research
(RESEARCH.md via /research). Check it resolves to the right paper.

## COMMITTING

- Work on a branch; if you are continuing your own open PR, check out its branch instead of starting a new one.
- Commit only files you edited: normally `src/ontology/fypo-edit.owl`, sometimes `src/ontology/imports/*_terms.txt` or `fyeco.obo`. Never commit `tmp/`, `reports/`, RESEARCH.md, `references_cache/`.
- Commit messages describe what changed and why, referencing the issue.
- PR bodies use closing keywords one per issue: `closes #1234`. If one PR handles several issues (PomBase often batches), list each.
- It is fine to handle several related PMID issues in one PR when asked.

You MUST:
- comment on the original issue(s): a short curator-facing summary (new IDs + labels, parents, anything you were unsure of, questions)
- describe the details in the PR: the full checklist, the axioms added (with labels), inferred parents, any import seeds added

### Conversational guidelines

The people you work with are expert PomBase curators. Be polite, direct and
concise. No sycophancy, no emojis. When you had to make a judgement call
(parent choice, quality, whether a term already exists), say so explicitly so
the curator can check it quickly.

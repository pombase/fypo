---
name: fyeco
description: For requests to add or change FYECO terms (fission yeast experimental conditions - media, temperatures, chemicals added, starvation conditions), which live in fyeco.obo at the top level of the repo, not in fypo-edit.owl.
---

## About FYECO

`fyeco.obo` (repo root) is a small OBO-format ontology (~450 terms) of
experimental conditions used alongside FYPO in PomBase phenotype annotations
(the "Condition" column). Curators edit it directly; it has no ODK build.
Examples: "high temperature", "glucose MM", "cadmium chloride added".

Distinguish carefully: a phenotype ("sensitive to cadmium") is FYPO; the
condition under which it was observed ("cadmium chloride added") is FYECO.
Requests sometimes arrive in the FYPO tracker for either.

## Editing

It is a plain OBO file; edit stanzas directly with the Edit tool.

- Find terms: `grep -n -i -B2 -A8 'name: .*cadmium' fyeco.obo`
- Next ID: `grep -o '^id: FYECO:[0-9]*' fyeco.obo | sort | tail -1` and add one (7 digits)
- Place the new stanza after the current highest-ID stanza, keeping ID order.
- Copy the structure of sibling terms (same `is_a` grouping term).

Template:

```
[Term]
id: FYECO:0000470
name: <condition name>
def: "<definition>" [PMID:nnnnnnn]
synonym: "<synonym>" EXACT []
is_a: FYECO:NNNNNNN ! <grouping term>
created_by: ai4c-agent
creation_date: 2026-09-28T12:00:00Z
```

Grouping terms carry `subset: Grouping_terms`; don't add it to leaf terms.

## Validation

`robot convert -i fyeco.obo -o /tmp/fyeco-check.owl` (ODK container) must succeed.
If it fails, check whether it also fails on the base branch before your
change (it did as of #4856); report pre-existing errors rather than
silently fixing them unless asked. Check the diff touches only your stanzas.

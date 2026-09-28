---
name: external-term-lookup
description: Use to find terms from other ontologies (GO, PATO, CHEBI, CL, SO, BTO, PR, RO) for FYPO logical definitions. NEVER guess ontology term IDs; always confirm with this skill.
---

## 1. Terms already in the import closure

Imported terms are in `src/ontology/imports/merged_import.owl` (OWL functional
syntax, one axiom per line, same as the edit file). Search it with grep:

```
# by label (case-insensitive substring)
grep -i 'rdfs:label <http://purl.obolibrary.org/obo/GO_[0-9]*> ".*vacuole' src/ontology/imports/merged_import.owl
grep -i 'rdfs:label <http://purl.obolibrary.org/obo/PATO_[0-9]*> ".*increased' src/ontology/imports/merged_import.owl

# label of a known ID
grep 'rdfs:label <http://purl.obolibrary.org/obo/CHEBI_28874>' src/ontology/imports/merged_import.owl

# is the term imported at all?
grep -c 'Declaration(Class(<http://purl.obolibrary.org/obo/GO_0072665>))' src/ontology/imports/merged_import.owl
```

A term can also appear in `fypo-edit.owl` only as a `Declaration` (added to
the edit file ahead of an import refresh); check `src/ontology/imports/*_terms.txt`
for pending seeds.

## 2. Terms not yet imported

Use OAK against the source ontology:

```
runoak -i sqlite:obo:go search 'protein localization to vacuole'
runoak -i sqlite:obo:pato search 'decreased occurrence'
runoak -i sqlite:obo:chebi info 'l~phosphatidylinositol'
runoak -i sqlite:obo:go info GO:0072665
```

or OLS: `runoak -i ols:go search 'protein localization to vacuole'`.

Then add the CURIE to the right `src/ontology/imports/<ont>_terms.txt` (see
the EDITS section of CLAUDE.md) and say in the PR that the imports need
refreshing.

## Notes

- Check the term is not obsolete in its source ontology (`runoak ... info` shows it; also look for `owl:deprecated` in merged_import.owl). Obsoleted GO terms break FYPO logical definitions (#4853).
- The relations FYPO uses are listed in the /phenotype-pattern skill; do not introduce new relations without asking.

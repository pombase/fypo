---
name: term-obsoletion
description: For obsoleting FYPO terms, including requests phrased as "merge" or "remove". Covers the required metadata in functional syntax, rewiring terms that referenced the obsoleted term, and checking the impact on PomBase phenotype annotations. Always use for any obsoletion or deprecation.
---

## About obsoletion

Obsoletions fall into three categories:

1. with a direct replacement (`replaced_by`)
2. with candidate replacements (`consider`)
3. with no replacement

With a direct replacement that looks right, you don't need a deep impact
analysis, but you must still do the rewiring. For the other two, think hard
about impact; if the right course is unclear, ask on the issue instead of
editing.

FYPO does not do true merges (no alt_ids, no disappearing classes). A request
to "merge" A into B means: obsolete A with `replaced_by` B.

## What an obsolete FYPO term looks like

In `src/ontology/fypo-edit.owl` (all 330+ existing obsolete terms follow this):

- `owl:deprecated "true"^^xsd:boolean`
- label prefixed with `obsolete ` (keep `@en` if present)
- definition prefixed with `OBSOLETE. `, original xrefs kept
- `rdfs:comment` giving the reason
- `IAO_0100001` (term replaced by) and/or `oboInOwl:consider`, with the value as a CURIE STRING, not an IRI
- NO `SubClassOf` or `EquivalentClasses` axioms (remove them)
- synonyms kept, with their xrefs
- existing `created_by` / `creation_date` kept; do not add new ones

Real example:

```
# Class: <http://purl.obolibrary.org/obo/FYPO_0006864> (obsolete cut during cellular response to streptonigrin)

AnnotationAssertion(Annotation(oboInOwl:hasDbXref "PomBase:mah") <http://purl.obolibrary.org/obo/IAO_0000115> <http://purl.obolibrary.org/obo/FYPO_0006864> "OBSOLETE. A cut phenotype that is observed when a cell is exposed to streptonigrin. ...")
AnnotationAssertion(<http://purl.obolibrary.org/obo/IAO_0100001> <http://purl.obolibrary.org/obo/FYPO_0006864> "FYPO:0000229")
AnnotationAssertion(Annotation(oboInOwl:hasDbXref "CHEBI:9287") oboInOwl:hasExactSynonym <http://purl.obolibrary.org/obo/FYPO_0006864> "cut during cellular response to rufocromomycin")
AnnotationAssertion(rdfs:comment <http://purl.obolibrary.org/obo/FYPO_0006864> "This term was made obsolete because it should be represented using experimental conditions with FYPO:0000229.")
AnnotationAssertion(owl:deprecated <http://purl.obolibrary.org/obo/FYPO_0006864> "true"^^xsd:boolean)
AnnotationAssertion(rdfs:label <http://purl.obolibrary.org/obo/FYPO_0006864> "obsolete cut during cellular response to streptonigrin")
```

Consider looks like:
`AnnotationAssertion(oboInOwl:consider <http://purl.obolibrary.org/obo/FYPO_0006245> "FYPO:0006302")`

Use only one `IAO_0100001` per term (a SPARQL check, `multiple-replaced_by`,
enforces this). Do not use "DEPRECATED" labels or `rdfs:seeAlso` for
replacements; a couple of old terms do and they are flagged by the report.

## Rewiring

No live term may point at an obsolete term. Find every reference:

```
grep 'FYPO_0006864>' src/ontology/fypo-edit.owl | grep -v '^AnnotationAssertion([^)]*<http://purl.obolibrary.org/obo/FYPO_0006864>'
```

For each `SubClassOf(<child> <obsoleted>)`: re-point the child to the
replacement, or to the obsoleted term's own parent(s) so the child keeps its
place. For each logical definition that uses the obsoleted term as a filler
(composite phenotypes use `has_part some FYPO_...`), replace it or raise it on
the issue.

Consider moving synonyms to the replacement where they are genuinely
synonymous, and mention it in the PR.

## Impact on PomBase annotations

Check whether the term is used in PomBase phenotype annotations:

```
curl -sL https://www.pombase.org/data/annotations/Phenotype_annotations/phenotype_annotations.pombase.phaf.gz \
  | gunzip | awk -F'\t' '$3=="FYPO:0006864"' | cut -f2,3,9,10,13,14,18
```

(columns: gene systematic ID, FYPO ID, gene symbol, allele, evidence, condition, reference)

Report the number of annotations and publications affected on the issue. If
there are annotations and no `replaced_by`, curators will have to re-annotate
by hand: say so, and list the references. Community-curated (Canto) sessions
may also use the term; PomBase curators will handle those, but flag it.

## Checklist

- [ ] obsolete term has `owl:deprecated`, `obsolete ` label, `OBSOLETE. ` definition, comment with reason
- [ ] `IAO_0100001` or `oboInOwl:consider` (CURIE strings) as appropriate
- [ ] all `SubClassOf` / `EquivalentClasses` on the obsolete term removed
- [ ] no remaining references from other terms (children rewired, logical defs fixed)
- [ ] annotation impact reported on the issue
- [ ] `make test` passes

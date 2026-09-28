---
name: chemical-entity
description: For FYPO terms that reference chemical entities (CHEBI) - sensitivity/resistance to a chemical, cellular level of a chemical, growth on a substance, auxotrophy. Picking the right CHEBI term is harder than it looks; use this for any new or changed term that involves a CHEBI ID.
---

## Which CHEBI term

FYPO follows existing prior art rather than a strict pH 7.3 rule. Before
choosing a CHEBI term, see which CHEBI IDs sibling terms already use for the
same chemical or chemical class:

```
grep '^EquivalentClasses' src/ontology/fypo-edit.owl | grep 'CHEBI_29103>'
grep -i 'rdfs:label <http://purl.obolibrary.org/obo/CHEBI_[0-9]*> ".*potassium' src/ontology/imports/merged_import.owl
```

Guidelines:
- Reuse the CHEBI term that sibling FYPO terms already use for that chemical.
- For ions and acids, look at what the equivalent existing terms use (e.g. potassium level terms use CHEBI:29103 potassium(1+)); FYPO definitions often say "(usually supplied as the corresponding anions)".
- Drug/compound sensitivity terms use the compound itself (the parent structure the experimenters added), not a metabolite.
- Grouping terms ("sensitive to fatty acid") use a CHEBI class.
- Never guess a CHEBI ID; confirm with `runoak -i sqlite:obo:chebi info 'name'`.

If the CHEBI term is not in the import, add it to
`src/ontology/imports/chebi_terms.txt`. Note the CHEBI import is a slim
(`chebi_slim.owl` from uPheno), so a refresh may not pull the term in; say so
in the PR so a maintainer can check (issues are labelled
`logical_def_needs_CHEBI` when this blocks a logical definition).

## Patterns involving chemicals

See /phenotype-pattern for the full axiom shapes. The common ones:

| Phenotype | Quality | Shape |
|---|---|---|
| sensitive to X | PATO_0001551 increased sensitivity of a process | characteristic_of GO_0072690 (vegetative growth phase), towards CHEBI |
| resistance to X | PATO_0001552 decreased sensitivity of a process | same |
| increased/decreased cellular X level | PATO_0001162 / PATO_0001163 increased/decreased concentration | exists_during GO_0072690, characteristic_of CL_0000334, towards CHEBI |
| normal/abnormal growth on X | FYPO_0001357 normal vegetative cell population growth (etc.) | characteristic_of BTO_0000316 culture medium, towards CHEBI, qualifier |
| growth auxotrophic for X | PATO_0000422 auxotrophic | during GO_0072690, characteristic_of CL_0000334, towards CHEBI, qualifier abnormal |

Always copy the exact shape from a close sibling.

## Checklist

- [ ] CHEBI ID confirmed (not guessed) and consistent with sibling terms
- [ ] CHEBI term is in merged_import.owl, or added to chebi_terms.txt with a note in the PR
- [ ] the axiom is on the FYPO term, not the CHEBI class (see #4854)

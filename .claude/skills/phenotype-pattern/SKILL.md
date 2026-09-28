---
name: phenotype-pattern
description: Use when creating a FYPO term or changing its logical definition (EquivalentClasses). Catalogues FYPO's has_part EQ patterns, the relations and PATO qualities used, and how to copy the pattern from sibling terms. No EquivalentClasses axiom should be written without using this skill.
---

## The general shape

Nearly every FYPO logical definition (6,100+ of them) is:

```
FYPO_X EquivalentTo: has_part some (Q and R1 some E1 and R2 some E2 ... [and qualifier some abnormal|normal|present])
```

in functional syntax:

```
EquivalentClasses(<FYPO_X> ObjectSomeValuesFrom(<BFO_0000051> ObjectIntersectionOf(<Q> ObjectSomeValuesFrom(<R1> <E1>) ...)))
```

`Q` is a PATO quality, or (for "growth on X" and composite phenotypes) a FYPO
class. The logical definition is necessary AND sufficient; label, text
definition and axiom must say the same thing.

## Read axioms with labels

The raw syntax is hard to read. Use the helper:

```
python3 .claude/skills/phenotype-pattern/show-term.py FYPO_0010105 FYPO_0005490
python3 .claude/skills/phenotype-pattern/show-term.py --label 'abolished protein localization to'
```

## Method: copy from siblings

1. Find 3-5 existing terms whose labels parallel the requested one (same
   leading phrase, e.g. "abolished protein localization to ...",
   "increased cellular ... level", "sensitive to ..."), with
   `show-term.py --label '<phrase>'`.
2. Copy from the closest family, and within it prefer the most recent terms
   (highest FYPO IDs). Families differ in details that look interchangeable
   but are not: e.g. `during` (GOREL_0000002) vs `happens_during`
   (GOREL_0000001), and `inheres_in` (RO_0000052) vs `inheres_in_part_of`
   (RO_0002314), are both in current use in different families. Match the
   family; never mix. Do not "fix" existing terms unless asked.
3. Copy the sibling's axiom and change only the differing filler(s): the GO
   process/component, the CHEBI chemical, the PATO quality.
4. Copy the sibling's asserted parent(s) too, adjusted to the new term.
5. If siblings disagree with each other, or you can find no sibling, say so on
   the issue/PR and describe the choice you made, or leave the logical
   definition off (labels `logical_def_required_later` exist for this).

## Relations

| IRI | label | typical filler |
|---|---|---|
| BFO_0000051 | has_part | outer wrapper, also FYPO parts in composite phenotypes |
| RO_0000052 | inheres_in (characteristic of) | GO process/function/component, CL_0000334, BTO_0000316, GO_0072690 |
| RO_0002314 | inheres_in_part_of | GO process (localization, "abnormal X" process terms) |
| RO_0002503 | towards | CHEBI (chemical), SO, PR |
| RO_0002573 | qualifier | PATO_0000460 abnormal, PATO_0000461 normal, PATO_0000467 present |
| GOREL_0000001 | happens_during | GO_0072690 vegetative growth phase, cell cycle phases |
| GOREL_0000002 | during | older form of the above |
| GOREL_0000032 | exists_during | GO_0072690 (for states: levels, morphology) |
| GOREL_0000501 | occurs_at | SO region (e.g. recombination at LTR) |
| RO_0002092 | happens during | nested inside a GO filler: `inheres_in some (GO_X and happens_during some GO_response)` for "... during cellular response to ..." |

Do not introduce relations not in this table without asking. The local
`fypo#...` properties exist but are not used in logical definitions.

## Common qualities

| IRI | label | used for |
|---|---|---|
| PATO_0000001 | quality | generic "abnormal X" (with qualifier abnormal), "normal X" (qualifier normal) |
| PATO_0001558 | lacking processual parts | "abolished X" |
| PATO_0002052 / PATO_0002051 | decreased / increased occurrence | "decreased/increased X" for processes and functions |
| PATO_0000911 / PATO_0000912 | decreased / increased rate | "slow/fast X", rate terms |
| PATO_0001162 / PATO_0001163 | increased / decreased concentration | cellular chemical or protein/RNA levels |
| PATO_0001551 / PATO_0001552 | increased / decreased sensitivity of a process | "sensitive to X" / "resistance to X" |
| PATO_0000502 | delayed | "delayed X" |
| PATO_0000051 | morphology | "abnormal X morphology" |
| PATO_0000422 | auxotrophic | "growth auxotrophic for X" |
| PATO_0002000 | lacks all parts of type | "absence of X" (structures) |

Never use BFO_0000019 as the quality (see #4855); use PATO_0000001.

Look up any other PATO term's label in merged_import.owl before using it.

## Common shapes (counts from the edit file, with a recent exemplar)

| shape (besides has_part + Q) | n | exemplar |
|---|---|---|
| inheres_in (GO_X and happens_during GO_response) | 645 | FYPO_0010089 decreased protein localization to nuclear envelope during cellular response to nitrogen starvation |
| inheres_in GO | 431 | FYPO_0010103 increased ribosome binding (molecular function) |
| happens_during GO_0072690, inheres_in_part_of GO, qualifier abnormal | 427 | FYPO_0010115 abnormal mitochondrial gene expression |
| inheres_in GO, qualifier abnormal | 422 | FYPO_0010090 abolished nucleophagy |
| inheres_in GO_0072690, towards CHEBI | 377 | FYPO_0010041 resistance to fatty acid |
| happens_during GO_0072690, inheres_in GO, qualifier normal | 349 | FYPO_0008372 normal protein localization to cell surface during vegetative growth |
| exists_during GO_0072690, inheres_in CL_0000334, towards CHEBI | 262 | FYPO_0010099 increased cellular phosphatidylinositol level |
| during GO, inheres_in GO, qualifier abnormal | 246 | FYPO_0010097 decreased 7-methylguanosine cap hypermethylation |
| inheres_in_part_of GO, qualifier abnormal | 192 | FYPO_0008430 abnormal lipid droplet formation |
| happens_during GO, occurs_at SO, inheres_in GO | 157 | FYPO_0010080 increased DNA recombination at long terminal repeat region |
| (FYPO_0001357 as Q) inheres_in BTO_0000316, towards CHEBI, qualifier | 154 | FYPO_0008442 normal growth on ethylenediaminetetraacetic acid |
| happens_during GO x2, inheres_in GO | 129 | FYPO_0010114 premature protein localization to mitotic spindle pole body during G2 phase |
| exists_during GO, inheres_in GO | 103 | FYPO_0009105 mislocalized nucleus during mitotic telophase |
| (FYPO_0000002 as Q) has_part FYPO x2-3, exists_during GO_0072690 | ~130 | FYPO_0007702 inviable elongated cell with cell cycle arrest at mitotic G2/M phase transition (composite) |

Run `show-term.py` on the exemplar before copying it.

## Checklist

- [ ] at least 3 sibling terms consulted (list them in the PR)
- [ ] axiom shape identical to the most recent siblings, except the intended fillers
- [ ] every filler ID confirmed by label (none guessed)
- [ ] quality is PATO (never BFO_0000019)
- [ ] label, text definition and axiom say the same thing
- [ ] reasoner check: no unintended equivalence; inferred parents sensible

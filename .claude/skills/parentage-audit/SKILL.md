---
name: parentage-audit
description: For "missing parentage", "wrong parent", "parentage check" and branch-review requests in FYPO - finding terms whose asserted or inferred parents are missing or wrong, and fixing them. Includes scripted checks for logical definitions that use obsolete GO/BTO/CHEBI classes and for terms that fall under both normal and abnormal phenotype.
---

## Why FYPO parentage breaks

1. **Obsolete fillers.** Much of FYPO's hierarchy is inferred by the reasoner
   from logical definitions that use GO terms. When GO obsoletes a term
   (e.g. the histone modification terms), every FYPO term defined with it
   loses its inferred parents (#4853).
2. **Sibling EQs pulling terms into the wrong branch.** A composite or
   precomposed term can be inferred under "normal ..." because of how a
   parent's logical definition is written (#4827).
3. **Parallel branches not linked.** e.g. "increased histone H3-K9
   dimethylation at centromere" should be under "increased histone H3-K9
   methylation at centromere"; the specific term was placed only by its GO
   filler, so when that link weakened, nothing connected the two.

## Tools

Build the reasoned ontology once (ODK container, from `src/ontology`):

```
robot reason -i fypo-edit.owl -r ELK --equivalent-classes-allowed asserted-only -o tmp/fypo-reasoned.ofn
```

Then, from the repo root:

```
# logical definitions that use obsolete classes (TSV)
python3 .claude/skills/parentage-audit/audit.py deprecated-fillers

# terms under both 'normal phenotype' and 'abnormal phenotype'
python3 .claude/skills/parentage-audit/audit.py normal-abnormal src/ontology/tmp/fypo-reasoned.ofn

# read a term's axioms with labels
python3 .claude/skills/phenotype-pattern/show-term.py FYPO_0000874

# inferred parents of a term
grep '^SubClassOf(<http://purl.obolibrary.org/obo/FYPO_0000874>' src/ontology/tmp/fypo-reasoned.ofn
```

`normal-abnormal` output needs triage: composite phenotypes such as "abnormal
cell shape, normal cell size" are legitimately under both. Flag only the
ones where the label is purely normal or purely abnormal.

## Procedure for a branch review

1. Scope: identify the branch (a root term and its descendants) from the
   issue. List its members with labels, using `show-term.py --label` or by
   walking `SubClassOf` edges in the reasoned file.
2. Run `deprecated-fillers`, restricted to the branch (grep the output).
3. Look for parallel label families that should nest: for each term, derive
   the expected more general label (drop "di"/"tri", drop "at <region>",
   drop "during vegetative growth", "abolished"/"decreased" -> "abnormal", etc.)
   and check the more general term exists and is an ancestor in the reasoned
   file.
4. Check the reasoned placement of anything suspicious (normal vs abnormal,
   process vs cell phenotype).
5. Report findings on the issue as a table (term, problem, proposed fix)
   BEFORE bulk-editing, unless the requester asked you to go ahead. Curators
   have indicated they want to decide on the modelling for whole branches
   (e.g. what to do when the GO terms a branch was defined with are gone).

## Fixing

- Missing parent: add an asserted `SubClassOf` to the parallel general term
  (FYPO asserts parents; this is normal practice, not a workaround).
- Obsolete GO filler: if GO gives a `replaced_by`, and the replacement means
  the same thing in this context, swap it in the logical definition (add it to
  `imports/go_terms.txt` if needed). If there is no replacement (common for the
  histone modification terms), do NOT invent a new pattern; assert parents so
  the hierarchy is preserved, and raise the modelling question on the issue.
- Wrong inferred parent: find which axioms cause it (from `src/ontology`):
  `robot explain -i fypo-edit.owl -r ELK -a "FYPO:0002429 SubClassOf FYPO:0000257" -e tmp/explain.md`
  This writes a labelled markdown explanation. For #4827 it shows the cause
  is `has_part` transitivity through a composite parent's logical definition
  (`has_part some normal vegetative cell size`). Propose a fix; do not
  silently delete a logical definition.

Follow the EDITS procedure in CLAUDE.md (edit, `robot convert` to normalise,
check the diff), then re-run the audits to show the problem is gone.

## Checklist

- [ ] scope of the audit stated (which branch, how many terms examined)
- [ ] audit scripts run; relevant output included in the issue/PR
- [ ] each fix has a stated reason
- [ ] re-run after edits shows the issues resolved
- [ ] modelling questions raised rather than guessed

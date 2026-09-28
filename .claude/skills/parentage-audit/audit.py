#!/usr/bin/env python3
"""FYPO hierarchy audits. Run from the repo root.

    python3 .claude/skills/parentage-audit/audit.py deprecated-fillers
        Live FYPO terms whose logical definition uses an obsolete class
        (from the edit file or the imports). These lose reasoner-derived
        parentage when the external term is obsoleted (e.g. #4853).

    python3 .claude/skills/parentage-audit/audit.py normal-abnormal src/ontology/tmp/fypo-reasoned.ofn
        Terms that end up (asserted or inferred) under both 'normal phenotype'
        (FYPO_0000257) and 'abnormal phenotype' (FYPO_0001985), e.g. #4827.
        Needs a reasoned file: robot reason -i fypo-edit.owl -r ELK
        --equivalent-classes-allowed asserted-only -o tmp/fypo-reasoned.ofn

Both print TSV.
"""

import re
import sys
from collections import defaultdict
from pathlib import Path

OBO = "http://purl.obolibrary.org/obo/"
ROOT = Path(__file__).resolve().parents[3]
EDIT = ROOT / "src/ontology/fypo-edit.owl"
IMPORT = ROOT / "src/ontology/imports/merged_import.owl"
NORMAL = OBO + "FYPO_0000257"
ABNORMAL = OBO + "FYPO_0001985"

LABEL_RE = re.compile(r'^AnnotationAssertion\(rdfs:label <([^>]+)> "([^"]*)"', re.M)
DEPRECATED_RE = re.compile(r'^AnnotationAssertion\(owl:deprecated <([^>]+)> "true"', re.M)
EQ_RE = re.compile(r"^EquivalentClasses\(<(" + re.escape(OBO) + r"FYPO_\d+)> (.*)$", re.M)
SUBCLASS_RE = re.compile(r"^SubClassOf\(<([^>]+)> <([^>]+)>\)$", re.M)


def short(iri: str) -> str:
    """
    >>> short("http://purl.obolibrary.org/obo/GO_0036123")
    'GO_0036123'
    """
    return iri[len(OBO):] if iri.startswith(OBO) else iri


def ancestors(parents: dict, node: str) -> set:
    """Reflexive-transitive closure over a child -> parents map.

    >>> sorted(ancestors({"a": {"b"}, "b": {"c"}}, "a"))
    ['a', 'b', 'c']
    """
    seen, stack = set(), [node]
    while stack:
        n = stack.pop()
        if n not in seen:
            seen.add(n)
            stack.extend(parents.get(n, ()))
    return seen


def deprecated_fillers() -> None:
    edit, imp = EDIT.read_text(), IMPORT.read_text()
    labels = dict(LABEL_RE.findall(imp))
    labels.update(LABEL_RE.findall(edit))
    deprecated = set(DEPRECATED_RE.findall(imp)) | set(DEPRECATED_RE.findall(edit))
    print("fypo_id\tfypo_label\tobsolete_filler\tfiller_label")
    for fid, axiom in EQ_RE.findall(edit):
        if fid in deprecated:
            continue
        for iri in sorted(set(re.findall(r"<([^>]+)>", axiom)) & deprecated):
            print(f"{short(fid)}\t{labels.get(fid, '')}\t{short(iri)}\t{labels.get(iri, '')}")


def normal_abnormal(reasoned: Path) -> None:
    text = reasoned.read_text()
    labels = dict(LABEL_RE.findall(text))
    parents = defaultdict(set)
    for child, parent in SUBCLASS_RE.findall(text):
        parents[child].add(parent)
    print("fypo_id\tfypo_label")
    for node in sorted(n for n in parents if n.startswith(OBO + "FYPO_")):
        anc = ancestors(parents, node)
        if NORMAL in anc and ABNORMAL in anc:
            print(f"{short(node)}\t{labels.get(node, '')}")


if __name__ == "__main__":
    if sys.argv[1:2] == ["deprecated-fillers"]:
        deprecated_fillers()
    elif sys.argv[1:2] == ["normal-abnormal"] and len(sys.argv) == 3:
        normal_abnormal(Path(sys.argv[2]))
    else:
        sys.exit(__doc__)

#!/usr/bin/env python3
"""Show FYPO terms' logical axioms with labels, for reading functional syntax.

Usage (from the repo root):

    python3 .claude/skills/phenotype-pattern/show-term.py FYPO_0010105 [FYPO_... ...]
    python3 .claude/skills/phenotype-pattern/show-term.py --label 'abolished protein localization to'

Prints each matching term's label, definition, SubClassOf parents and
EquivalentClasses axiom, with every IRI rendered as ID 'label'. Labels are
read from src/ontology/fypo-edit.owl and src/ontology/imports/merged_import.owl.
"""

import re
import sys
from pathlib import Path

OBO = "http://purl.obolibrary.org/obo/"
ROOT = Path(__file__).resolve().parents[3]
EDIT = ROOT / "src/ontology/fypo-edit.owl"
IMPORT = ROOT / "src/ontology/imports/merged_import.owl"

LABEL_RE = re.compile(r'^AnnotationAssertion\(rdfs:label <([^>]+)> "([^"]*)"', re.M)


def short(iri: str) -> str:
    """Strip the OBO PURL base from an IRI.

    >>> short("http://purl.obolibrary.org/obo/FYPO_0010105")
    'FYPO_0010105'
    >>> short("http://purl.obolibrary.org/obo/fypo#qualifier")
    'fypo#qualifier'
    """
    return iri[len(OBO):] if iri.startswith(OBO) else iri


def render(axiom: str, labels: dict) -> str:
    """Replace each <IRI> in an axiom with its short ID and label.

    >>> render("SubClassOf(<http://purl.obolibrary.org/obo/FYPO_1> <http://purl.obolibrary.org/obo/PATO_2>)",
    ...        {"http://purl.obolibrary.org/obo/PATO_2": "abnormal"})
    "SubClassOf(FYPO_1 PATO_2 'abnormal')"
    """
    def sub(m):
        iri = m.group(1)
        label = labels.get(iri)
        return f"{short(iri)} '{label}'" if label else short(iri)
    return re.sub(r"<([^>]+)>", sub, axiom)


def main(argv: list) -> None:
    edit = EDIT.read_text()
    labels = dict(LABEL_RE.findall(IMPORT.read_text()))
    labels.update(LABEL_RE.findall(edit))
    if argv and argv[0] == "--label":
        needle = argv[1].lower()
        ids = [short(i) for i, lab in labels.items() if i.startswith(OBO + "FYPO_") and needle in lab.lower()]
    else:
        ids = argv
    for fid in ids:
        iri = OBO + fid.replace(":", "_")
        print(f"== {short(iri)} '{labels.get(iri)}'")
        for line in edit.splitlines():
            if line.startswith((f"EquivalentClasses(<{iri}>", f"SubClassOf(<{iri}>")):
                print("  " + render(line, labels))
            elif line.startswith("AnnotationAssertion(") and f"IAO_0000115> <{iri}>" in line:
                print("  def: " + line.split(f"<{iri}> ", 1)[1].rstrip(")"))
        print()


if __name__ == "__main__":
    main(sys.argv[1:])

# checkout fypo-edit.obo from master

set -e

echo "Checking out"
cd ~/ws/fypo
git fetch
git checkout origin/master -- fypo_edit.obo
cp fypo_edit.obo src/ontology/fypo-edit.obo

echo "Running substitutions"
cd ~/ws/fypo/src/ontology
sed -i '' '/^[<]/d' fypo-edit.obo
sed -i '' '/^xref[:][ ]BFO[:]0000062/d' fypo-edit.obo #precedes
sed -i '' '/^xref[:][ ]BFO[:]0000063/d' fypo-edit.obo #preceded by
sed -i '' '/^xref[:][ ]RO[:]0002353/d' fypo-edit.obo #output of
sed -i '' '/^xref[:][ ]RO[:]0002234/d' fypo-edit.obo #has output
sh run.sh sed -i 's/^name[:] qualifier/name: qualifier\nxref: RO:0002573/g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/bto_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/cl_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/ro_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/iao_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/go_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/cl_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/pato_import.owl!g' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/imports/so_import.owl!g' fypo-edit.obo

echo "Moving EQs to component"
sh run.sh robot filter -i ../ontology/fypo-edit.obo --axioms "EquivalentClasses" --preserve-structure false annotate --ontology-iri http://purl.obolibrary.org/obo/fypo/components/fypo-eqs.owl -o ../ontology/components/fypo-eqs.ofn
mv ../ontology/components/fypo-eqs.ofn ../ontology/components/fypo-eqs.owl
sed -i '' '/^intersection_of[:]/d' fypo-edit.obo
sh run.sh sed -i 's!^ontology[:] fypo!ontology: fypo\nimport: http://purl.obolibrary.org/obo/fypo/components/fypo-eqs.owl!g' fypo-edit.obo


echo "Running release"
sh run.sh make IMP=false prepare_release

#sh run.sh robot diff --left fypo.owl --right-iri http://purl.obolibrary.org/obo/fypo.owl -o fypo_diff.txt


- id: ro
- id: iao
- id: chebi
- id: go
- id: cl
- id: pato
- id: so
- id: bto

# checkout fypo-edit.obo from master

set -e

cd ~/ws/fypo
git fetch
git checkout origin/master -- fypo_edit.obo
cp fypo_edit.obo src/ontology/fypo-edit.obo

cd ~/ws/fypo/src/scripts
sh run.sh robot filter -i ../ontology/fypo-edit.obo --axioms "EquivalentClasses" --preserve-structure false -o ../ontology/components/fypo-eqs.ofn
mv ../ontology/components/fypo-eqs.ofn ../ontology/components/fypo-eqs.owl
sed -i '/^intersection_of[:]/d' src/ontology/fypo-edit.obo


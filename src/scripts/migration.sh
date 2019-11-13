# checkout fypo-edit.obo from master

set -e

cd ~/ws/fypo
git fetch
git checkout origin/master -- fypo_edit.obo
cp fypo_edit.obo src/ontology/fypo-edit.obo

cd ~/ws/fypo/src/ontology
sh run.sh robot filter -i ../ontology/fypo-edit.obo --axioms "EquivalentClasses" --preserve-structure false -o ../ontology/components/fypo-eqs.ofn
mv ../ontology/components/fypo-eqs.ofn ../ontology/components/fypo-eqs.owl
sed -i '' '/^intersection_of[:]/d' fypo-edit.obo
sed -i '' '/^[<]/d' fypo-edit.obo
sed -i '' '/^xref[:][ ]BFO[:]0000062/d' fypo-edit.obo
sed -i '' '/^xref[:][ ]BFO[:]0000063/d' fypo-edit.obo
sed -i '' '/^xref[:][ ]RO[:]0002353/d' fypo-edit.obo
sed -i '' '/^xref[:][ ]RO[:]0002234/d' fypo-edit.obo

echo "WARN: Add xref: RO:0002573 to qualifier typedef!"



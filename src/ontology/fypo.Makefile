## Customize Makefile settings for fypo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

pre_release:
	$(ROBOT) merge -i $(SRC) -i import-statements.owl -o fypo-edit-release.owl

fix=qdi
fix_patterns=$(sort $(foreach r,$(fix), fixpattern_$(r)))

tmp/fixpattern_old_%.tsv: components/fypo-eqs.owl
	dosdp-tools query --ontology=$< --reasoner=elk --obo-prefixes=true --template=../patterns/dosdp-patterns/old_$*.yaml --outfile=$@
.PRECIOUS: tmp/fixpattern_old_%.tsv

tmp/fixpattern_%.owl: components/fypo-eqs.owl tmp/fixpattern_old_%.tsv
	dosdp-tools generate --infile=tmp/fixpattern_old_$*.tsv --template=../patterns/dosdp-patterns/new_$*.yaml --ontology=$< --obo-prefixes=true --outfile=$@
.PRECIOUS: tmp/fixpattern_%.owl

tmp/remove_%.txt: tmp/fixpattern_%.owl
	$(ROBOT) query -f csv -i $< --query ../sparql/fypo_terms.sparql $@

fixpattern_%: tmp/fixpattern_%.owl tmp/remove_%.txt
	$(ROBOT) remove -i components/fypo-eqs.owl --term-file tmp/remove_$*.txt --axioms equivalent --trim false --preserve-structure false -o $@
	$(ROBOT) merge -i components/fypo-eqs.owl -i $< -o $@

fix_patterns: $(fix_patterns)

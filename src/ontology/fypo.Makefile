## Customize Makefile settings for fypo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

pre_release:
	$(ROBOT) merge -i $(SRC) -i import-statements.owl -o fypo-edit-release.owl

fix=qdi qodiipoq qpiipoq qodiq qodi qpi qoiq qoi qoiipoq
fix_patterns=$(sort $(foreach r,$(fix), fixpattern_$(r)))

tmp/fixpattern_old_%.tsv: components/fypo-eqs.owl
	dosdp-tools query --ontology=$< --reasoner=elk --obo-prefixes=true --template=../patterns/dosdp-patterns/old_$*.yaml --outfile=$@
.PRECIOUS: tmp/fixpattern_old_%.tsv

tmp/fixpattern_%.owl: components/fypo-eqs.owl tmp/fixpattern_old_%.tsv
	dosdp-tools generate --infile=tmp/fixpattern_old_$*.tsv --template=../patterns/dosdp-patterns/new_$*.yaml --ontology=$< --obo-prefixes=true --outfile=$@
.PRECIOUS: tmp/fixpattern_%.owl

tmp/remove_%.txt: tmp/fixpattern_%.owl
	$(ROBOT) query -f csv -i $< --query ../sparql/fypo_terms.sparql $@
	echo "http://purl.obolibrary.org/obo/FYPO_0000128" $@
.PRECIOUS: tmp/remove_%.txt

fixpattern_%: tmp/fixpattern_%.owl tmp/remove_%.txt
	$(ROBOT) remove -i components/fypo-eqs.owl --term-file tmp/remove_$*.txt --axioms equivalent --preserve-structure false -o tmp/fypo-eqs.ofn
	$(ROBOT) merge -i tmp/fypo-eqs.ofn -i $< -o components/fypo-eqs.ofn && mv components/fypo-eqs.ofn components/fypo-eqs.owl

fix_patterns: $(fix_patterns)
	java -jar ../scripts/add-haspart-buffer.jar components/fypo-eqs.owl
	#echo "REMOVING AUXOTROPHY"
	#$(ROBOT) remove -i components/fypo-eqs.owl --term FYPO:0000128 --axioms equivalent --preserve-structure false -o tmp/fypo-eqs.ofn
	#mv tmp/fypo-eqs.ofn components/fypo-eqs.owl

merge_eqs:
	$(ROBOT) merge -i $(SRC) -i components/has_part_fypo-eqs.owl --collapse-import-closure false convert --check false -f obo -o "merged_"$(SRC) && mv "merged_"$(SRC) $(SRC)
	
diff:
	$(ROBOT) diff --right-iri $(URIBASE)/fypo.owl --left ../../fypo.owl -o diff.txt
	
obo:
	$(ROBOT) -vvv merge -i $(SRC) --collapse-import-closure false convert -f obo -o "merged_"$(SRC)

pombase: $(ONT)-simple-pombase.obo

$(ONT)-simple-pombase.obo:
	$(ROBOT) merge -i $(ONT)-simple.owl -i components/lost-inferred-subsumptions-pre-odk.owl \
		reason --reasoner ELK --equivalent-classes-allowed asserted-only --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
		convert --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo

prepare_release: $(ASSETS) $(PATTERN_RELEASE_FILES) $(ONT)-simple-pombase.obo
	rsync -R $(ASSETS) $(RELEASEDIR) &&\
  rm -f $(MAIN_FILES) $(SRCMERGED) &&\
  mv $(ONT)-simple-pombase.obo $(RELEASEDIR) &&\
  echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release on your git hosting site such as GitHub or GitLab"


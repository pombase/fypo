set -e

robot diff --left fypo.obo --right-iri http://purl.obolibrary.org/obo/fypo.obo -o diff_fypo_obo.txt
robot diff --left fypo.owl --right-iri http://purl.obolibrary.org/obo/fypo.owl -o diff_fypo_owl.txt

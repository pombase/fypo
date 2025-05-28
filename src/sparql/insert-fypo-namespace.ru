PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

INSERT {
  ?term oboInOwl:hasOBONamespace "fission_yeast_phenotype" .
}
WHERE {
  ?term a owl:Class .
  FILTER(isIRI(?term))
  FILTER(STRSTARTS(STR(?term), "http://purl.obolibrary.org/obo/FYPO_"))
}

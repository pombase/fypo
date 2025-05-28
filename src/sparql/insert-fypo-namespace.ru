PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

INSERT {
  ?term oboInOwl:hasOBONamespace "fission_yeast_phenotype" .
}
WHERE {
  ?term a owl:Class .
  FILTER(isIRI(?term))
  FILTER(STRSTARTS(STR(?term), "http://purl.obolibrary.org/obo/FYPO_"))
}

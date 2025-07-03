PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

DELETE {
  ?term oboInOwl:hasOBONamespace ?o .
}
WHERE {
  ?term a owl:Class .
  ?term oboInOwl:hasOBONamespace ?o .
  FILTER(isIRI(?term))
  FILTER(STRSTARTS(STR(?term), "http://purl.obolibrary.org/obo/FYPO_"))
}

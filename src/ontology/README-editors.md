These notes are for the EDITORS of fypo

This project was created using the [ontology development kit](https://github.com/INCATools/ontology-development-kit). See the site for details.

For more details on ontology management, please see the [OBO tutorial](https://github.com/jamesaoverton/obo-tutorial) or the [Gene Ontology Editors Tutorial](https://go-protege-tutorial.readthedocs.io/en/latest/)

You may also want to read the [GO ontology editors guide](http://go-ontology.readthedocs.org/)

## Requirements

 1. Protege (for editing)
 2. A git client (we assume command line git)
 3. [docker](https://www.docker.com/get-docker) (for managing releases)

## Editors Version

Make sure you have an ID range in the [idranges file](fypo-idranges.owl)

If you do not have one, get one from the maintainer of this repo.

The editors version is [fypo-edit.owl](fypo-edit.owl)

** DO NOT EDIT fypo.obo OR fypo.owl in the top level directory **

[../../fypo.owl](../../fypo.owl) is the release version

To edit, open the file in Protege. First make sure you have the repository cloned, see [the GitHub project](https://github.com/pombase/fypo) for details.

You should discuss the git workflow you should use with the maintainer
of this repo, who should document it here. If you are the maintainer,
you can contact the odk developers for assistance. You may want to
copy the flow an existing project, for example GO: [Gene Ontology
Editors Tutorial](https://go-protege-tutorial.readthedocs.io/en/latest/).

In general, it is bad practice to commit changes to master. It is
better to make changes on a branch, and make Pull Requests.

## ID Ranges

These are stored in the file

 * [fypo-idranges.owl](fypo-idranges.owl)

** ONLY USE IDs WITHIN YOUR RANGE!! **

If you have only just set up this repository, modify the idranges file
	and add yourself or other editors. Note Protege does not read the file
- it is up to you to ensure correct Protege configuration.


### Setting ID ranges in Protege

We aim to put this up on the technical docs for OBO on http://obofoundry.org/

For now, consult the [GO Tutorial on configuring Protege](http://go-protege-tutorial.readthedocs.io/en/latest/Entities.html#new-entities)

## Imports

All import modules are in the [imports/](imports/) folder.

There are two ways to include new classes in an import module

 1. Reference an external ontology class in the edit ontology. In Protege: "add new entity", then paste in the PURL
 2. Add to the imports/fypo_terms.txt file

After doing this, you can run

`./run.sh make all_imports`

to regenerate imports.

Note: the fypo_terms.txt file may include 'starter' classes seeded from
the ontology starter kit. It is safe to remove these.

## Design patterns

You can automate (class) term generation from design patterns by placing DOSDP
yaml file and tsv files under src/patterns. Any pair of files in this
folder that share a name (apart from the extension) are assumed to be
a DOSDP design pattern and a corresponding tsv specifying terms to
add.

Design patterns can be used to maintain and generate complete terms
(names, definitions, synonyms etc) or to generate logical axioms
only, with other axioms being maintained in editors file.  This can be
specified on a per-term basis in the TSV file.

Design pattern docs are checked for validity via Travis, but can be
tested locally using

`./run.sh make patterns`

In addition to running standard tests, this command generates an owl
file (`src/patterns/pattern.owl`), which demonstrates the relationships
between design patterns.

(At the time of writing, the following import statements need to be
added to `src/patterns/pattern.owl` for all imports generated in
`src/imports/*_import.owl`.   This will be automated in a future release.')

To compile design patterns to terms run:

`./run.sh make ../patterns/definitions.owl`

This generates a file (`src/patterns/definitions.owl`).  You then need
to add an import statement to the editor's file to import the
definitions file.


## Release Manager notes

You should only attempt to make a release AFTER the edit version is
committed and pushed, AND the travis build passes.

These instructions assume you have
[docker](https://www.docker.com/get-docker). This folder has a script
[run.sh](run.sh) that wraps docker commands.

to release:

first type

    git branch

to make sure you are on master

    cd src/ontology
    ./build.sh

If this looks good type:

    ./prepare_release.sh

This generates derived files such as fypo.owl and fypo.obo and places
them in the top level (../..).

Note that the versionIRI value automatically will be added, and will
end with YYYY-MM-DD, as per OBO guidelines.

Commit and push these files.

    git commit -a

And type a brief description of the release in the editor window

Finally type:

    git push origin master

IMMEDIATELY AFTERWARDS (do *not* make further modifications) go here:

 * https://github.com/pombase/fypo/releases
 * https://github.com/pombase/fypo/releases/new

__IMPORTANT__: The value of the "Tag version" field MUST be

    vYYYY-MM-DD

The initial lowercase "v" is REQUIRED. The YYYY-MM-DD *must* match
what is in the `owl:versionIRI` of the derived fypo.owl (`data-version` in
fypo.obo). This will be today's date.

This cannot be changed after the fact, be sure to get this right!

Release title should be YYYY-MM-DD, optionally followed by a title (e.g. "january release")

You can also add release notes (this can also be done after the fact). These are in markdown format.
In future we will have better tools for auto-generating release notes.

Then click "publish release"

__IMPORTANT__: NO MORE THAN ONE RELEASE PER DAY.

The PURLs are already configured to pull from github. This means that
BOTH ontology purls and versioned ontology purls will resolve to the
correct ontologies. Try it!

 * http://purl.obolibrary.org/obo/fypo.owl <-- current ontology PURL
 * http://purl.obolibrary.org/obo/fypo/releases/YYYY-MM-DD.owl <-- change to the release you just made

For questions on this contact Chris Mungall or email obo-admin AT obofoundry.org

# Travis Continuous Integration System

Check the build status here: [![Build Status](https://travis-ci.org/pombase/fypo.svg?branch=master)](https://travis-ci.org/pombase/fypo)

Note: if you have only just created this project you will need to authorize travis for this repo.

 1. Go to [https://travis-ci.org/profile/pombase](https://travis-ci.org/profile/pombase)
 2. click the "Sync account" button
 3. Click the tick symbol next to fypo

Travis builds should now be activated

# FYPO synonyms pipeline

The goal of the synonym pipeline is to bulk add a lot of synonyms rapidly using a spreadsheet. The steps are as follows:

1. Edit the *throw away* template in `src/templates/bulk_synonyms.tsv`. Note that this tsv really is single use only - after the pipeline is run and you are happy with the results, you should remove all the synonyms in it (you can keep the tsv of course for future use.)
   * You will notice: synonyms are separated by the pipe `|` character. 
   * xrefs can be added, again `|` separated, in the column immediately to the right of the synonym
   * I have added columns for exact, narrow, broad and related synonyms. Any column can be left blank!
2. If you are unsure, you can run `sh run.sh make ../templates/bulk_synonyms.owl -B` to simply compile the template to look at it (`../templates/bulk_synonyms.owl`) in a text editor. Not necessary.
3. If you are ready with the template, run `sh run.sh make synonyms -B`. This will first turn the tsv into OWL, then merge it into `fypo-edit.obo`.
4. To review what you did, run `git diff fypo-edit.obo | grep -v '[+-]owl' > diff.txt` and review diff.txt. If it all looks as expected, delete diff.txt (dont accidentally commit!), you can commit.
   * Note the `| grep -v '[+-]owl'` in the `git diff` command. The point of this to exclude the huge diff that this stupid EQ blop in the beginning of the OBO file always gives - just noise.

Example bulk_synonyms.tsv file:

```
Term import ID	Synonym	S xref	Narrow synonym	NS xref	Broad synonym	BS xref	Related synonym	RS xref
ID	A oboInOwl:hasExactSynonym SPLIT=|	>A oboInOwl:hasDbXref SPLIT=|	A oboInOwl:hasNarrowSynonym SPLIT=|	>A oboInOwl:hasDbXref SPLIT=|	A oboInOwl:hasBroadSynonym SPLIT=|	>A oboInOwl:hasDbXref SPLIT=|	A oboInOwl:hasRelatedSynonym SPLIT=|	>A oboInOwl:hasDbXref SPLIT=|
FYPO:0001431	syn1|syn2	xref1|xref2	syn1|syn2	xref1|xref2	syn1|syn2	xref1|xref2	syn1|syn2	xref1|xref2
FYPO:0001432			syn3|syn4	xref3|xref4	syn3|syn4	xref3|xref4	syn3|syn4	xref3|xref4
```
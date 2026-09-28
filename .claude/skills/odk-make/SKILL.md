---
name: odk-make
description: Use whenever you run a Makefile target (e.g. `make test`) or a ROBOT command (convert, reason, explain, report) on FYPO. These must run inside the pinned ODK Docker image, not against host tools. Covers validation, reasoning and normalising the edit file.
---

## The core rule

`make` targets and `robot` commands must run in the ODK image
(`obolibrary/odkfull`) at the version CI uses, which is pinned in
`.github/workflows/qc.yml` (currently `v1.6`). Host tools may be missing or a
different version.

## Which environment am I in?

- **GitHub Actions (`ai4c-agent`)**: the job already runs inside
  `obolibrary/odkfull:v1.6`. Call `make` / `robot` directly from
  `src/ontology`. Don't nest Docker.
- **Local workstation**: use the wrapper, which works from anywhere in the repo
  and runs in `src/ontology` inside the container:

```
.claude/skills/odk-make/odk-run.sh make test IMP=false PAT=false MIR=false
.claude/skills/odk-make/odk-run.sh robot convert -i fypo-edit.owl --format ofn -o fypo-edit.owl
```

Do not use `src/ontology/run.sh` non-interactively: it requests a TTY and
defaults to `odkfull:latest`, not the CI version.

If unsure: `robot --version` working on the bare PATH and a `/work` or
`/__w` working directory mean you are inside ODK.

## Commands

All paths relative to `src/ontology`.

| Goal | Command |
|---|---|
| CI validation (what `qc.yml` runs) | `make ROBOT_ENV='ROBOT_JAVA_ARGS=-Xmx6G' test IMP=false PAT=false MIR=false` |
| Normalise the edit file after hand edits | `robot convert -i fypo-edit.owl --format ofn -o fypo-edit.owl` |
| Reason, to inspect inferred parents | `robot reason -i fypo-edit.owl -r ELK --equivalent-classes-allowed asserted-only -o tmp/fypo-reasoned.ofn` |
| Explain an inference | `robot explain -i fypo-edit.owl -r ELK -a "FYPO:0002429 SubClassOf FYPO:0000257" -e tmp/explain.md` |
| Explain unsatisfiable classes | `robot explain -i fypo-edit.owl -r ELK -M unsatisfiability --unsatisfiable all -e tmp/explain.md` |
| Syntax error stack trace | `robot convert -vvv -i fypo-edit.owl --format ofn -o tmp/check.ofn` |
| ROBOT report on the edit file | `robot report -i fypo-edit.owl --fail-on none -o tmp/report.tsv` |

`IMP=false PAT=false MIR=false` stops `make` from refreshing imports, patterns
and mirrors: that needs network access and minutes of downloads, and import
refreshes are done separately by maintainers (`update-imports.yml`). Never run
`make` without these flags as part of an edit; never run `refresh-imports`,
`prepare_release`, or the release targets (`make_release.yml` does that).

Allow 15+ minutes for `make test`. The reason/convert/explain commands take a
minute or two each on the 20 MB edit file.

## Gotchas

- Use ELK. Never HermiT on the whole ontology.
- Write scratch output to `src/ontology/tmp/` and never commit it.
- Only commit files you edited (normally `src/ontology/fypo-edit.owl`).
- `robot convert` on the edit file resolves `imports/merged_import.owl`
  through `catalog-v001.xml`; run it from `src/ontology`.

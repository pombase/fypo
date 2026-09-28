#!/bin/sh
# Non-interactive ODK runner for agents.
#
# Like src/ontology/run.sh, but without `-ti` (which fails when no terminal is
# attached) and pinned to the ODK image CI uses. run.sh defaults to
# odkfull:latest; this reads the tag from .github/workflows/qc.yml so local
# results match CI.
#
#   .claude/skills/odk-make/odk-run.sh make test IMP=false PAT=false MIR=false
#   .claude/skills/odk-make/odk-run.sh robot --version
#
# Paths passed to commands are relative to src/ontology (the container workdir).

set -eu

REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
IMG="$(grep -o 'obolibrary/odkfull:[^ "]*' "$REPO/.github/workflows/qc.yml" | head -n1)"
if [ -z "$IMG" ]; then
  echo "odk-run.sh: could not determine ODK image from .github/workflows/qc.yml" >&2
  exit 1
fi

exec docker run --rm -m 12g -e ROBOT_JAVA_ARGS=-Xmx10G -v "$REPO:/work" -w /work/src/ontology "$IMG" "$@"

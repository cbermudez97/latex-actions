#!/bin/sh
set -eux

ROOT="$1"
GITHUB_TOKEN="$2"
REPOSITORY="$3"
PDFNAME="$4"

echo "this repository name is: "
echo "${REPOSITORY}"

cd $(dirname ${ROOT}) && latexmk $(basename ${ROOT}) &> /dev/null && cd /github/workspace

ACCEPT_HEADER="Accept: application/vnd.github.jean-grey-preview+json"
TOKEN_HEADER="Authorization: token ${GITHUB_TOKEN}"
ENDPOINT="https://api.github.com/repos/${REPOSITORY}/releases"

# create release
REL=`curl -H "${ACCEPT_HEADER}" -H "${TOKEN_HEADER}" -X POST "${ENDPOINT}" \
-d "
{
  \"tag_name\": \"v$GITHUB_SHA\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"pdf build\",
  \"draft\": false,
  \"prerelease\": false
}"`

# extract release id
REL_ID=`echo ${REL} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`
echo "Github release created as ID: ${REL_ID}"

# upload built pdf
REL_URL="https://uploads.github.com/repos/${REPOSITORY}/releases/${REL_ID}/assets"

FILE=`echo ${ROOT} | sed -e "s/\(.*\)\(.*\).tex/\1\2.pdf/g"`
echo "Uploading assets ${FILE} as application/pdf..."
NAME="${PDFNAME}.pdf"

curl -v \
    -H "${ACCEPT_HEADER}" \
    -H "${TOKEN_HEADER}" \
    -H "Content-Type: application/pdf" \
    --upload-file "${FILE}" \
    "${REL_URL}?name=${NAME}"
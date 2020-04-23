#!/bin/bash

set -ex

if [ "$TRAVIS_TAG" == "" ]; then
  exit
fi

echo "Setting version: $TRAVIS_TAG"

if [ "${TRAVIS_TAG:0:1}" != "v" ]; then
  echo "TRAVIS VERSION INFO IS NOT CORRECT FORMAT."
  echo "must start with character v"
  exit 1
fi

version_number=${TRAVIS_TAG:1}
semver=( ${version_number//./ } )
major="${semver[0]}"
minor="${semver[1]}"
patch="${semver[2]}"

patch_upper=$((${semver[2]} / 256))
patch_lower=$((${semver[2]} % 256))

cat <<-EOF > RomWBW/Source/ver.inc

#DEFINE	RMJ	${major}
#DEFINE	RMN	${minor}
#DEFINE	RUP	${patch_upper}
#DEFINE	RTP	${patch_lower}
#DEFINE BIOSVER	"${TRAVIS_TAG}"

EOF

printf '%s\n' \
"rmj	equ	${major}" \
"rmn	equ	${minor}" \
"rup	equ	${patch_upper}" \
"rtp	equ	${patch_lower}" \
"biosver	macro" \
"  db	\"${TRAVIS_TAG}\"" \
"	endm" > RomWBW/Source/ver.lib

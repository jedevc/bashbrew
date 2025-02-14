#!/usr/bin/env bash
set -Eeuo pipefail

jq --arg dpkgSmokeTest '[ "$(dpkg --print-architecture)" = "amd64" ]' '
	.matrix.include += [
		.matrix.include[]
		| select(.name | test(" [(].+[)]") | not) # ignore any existing munged builds
		| select(.os | startswith("windows-") | not)
		| .name += " (i386)"
		| .runs.pull = ([
			"# pull i386 variants of base images for multi-architecture testing",
			$dpkgSmokeTest,
			(
				.meta.froms[]
				| ("i386/" + . | @sh) as $i386
				| (
					"docker pull " + $i386,
					"docker tag " + $i386 + " " + @sh
				)
			)
		] | join("\n"))
	]
' "$@"

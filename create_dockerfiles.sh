#!/usr/bin/env bash
set -Eeuo pipefail
versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
eval "set -- $versions"

for version; do
	export version
    echo $version
	rm -rf "$version/"
    variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

    for variant in "${variants[@]}"; do
        export variant

		dir="$version/$variant"
		mkdir -p "$dir"

        echo "processing $dir ..."

        wget -qO "$dir/Dockerfile" 'https://raw.githubusercontent.com/docker-library/tomcat/master/'$version'/jdk17/corretto/Dockerfile'

        sed '1,/FROM/d' "$dir/Dockerfile" > "$dir/Dockerfile.tmp" 
        mv "$dir/Dockerfile.tmp" "$dir/Dockerfile"

        echo "FROM ghcr.io/graalvm/graalvm-ce:ol7-java17\nRUN gu install native-image" | cat - "$dir/Dockerfile" > "$dir/Dockerfile.tmp"
        mv "$dir/Dockerfile.tmp" "$dir/Dockerfile"
    done
done

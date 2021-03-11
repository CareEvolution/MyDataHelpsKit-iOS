#!/bin/zsh

jazzy -c --module MyDataHelpsKit --author "CareEvolution, LLC" --author_url 'https://developer.rkstudio.careevolution.com' --github_url 'https://github.com/CareEvolution/MyDataHelpsKit-iOS' --copyright '<p>©2021 CareEvolution, LLC.</p><p>Have questions about RKStudio? Contact us at <a href="mailto:rkstudio-support@careevolution.com" target="blank">rkstudio-support@careevolution.com</a></p><a target="_blank" href="https://careevolution.com"><img class="ce-logo" src="/images/logo.svg" height="30" alt="CareEvolution"></a>'

# Warn about undocumented symbols
numWarnings=$(jq '.warnings | length' < docs/undocumented.json)
if [ "$numWarnings" -gt 0 ]; then
    echo "$numWarnings warning(s):" >&2
    jq -r -M '.warnings[].symbol' < docs/undocumented.json >&2
fi

# Clean up files we don't want to publish
rm -rf docs/docsets
rm docs/undocumented.json
rm docs/badge.svg

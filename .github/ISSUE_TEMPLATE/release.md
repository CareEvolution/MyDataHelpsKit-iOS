---
name: Release checklist
about: Process for publishing a new public SDK release
title: 'Release <<X.Y>>'
labels: releases

---

## Release description



## Checklist

- [ ] Create a new branch `release/X.Y` off of `main`
- [ ] In Xcode, select the MyDataHelpsKit target, and set the correct version and build numbers in Project Settings
- [ ] Compile MyDataHelpsKit, which regenerates SDKVersion.swift
- [ ] Commit the changes to project.pbxproj and SDKVersion.swift files
- [ ] Create a pull request with your changes
- [ ] Regenerate documentation and create a separate PR for publishing the docs
- [ ] After merging the pull request, create a release tag in GitHub and link back to this issue in the release description.

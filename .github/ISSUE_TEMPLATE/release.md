---
name: Release checklist
about: Process for publishing a new public SDK release
title: 'Release <<X.Y>>'

---

## Release description

TBD

## Checklist

- [ ] Create a new branch off of `main`
- [ ] In Xcode, select the MyDataHelpsKit target, and set the correct version and build numbers in Project Settings
- [ ] Compile MyDataHelpsKit, which regenerates SDKVersion.swift
- [ ] Commit the changes to project.pbxproj and SDKVersion.swift files
- [ ] Create a pull request with your changes
- [ ] After merging the pull request, create a release tag in GitHub and link back to issue in the release description.

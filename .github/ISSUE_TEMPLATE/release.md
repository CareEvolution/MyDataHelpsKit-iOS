---
name: Release checklist
about: Process for publishing a new public SDK release
title: 'Release <<X.Y.Z>>'
labels: releases

---

## Release description



## Checklist

- [ ] Create a new branch `release/X.Y.Z` off of `main`
- [ ] In Xcode, select the MyDataHelpsKit target, and set the correct version and build numbers in Project Settings
- [ ] Compile MyDataHelpsKit, which regenerates SDKVersion.swift and MyDataHelpsKit.podspec
- [ ] Commit the changes to project.pbxproj and SDKVersion.swift files
- [ ] Create a pull request with your changes
- [ ] Regenerate documentation and create a separate PR for publishing the docs
- [ ] Merge the pull request. Create a release tag in GitHub and link back to this issue in the release description. (Swift Package Manager requires the tag to be in format X.Y.Z (full semantic version); include the patch number even if it is `.0`)
- [ ] Publish the new release on Cocoapods trunk

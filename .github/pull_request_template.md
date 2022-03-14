## Overview

Explain your changes, including any Issues or relevant context about why they are needed.

## Security

REMINDER: All file contents are public.

- [ ] I have ensured no secure credentials or sensitive information remain in code, metadata, comments, etc. Of particular note:
    - No temporary testing changes committed such as API base URLs, access tokens, print/log statements, etc.
    - Xcode project/target settings should remain generic. Don't leak team identifiers, code signing info, local filesystem paths, etc.
- [ ] My changes do not introduce any security risks, or any such risks have been properly mitigated.

Describe briefly what security risks you considered, why they don't apply, or how they've been mitigated.

## Checklist

- [ ] All public symbols are documented using Swift Markup comments.
- [ ] If this feature requires a developer doc update, tag @CareEvolution/api-docs.
- [ ] Source code file header comments are clean and standardized. Use "Created by CareEvolution on m/dd/yy".
- [ ] Test and update the example app as needed. The example app should demonstrate all features of the SDK, and it's the most convenient way to test your feature.

Consider "Squash and merge" as needed to keep the commit history reasonable on `main`.

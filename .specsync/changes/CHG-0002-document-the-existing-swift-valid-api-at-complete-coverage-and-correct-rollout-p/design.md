---
change: CHG-0002-document-the-existing-swift-valid-api-at-complete-coverage-and-correct-rollout-p
artifact: design
---

# Design

Use one stable `valid` module because all twelve source files form one public library product and share the same result
and composition model. Map every implementation file explicitly, describe every exported validator family, and link
stable requirements to the existing five test suites. Set the committed contract to 100 percent and include public
documentation and governance policy files in lifecycle enforcement.

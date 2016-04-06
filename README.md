## About
This tool collection allows modifying of HTML files. The supported workflow is replacing (thus unifying) style information.

Calling `html-purify.sh`

1. changes style implementation of the exported HTML
2. (optionally) provides SSH based upload feature to a publishing location

## Features
### Documents to publish
If *html-purify* is working in a directory with source files (e.g. markdown files, that were exported from [Atom](https://atom.io)'s *markdown preview* as HTML), it tries to beautify (and publish) all of these files.
To only select individual files for beautifing and publishing create a sub-directory within the target directory (defaulting to `publish`) and symlink the desired individual source (e.g. markdown) files. (Do not symlink HTML exported files, as they won't be targeted for managing in SCM)

### Resources
External resources (e.g. videos, pdfs) relatively linked in source documents, can be placed in *resources root* (`./resources`).  
When publishing a document (e.g. `foo.md`) all resources belonging to the document, which are contained in a sub-directory below *resources root* (e.g. `./resources/foo` directory or link) are rsyncd to target. To exclude files and folders below *resources root* from syncing, they have to match naming pattern `*.draft` or `.*`.

### Project-specific configuration
Next to global configuration, a project-specific configuration is available allowing to override global settings.
Therefore place file named `.html-purify` in a folder and run _html-purify_ from that folder.

## Caveats
* tool collection sparely tested - it does what I need it for
* documentation of features not complete

## Credits
Style definitions are taken from https://gist.github.com/evertton/4133083.

Thanks you!

## About
This tool collection allows modifying of HTML exported markdown files.  
The supported workflow is saving the markdown's HTML representation from [Atom](https://atom.io)'s *markdown preview* to a HTML file (appending `.html` to the original markdown file name).

Calling `beautify_atom_markdown.sh`

1. changes style implementation of the exported HTML
2. (optionally) provides SSH based upload feature to a publishing location

## Features
### Documents to publish
If beautifier is working in a directory with multiple markdown files, it tries to beautify (and publish) all of these files.
To only select individual files for beautifing and publishing create a sub-directory within the target directory (defaulting to `publish`) and symlink the desired individual *markdown* files. (Do not symlink HTML exported files, as they won't be targeted for managing in SCM)

## Caveats
* tool collection sparely tested - it does what I need it for
* documentation of features not complete

## Credits
Style definitions are taken from https://gist.github.com/evertton/4133083.

Thanks you!

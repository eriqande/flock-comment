# flock-comment

This is LaTeX code to typeset a comment for Molecular Ecology Resources
about the similarity between the program FLOCK and structure.

In order to typeset it, `cd` into the `tex` directory and issue these
commands (note that you have to have a TeX system installed on your
system):
```
pdflatex flock-comment-main.tex
bibtex flock-comment-main
pdflatex flock-comment-main.tex
pdflatex flock-comment-main.tex
```
The resulting PDF file, `flock-comment-main` should then be complete.

## Terms 

As a work partially of the United States Government, this package is in the
public domain within the United States. 

See TERMS.md for more information.


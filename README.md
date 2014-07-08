# flock-comment

This is LaTeX code to typeset a comment for Molecular Ecology Resources
about the similarity between the program FLOCK and structure.

In order to typeset it, `cd` into the `tex` directory and issue these
commands (note that you have to have a TeX system installed on your
system):
```
latexmk -pdf flock-comment-main.tex
```
The resulting PDF file, `flock-comment-main.pdf` should then be complete.

## Terms 

As a work partially of the United States Government, this package is in the
public domain within the United States. 

Of course, it would be awfully lame of anyone to copy this work and claim it as their
own before we pubish it.

See TERMS.md for more information.

## R script 'Flock2Structure' 
The R script 'Flock2Structure' will read Flock formatted results files (excel .XLS), 
create populationq values and extract individual q values. These values will be 
placed inside of the output format of Structure (StructOuput_skeleton_k=*.txt files) 
so that results can be run through the programs CLUMP and Distruct. If the user wishes
to run more k, similarly formatted skeleton files should be added to the directory.
The raw output from Flock should be stored in the working directory in a folder 
titled 'Flock-output-Raw' and the skeleton files should be stored in the working directory. 

After CLUMP and Distruct have been run, code exists at the end of the R script to 
import relabeled individual q values for comparison. Relabeled CLUMP output
should be stored in a folder titled 'intermediate' and  be of the form 
'Output_00K.perms_X' where K is the number of clusters and X is the iteration.



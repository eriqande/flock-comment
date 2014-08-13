# flock-comment

This is LaTeX code to typeset a comment for Molecular Ecology Resources
about the similarity between the program FLOCK and structure.

In order to typeset it, `cd` into the `tex` directory and issue this
command (note that you have to have a TeX system installed on your
system, and a decent shell like bash, too):
```
../compile-documents.sh
```
This should result in two PDF files:

| Name of File  | Purpose of File |
| :-------------| :---------------|
| flock-comment-one-column-main.pdf   |  Single-column version formatted for submission to MER |
| flock-comment-main.pdf              |  Two-column version for easy reading                   |



## Terms 

As a work partially of the United States Government, this package is in the
public domain within the United States. 

Of course, it would be awfully lame of anyone to copy this work and claim it as their
own before we pubish it.

See TERMS.md for more information.

## R script 'Flock2Structure' 
The R script 'Flock2Structure' will read Flock formatted results files (excel .XLS), 
create population q values and extract individual q values. These values will be 
placed inside of the output format of Structure (StructOuput_skeleton_k=*.txt files) 
so that results can be run through the programs CLUMPP and Distruct. If the user wishes
to run more k, similarly formatted skeleton files should be added to the directory.
The raw output from Flock should be stored in the working directory in a folder 
titled 'Flock-output-Raw' and the skeleton files should be stored in the working directory. 

To format Flock output so that it can be compared with Structure output, 
open the Flock2Structure.R script in an editor such as Rstudio (our favorite),
Tinn-R, Vim (with VimR), etc. You should be working in the 'ForPipeline' 
directory where Flock2Structure lives. All Flock results are stored in 
the folder 'Flock-output-Raw'. Run the R script in the blocks separated by #s.
Note that this should be done on a Mac or Linux OS as system commands are
employed that cannot be passed to DOS. Part of the code uses Java to read from
Excel. Most moderately equipped machines should not have issues, but if heap 
errors are encountered the java parameters options on line 37 may help ameliorate
the problem. 

Once the code is executed a folder named 'Flock-output-Formatted' should be created
with Flock results now formatted such that they can be processed by the programs 
CLUMPP and Distruct. 

After CLUMP and Distruct have been run, code exists at the end of the R script to 
import relabeled individual q values for comparison. Relabeled CLUMP output
should be stored in a folder titled 'intermediate' and  be of the form 
'Output_00K.perms_X' where K is the number of clusters and X is the iteration.



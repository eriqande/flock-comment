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

## R script 'FLOCKTUREvSTURCTUREnew.R' 

The R script 'Flock2Structure.new' will rerun the analyses comparing Structure and FLOCKTURE from the manuscript. The code is divided into 5 main parts: (1) Simulate data (2) Run FLOCKTURE (3) Run STRUCTURE (4) Run CLUMPP and DISTRUCT, & (5) Compute zero-one loss and graph output.  In order to do this you will need to clone a few git repositories:

```sh
git clone https://github.com/eriqande/flock-comment.git
git clone https://github.com/eriqande/flockture.git
git clone https://github.com/eriqande/slg_pipe.git
```
Please note that the executables in the slg_pipe are for Mavericks OS and should be changed if you have a different OS. Follow the instructions in each of the readme files on how to (1) compile the FLOCKTURE code and (2) set up slg_pipe.

Once FLOCKTURE and the slg_pipe are setup, open the FLOCKTUREvSTRUCTUREnew.R script in your favorite editor such as Rstudio, Tinn-R, Vim (with VimR), etc. The code should be executed for each of the 5 main parts separately. There are a few options that can be changed:
(1) Marker type (line10): Set to 1 for microsatellites and 2 for SNPs
(2) Reps (line33): How many times do you want to run all models. Can be set from 1-9.
(3) MGrate (lines37/40): This is a vector of migration rates for the coalescent simulation. These values determine the amount of population differentiation among the five populations simulated. 
(3) Seedset (line32): Set from 1-3. These are seeds for simulating data. In the manuscript we simulated 16 datasets with varying migration rates using the same random seeds, and then changed the random seeds twice to simulate the remaining 32 for each marker type. Setting this to 3 will run the full set of simulations.



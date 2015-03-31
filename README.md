# flock-comment

Notes for eric:

When making the dryad archive we can jettison:

* forms/
* ForPipeline/
* inst/
* reviews1/
* SimDat1/
* SimDat2/
* in tex folder, letters to the editors and stuff.

Then modify README a little to refer to the fact that the full simulated data sets
are also in the archive.

This is LaTeX code to typeset a comment for Molecular Ecology Resources
about the similarity between the program FLOCK and structure.  And now it also 
includes some R code to reproduce results in the paper.

## Typesetting
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


## Reproducing the simulations

The R script 'Flock2Structure' will rerun the analyses comparing Structure and FLOCKTURE from the 
manuscript.  In order to make this work you ought to be on a sane Unix system (you will need `rsync`,
`awk`, `make` and other such utilities.  Easiest, probably, is going to
be if you are running Mac OS Mavericks or higher with the Developer Tools installed.

The code is divided into 5 main parts: 

1. Simulate data
2. Run FLOCKTURE
3. Run STRUCTURE
4. Run CLUMPP and DISTRUCT
5. Compute zero-one loss and graph output.  

In order to do this you will need to clone a few git repositories: `flock-comment`, `flockture` and 
`slg_pipe`.  With the latter two there are some further setup things that must be done as described
in their READMEs.  See the README section at 
[https://github.com/eriqande/flockture](https://github.com/eriqande/flockture) and
[https://github.com/eriqande/slg_pipe](https://github.com/eriqande/slg_pipe)

When you do this, make sure that you clone all the repositories so that the directories
that get cloned all appear together at the same directory level.  When I do this it looks like
so:

```sh
# first get the three repositories
git clone https://github.com/eriqande/flock-comment.git
git clone https://github.com/eriqande/flockture.git
git clone https://github.com/eriqande/slg_pipe.git

# notice how these are all together in the same directory level:
ls

## output is: flock-comment/ flockture/     slg_pipe/


# Now make flockture:
cd flockture/src/
make
cd ../../   # return to the directory that holds the cloned repos


# Then get the necessary binaries for slg_pipe and place them where needed
curl -o slg_pipe_binaries.tar.gz  https://dl.dropboxusercontent.com/u/19274778/slg_pipe_binaries.tar.gz
gunzip slg_pipe_binaries.tar.gz 
tar -xvf slg_pipe_binaries.tar 
rsync -avh slg_pipe_binaries/* slg_pipe


```
Please note that the executables in the slg_pipe are for Mavericks OS and should be changed if you have a different OS. Follow the instructions in each of the readme files on how to:

1. compile the FLOCKTURE code, and
2. set up slg_pipe.

Once FLOCKTURE and the slg_pipe are setup, open the FLOCKTUREvSTRUCTURE.R script in your favorite editor such as Rstudio, Tinn-R, Vim (with VimR), etc. The code should be executed for each of the 5 main parts separately. There are a few options that can be changed:

1. Marker type (line10): Set to 1 for microsatellites and 2 for SNPs
2. Reps (line33): How many times do you want to run all models. Can be set from 1-9.
3. MGrate (lines37/40): This is a vector of migration rates for the coalescent simulation. These values determine the amount of population differentiation among the five populations simulated. 
4. Seedset (line32): Set from 1-3. These are seeds for simulating data. In the manuscript we simulated 16 datasets with varying migration rates using the same random seeds, and then changed the random seeds twice to simulate the remaining 32 for each marker type. Setting this to 3 will run the full set of simulations.


## Terms 

As a work partially of the United States Government, this package is in the
public domain within the United States. 

Of course, it would be awfully lame of anyone to copy this work and claim it as their
own before we pubish it.

See TERMS.md for more information.



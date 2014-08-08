

# this is a shell script that will compile the documents 
# associated with this manuscript.
# this should be run in the ./tex directory

if [ $(basename $PWD) != "tex" ]; then
	echo "Looks like you are not running $0 from the right directory.
Your working directory must be the \"tex\" directory within the
\"flock-comment\" directory.  Aborting..." > /dev/stderr
exit 1
fi


# first, LaTeX the two column version of the manuscript.
latexmk -pdf  flock-comment-main.tex  || echo "latexmk returned error compiling flock-comment-main.tex"

# then LaTeX the one-column submission format version
latexmk -pdf  flock-comment-one-column-main.tex  || echo "latexmk returned error compiling flock-comment-one-column-main.tex"


echo; echo; echo
echo "Check it out! If everything worked, then you have two
compiled documents ready to go:
   flock-comment-one-column-main.pdf   <--  version for submission
   flock-comment-main.pdf              <--  two column version for easy reading
   
"
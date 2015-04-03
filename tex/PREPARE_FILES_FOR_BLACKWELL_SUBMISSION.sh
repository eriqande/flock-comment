


# this is a little script that will create a directory on my desktop
# with all the files needed to typeset the final submission to
# Molecular Ecology Resources

DIR=~/Desktop/flock-comment-tex-stuff

rm -r $DIR

mkdir $DIR

cp  -r flock-comment-one-column-main.tex  \
	flock-comment-one-column-main.bbl \
	abstract.tex  \
	author-title-etc.tex \
 	main-body-text.tex \
 	lineno.sty \
 	images \
 	$DIR/


# now remove some of the files that are not needed/referenced
rm 	-r $DIR/images/NMFS_letterhead.pdf \
	$DIR/images/banner.pdf \
	$DIR/images/Tables-Pat \
	$DIR/images/Figures-Pat/*BW.pdf



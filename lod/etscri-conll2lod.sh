#!/bin/bash
HOME=`echo $0 | sed s/'[^\/]*$'//g`.;
SYSTEM_HOME=$HOME
if echo $OSTYPE | grep -i cygwin >&/dev/null; then
	echo -n $SYSTEM_HOME '> ' 1>&2;
	SYSTEM_HOME=`cygpath -wa . | sed s/'[\\]'/'\/'/g`;
	echo $SYSTEM_HOME 1>&2;
fi;
echo synopsis: $0 "[-debug] [-grammar]" 1>&2;
echo '  'performs linking of a ETSCRI conll file with ePSD dictionary, writes CoNLL-RDF 1>&2;
echo '  -debug   write CoNLL-RDF *excerpt* with syntax highlighting' 1>&2;
echo '  -grammar' compact visualization of original annotations 1>&2;
echo '  both options can be combined to compare CoNLL-RDF and annotations' 1>&2;
echo '          ' for additional visualization parameters see CoNLLRDFFormatter 1>&2;
echo convert ETCSRI/CDLI annotated data to LOD 1>&2
echo reads CoNLL from stdin and writes to stdout 1>&2
echo note that the parameters are hard-wired, e.g., 1>&2;
echo the dictionary to be linked with '(ePSD HTML edition),' 1>&2
echo column '(field)' names and SPARQL queries 1>&2
echo 'always run this script from its home directory' 1>&2
echo 'applies to all files in '$HOME'/data/*.conll' 1>&2
echo 1>&2

echo create local ePSD edition 1>&2;	# slow, but we cannot provide the data without back-confirmation
bash dict/build-epsd-ttl.sh;

for file in $HOME/data/*.conll; do
	BASE_URI="http://oracc.museum.upenn.edu/etcsri/"`echo $file | sed -e s/'.*\/'//g -e s/'.conll$'//`'#';
	COLS=" ID    WORD    BASE    CF      EPOS    FORM    GW      LANG    MORPH   MORPH2  NORM    POS     SENSE";
	echo 'calling CoNLLStreamExtractor '$BASE_URI 1>&2;
	echo '                             '$COLS 1>&2	
	iconv -f utf-8 -t utf-8 $file | \
	sed s/'#.*'//g | \
	$HOME/linker/run.sh CoNLLStreamExtractor $BASE_URI $COLS | \
	$HOME/linker/run.sh CoNLLRDFUpdater \
		-custom -model file:///$SYSTEM_HOME/dict/epsd.ttl http://psd.museum.upenn.edu/epsd/epsd \
		-updates $SYSTEM_HOME/linker/link-ePSD.sparql \
		| \
	if echo $* | grep 'debug' >/dev/null; then				# DEBUG: filter content to be shown
		$HOME/linker/run.sh CoNLLRDFUpdater \
			-custom http://example.org \
			-updates $SYSTEM_HOME/linker/slim-etscri.sparql;
	else cat;
	fi | \
	$HOME/linker/run.sh CoNLLRDFFormatter $* 2>&1 | \
	if echo $* | grep 'debug' >/dev/null; then				# DEBUG: treat epsd like a namespace
		sed -e s/'<http:..psd.museum.upenn.edu.epsd.epsd.\([^>]*\)>'/'epsd:\1'/g;
	else
		cat
	fi;
done;
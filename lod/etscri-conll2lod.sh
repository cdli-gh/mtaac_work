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

#
# 0. preparations (necessary for illustrational demo, not part of the data workflow)
echo create local ePSD edition 1>&2;	# slow, we thus provide a precompiled version
bash dict/build-epsd-ttl.sh;

echo 1>&2;

if [ -e metadata/cdli_bm_export-sample.ttl ]; then		# use precompiled metadata when available
	echo use local CDLI metadata 1>&2
else 
	echo create local CDLI metadata 1>&2;
	bash java -jar metadata/csv2rdf.jar metadata/cdli2rdf-template.ttl metadata/cdli_bm_export-sample.csv metadata/cdli_bm_export-sample.ttl;
fi;

echo 1>&2;

#
# actual processing: file by file
for file in $HOME/data/*.conll; do
	BASE_URI="http://oracc.museum.upenn.edu/etcsri/"`echo $file | sed -e s/'.*\/'//g -e s/'.conll$'//`'#';
	COLS=" ID    WORD    BASE    CF      EPOS    FORM    GW      LANG    MORPH   MORPH2  NORM    POS     SENSE";
	echo 'calling CoNLLStreamExtractor '$BASE_URI 1>&2;
	echo '                             '$COLS 1>&2	
	iconv -f utf-8 -t utf-8 $file | \
	sed s/'#.*'//g | \
	#
	# 1. convert CoNLL data to RDF and prepare linking with CDLI metadata
	$HOME/linker/run.sh CoNLLStreamExtractor $BASE_URI $COLS \
		-u $SYSTEM_HOME/linker/define-etscri-inscription.sparql \
	| \
	#
	# 2. link ePSD dictionary
	$HOME/linker/run.sh CoNLLRDFUpdater \
		-custom -model file:///$SYSTEM_HOME/dict/epsd.ttl http://psd.museum.upenn.edu/epsd/epsd \
		-updates $SYSTEM_HOME/linker/link-ePSD.sparql \
		| \
	#
	# 3. copy CDLI and BM metadata
	$HOME/linker/run.sh CoNLLRDFUpdater \
		-custom -model file:///$SYSTEM_HOME/metadata/cdli_bm_export-sample.ttl "http://cdli.ucla.edu/?q=cdli-search-information" \
		-updates $SYSTEM_HOME/linker/link-inscription-cdli.sparql \
	| \
	# 4. we're done, now we format
	if echo $* | grep 'debug' >/dev/null; then				# DEBUG: filter content to be shown
		$HOME/linker/run.sh CoNLLRDFUpdater \
			-custom http://example.org \
			-updates $SYSTEM_HOME/linker/slim-etscri.sparql |\
		$HOME/linker/run.sh CoNLLRDFFormatter $* 2>&1 | \
															# DEBUG: treat epsd like a namespace, remove prefixes
		sed -e s/'<http:..psd.museum.upenn.edu.epsd.epsd.\([^>]*\)>'/'epsd:\1'/g | \
		grep -v -i '@prefix' | \
		grep -v '^SLF4J';
	else
		$HOME/linker/run.sh CoNLLRDFFormatter $* 2>&1;
	fi;
done;
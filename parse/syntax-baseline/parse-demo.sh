#!/bin/bash
# run parse.sh with default parameters on ETSCRI sample data in ../data/*.conll
# args: see CoNLLRDFFormatter 

HOME=`echo $0 | sed s/'[^\/]*$'//`.;
CONLL_RDF=$HOME/conll-rdf
DATA=$HOME/../data;
SPARQL=$HOME/sparql;

for file in $DATA/*.conll;
	# ../data/Q000985.conll; # problematic, the others are more or less ok
	# ../data/Q000937.conll; 
	# ../data/Q001792.conll;
	# ../data/Q001789.conll;
	# ../data/Q001758.conll;
	# ../data/Q001685.conll;
	# ../data/Q001642.conll;
	# ../data/Q000988.conll;
	# ../data/Q000954.conll;
	# ../data/Q000953.conll;
	# ../data/Q000949.conll; 
	# ../data/Q000940.conll; 
	# ../data/Q000950.conll;
	# ../data/Q001619.conll;
do
	egrep '^[0-9]' $file; 	# merge lines, treat tablet as single sentence
	echo;
done | \
bash -e $HOME/parse.sh 	\
	http://oracc.museum.upenn.edu/etcsri/ \
	OLD_ID   WORD BASE CF     EPOS   FORM   GW     LANG   MORPH  MORPH2 NORM   POS SENSE | \
$CONLL_RDF/run.sh CoNLLStreamExtractor http://oracc.museum.upenn.edu/etcsri/ \
	ID IGNORE WORD BASE IGNORE IGNORE IGNORE GW     IGNORE IGNORE MORPH2 IGNORE POS IGNORE HEAD EDGE \
	-u $SPARQL/remove-IGNORE.sparql 2>/dev/null | \
$CONLL_RDF/run.sh CoNLLRDFFormatter -grammar 2>/dev/null
#!/bin/bash
# perform baseline parsing (syntactic pre-annotation) with CoNLL-RDF
# read CoNLL from stdin, write CoNLL to stdout
# arguments: BASE_URI COL_LABEL1..n
# we return CoNLL

HOME=`echo $0 | sed s/'[^\/]*$'//`.;
CONLL_RDF=$HOME/conll-rdf;
SPARQL=$HOME/sparql;

$CONLL_RDF/run.sh CoNLLStreamExtractor $* \
	-u	$SPARQL/remove-IGNORE.sparql{0} \
		\
		$SPARQL/extract-feats.sparql \
		$SPARQL/remove-MORPH2.sparql{0} \
		\
		$SPARQL/init-SHIFT.sparql \
		\
		$SPARQL/REDUCE-compound-verbs.sparql \
		$SPARQL/REDUCE-adjective.sparql{3} \
		$SPARQL/REDUCE-adnominal.sparql{3} \
		$SPARQL/REDUCE-appos.sparql{1} \
		$SPARQL/REDUCE-absolutive.sparql{1} \
		$SPARQL/REDUCE-appos.sparql{1} \
		$SPARQL/REDUCE-adjective.sparql{1} \
		$SPARQL/REDUCE-appos.sparql{4} \
		$SPARQL/REDUCE-preposed-genitive.sparql{1} \
		$SPARQL/REDUCE-arguments.sparql{5} \
		$SPARQL/REDUCE-adjective.sparql{1} \
		$SPARQL/REDUCE-arguments.sparql{5} \
		\
		$SPARQL/REDUCE-to-HEAD.sparql \
		$SPARQL/remove-feats.sparql \
		$SPARQL/create-ID-and-DEP.sparql | \
(shift;			# skip first argument, note that we add a new ID column *in front* 
$CONLL_RDF/run.sh CoNLLRDFFormatter -conll ID $* DEP EDGE)

# note that the iterations are chosen to account for the examples
# otherwise, there is no regulation to balance low or high attachment

# NOTE: we currently miss a few examples
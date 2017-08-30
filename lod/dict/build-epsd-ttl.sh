#!/bin/bash
# we build a partial lemon model for the ePSD

TARGET=epsd.ttl;

if [ -e $TARGET ] ; then
	echo found $TARGET, skipping dictionary conversion 1>&2
else 
  (
	echo building lemon dictionary $TARGET 1>&2;
	
	EPSD=http://psd.museum.upenn.edu/epsd/epsd

	echo "@prefix ontolex: <http://www.w3.org/ns/lemon/ontolex#> ."
	echo "@prefix lime: <http://www.w3.org/ns/lemon/lime#> ."
	echo "@prefix skos: <http://www.w3.org/2004/02/skos/core#> ."
	echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
	echo "@prefix epsd: <"$EPSD"/> ."
	echo ;
	echo "<"$EPSD"> a lime:Lexicon; lime:language \"sux\"."
	for i in {1000..6700}; do	# currently, it's 6609, but it might grow
	  echo -n $EPSD/e$i.html 1>&2;
	  if curl --silent --fail -r 0-0 $EPSD/e$i.html >/dev/null; then # if the file is found
		echo 1>&2;
		echo;
		echo "<"$EPSD"> lime:entry epsd:e"$i" .";
		xmllint -recover -xpath '//*[@class="wr" or @class="sense"]' $EPSD/e$i.html | \
		sed -e s/'<span class="wr"'/'\n&'/g \
			-e s/'<h3'/'\n&'/g \
			-e s/'<sup>'/'{'/g -e s/'<\/sup>'/'}'/g -e s/'([^()]*)'//g -e s/'|[^|]*|'//g \
			-e s/'&#x11C;'/'Ĝ'/g \
			-e s/'&#x11D;'/'ĝ'/g \
			-e s/'&#x160;'/'Š'/g \
			-e s/'&#x161;'/'š'/g \
			-e s/'&#xD7;'/'×'/g | \
		egrep '.' | sort -u | \
		perl -e '
			print "epsd:e'$i' a ontolex:LexicalEntry; rdfs:isDefinedBy <'$EPSD/e$i.html'>";
			while(<>) {
				s/\n//g;
				if(m/^<span/) {
					while(m/<[^>]*>/) {
						s/<[^>]*>//;
					};
					if(m/[a-zA-Z]/) {
						$my=$_;
						print ";\n ontolex:lexicalForm [ a ontolex:Form; ontolex:writtenRep \"";
						print $my;
						print "\"\@sux ]";
					}
				}
				if(m/^<h3/) {
					s/<[\/]?h3[^>]*>//g;
					while(m/<[^>]*>[^<]*<\/[^>]*>/) {
						s/<[^>]*>[^<>]*<\/[^<>]*>//g;
					};
					s/^[ \t]+//;
					s/[ \t]+$//;
					s/"/\\"/g;
					if(m/[a-zA-Z]/) {
						$my=$_;
						print ";\n ontolex:sense [ a ontolex:LexicalSense; skos:definition \"";
						print $my;
						print "\"\@en ]";
					}
				}
			}
			print " .\n";
		';
	  else echo not found 1>&2;
	  fi;
	done;
  ) > $TARGET;
fi;
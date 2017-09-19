Towards a Linked Open Data edition of Sumerian corpus data
==

 - edit sample data from CDLI-related language resources to develop format specifications
 - given a sample of an annotated corpus provided a CoNLL (TSV) format
     1. convert via CoNLL-RDF (illustrated for an ETSCRI data sample, see data/)
     2. link with dictionary (illustrated for the ePSD, see dict/)
     3. link annotations to repositories of annotation terminology (here, UniMorph, later the Universal Dependencies, see annotations/)
     4. link with CDLI metadata (samples from CDLI, see metadata/)
	 5. link with external metadata repositories (not accessible yet)
		  - http://triplestore.modyco.fr currently down, to be up again by end of Sep 2017
		  - https://collection.britishmuseum.org/sparql up and running, but the certificate currently blocks our SERVICE requests

 -  apply these specifications to provide a LLOD view on CDLI content, e.g., using http://www.rdb2rdf.org


Implementation status:
 - <code>etscri-conll2lod.sh</code> currently performs steps (1), (2) and (4) for an ETSCRI/CDLI data sample
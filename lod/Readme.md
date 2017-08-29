Towards a Linked Open Data edition of Sumerian corpus data
==

 - edit sample data from CDLI-related language resources to develop format specifications
 - given a sample of an annotated corpus provided a CoNLL (TSV) format
     1. convert via CoNLL-RDF (illustrated for an ETSCRI data sample, see data/)
     2. link with dictionary (illustrated for the ePSD, see dict/)
     3. link annotations to repositories of annotation terminology (here, the Universal Dependencies or UniMorph)
     4. link with CDLI metadata (e.g., http://triplestore.modyco.fr -- availability of that data needs to be confirmed)
 
 -  apply these specifications to provide a LLOD view on CDLI content, e.g., using http://www.rdb2rdf.org

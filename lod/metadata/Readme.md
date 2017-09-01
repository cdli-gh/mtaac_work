CDLI Metadata sample
=

CSV
-
- 50 Ur III objects with references to the British Museum (this is to illustrate the linking with external resources)
- originally provided as csv
  columns:
	- museum no (here BM: British Museum)
	- id_text (CDLI id)
	- composite (groups together multiple objects with the same text, e.g., copies)
	- id_text2 (???, empty in the sample)
	- height
	- material
	- period
	- thickness
	- width
	- id (DB primary key?)

Modelling approach
-
- modelled here as CIDOC-CRM, following examples from the British Museum 
	- composite (groups together multiple objects with the same text, e.g., copies) => ?composite a crm:E34_Inscription
		"Note that special rules apply in the case of several text genres now being entered to CDLI bearing on those texts or text-like artifacts that can be found in multiple copies in antiquity, and that therefore are supplemented with an artificial composite identifier." (http://cdli.ucla.edu/?q=cdli-search-information)
	
	- id_text (CDLI id) => ?object URI
		?object crm:P65_shows_visual_item ?composite. # cf. BM
			from the CRM documentation, the superproperty crm:P128_carries would suit, too, cf. http://www.cidoc-crm.org/html/5.0.4/cidoc-crm.html#P128
			hence, it must be a physical thing, in our case a E84_Information_Carrier
  However, if no ?composite is found, then a separate crm:E34_Inscription must be created
 - museum no (here BM: British Museum) => ?object owl:sameAs (resolved museum no)

Data model
- 

- classes:
	- E84_Information_Carrier (< id_text)
	- E34_Inscription (< composite; if missing < id_text)

- object properties:
	- ?e84 P65_shows_visual_item ?e34
	- ?e84 owl:sameAs ?link_to_external_object_description, e.g., in the BM

- datatype properties:
	- every column just gets its own object property in a cdli namespace
	- for the CDLI namespace, we take http://cdli.ucla.edu/?q=cdli-search-information as a placeholder, to be replaced by a proper URL

Note that for the moment, only an instance of E84_Information_Carrier is generated, remainder as DatatypeProperties.
	
Converter
-

Raw conversion to rdf using https://github.com/clarkparsia/csv2rdf (jar included)
(as a Python alternative, use rdflib and csv2rdf)

<code>java -jar csv2rdf.jar cdli2rdf-template.ttl cdli_bm_export-sample.csv cdli_bm_export-sample.ttl</code>


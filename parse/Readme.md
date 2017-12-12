MTAAC Baseline Parser
==

In order to facilitate manual annotation, we provide a rule-based parser for syntactic pre-annotation.
This is based on ETSCRI data and example analyses provided by Hayes (2000).

At the moment, we propagate ETSCRI case labels and employ them in place of dependencies. In the longer perspective, these shall be replaced by UD relations.

Run syntax-baseline/parse-demo.sh.

Later, statistical or neural parsers will be added, trained on annotated MTAAC data.
SkyscrapAR
==========

Software visualization with augmented reality. Created by Rodrigo Souza and Bruno Carreiro for a software visualization course at Federal University of Bahia, Brazil,  taught by professor Manoel Mendonça.

Inspired by [CodeCity](http://www.inf.usi.ch/phd/wettel/codecity.html), by Richard Wettel and Michele Lanza from University of Lugano, Switzerland.

See also [SkyscrapAR-extractor](https://github.com/rodrigorgs/SkyscrapAR-extractor), needed to create data files for SkyscrapAR.

Demo
----

You can see SkyscrapAR in action in the following video: http://www.youtube.com/watch?v=VVRjihr-40U

Dependencies
------------

To run SkyscrapAR, you'll need [Processing](http://processing.org/) 1.5.1 (it WON'T work with 2.0 or newer versions), an open source programming language and environment. You'll also need the following Processing plug-ins:

* [NyARToolkit for Processing](http://sourceforge.jp/projects/nyartoolkit/releases/)
* [Processing Picking Library](http://code.google.com/p/processing-picking-library/)
* [ttslib](http://www.local-guru.net/blog/pages/ttslib)
* [Treemap Library](http://benfry.com/writing/treemap/)

For your convenience, the dependencies are available at http://app.dcc.ufba.br/~rodrigo/SkyscrapAR-deps.zip

Windows/Linux users: see http://wiki.processing.org/w/Video_Issues

Visualize your system
---------------------

SkyscrapAR comes with a XML file with metrics from the JUnit project. If you want to visualize your software project, you will need to extract its metrics using [SkyscrapAR-extractor](https://github.com/rodrigorgs/SkyscrapAR-extractor). 

Your project needs to be in a Git repository. After extracting the metrics, rename the generated `SCMtoXML2.xml` file to `junit.xml` and copy it to the `data/` folder inside SkyscrapAR's root folder (overwrite the existing file).
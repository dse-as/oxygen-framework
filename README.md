# 📑 dse-as oXygen Framework

This repository contains an oXygen XML Editor framework to customize the editing environment of the _Digital Scholarly Edition Annermarie Schwarzenbach_ (dse-as).

## Status

🔬Experimental, do not use in production!

## Features

* Simple graphical display of the project's markup based on [TEI-XML](https://tei-c.org/guidelines/) and the [DTA-Basisformat](https://www.deutschestextarchiv.de/doku/basisformat/index.html).
* Referencing of [Geovistory](https://www.geovistory.org/) entites via [SPARQL API](https://www.geovistory.org/sparql).
* Uses [ediarum.JAR](https://github.com/ediarum/ediarum.JAR) for index operations in [Oxygen Author Mode](https://www.oxygenxml.com/doc/versions/24.1/ug-editor/topics/editing-xml-documents-author.html).
* Insert actions for frequently used tags.

## Installation

### Add-on

TBD

### Project file and Git

As described in the [official documentation](https://www.oxygenxml.com/doc/versions/23.0/ug-editor/topics/author-document-type-extension-sharing.html):

1. Clone this repository.
2. Open project file (`dseas-framework.xpr`) with Oxygen XML Editor.
3. Go to **Options > Preferences > Network Connection Settings > Trusted Hosts** and add an entry for `sparql.geovistory.org`.
4. Go to **Options > Preferences > Document Type Association > Locations** and select **Project Options** at the bottom of the page.
5. In the **Additional frameworks directories** list, add a new entry: **`${pd}`**.
6. Go back to **Document Type Association** and select the framework.

> 👉 To update, do `git pull`.

## Acknowledgement

This framework is made possible thanks to the inspirations from this projects:

* [hallerNet](https://hallernet.org/)
* [HisTEI](https://github.com/odaata/HisTEI)
* [ediarum.BASE.edit](https://github.com/ediarum/ediarum.BASE.edit)
* [ediarum.jar](https://github.com/ediarum/ediarum.JAR)

## License

TBD
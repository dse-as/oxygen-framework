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

This is the preferred installation method for editors:

1. Open `Options > Preferences > Add-ons` on Windows or `Oxygen XML Editor > Preferences > Add-ons` (on other platforms) from the menu.
2. `Add` a new add-on by entering this URL: https://docs.annemarie-schwarzenbach.ch/dseas.xml
3. `"Enable automatic updates checking"` should be activated. This will automatically prompt you to update the framework when an update was deployed.
4. Confirm with `OK`. 
5. Open `Help > Install new add-ons...` from the menu. Select the dse-as URL from the dropdown menu ("Show add-ons from").
6. The latest version of the add-on should be displayed. Select it, choose `Next` and confirm all upcoming prompts (including possible certificate warnings).
7. Restart the application. Note: The framework/add-on should keep itself up to date. Updates will be offered during the start of oXygen.
8. Open `Options > Preferences > Document Type Associations` on Windows or `Oxygen XML Editor > Preferences > Document Type Associations` (on other platforms) from the menu and make sure the framework is activated.

See https://www.oxygenxml.com/doc/versions/23.0/ug-editor/topics/packing-and-deploying-addons.html#packing-and-deploying-addons

### Project file and Git

This is the preferred method for developers:

1. Clone this repository.
2. Open project file (`dseas-framework.xpr`) with Oxygen XML Editor.
3. Go to **Options > Preferences > Network Connection Settings > Trusted Hosts** and add an entry for `sparql.geovistory.org`.
4. Go to **Options > Preferences > Document Type Association > Locations** and select **Project Options** at the bottom of the page.
5. In the **Additional frameworks directories** list, add a new entry: **`${pd}`**.
6. Go back to **Document Type Association** and select the framework.

> 👉 To update, do `git pull`.

See also the [official documentation](https://www.oxygenxml.com/doc/versions/23.0/ug-editor/topics/author-document-type-extension-sharing.html).

## Acknowledgement

This framework is made possible thanks to the inspirations from this projects:

* [hallerNet](https://hallernet.org/)
* [HisTEI](https://github.com/odaata/HisTEI)
* [ediarum.BASE.edit](https://github.com/ediarum/ediarum.BASE.edit)
* [ediarum.jar](https://github.com/ediarum/ediarum.JAR)

## License

* [dse-as/oxygen-framework](https://github.com/dse-as/oxygen-framework): See [LICENSE](LICENSE)
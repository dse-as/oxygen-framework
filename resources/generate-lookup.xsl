<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:local="urn:dseas:generate-lookup"
    exclude-result-prefixes="#all"
    expand-text="true"
    version="3.0">
    
    <xsl:param name="type" select="'all'"/>
    <xsl:param name="gsheet-sheetID" select="'1pzY0f-4SyWGZEd3-kF2E-djY54qsr9HrRIljVDG5gkc'"/>
    <xsl:param name="zotero-project" select="'5746334'"/>
    <xsl:param name="zotero-batch-size" select="100"/>
    <xsl:variable name="result-path" select="document-uri(.) => replace('generate-lookup.xsl','')"/>
    
    <xsl:template match="/">
        <xsl:if test="$type = 'person' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="$gsheet-sheetID"/>
                <xsl:with-param name="sheet" select="'Personen'"/>
                <xsl:with-param name="output-file" select="'lookup-person.xml'"/>
                <!-- Extra columns of the register dialog:
                column F ("Variante; Spitzname") li/@alt_n,
                sheet columns J-K (birth and death date) become li/@dates ("1911–1977"),
                column L ("Typ") li/@type -->
                <xsl:with-param name="extra-columns" select="'alt_n=F', 'dates=J-K', 'type=L'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'place' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="$gsheet-sheetID"/>
                <xsl:with-param name="sheet" select="'Orte'"/>
                <xsl:with-param name="output-file" select="'lookup-place.xml'"/>
                <!-- Extra columns of the register dialog:
                column E ("Namensvariante; Namensvariante") li/@alt_n,
                column K ("Type") li/@type,
                column M ("Land) li/@country,
                 -->
                <xsl:with-param name="extra-columns" select="'alt_n=E', 'type=K', 'country=M'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'org' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="$gsheet-sheetID"/>
                <xsl:with-param name="sheet" select="'Organisationen'"/>
                <xsl:with-param name="output-file" select="'lookup-org.xml'"/>
                <!-- Extra columns of the register dialog:
                column E ("Alternative Namen") li/@alt_n,
                column G ("Type") li/@type -->
                <xsl:with-param name="extra-columns" select="'alt_n=E', 'type=G'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$type = 'letter' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="'1KgZmtgZUEKx6o48KXTAYxWHhsOVrIxyOElFAUUOIc98'"/>
                <xsl:with-param name="sheet" select="'Briefe'"/>
                <xsl:with-param name="output-file" select="'lookup-letter.xml'"/>
                <!-- Extra columns of the register dialog:
                column L ("Verfasser_in") li/@sender,
                column M ("Adressat_in") li/@recipient,
                column O ("Datierung_normiert") li/@date -->
                <xsl:with-param name="extra-columns" select="'sender=L', 'recipient=M', 'date=O'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$type = 'smallform' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="'1S2Qun726gyqUKr2Yb5vW9RaGPlo8vZ43qbTV-xryyEo'"/>
                <xsl:with-param name="sheet" select="'Kleine+Formen'"/>
                <xsl:with-param name="output-file" select="'lookup-smallform.xml'"/>
                <!-- Extra columns of the register dialog:
                column E ("Datum Publikation/[Entstehungszeitraum]") li/@date,
                column F ("Titel") li/@title,
                column H ("Dokumenttyp") li/@type,
                column I ("Publikationsort/Archivort") li/@place -->
                <xsl:with-param name="extra-columns" select="'date=E', 'title=F', 'type=H', 'place=I'"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="$type = 'image' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="'13Sf1h6-bufC8q6N91gPxFrAh-di1PDpXXX5TQUHCMMo'"/>
                <xsl:with-param name="sheet" select="'Fotografien'"/>
                <xsl:with-param name="output-file" select="'lookup-image.xml'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$type = 'bibl' or $type = 'all'">
            <xsl:call-template name="fetch-zotero-items"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Google Sheet -->
    <xsl:template name="fetch-and-process-gsheet-items">
        <xsl:param name="sheetID"/>
        <xsl:param name="sheet"/>
        <xsl:param name="output-file"/>
        <!-- Optional additional sheet columns, as 'attribute=column' (e.g. 'type=L'),
             or 'attribute=column-column' to join several columns with an en dash
             (e.g. 'dates=J-K' gives "1911–1977", "1911–" or "–1977").
             Each becomes an attribute of li (omitted when all its cells are empty).
             An attribute named 'date' is normalized to a sortable key (see local:date-key);
             if its cell has no date, the date at the end of the label is used. -->
        <xsl:param name="extra-columns" as="xs:string*" select="()"/>
        <xsl:variable name="extra-names" select="$extra-columns ! substring-before(., '=')"/>
        <xsl:variable name="extra-sources" select="$extra-columns ! substring-after(., '=')"/>
        <xsl:variable name="columns" select="string-join(('A', 'B', $extra-sources ! tokenize(., '-')), '%2C%20')"/>
        <xsl:variable name="url" select="'https://docs.google.com/a/google.com/spreadsheets/d/'||$sheetID||'/gviz/tq?tq=select%20'||$columns||'%20where%20A%20matches%20''%5Ba-z%5D*_%5Cd%2B''%20and%20B%20is%20not%20null%20order%20by%20B&amp;tqx=out:csv&amp;sheet='||$sheet"/>
        <xsl:try>
            <!-- records, not lines: cells may contain line breaks (gviz quotes every cell) -->
            <xsl:variable name="result" select="tokenize(unparsed-text($url), '&quot;\r?\n&quot;')"/>
            <xsl:variable name="list">
                <ul type="{lower-case($sheet)}">
                    <xsl:for-each select="$result[position() gt 1]">
                        <!-- "a","b ""quoted""","c" → a | b "quoted" | c -->
                        <xsl:variable name="cells" select="tokenize(replace(., '^&quot;|&quot;\s*$', ''), '&quot;,&quot;') ! replace(., '&quot;&quot;', '&quot;')"/>
                        <li id="{$cells[1]}" val="{$cells[2]}">
                            <xsl:for-each select="1 to count($extra-names)">
                                <xsl:variable name="i" select="."/>
                                <!-- this attribute's cells follow id, label and the cells of the attributes before it -->
                                <xsl:variable name="first" select="3 + count($extra-sources[position() lt $i] ! tokenize(., '-'))"/>
                                <!-- spreadsheet error values such as #ERROR! or #N/A count as empty -->
                                <xsl:variable name="parts" select="subsequence($cells, $first, count(tokenize($extra-sources[$i], '-')))
                                    ! (if (matches(., '^#(ERROR!|N/A|REF!|VALUE!|NAME\?|DIV/0!|NUM!|NULL!)$')) then '' else .)"/>
                                <xsl:variable name="value" select="if ($extra-names[$i] = 'date')
                                    then (local:date-key(string-join($parts, ' ')), local:date-key(replace($cells[2], '^.*,', '')))[1]
                                    else if (some $part in $parts satisfies $part ne '') then string-join($parts, '–') else ()"/>
                                <xsl:if test="exists($value)">
                                    <xsl:attribute name="{$extra-names[$i]}" select="normalize-space($value)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            <xsl:result-document href="{$result-path||$output-file}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} entries in {$result-path||$output-file}</xsl:message>
            <xsl:catch>
                <xsl:message>⚠ Failed to fetch or parse data from {$url}
                    Code: <xsl:value-of select="$err:code"/>
                    Description: <xsl:value-of select="$err:description"/>
                </xsl:message>
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
    <!-- Sortable date key: all dates in $s as yyyy[-mm[-dd]], joined with "/" (start/end of a range).
         "1.6.1925" → "1925-06-01", "[1938.01 (ca.)]" → "1938-01", "1931-05-1931-06" → "1931-05/1931-06";
         empty if $s contains no four-digit year. -->
    <xsl:function name="local:date-key" as="xs:string?">
        <xsl:param name="s" as="xs:string?"/>
        <!-- d.m.yyyy to yyyy-mm-dd -->
        <xsl:variable name="iso" as="xs:string">
            <xsl:value-of>
                <xsl:analyze-string select="string($s)" regex="(\d{{1,2}})\.(\d{{1,2}})\.(\d{{4}})">
                    <xsl:matching-substring>{regex-group(3)}-{format-number(xs:integer(regex-group(2)), '00')}-{format-number(xs:integer(regex-group(1)), '00')}</xsl:matching-substring>
                    <xsl:non-matching-substring>{.}</xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:value-of>
        </xsl:variable>
        <!-- separate a following year ("1931-05-1931-06"), so that it is not read as a day -->
        <xsl:variable name="dates" select="analyze-string(replace($iso, '(\d)[.\-/](\d{4})', '$1 $2'), '\d{4}([.\-]\d\d){0,2}')//*:match ! translate(., '.', '-')"/>
        <xsl:sequence select="if (exists($dates)) then string-join(distinct-values($dates), '/') else ()"/>
    </xsl:function>

    <!-- Zotero -->
    <xsl:template name="fetch-zotero-items">
        <xsl:param name="start" select="0"/>
        <xsl:param name="accum" as="array(*)" select="[]"/>
        <xsl:variable name="url" select="'https://api.zotero.org/groups/'||$zotero-project||'/items?limit='||$zotero-batch-size||'&amp;start='||$start"/>

        <xsl:try>
            <xsl:variable name="response" select="unparsed-text($url) => parse-json()"/>
            <xsl:variable name="items" select="$response?*?('data')"/>
            <xsl:variable name="new-accum" select="array:append($accum, $items)"/>
            
            <xsl:choose>
                <xsl:when test="exists($items) and count($items) = $zotero-batch-size">
                    <!-- More items likely available, recurse -->
                    <xsl:call-template name="fetch-zotero-items">
                        <xsl:with-param name="start" select="$start + $zotero-batch-size"/>
                        <xsl:with-param name="accum" select="$new-accum"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- All items fetched, process $new-accum -->
                    <xsl:call-template name="process-zotero-items">
                        <xsl:with-param name="all-items" select="$new-accum"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch>
                <xsl:message>⚠ Failed to fetch or parse data from {$url}
                    Code: <xsl:value-of select="$err:code"/>
                    Description: <xsl:value-of select="$err:description"/>
                </xsl:message>
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
    <!-- Zotero item types as shown in the register dialog -->
    <xsl:variable name="zotero-types" select="map {
        'artwork': 'Kunstwerk', 'audioRecording': 'Tonaufnahme', 'blogPost': 'Blogbeitrag',
        'book': 'Buch', 'bookSection': 'Buchkapitel', 'conferencePaper': 'Konferenzbeitrag',
        'dictionaryEntry': 'Wörterbucheintrag', 'document': 'Dokument',
        'encyclopediaArticle': 'Lexikonartikel', 'film': 'Film', 'interview': 'Interview',
        'journalArticle': 'Zeitschriftenartikel', 'letter': 'Brief', 'magazineArticle': 'Magazinartikel',
        'manuscript': 'Manuskript', 'map': 'Karte', 'newspaperArticle': 'Zeitungsartikel',
        'podcast': 'Podcast', 'presentation': 'Vortrag', 'radioBroadcast': 'Radiosendung',
        'report': 'Bericht', 'thesis': 'Hochschulschrift', 'tvBroadcast': 'Fernsehsendung',
        'videoRecording': 'Videoaufnahme', 'webpage': 'Webseite'}"/>

    <!-- "Last, First; Last, First" of the authors (else the directors of a film, else
         the editors, marked "(Hg.)", else all creators); more than three: the first
         one and "u. a." -->
    <xsl:function name="local:zotero-authors" as="xs:string?">
        <xsl:param name="creators" as="item()?"/>
        <xsl:variable name="all" select="if (exists($creators)) then $creators?* else ()"/>
        <xsl:variable name="authors" select="$all[?('creatorType') = 'author']"/>
        <xsl:variable name="directors" select="$all[?('creatorType') = 'director']"/>
        <xsl:variable name="editors" select="$all[?('creatorType') = 'editor']"/>
        <xsl:variable name="chosen" select="if (exists($authors)) then $authors else if (exists($directors)) then $directors
            else if (exists($editors)) then $editors else $all"/>
        <xsl:variable name="names" select="$chosen ! (if (?('lastName')) then string-join((?('lastName'), ?('firstName')[normalize-space()]), ', ') else string(?('name')))"/>
        <xsl:variable name="names" select="$names[normalize-space()]"/>
        <xsl:if test="exists($names)">
            <xsl:sequence select="(if (count($names) gt 3) then $names[1] || ' u. a.' else string-join($names, '; '))
                || (if (empty($authors) and empty($directors) and exists($editors)) then ' (Hg.)' else '')"/>
        </xsl:if>
    </xsl:function>

    <xsl:template name="process-zotero-items">
        <xsl:param name="all-items" as="array(*)"/>
        <xsl:variable name="flat-items" select="array:flatten($all-items)"/>
        <xsl:variable name="list">
            <ul type="bibl">
                <xsl:for-each select="$flat-items[not(matches(?('itemType'), 'annotation|attachment|note'))]">
                    <xsl:sort select="?('creators')[1]?*?('lastName')[1]"/>
                    <xsl:sort select="?('date')"/>
                    <xsl:sort select="?('title')"/>
                    <xsl:variable name="id" select="?('key')"/>
                    <xsl:variable name="itemType" select="?('itemType')"/>
                    <xsl:variable name="label" select="?('title')"/>
                    <xsl:variable name="creator" select="?('creators')[1]?*?('lastName')[1]"/>
                    <xsl:variable name="date" select="?('date')"/>
                    <!-- val: the label inserted into the document (unchanged).
                         author, year, title, type: separate fields for the columns
                         of the register dialog (empty ones are left out). -->
                    <li id="{$id}" val="{(if ($creator) then $creator else 'NN') || (if ($date) then ' (' || $date || '): ' else ': ') || $label || ' [' || $id || '], ' || $itemType}">
                        <xsl:variable name="authors" select="local:zotero-authors(?('creators'))"/>
                        <xsl:if test="$authors">
                            <xsl:attribute name="author" select="$authors"/>
                        </xsl:if>
                        <xsl:if test="matches(string($date), '\d{4}')">
                            <xsl:attribute name="year" select="replace(string($date), '^.*?(\d{4}).*$', '$1')"/>
                        </xsl:if>
                        <xsl:if test="normalize-space(string($label))">
                            <xsl:attribute name="title" select="normalize-space(string($label))"/>
                        </xsl:if>
                        <xsl:attribute name="type" select="(map:get($zotero-types, string($itemType)), string($itemType))[1]"/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:variable>
        <xsl:result-document href="{$result-path||'lookup-bibl.xml'}" method="xml" indent="no">
            <xsl:copy-of select="$list"/>
        </xsl:result-document>
        <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} bibliographic entries in {$result-path||'lookup-bibl.xml'}</xsl:message>
    </xsl:template>
    
</xsl:transform>
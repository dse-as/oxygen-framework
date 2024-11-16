<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="type"/>
    
    <xsl:variable name="geovistory-project" select="'api_v1_project_153'"/>
    <xsl:variable name="zotero-project" select="'5746334'"/>
    <xsl:variable name="result-path" select="document-uri(.) => replace('generate-lookup.xsl','')"/>
    
    <xsl:template match="/">
       
        <xsl:if test="$type = 'person' or $type = 'all'">
            <xsl:variable name="sparql">
                PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#>
                PREFIX n1: &lt;https://ontome.net/ontology/>
                SELECT DISTINCT ?c21_1 ?label_38
                WHERE { ?c21_1 a n1:c21 .
                        ?c21_1 rdfs:label ?label_38 . }
                ORDER BY ASC(UCASE(str(?label_38)))
                LIMIT 9999
            </xsl:variable>
            <xsl:variable name="result" select="doc('https://sparql.geovistory.org/'||$geovistory-project||'?query='||encode-for-uri($sparql))"/>
            
            <xsl:result-document href="{$result-path||'lookup-person.xml'}" method="xml" indent="no">
                <ul type="persons">
                    <xsl:for-each select="$result//*:result">
                        <xsl:variable name="id" select="*:binding[@name='c21_1']/*:uri => replace('http://geovistory.org/resource/','')"/>
                        <xsl:variable name="label" select="*:binding[@name='label_38']/*:literal"/>
                        <li id="{$id}" val="{$label||' ('||$id||')'}"/>  
                    </xsl:for-each>
                </ul>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:if test="$type = 'place' or $type = 'all'">
            <xsl:variable name="sparql">
                PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#>
                PREFIX n1: &lt;https://ontome.net/ontology/>
                SELECT DISTINCT ?c363_1 ?label_68
                WHERE { ?c363_1 a n1:c363 .
                        ?c363_1 rdfs:label ?label_68 . }
                ORDER BY ASC(UCASE(str(?label_68)))
                LIMIT 9999
            </xsl:variable>
            <xsl:variable name="result" select="doc('https://sparql.geovistory.org/'||$geovistory-project||'?query='||encode-for-uri($sparql))"/>
            
            <xsl:result-document href="{$result-path||'lookup-place.xml'}" method="xml" indent="no">
                <ul type="places">
                    <xsl:for-each select="$result//*:result">
                        <xsl:variable name="id" select="*:binding[@name='c363_1']/*:uri => replace('http://geovistory.org/resource/','')"/>
                        <xsl:variable name="label" select="*:binding[@name='label_68']/*:literal"/>
                        <li id="{$id}" val="{$label||' ('||$id||')'}"/>  
                    </xsl:for-each>
                </ul>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:if test="$type = 'org' or $type = 'all'">
            <xsl:variable name="sparql">
                PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#>
                PREFIX n1: &lt;https://ontome.net/ontology/>
                SELECT DISTINCT ?c68_1 ?label_38
                WHERE { ?c68_1 a n1:c68 .
                        ?c68_1 rdfs:label ?label_38 . }
                ORDER BY ASC(UCASE(str(?label_38)))
                LIMIT 9999
            </xsl:variable>
            <xsl:variable name="result" select="doc('https://sparql.geovistory.org/'||$geovistory-project||'?query='||encode-for-uri($sparql))"/>
            
            <xsl:result-document href="{$result-path||'lookup-org.xml'}" method="xml" indent="no">
                <ul type="org">
                    <xsl:for-each select="$result//*:result">
                        <xsl:variable name="id" select="*:binding[@name='c68_1']/*:uri => replace('http://geovistory.org/resource/','')"/>
                        <xsl:variable name="label" select="*:binding[@name='label_38']/*:literal"/>
                        <li id="{$id}" val="{$label||' ('||$id||')'}"/>  
                    </xsl:for-each>
                </ul>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:if test="$type = 'bibl' or $type = 'all'">
            <xsl:variable name="result" select="unparsed-text('https://api.zotero.org/groups/'||$zotero-project||'/items') => parse-json()"/>
            
            <xsl:result-document href="{$result-path||'lookup-bibl.xml'}" method="xml" indent="no">
                <ul type="bibl">
                    <xsl:for-each select="$result?*?('data')">
                        <xsl:sort select="?('creators')[1]?*?('lastName')[1]"/>
                        <xsl:sort select="?('date')"/>
                        <xsl:sort select="?('title')"/>
                        <xsl:variable name="id" select="?('key')"/>
                        <xsl:variable name="label" select="?('title')"/>
                        <xsl:variable name="creators" select="?('creators')[1]?*?('lastName')[1] || (if (?('creators')[1]?*?('lastName')[2][normalize-space()]) then ' et al.' else '')"/>
                        <xsl:variable name="date" select="?('date')"/>
                        <li id="{$id}" val="{(if ($creators) then $creators else 'NN') ||
                            (if ($date) then ' (' || $date || '): ' else ': ') ||
                            $label || ' [' || $id || ']'}"/>  
                    </xsl:for-each>
                </ul>
            </xsl:result-document>
        </xsl:if>            
        
        
    </xsl:template>
    
</xsl:transform>
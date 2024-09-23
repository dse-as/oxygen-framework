<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="type"/>
    
    <xsl:variable name="project" select="'api_v1_project_153'"/>
  
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$type = 'person'">
                <xsl:variable name="sparql">
                    PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX n1: &lt;https://ontome.net/ontology/>
                    SELECT DISTINCT ?c21_1 ?label_38
                    WHERE { ?c21_1 a n1:c21 .
                            ?c21_1 rdfs:label ?label_38 . }
                    ORDER BY ASC(UCASE(str(?label_38)))
                    LIMIT 9999
                </xsl:variable>
                <xsl:variable name="result" select="doc('https://sparql.geovistory.org/'||$project||'?query='||encode-for-uri($sparql))"/>
                
                <xsl:result-document href="../resources/lookup-person.xml" method="xml" indent="no">
                    <ul type="persons">
                        <xsl:for-each select="$result//*:result">
                            <li id="{*:binding[@name='c21_1']/*:uri => replace('http://geovistory.org/resource/','')}" val="{*:binding[@name='label_38']/*:literal}"/>  
                        </xsl:for-each>
                    </ul>
                </xsl:result-document>
            </xsl:when>
            
            <xsl:when test="$type = 'place'">
                <xsl:variable name="sparql">
                    PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX n1: &lt;https://ontome.net/ontology/>
                    SELECT DISTINCT ?c363_1 ?label_68
                    WHERE { ?c363_1 a n1:c363 .
                            ?c363_1 rdfs:label ?label_68 . }
                    ORDER BY ASC(UCASE(str(?label_68)))
                    LIMIT 9999
                </xsl:variable>
                <xsl:variable name="result" select="doc('https://sparql.geovistory.org/'||$project||'?query='||encode-for-uri($sparql))"/>
                
                <xsl:result-document href="../resources/lookup-place.xml" method="xml" indent="no">
                    <ul type="places">
                        <xsl:for-each select="$result//*:result">
                            <li id="{*:binding[@name='c363_1']/*:uri => replace('http://geovistory.org/resource/','')}" val="{*:binding[@name='label_68']/*:literal}"/>  
                        </xsl:for-each>
                    </ul>
                </xsl:result-document>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:transform>
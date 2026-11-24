<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:dseas="https://annemarie-schwarzenbach.ch/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!-- Titel -->
    <xsl:template name="headerTitle">
        <h1 class="title">
            <xsl:value-of select=".//titleStmt/title[1] => fn:normalize-space()"/>
        </h1>
        <xsl:if test=".//titleStmt/title[@type='desc'][normalize-space()]">
            <p class="subtitle">
                <xsl:value-of select=".//titleStmt/title[@type='desc'][1] => fn:normalize-space()"/>
            </p>
        </xsl:if>
    </xsl:template>
    
    <!-- Identifikator -->
    <xsl:template name="headerId">
        <p class="headerData">
            <span class="infoTitle">Identifikator: </span>
            <xsl:value-of select="./@xml:id"/>
        </p>
    </xsl:template>
    
    <!-- Angaben zur Korrespondenz (Brief) -->
    <xsl:template name="headerCorresp">
        <xsl:for-each select=".//correspDesc//correspAction">
            <xsl:choose>
                <xsl:when test=".[@type='sent']">
                    <p class="headerData">
                        <xsl:for-each select="./persName[normalize-space()]">
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>            
                        <xsl:for-each select="./orgName[normalize-space()]">
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>            
                        <xsl:for-each select="./placeName[normalize-space()]">
                            <xsl:text>Schreibort: </xsl:text>
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>
                        <xsl:text>Schreibdatum: </xsl:text>
                        <xsl:value-of select="dseas:formatDateAttributes(./date)"/>
                    </p>       
                </xsl:when>
                <xsl:when test=".[@type='received']">
                    <p class="headerData">
                        <xsl:for-each select="./persName[normalize-space()]">
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>            
                        <xsl:for-each select="./orgName[normalize-space()]">
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>            
                        <xsl:for-each select="./placeName[normalize-space()]">
                            <xsl:text>Empfangsort: </xsl:text>
                            <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>            
                        <xsl:text>Empfangsdatum: </xsl:text>
                        <xsl:value-of select="dseas:formatDateAttributes(./date)"/>
                    </p>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Bibliographische Angaben (Publikation) -->
    <xsl:template name="headerBibl">
        <span class="infoTitle">Bibliographische Angaben: </span><br/>
        <p class="headerData">
            <xsl:for-each select=".//sourceDesc/bibl/persName[normalize-space()]">
                <xsl:value-of select="."/>
                <br/>
            </xsl:for-each>            
            <xsl:for-each select=".//sourceDesc/bibl/bibl/title[normalize-space()]">
                <xsl:value-of select="."/>
                <br/>
            </xsl:for-each>            
            <xsl:for-each select=".//sourceDesc/bibl/bibl/date[@when or @from or @to]">
                <xsl:value-of select="dseas:formatDateAttributes(.)"/>
                <br/>
            </xsl:for-each>
            <xsl:for-each select=".//sourceDesc/bibl/bibl/biblScope[normalize-space()]">
                <xsl:value-of select="."/>
                <br/>
            </xsl:for-each>    
        </p>
    </xsl:template>

    <!-- Bibliographische Angaben (Manuskript) -->
    <xsl:template name="headerMsIdent">
        <xsl:for-each select=".//sourceDesc/msDesc/msIdentifier">
            <p class="headerData">
                <xsl:for-each select="repository[normalize-space()]">
                    <xsl:text>Archiv: </xsl:text>
                    <xsl:value-of select="."/>
                    <br/>
                </xsl:for-each>            
                <xsl:for-each select="collection[normalize-space()]">
                    <xsl:text>Sammlung: </xsl:text>
                    <xsl:value-of select="."/>
                    <br/>
                </xsl:for-each>
                <xsl:for-each select="idno[normalize-space()]">
                    <xsl:text>Signatur: </xsl:text>
                    <xsl:value-of select="."/>
                    <br/>
                </xsl:for-each>  
                <xsl:for-each select="altIdentifier[normalize-space()]">
                    <xsl:text>Alt. Signatur: </xsl:text>
                    <xsl:value-of select="."/>
                    <br/>
                </xsl:for-each>  
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Editionen -->
    <xsl:template name="headerEditions">
        <span class="infoTitle">Posthume Edition: </span><br/>
        <xsl:for-each select=".//listBibl[@type='editions']/bibl">
            <p class="headerData">
                <xsl:value-of select="(title[normalize-space()] | biblScope[normalize-space()]) => string-join(', ')"/>
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Digitalisat (online) -->
    <xsl:template name="headerOnline">
        <xsl:if test=".//listBibl[@type='online']/bibl[normalize-space(@source)]">
            <span class="infoTitle">Digitalisat (online): </span><br/>
            <xsl:for-each select=".//listBibl[@type='online']/bibl[normalize-space(@source)]">
                <p class="headerData">
                    <a class="onlineLink" href="{@source}"><xsl:value-of select="@source"/></a>
                </p>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- Faksimile (IIIF-Viewer) -->
    <xsl:template name="headerFacsimile">
        <xsl:if test=".//pb[@facs]">
            <xsl:variable name="manifest"
                select="'https://iiif.annemarie-schwarzenbach.ch/presentation/' || (@xml:id => encode-for-uri()) || '.json'"/>
            <p class="headerData">
                <span class="infoTitle">Faksimile: </span>
                <a class="facsimileLink" href="https://cforney.github.io/iiif-viewer-nuxt/content/zoom?manifest={$manifest}">Im IIIF-Viewer öffnen</a>
            </p>
        </xsl:if>
    </xsl:template>
    
    <!-- Überblickskommentar -->
    <xsl:template name="headerGlobalComment">
        <xsl:if test=".//notesStmt/note[@type='global_comment']">
            <div>
                <span class="infoTitle">Überblickskommentar: </span><br/>
                <xsl:apply-templates select=".//notesStmt/note[@type='global_comment']"  mode="#current"/>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- FUNCTIONS -->
    
    <!-- formatDateAttributes: @when | @notBefore/@notAfter (letters) | @from/@to (smallforms);
         conjectural dates in brackets -->
    <xsl:function name="dseas:formatDateAttributes" as="xs:string">
        <xsl:param name="date" as="element()*"/>
        <xsl:variable name="d" select="$date[1]"/>
        <xsl:variable name="min" select="($d/@notBefore, $d/@from)[1]"/>
        <xsl:variable name="max" select="($d/@notAfter, $d/@to)[1]"/>
        <xsl:variable name="text" select="
            if ($d/@when) then dseas:formatDate($d/@when)
            else if ($min and $max) then dseas:formatRange($min, $max)
            else if ($min) then 'nach ' || dseas:formatDate($min)
            else if ($max) then 'vor ' || dseas:formatDate($max)
            else ''"/>
        <xsl:sequence select="if ($text = '') then '-' else if ($d/@type = 'conjecture') then '[' || $text || ']' else $text"/>
    </xsl:function>

    <!-- formatRange: compact forms for year and same-year month ranges, e.g. "1928/1929", "Mai/Juni 1931", "Mai–Juli 1931" -->
    <xsl:function name="dseas:formatRange" as="xs:string">
        <xsl:param name="min" as="xs:string"/>
        <xsl:param name="max" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($min, '^\d{4}$') and matches($max, '^\d{4}$')">
                <xsl:sequence select="$min || (if (xs:integer($max) - xs:integer($min) = 1) then '/' else '–') || $max"/>
            </xsl:when>
            <xsl:when test="matches($min, '^\d{4}-\d\d$') and matches($max, '^\d{4}-\d\d$')
                and substring($min, 1, 4) = substring($max, 1, 4)
                and (every $v in ($min, $max) satisfies ($v || '-01') castable as xs:date)">
                <xsl:variable name="months" select="for $v in ($min, $max) return format-date(xs:date($v || '-01'), '[MNn]', 'de', (), ())"/>
                <xsl:variable name="sep" select="if (xs:integer(substring($max, 6)) - xs:integer(substring($min, 6)) = 1) then '/' else '–'"/>
                <xsl:sequence select="$months[1] || $sep || $months[2] || ' ' || substring($min, 1, 4)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'zwischen ' || dseas:formatDate($min) || ' und ' || dseas:formatDate($max)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- formatDate: yyyy-mm-dd | yyyy-mm | yyyy in German; other values verbatim -->
    <xsl:function name="dseas:formatDate" as="xs:string">
        <xsl:param name="date"/>
        <xsl:variable name="d" select="string($date)"/>
        <xsl:sequence select="
            if (matches($d, '^\d{4}-\d\d-\d\d$') and $d castable as xs:date) then format-date(xs:date($d), '[D1o] [MNn] [Y0001]', 'de', (), ())
            else if (matches($d, '^\d{4}-\d\d$') and ($d || '-01') castable as xs:date) then format-date(xs:date($d || '-01'), '[MNn] [Y0001]', 'de', (), ())
            else $d"/>
    </xsl:function>
</xsl:stylesheet>
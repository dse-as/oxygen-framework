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
            <xsl:value-of select=".//titleStmt/title => fn:normalize-space()"/>
        </h1>
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
            <xsl:for-each select=".//sourceDesc/bibl/bibl/date[normalize-space()]">
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
    
    <!-- formatDateAttributes -->
    <xsl:function name="dseas:formatDateAttributes">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="$date[@when]">
                <xsl:value-of select="dseas:formatDate($date/@when)"/>
            </xsl:when>
            <xsl:when test="$date[@from and @to]">
                <xsl:text>zwischen </xsl:text>
                <xsl:value-of select="dseas:formatDate($date/@from)"/>
                <xsl:text> und </xsl:text>
                <xsl:value-of select="dseas:formatDate($date/@to)"/>
            </xsl:when>
            <xsl:when test="$date[@from]">
                <xsl:text>nach </xsl:text>
                <xsl:value-of select="dseas:formatDate($date/@from)"/>
            </xsl:when>
            <xsl:when test="$date[@to]">
                <xsl:text>vor </xsl:text>
                <xsl:value-of select="dseas:formatDate($date/@to)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- formatDate -->
    <xsl:function name="dseas:formatDate">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="matches($date,'^\d\d\d\d-\d\d-\d\d$')">
                <xsl:try>
                    <xsl:value-of select="format-date($date, '[D1o] [MNn] [Y0001]')"/>
                    <xsl:catch>
                        <xsl:value-of select="$date"/>
                    </xsl:catch>
                </xsl:try>
            </xsl:when>
            <xsl:when test="matches($date,'^\d\d\d\d-\d\d$')">
                <xsl:try>
                    <xsl:value-of select="format-date($date, '[MNn] [Y0001]')"/>
                    <xsl:catch>
                        <xsl:value-of select="$date"/>
                    </xsl:catch>
                </xsl:try>
            </xsl:when>
            <xsl:when test="matches($date,'^\d\d\d\d$')">
                <xsl:value-of select="$date"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
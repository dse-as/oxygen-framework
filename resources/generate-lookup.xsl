<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    exclude-result-prefixes="#all"
    expand-text="true"
    version="3.0">
    
    <xsl:param name="type" select="'all'"/>
    <xsl:param name="sheetID" select="'1pzY0f-4SyWGZEd3-kF2E-djY54qsr9HrRIljVDG5gkc'"/>
    <xsl:param name="zotero-project" select="'5746334'"/>
    <xsl:variable name="result-path" select="document-uri(.) => replace('generate-lookup.xsl','')"/>
    
    <xsl:template match="/">
        <xsl:if test="system-property('xsl:version') lt '3.0'">
            <xsl:message terminate="yes">XSLT 3.0 or higher is required.</xsl:message>
        </xsl:if>
        <xsl:if test="$type = 'person' or $type = 'all'">
            <xsl:call-template name="generate-list-from-gsheet">
                <xsl:with-param name="sheet" select="'Personen'"/>
                <xsl:with-param name="output-file" select="'lookup-person.xml'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'place' or $type = 'all'">
            <xsl:call-template name="generate-list-from-gsheet">
                <xsl:with-param name="sheet" select="'Orte'"/>
                <xsl:with-param name="output-file" select="'lookup-place.xml'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'org' or $type = 'all'">
            <xsl:call-template name="generate-list-from-gsheet">
                <xsl:with-param name="sheet" select="'Organisationen'"/>
                <xsl:with-param name="output-file" select="'lookup-org.xml'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'bibl' or $type = 'all'">
            <xsl:call-template name="generate-list-from-zotero"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Google Sheet -->
    <xsl:template name="generate-list-from-gsheet">
        <xsl:param name="sheet"/>
        <xsl:param name="output-file"/>
        <xsl:variable name="url" select="'https://docs.google.com/a/google.com/spreadsheets/d/'||$sheetID||'/gviz/tq?tqx=out:csv&amp;sheet='||$sheet"/>
        <xsl:try>
            <xsl:variable name="result" select="unparsed-text-lines($url)"/>
            <xsl:variable name="list">
                <ul type="{lower-case($sheet)}">
                    <xsl:for-each select="$result[position() gt 1][count(tokenize(.,'&quot;')) ge 4]">
                        <xsl:sort select="tokenize(.,'&quot;')[4]"/>
                        <xsl:variable name="id" select="tokenize(.,'&quot;')[2]"/>
                        <xsl:variable name="label" select="tokenize(.,'&quot;')[4]"/>
                        <xsl:if test="matches($id,'\d\d\d') and $label!=''">
                            <li id="{$id}" val="{$label}"/>
                        </xsl:if>
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
    
    <!-- Zotero -->
    <xsl:template name="generate-list-from-zotero">
        <xsl:param name="url" select="'https://api.zotero.org/groups/'||$zotero-project||'/items?limit=100'"/>
        <xsl:try>
            <xsl:variable name="result" select="unparsed-text($url) => parse-json()"/>
            <xsl:variable name="list">
                <ul type="bibl">
                    <xsl:for-each select="$result?*?('data')[not(matches(?('itemType'), 'annotation|attachment|note'))]">
                        <xsl:sort select="?('creators')[1]?*?('lastName')[1]"/>
                        <xsl:sort select="?('date')"/>
                        <xsl:sort select="?('title')"/>
                        <xsl:variable name="id" select="?('key')"/>
                        <xsl:variable name="itemType" select="?('itemType')"/>
                        <xsl:variable name="label" select="?('title')"/>
                        <xsl:variable name="creator" select="?('creators')[1]?*?('lastName')[1]"/>
                        <xsl:variable name="date" select="?('date')"/>
                        <li id="{$id}" val="{(if ($creator) then $creator else 'NN') || (if ($date) then ' (' || $date || '): ' else ': ') || $label || ' [' || $id || '], ' || $itemType}"/>
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            <xsl:result-document href="{$result-path||'lookup-bibl.xml'}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} bibliographic entries in {$result-path||'lookup-bibl.xml'}</xsl:message>
            <xsl:catch>
                <xsl:message>⚠ Failed to fetch or parse data from {$url}
                    Code: <xsl:value-of select="$err:code"/>
                    Description: <xsl:value-of select="$err:description"/>
                </xsl:message>
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
</xsl:transform>
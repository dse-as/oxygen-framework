<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
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
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'place' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="$gsheet-sheetID"/>
                <xsl:with-param name="sheet" select="'Orte'"/>
                <xsl:with-param name="output-file" select="'lookup-place.xml'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$type = 'org' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="$gsheet-sheetID"/>
                <xsl:with-param name="sheet" select="'Organisationen'"/>
                <xsl:with-param name="output-file" select="'lookup-org.xml'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$type = 'letter' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="'1KgZmtgZUEKx6o48KXTAYxWHhsOVrIxyOElFAUUOIc98'"/>
                <xsl:with-param name="sheet" select="'Briefe'"/>
                <xsl:with-param name="output-file" select="'lookup-letter.xml'"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$type = 'smallform' or $type = 'all'">
            <xsl:call-template name="fetch-and-process-gsheet-items">
                <xsl:with-param name="sheetID" select="'1S2Qun726gyqUKr2Yb5vW9RaGPlo8vZ43qbTV-xryyEo'"/>
                <xsl:with-param name="sheet" select="'Kleine+Formen'"/>
                <xsl:with-param name="output-file" select="'lookup-smallform.xml'"/>
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
                    <li id="{$id}" val="{(if ($creator) then $creator else 'NN') || (if ($date) then ' (' || $date || '): ' else ': ') || $label || ' [' || $id || '], ' || $itemType}"/>
                </xsl:for-each>
            </ul>
        </xsl:variable>
        <xsl:result-document href="{$result-path||'lookup-bibl.xml'}" method="xml" indent="no">
            <xsl:copy-of select="$list"/>
        </xsl:result-document>
        <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} bibliographic entries in {$result-path||'lookup-bibl.xml'}</xsl:message>
    </xsl:template>
    
</xsl:transform>
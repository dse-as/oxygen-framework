<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="type"/>
    
    <xsl:variable name="sheetID" select="'1pzY0f-4SyWGZEd3-kF2E-djY54qsr9HrRIljVDG5gkc'"/>
    <xsl:variable name="zotero-project" select="'5746334'"/>
    <xsl:variable name="result-path" select="document-uri(.) => replace('generate-lookup.xsl','')"/>
    
    <xsl:template match="/">
       
        <xsl:if test="$type = 'person' or $type = 'all'">
            <xsl:variable name="result" select="unparsed-text-lines('https://docs.google.com/spreadsheets/d/'||$sheetID||'/export?format=tsv&amp;gid=846284184')"/>
            <xsl:variable name="list">
                <ul type="org">
                    <xsl:for-each select="$result[position() gt 1]">
                        <xsl:variable name="id" select=". => substring-before('&#x9;')"/>
                        <xsl:variable name="label" select=". => substring-after('&#x9;') => substring-before('&#x9;')"/>
                        <xsl:if test="matches($id,'\d\d\d') and $label!=''">
                            <li id="{$id}" val="{$label}"/> 
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            
            <xsl:result-document href="{$result-path||'lookup-person.xml'}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} person entries in {$result-path||'lookup-person.xml'}</xsl:message>
        </xsl:if>
        
        <xsl:if test="$type = 'place' or $type = 'all'">
            <xsl:variable name="result" select="unparsed-text-lines('https://docs.google.com/spreadsheets/d/'||$sheetID||'/export?format=tsv&amp;gid=811311071')"/>
            <xsl:variable name="list">
                <ul type="org">
                    <xsl:for-each select="$result[position() gt 1]">
                        <xsl:variable name="id" select=". => substring-before('&#x9;')"/>
                        <xsl:variable name="label" select=". => substring-after('&#x9;') => substring-before('&#x9;')"/>
                        <xsl:if test="matches($id,'\d\d\d') and $label!=''">
                            <li id="{$id}" val="{$label}"/> 
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            
            <xsl:result-document href="{$result-path||'lookup-place.xml'}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} place entries in {$result-path||'lookup-place.xml'}</xsl:message>
        </xsl:if>
        
        <xsl:if test="$type = 'org' or $type = 'all'">
            <xsl:variable name="result" select="unparsed-text-lines('https://docs.google.com/spreadsheets/d/'||$sheetID||'/export?format=tsv&amp;gid=1709662033')"/>
            <xsl:variable name="list">
                <ul type="org">
                    <xsl:for-each select="$result[position() gt 1]">
                        <xsl:variable name="id" select=". => substring-before('&#x9;')"/>
                        <xsl:variable name="label" select=". => substring-after('&#x9;') => substring-before('&#x9;')"/>
                        <xsl:if test="matches($id,'\d\d\d') and $label!=''">
                            <li id="{$id}" val="{$label}"/> 
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            
            <xsl:result-document href="{$result-path||'lookup-org.xml'}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} organisation entries in {$result-path||'lookup-org.xml'}</xsl:message>
        </xsl:if>
        
        <xsl:if test="$type = 'bibl' or $type = 'all'">
            <xsl:variable name="result" select="unparsed-text('https://api.zotero.org/groups/'||$zotero-project||'/items') => parse-json()"/>
            <xsl:variable name="list">
                <ul type="bibl">
                    <xsl:for-each select="$result?*?('data')">
                        <xsl:sort select="?('creators')[1]?*?('lastName')[1]"/>
                        <xsl:sort select="?('date')"/>
                        <xsl:sort select="?('title')"/>
                        <xsl:variable name="id" select="?('key')"/>
                        <xsl:variable name="itemType" select="?('itemType')"/>
                        <xsl:variable name="label" select="?('title')"/>
                        <xsl:variable name="creator" select="?('creators')[1]?*?('lastName')[1]"/>
                        <xsl:variable name="date" select="?('date')"/>
                        <li id="{$id}" val="{(if ($creator) then $creator else 'NN') ||
                            (if ($date) then ' (' || $date || '): ' else ': ') ||
                            $label || ' [' || $id || '], ' || $itemType}"/>  
                    </xsl:for-each>
                </ul>
            </xsl:variable>
            
            <xsl:result-document href="{$result-path||'lookup-bibl.xml'}" method="xml" indent="no">
                <xsl:copy-of select="$list"/>
            </xsl:result-document>
            
            <xsl:message expand-text="yes">✅ Saved {count($list//*:li)} bibliographic entries in {$result-path||'lookup-bibl.xml'}</xsl:message>
        </xsl:if>            
        
    </xsl:template>
    
</xsl:transform>
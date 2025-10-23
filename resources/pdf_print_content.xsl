<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:dseas="https://annemarie-schwarzenbach.ch/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!-- cb -->
    <xsl:template mode="#all" match="cb">
        <span class="cb">
            <xsl:text>|</xsl:text>
        </span>
    </xsl:template>
    
    <!-- g -->
    <xsl:template mode="#all" match="g[(@ref='#ngem' and .='n') or (@ref='#mgem' and .='m')]">
        <span class="g">
            <xsl:value-of select=".||."/>
        </span>
    </xsl:template>

    <!-- milestone -->
    <xsl:template mode="#all" match="milestone"/>
    
    <!-- lb -->
    <xsl:template mode="#all" match="lb">
        <!--<br/>-->
    </xsl:template>
        
    <!-- This template removes trailing whitespace directly preceding a lb element with @break = 'no' -->
    <xsl:template mode="#all" match="text()[following-sibling::*[position()=1 and local-name()='lb' and @break='no']][matches(.,'\s+$')]">
        <xsl:value-of select="replace(.,'\s+$','')"/>    
    </xsl:template>

    <!-- p -->
    <xsl:template match="p">
        <xsl:element name="p">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- pb -->
    <xsl:template mode="#all" match="pb">
        <span class="pb">
            <xsl:text>|</xsl:text>
            <xsl:if test="@n">
                <span class="pbNum">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="@n"/>
                    <xsl:text>) </xsl:text>
                </span>
            </xsl:if>
        </span>
    </xsl:template>
    
    <!-- ab -->
    <xsl:template mode="#all" match="ab[address]">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- address -->
    <xsl:template mode="#all" match="address">
        <span class="address">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <xsl:template mode="#all" match="addrLine">
        <xsl:apply-templates mode="#current"/>
        <br/>
    </xsl:template>
    
    <xsl:template mode="#all" match="closer">
        <div class="closer">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template mode="#all" match="opener">
        <div class="opener">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template mode="#all" match="postscript">
        <div class="postscript">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template mode="#all" match="dateline">
        <p class="dateline">
            <xsl:choose>
                <xsl:when test="@rendition='#left'">
                    <div class="alignLeft">
                        <xsl:apply-templates mode="#current"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    
    <xsl:template mode="#all" match="salute">
        <p class="salute">
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    
    <xsl:template mode="#all" match="signed">
        <p class="signed">
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    
    <!-- list -->
    <xsl:template mode="#all" match="list">
        <xsl:choose>
            <xsl:when test=".[@type='ordered']">
                <ol>
                    <xsl:apply-templates mode="#current"/>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test=".[@rendition='none']">
                        <ul style="list-style-type:none;">
                            <xsl:apply-templates mode="#current"/>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul>
                            <xsl:apply-templates mode="#current"/>
                        </ul> 
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template mode="#all" match="item[not(.//list)]">
        <li>
            <xsl:apply-templates mode="#current"/>
        </li>
    </xsl:template>
    
    <!-- table -->
    <xsl:template name="table_template" mode="#all" match="table">
        <div class="tableContainer">
            <table>
                <caption>
                    <xsl:for-each select="head">
                        <span class="tableCaption"> 
                            <xsl:apply-templates mode="#current"/>
                        </span>
                    </xsl:for-each>
                </caption>
                <xsl:for-each select="row">
                    <tr>
                        <xsl:choose>
                            <xsl:when test="@role='label'">
                                <xsl:for-each select="cell">
                                    <th>
                                        <xsl:sequence select="dseas:drawCell(.)"/>
                                        <xsl:apply-templates mode="#current"/>
                                    </th>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="cell">
                                    <td>
                                        <xsl:sequence select="dseas:drawCell(.)"/>
                                        <xsl:apply-templates mode="#current"/>
                                    </td>
                                </xsl:for-each>
                            </xsl:otherwise> 
                        </xsl:choose>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
    </xsl:template>
    
    <!-- lg/l -->
    <xsl:template mode="#all" match="lg[@type='poem']">
        <p class="poem">
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
    <xsl:template mode="#all" match="lg[@n]">
        <span class="strophe">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="l">
        <xsl:apply-templates mode="#current"/>
        <br/>
    </xsl:template>
    
    <!-- quote -->
    <xsl:template mode="#all" match="quote[not(parent::div)]">
        <span class="quoteInline">
            "<xsl:apply-templates mode="#current"/>"
        </span>
    </xsl:template>
    
    <xsl:template mode="#all" match="quote[parent::div]">
        <p class="quoteBlock">
            <xsl:apply-templates mode="#current"/>
        </p>
    </xsl:template>
        
    <!-- hi -->
    <xsl:template match="hi[@rendition='#u']" mode="#all">
        <span class="underline">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#i']" mode="#all">
        <span class="italic">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#b']" mode="#all">
        <span class="bold">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#g']" mode="#all">
        <span class="spaced">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#sub']" mode="#all">
        <span class="sub">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#sup']" mode="#all">
        <span class="sup">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template match="hi[@rendition='#c']" mode="#all">        
        <span class="center">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <!-- unclear -->
    <xsl:template mode="#all" match="unclear">
        <span class="gapSymbol">&#8970;</span>
            <xsl:apply-templates mode="#current"/>
        <span class="gapSymbol">&#8969;</span>
    </xsl:template>
    
    <!-- foreign -->
    <xsl:template mode="#all" match="foreign">
        <span class="foreign">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <!-- head -->
    <xsl:template match="head">
        <xsl:variable name="preDivs" select="count(ancestor-or-self::div)"/>
        <xsl:choose>
            <xsl:when test="$preDivs gt 0 and $preDivs lt 7">
                <!-- h1, h2, h3, h4, h5, h6 -->
                <element name="{h||$preDivs}">
                    <xsl:apply-templates mode="#current"/>
                </element>
            </xsl:when>
            <xsl:otherwise>
                <p class="minorHeading">
                    <xsl:apply-templates mode="#current"/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- seg -->
    <xsl:template mode="#all" match="seg">
        <span class="seg">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <!-- TODO: figure -->
    <xsl:template mode="#all" match="figure">
        <!--<br/>-->
        <p class="figure">
            <xsl:text>[Abbildung]</xsl:text>
            <xsl:apply-templates select="p" mode="#current"/>
        </p>
    </xsl:template>
    
    <!-- FUNCTIONS -->
    
    <xsl:function name="dseas:drawCell">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$node/@cols and $node/@rows">
                <xsl:attribute name="colspan" select="$node/@cols"/>
                <xsl:attribute name="rowspan" select="$node/@rows"/>
            </xsl:when>
            <xsl:when test="$node/@cols">
                <xsl:attribute name="colspan" select="$node/@cols"/>
            </xsl:when>
            <xsl:when test="$node/@rows">
                <xsl:attribute name="rowspan" select="$node/@rows"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$node/@rendition='#right'">
            <xsl:attribute name="class" select="'alignRight'"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="dseas:endnoteAtEnd">
        <xsl:param name="counter"/>
        <span>
            <xsl:attribute name="name" select="'appRef_'||$counter"/>
            <xsl:attribute name="href" select="'#app_'||$counter"/>
            <span class="endnote">
                <xsl:value-of select="$counter"/>
                <xsl:text>)</xsl:text>
            </span>
        </span>
        <xsl:text> </xsl:text>
    </xsl:function>
    
    <xsl:function name="dseas:endnoteInText">
        <xsl:param name="counter"/>
        <span>
            <xsl:attribute name="name" select="'appRef_'||$counter"/>
            <xsl:attribute name="href" select="'#app_'||$counter"/>
            <span class="sup"><xsl:value-of select="$counter||' '"/></span>
        </span>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_noteFoot">
        <xsl:param name="node"/>
        <xsl:apply-templates select="$node/node()"/>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_add">
        <xsl:param name="node"/>
        <xsl:apply-templates select="$node"/>
        <xsl:text>] </xsl:text>
        <span class="additionLabel">
            <xsl:choose>
                <xsl:when test="$node[not(@place)]">
                    <xsl:text>eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'above']">
                    <xsl:text>überhalb eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'below']">
                    <xsl:text>unterhalb eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'top']">
                    <xsl:text>am oberen Rand eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'left']">
                    <xsl:text>am linken Rand eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'right']">
                    <xsl:text>am rechten Rand eingetragen</xsl:text>
                </xsl:when>
                <xsl:when test="$node[@place = 'bottom']">
                    <xsl:text>am unteren Rand eingetragen</xsl:text>
                </xsl:when>
            </xsl:choose>
        </span>
        
        <!--TODO: Hand-->
        <xsl:if test="$node[@hand]">
            <xsl:text> durch </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$node[@hand='#author']">
                <xsl:text>Autor dieses Textes</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@hand='#addressee']">
                <xsl:text>Empfänger des Briefes</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@hand='#unknown']">
                <xsl:text>unbekannten Schreiber</xsl:text>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_choice">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$node[abbr]">
                <xsl:text>Abkürzung durch Herausgeber aufgelöst.</xsl:text>
            </xsl:when>
            <xsl:when test="$node[corr[not(@type='deleted')]]">
                <xsl:value-of select="$node/corr||'] '||$node/sic"/>
            </xsl:when>
            <xsl:when test="$node[corr[(@type='deleted')]]">
                <span class="italic"><xsl:text>folgt </xsl:text></span>
                <xsl:value-of select="'&lt;&lt;'||$node/sic||'&gt;&gt;'"/>
            </xsl:when>
            <xsl:when test="$node[orig]">
                <xsl:value-of select="$node/reg||'] '||$node/orig"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_del">
        <xsl:param name="node"/>
        <xsl:text>||] </xsl:text>
        <xsl:choose>
            <xsl:when test="$node[gap]">
                <span class="deletedGap">
                    <span class="angleBracket">&#x2329;</span>
                    <xsl:apply-templates select="$node/gap//preceding-sibling::node()"/>
                    <span class="gapSymbol"> &#8970;&#8969; </span>
                    <xsl:apply-templates select="$node/gap//following-sibling::node()"/>
                    <span class="angleBracket">&#x232A;</span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="deleted">
                    <xsl:apply-templates select="$node/string()"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_gap">
        <xsl:param name="node"/>
        <span class="gapSymbol">&#8970;&#8969;</span>
        <xsl:text>] </xsl:text>
        <xsl:choose>
            <xsl:when test="$node[@reason = 'lost']">
                <xsl:text>Verlust</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@reason = 'illegible']">
                <xsl:text>unleserlich</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_note">
        <xsl:param name="node"/>
        <xsl:text>Anmerkung im Original</xsl:text>
        <xsl:choose>
            <xsl:when test="$node[@place='right']">
                <xsl:text> am rechten Rand</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@place='left']">
                <xsl:text> am linken Rand</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@place='top']">
                <xsl:text> am oberen Rand</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@place='bottom']">
                <xsl:text> am unteren Rand</xsl:text>
            </xsl:when>
            <xsl:when test="$node[@place='inline']">
                <xsl:text> innerhalb der Zeile</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="if ($node[normalize-space()]) then ': '||$node => normalize-space() else ''"/>
    </xsl:function>
    
    <xsl:function name="dseas:noteContent_space">
        <xsl:param name="node"/>
        <span class="spaceFootnote">
            <xsl:choose>
                <xsl:when test="$node/@dim= 'horizontal'">
                    <xsl:text>Horizontale </xsl:text>
                </xsl:when>
                <xsl:when test="$node/@dim = 'vertical'">
                    <xsl:text>Vertikale </xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:text>Lücke</xsl:text>
        </span>
    </xsl:function>

</xsl:stylesheet>
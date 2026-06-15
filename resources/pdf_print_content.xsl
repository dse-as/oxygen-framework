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
    <!-- A normal <lb/> is a word boundary; it renders as nothing because the
         source whitespace that surrounds it already collapses to a single
         space. A non-breaking <lb break="no"/> renders as nothing too, and the
         surrounding whitespace is stripped by the text() normalisation below. -->
    <xsl:template mode="#all" match="lb">
        <!--<br/>-->
    </xsl:template>

    <!-- ============================================================
         Line-break (lb) whitespace normalisation
         ============================================================
         The sources are transcribed line by line: every physical line of the
         witness starts with an <lb/>, and because the XML is pretty-printed,
         each line's text node carries trailing "newline + indentation"
         whitespace. The reading text in the PDF must join those lines again:

           * normal  <lb/>          word boundary  => keep one space
                                     (the trailing source whitespace provides it)
           * <lb break="no"/>       NOT a word boundary => the word continues,
                                     so the two lines are joined with NO space
                                     (e.g. "Ein" + "zelnen" => "Einzelnen")

         Only <lb break="no"/> joins the two halves. Hyphens are NEVER altered:
         a word-final "-" before a normal <lb/> is kept verbatim (so e.g.
         "Anne-" + <lb/> + "marie" stays "Anne- marie", it is NOT merged into
         "Annemarie").
         ============================================================ -->
    <xsl:template mode="#all" match="text()">
        <xsl:choose>
            <!-- Whitespace-only node: it normally just pads the gap between
                 inline markup and an <lb>. Drop it when it merely fills the gap
                 around a non-breaking <lb> (otherwise it collapses into a stray
                 space inside the joined word); keep it everywhere else. -->
            <xsl:when test="not(normalize-space())">
                <xsl:if test="not(dseas:inNoBreakGap(.))">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="dseas:normaliseLineText(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- p -->
    <xsl:template match="p">
        <xsl:element name="p">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>

    <!-- label (Zwischentitel im Überblickskommentar) -->
    <xsl:template mode="#all" match="label[ancestor::note[@type='global_comment']]">
        <span class="subheading">
            <xsl:apply-templates mode="#current"/>
        </span>
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
        
    <!-- map rendition values to class names -->
    <xsl:variable name="rendition-map" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'#u'" select="'underline'"/>
            <xsl:map-entry key="'#i'" select="'italic'"/>
            <xsl:map-entry key="'#b'" select="'bold'"/>
            <xsl:map-entry key="'#g'" select="'spaced'"/>
            <xsl:map-entry key="'#sub'" select="'sub'"/>
            <xsl:map-entry key="'#sup'" select="'sup'"/>
            <xsl:map-entry key="'#c'" select="'center'"/>
        </xsl:map>
    </xsl:variable>
    
    <!-- hi -->
    <xsl:template match="hi[@rendition]" mode="#all">
        <xsl:variable name="cssClass" select="$rendition-map(@rendition)"/>
        <xsl:choose>
            <xsl:when test="exists($cssClass)">
                <span class="{$cssClass}">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <!-- Fallback for unknown rendition values -->
                <span class="{substring-after(@rendition, '#')}">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
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

    <!-- True when a whitespace-only text node only pads the gap immediately
         before or after a non-word-breaking <lb> (i.e. there is no significant
         text between it and that <lb>). Such padding must be discarded so the
         word halves join seamlessly; whitespace anywhere else is preserved. -->
    <xsl:function name="dseas:inNoBreakGap" as="xs:boolean">
        <xsl:param name="t" as="text()"/>
        <xsl:variable name="nextNoBreak" select="$t/following::lb[@break='no'][1]"/>
        <xsl:variable name="prevNoBreak" select="$t/preceding::lb[@break='no'][1]"/>
        <xsl:sequence select="
            (: in the gap that ends just before a non-breaking lb :)
            (exists($nextNoBreak)
                and (empty($t/following::text()[normalize-space()])
                     or $nextNoBreak &lt;&lt; $t/following::text()[normalize-space()][1]))
            or
            (: in the gap that starts just after a non-breaking lb :)
            (exists($prevNoBreak)
                and (empty($t/preceding::text()[normalize-space()])
                     or $t/preceding::text()[normalize-space()][1] &lt;&lt; $prevNoBreak))
            "/>
    </xsl:function>

    <!-- Normalises a significant (non-whitespace) text node with respect to the
         line breaks around it: strips the leading whitespace when the previous
         line was joined onto this one (preceding lb break="no"), and strips the
         trailing whitespace when this line is joined onto the next one (following
         lb break="no"). A plain word-breaking <lb/> leaves the surrounding
         whitespace untouched so it collapses to the expected single inter-word
         space. Hyphens are left exactly as transcribed. -->
    <xsl:function name="dseas:normaliseLineText" as="xs:string">
        <xsl:param name="t" as="text()"/>

        <!-- the <lb> that opens this text node's line, if this is its first
             significant text -->
        <xsl:variable name="prevLb" select="$t/preceding::lb[1]"/>
        <xsl:variable name="lineInitial" as="xs:boolean" select="
            exists($prevLb)
            and (empty($t/preceding::text()[normalize-space()])
                 or $t/preceding::text()[normalize-space()][1] &lt;&lt; $prevLb)"/>

        <!-- the <lb> that closes this text node's line, if this is its last
             significant text -->
        <xsl:variable name="nextLb" select="$t/following::lb[1]"/>
        <xsl:variable name="lineFinal" as="xs:boolean" select="
            exists($nextLb)
            and (empty($t/following::text()[normalize-space()])
                 or $nextLb &lt;&lt; $t/following::text()[normalize-space()][1])"/>

        <!-- the previous line joins onto this one only when it ended on a
             non-breaking lb; this line joins onto the next one only when it ends
             on a non-breaking lb -->
        <xsl:variable name="joinedFromPrev" as="xs:boolean"
            select="$lineInitial and $prevLb/@break = 'no'"/>
        <xsl:variable name="joinsToNext" as="xs:boolean"
            select="$lineFinal and $nextLb/@break = 'no'"/>

        <xsl:variable name="afterLead" select="
            if ($joinedFromPrev) then replace(string($t), '^\s+', '') else string($t)"/>
        <xsl:variable name="afterTrail" select="
            if ($joinsToNext) then replace($afterLead, '\s+$', '') else $afterLead"/>
        <xsl:sequence select="$afterTrail"/>
    </xsl:function>

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
    
    <!-- Handler for all note content types -->
    <xsl:function name="dseas:noteContent">
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            <!-- noteFoot: Content notes (annotation/figure_note) -->
            <xsl:when test="$node[self::note and (@type='annotation' or @type='figure_note')]">
                <xsl:apply-templates select="$node/node()"/>
            </xsl:when>
            
            <!-- add: Addition -->
            <xsl:when test="$node[self::add]">
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
            </xsl:when>
            
            <!-- choice: Abbreviation, correction, or normalization -->
            <xsl:when test="$node[self::choice]">
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
            </xsl:when>
            
            <!-- del: Deletion -->
            <xsl:when test="$node[self::del]">
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
            </xsl:when>
            
            <!-- gap: Gap/lacuna -->
            <xsl:when test="$node[self::gap]">
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
            </xsl:when>
            
            <!-- note: Original note/marginal (non-annotation type) -->
            <xsl:when test="$node[self::note]">
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
            </xsl:when>
            
            <!-- space: Intentional space/gap -->
            <xsl:when test="$node[self::space]">
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
            </xsl:when>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
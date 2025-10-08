<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:dseas="https://annemarie-schwarzenbach.ch/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">

    <!--
        The PDF functionality in this framework is adapted from https://github.com/ediarum/ediarum.BASE.edit.
        GNU General Public License © Berlin-Brandenburg Academy of Sciences and Humanities.
    -->

    <xsl:import href="pdf_print_header.xsl"/>
    <xsl:import href="pdf_print_content.xsl"/>
    
    <xsl:output method="html"/>

    <xsl:param name="p_notesAsFootnotes" select="true()"/>
    
    <xsl:variable name="placeOfNotes" select="if ($p_notesAsFootnotes = true()) then 'foot' else 'end'"/>
    
    <xsl:template match="TEI">
        <html>
            <head>
                <meta name="author" content="DSE-AS"/>
                <meta name="description" content="{'PDF-Vorschau vom '||format-date(fn:current-date(),'[D01].[M01].[Y0001]')||', '||format-time(fn:current-time(),'[H01]:[m01]')}"/>
                <title><xsl:value-of select="//titleStmt/title"/></title>
            </head>
            <body>

                <p class="heading">
                    <xsl:value-of select="//titleStmt/title"/>
                </p>

                <xsl:call-template name="structure_header"/>
                
                <xsl:call-template name="structure_content">
                    <xsl:with-param name="placeOfNotes" select="$placeOfNotes"/>
                </xsl:call-template>

                <xsl:call-template name="structure_criticalApp">
                    <xsl:with-param name="placeOfNotes" select="$placeOfNotes"/>
                </xsl:call-template>
                
                <!-- CreatedAt -->
                <p class="createdAt">
                    <br/>
                    <xsl:value-of select="'PDF-Vorschau vom '||format-date(fn:current-date(),'[D01].[M01].[Y0001]')||', '||format-time(fn:current-time(),'[H01]:[m01]')"/>
                </p>
                
            </body>
        </html>
    </xsl:template>

    <!-- header -->
    <xsl:template name="structure_header">
        <header>
            <xsl:call-template name="headerTitle"/>
            <div class="headerInfo">
                <xsl:if test="./@xml:id">
                    <xsl:call-template name="headerId"/>
                </xsl:if>
                <xsl:if test=".//sourceDesc/msDesc/msIdentifier">
                    <xsl:call-template name="headerMsIdent"/>
                </xsl:if>
                <xsl:if test=".//profileDesc/correspDesc">
                    <xsl:call-template name="headerCorresp"/>
                </xsl:if>
                <xsl:if test=".//sourceDesc/bibl">
                    <xsl:call-template name="headerBibl"/>
                </xsl:if>
                <xsl:if test=".//notesStmt/note[@type='global_comment'][normalize-space()]">
                    <xsl:call-template name="headerGlobalComment"/>
                </xsl:if>
            </div>
            <br/>
        </header>
    </xsl:template>
    
    <!-- content -->
    <xsl:template name="structure_content">
        <xsl:param name="placeOfNotes"/>
        <div>
            <hr/>
            <h2>Transkription</h2>
            <xsl:for-each select=".//body/div">
                <div class="textDiv">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="placeOfNotes" tunnel="yes" select="$placeOfNotes"/>
                    </xsl:apply-templates>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <!-- TEMPLATES (APP) -->
    
    <!-- structure_criticalApp -->
    <xsl:template name="structure_criticalApp">
        <xsl:param name="placeOfNotes"/>
        
        <xsl:variable name="textNoteElements" select="//add[not(ancestor::subst)] |
                            //choice[abbr | corr | orig] |
                            //del[not(ancestor::subst)] |
                            //gap |
                            //note[ancestor::div][not(@type='annotation') and not(@type='figure_note') and not(ancestor::seg)] |
                            //space"/>
        
        <xsl:variable name="contentNoteElements" select="//note[ancestor-or-self::div and (@type='annotation' or @type='figure_note')] |
                            //rs[ancestor-or-self::body][not(@key=preceding::rs[ancestor-or-self::body]/@key)][not(@type='place')] |
                            //ref[ancestor-or-self::body][not(ancestor-or-self::note)][@target]"/>
        
        <xsl:if test="($placeOfNotes = 'foot' and count($textNoteElements) gt 0) or ($placeOfNotes != 'foot' and count($contentNoteElements) gt 0)">
            <div class="criticalAppNextPage">
                <br/>
                <hr/>
                <h2>Kritischer Apparat</h2>
                <ul class="criticalApp">
                    <xsl:choose>
                        <!-- Bearbeitungsanmerkungen als Endnoten -->
                        <xsl:when test="$placeOfNotes = 'foot'">
                            <xsl:for-each select="$textNoteElements">
                                <xsl:apply-templates mode="criticalAppText" select="."/>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- Sachanmerkungen als Endnoten -->
                        <xsl:otherwise>
                            <xsl:for-each select="$contentNoteElements">
                                <xsl:apply-templates mode="criticalAppContent" select="."/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Footnotes - content notes -->
    <xsl:template match="note[ancestor-or-self::div and (@type='annotation' or @type='figure_note')] |
                         rs[ancestor-or-self::body][not(@key=preceding::rs[ancestor-or-self::body]/@key)][not(@type='place')] |
                         ref[ancestor-or-self::body][not(ancestor-or-self::note)][@target]">
        
        <xsl:param name="placeOfNotes" tunnel="yes"/>
        
        <xsl:variable name="counter" select="dseas:getCounterContent(.)"/>
        
        <xsl:choose>
            <xsl:when test="self::note">
                <xsl:if test="$placeOfNotes eq 'foot'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_noteFoot(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:when test="self::rs">
                <xsl:apply-templates/>
                <xsl:if test="$placeOfNotes eq 'foot'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:getRegisterLink(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        
        <xsl:if test="$placeOfNotes eq 'end'">
            <xsl:copy-of select="dseas:endnoteInText($counter)"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Endotes - content notes -->
    <xsl:template mode="criticalAppContent" match="*">
        
        <xsl:variable name="counter" select="dseas:getCounterContent(.)"/>
        
        <li>
            <xsl:copy-of select="dseas:endnoteAtEnd($counter)"/>
            
            <xsl:choose>
                <xsl:when test="self::note">
                    <xsl:copy-of select="dseas:noteContent_noteFoot(.)"/>
                </xsl:when>
                <xsl:when test="self::rs">
                    <xsl:copy-of select="dseas:getRegisterLink(.)"/>
                </xsl:when>
            </xsl:choose>
        </li>
    </xsl:template>
    
    <!-- Footnotes - textcritial notes -->
    <xsl:template match="add[not(ancestor::subst)] |
                         choice[abbr | corr | orig] |
                         del[not(ancestor::subst)] |
                         gap |
                         note[ancestor::div][not(@type='annotation') and not(@type='figure_note') and not(ancestor::seg)] |
                         space">
        
        <xsl:param name="placeOfNotes" tunnel="yes"/>
        
        <xsl:variable name="counter" select="dseas:getCounterText(.)"/>

        <xsl:choose>
            <xsl:when test="self::add[not(ancestor::subst)]">
                <xsl:apply-templates mode="#current"/>
                <xsl:if test="$placeOfNotes eq 'end'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_add(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:choose>
                    <xsl:when test=".[abbr]">
                        <span class="expan">
                            <xsl:apply-templates mode="#current" select="expan"/>
                        </span>
                        <xsl:if test="$placeOfNotes eq 'end'">
                            <span class="footnote">
                                <xsl:copy-of select="dseas:noteContent_choice(.)"/>
                            </span>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test=".[corr]">
                        <xsl:if test=".[corr[not(@type='deleted')]]">
                            <span>
                                <xsl:apply-templates mode="#current" select="corr"/>
                            </span>
                        </xsl:if>
                        <xsl:if test="$placeOfNotes eq 'end'">
                            <span class="footnote">
                                <xsl:copy-of select="dseas:noteContent_choice(.)"/>
                            </span>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test=".[orig]">
                        <xsl:apply-templates mode="#current" select="reg"/>
                        <xsl:if test="$placeOfNotes eq 'end'">
                            <span class="footnote">
                                <xsl:copy-of select="dseas:noteContent_choice(.)"/>
                            </span>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="self::del[not(ancestor::subst)]">
                <xsl:text>||</xsl:text>
                <xsl:if test="$placeOfNotes eq 'end'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_del(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:when test="self::gap">
                <xsl:choose>
                    <xsl:when test="self::gap[ancestor::del]"/>
                    <xsl:otherwise>
                        <span class="gapSymbol"> &#8970;&#8969; </span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$placeOfNotes eq 'end'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_gap(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:when test="self::note">
                <xsl:if test="$placeOfNotes eq 'end'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_note(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:when test="self::space">
                <xsl:text>| _ |</xsl:text>
                <xsl:if test="$placeOfNotes eq 'end'">
                    <span class="footnote">
                        <xsl:copy-of select="dseas:noteContent_space(.)"/>
                    </span>
                </xsl:if>
            </xsl:when>
        </xsl:choose>

        <xsl:if test="$placeOfNotes eq 'foot'">
            <xsl:choose>
                <xsl:when test="self::del and .[gap] or self::del[(ancestor::subst)]"/>
                <xsl:otherwise>
                    <xsl:copy-of select="dseas:endnoteInText($counter)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- Endnotes - textcritial notes -->
    <xsl:template mode="criticalAppText" match="*">
        
        <xsl:variable name="counter" select="dseas:getCounterText(.)"/>
        
        <li>
            <xsl:copy-of select="dseas:endnoteAtEnd($counter)"/>
            
            <xsl:choose>
                <xsl:when test="self::add">
                    <xsl:copy-of select="dseas:noteContent_add(.)"/>
                </xsl:when>
                <xsl:when test="self::choice">
                    <xsl:copy-of select="dseas:noteContent_choice(.)"/>
                </xsl:when>
                <xsl:when test="self::del[not(ancestor::subst)]">
                    <xsl:copy-of select="dseas:noteContent_del(.)"/>
                </xsl:when>
                <xsl:when test="self::gap">
                    <xsl:copy-of select="dseas:noteContent_gap(.)"/>
                </xsl:when>
                <xsl:when test="self::note">
                    <xsl:copy-of select="dseas:noteContent_note(.)"/>
                </xsl:when>
                <xsl:when test="self::space">
                    <xsl:copy-of select="dseas:noteContent_space(.)"/>
                </xsl:when>
            </xsl:choose>
        </li>
    </xsl:template>

    <!-- FUNCTIONS (APP) -->
    
    <!-- getCounterText -->
    <xsl:function name="dseas:getCounterText" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:for-each select="$node">
            <xsl:number level="any" format="aa" 
                count="add[not(ancestor::subst)] |
                       choice[abbr | corr | orig] |
                       del[not(ancestor::subst)] |
                       gap[not(ancestor::del)] |
                       note[ancestor::div][not(@type='annotation') and not(@type='figure_note') and not(ancestor::seg)] |
                       space"/>
        </xsl:for-each>
    </xsl:function>    

    <!-- getCounterContent -->
    <xsl:function name="dseas:getCounterContent" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:for-each select="$node">
            <xsl:number level="any" format="aa" 
                count="note[ancestor-or-self::div and (@type='annotation' or @type='figure_note')] |
                       rs[ancestor-or-self::body][not(@key=preceding::rs[ancestor-or-self::body]/@key)][not(@type='place')] |
                       ref[ancestor-or-self::body][not(ancestor-or-self::note)][@target]"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- getRegisterLink -->
    <xsl:function name="dseas:getRegisterLink">
        <xsl:param name="node"/>
        <xsl:variable name="registerType" select="$node/@type"/>
        <xsl:variable name="registerDoc" select="'lookup-'||$registerType||'.xml'"/>
        <xsl:variable name="key" select="if ($node[@key]) then $node/@key 
            else if ($node[@sameAs]) then $node/@sameAs 
            else if ($node[@target]) then $node/@target 
            else ''"/>
        
        <xsl:choose>
            <xsl:when test="$key = ''">
                <xsl:text>FEHLER (leeres Attribut)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tokenize($key, ' ')">
                    
                    <xsl:value-of select="if (position() = last() and not(position() = 1)) then ' und ' 
                        else if (position() &gt; 1) then ', '
                        else ''"/>
                    
                    <xsl:variable name="keyLoop" select="."/>
                    
                    <xsl:variable name="registerEntry">
                        <xsl:try>
                            <xsl:choose>
                                <xsl:when test="doc($registerDoc)//*[@id=$keyLoop]">
                                    <xsl:value-of select="doc($registerDoc)//*[@id=$keyLoop]/@val"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>FEHLER (keine Referenz gefunden)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:catch errors="*">
                                <xsl:message>
                                    <xsl:text>FEHLER (Lookup)</xsl:text>
                                </xsl:message>
                                <xsl:text>FEHLER (Lookup)</xsl:text>
                            </xsl:catch>
                        </xsl:try>
                    </xsl:variable>
                    
                    <xsl:value-of select="$registerEntry"/>          
                    
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
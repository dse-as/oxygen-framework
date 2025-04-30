<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process" 
    queryBinding="xslt3" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>

    <!-- global variables -->
    
    <let name="filename" value="tokenize(document-uri(/), '/')[last()]"/>
    <let name="dir" value="tokenize(document-uri(/), '/')[last() - 1]"/>
    <let name="type" value="$filename => substring-before('_')"/>
    <let name="typePl" value="$type||'s'"/>
    
    <pattern>
        
        <rule context="tei:TEI">
            <let name="pathToFacs" value="'../../facs/'||$typePl||'/'||$dir||'/'||$filename"/>
            <assert test="doc-available($pathToFacs)">Missing file with facsimile in <value-of select="$pathToFacs"/></assert>
            
            <let name="idRegex" value="'^'||$type||'_\d{4}'"/>
            <assert test="matches($filename,$idRegex||'\.xml$')">The filename does not follow the conventions.</assert>
            <assert test="contains($filename,@xml:id)">@xml:id must correspond to the filename (<xsl:value-of select="$filename"/>)</assert>
            <assert test="matches(@xml:id,$idRegex||'$')">The <name/> element needs '@xml:id' with the prefix '<xsl:value-of select="$type"/>_' followed by exactly 4 digits.</assert>
            
            <let name="pathRegex" value="$typePl||'/'||substring-after(@xml:id,'_') => substring(1,2)||'/'||@xml:id||'.xml'"/>
            <assert test="matches(document-uri(/),$pathRegex)">The file is not saved in the right location (<xsl:value-of select="$pathRegex"/>; current location: <xsl:value-of select="document-uri(/)"/>).</assert>
        </rule>
        
    </pattern>    
    
    <!-- allowed elements -->
    
    <pattern>

        <rule context="tei:body/*">
            <let name="allowedElements" value="'div'"/>
            
            <assert test="local-name() = tokenize($allowedElements, ' ')">Unexpected element(s) found in element '&lt;<value-of select="parent::*/name()"/>&gt;'. A &lt;<value-of select="parent::*/name()"/>&gt; element may contain only the elements '<value-of select="$allowedElements"/>'. Offending element: &lt;<value-of select="local-name()[not(. = tokenize($allowedElements, ' '))]"/>&gt;.</assert>
        </rule>
        
        <rule context="tei:body/div/*">
            <let name="allowedElements" value="'closer div lg milestone opener p pb postscript'"/>
            
            <assert test="local-name() = tokenize($allowedElements, ' ')">Unexpected element(s) found in element '&lt;<value-of select="parent::*/name()"/>&gt;'. A &lt;<value-of select="parent::*/name()"/>&gt; element may contain only the elements '<value-of select="$allowedElements"/>'. Offending element: &lt;<value-of select="local-name()[not(. = tokenize($allowedElements, ' '))]"/>&gt;.</assert>
        </rule>
        
    </pattern>
    
    <!-- mandatory elements -->
    
    <pattern>
        
        <!-- teiHeader -->
        <rule context="tei:teiHeader">
            <assert test="tei:fileDesc">A &lt;<name/>&gt; element must contain a &lt;fileDesc&gt; element.</assert>
            <assert test="tei:profileDesc">A &lt;<name/>&gt; element must contain a &lt;profileDesc&gt; element.</assert>
        </rule>
        
        <!-- fileDesc -->
        <rule context="tei:fileDesc">
            <assert test="tei:titleStmt">A &lt;<name/>&gt; element must contain a &lt;titleStmt&gt; element.</assert>
            <assert test="tei:publicationStmt">A &lt;<name/>&gt; element must contain a &lt;publicationStmt&gt; element.</assert>
            <assert test="tei:notesStmt">A &lt;<name/>&gt; element must contain an &lt;notesStmt&gt; element.</assert>
            <assert test="tei:sourceDesc">A &lt;<name/>&gt; element must contain a &lt;sourceDesc&gt; element.</assert>
        </rule>
        
        <!-- titleStmt -->
        <rule context="tei:titleStmt">
            <assert test="tei:title">A &lt;<name/>&gt; element must contain a &lt;title&gt; element.</assert>
        </rule>

        <!-- notesStmt -->
        <rule context="tei:notesStmt">
            <assert test="tei:note[@type='global_comment']">A &lt;<name/>&gt; element must contain a &lt;note&gt; element of type 'global_comment'.</assert>
        </rule>

        <!-- global_comment -->
        <rule context="tei:note[@type='global_comment']">
            <assert test="tei:p">A &lt;<name/>&gt; element of type 'global_comment' must contain a &lt;p&gt; element.</assert>
        </rule>
        
        <!-- sourceDesc -->
        <rule context="tei:sourceDesc">
            <report test="ancestor::tei:TEI/@type='dseas-letter' and not(tei:msDesc)">A &lt;<name/>&gt; element of a letter must contain a &lt;msDesc&gt; element.</report>
            <report test="ancestor::tei:TEI/@type='dseas-smallform' and not(tei:bibl)">A &lt;<name/>&gt; element of a smallform must contain a &lt;bibl&gt; element.</report>
            <report test="descendant::tei:bibl[@type='Manuskript' or @type='Typoskript'] and not(child::tei:msDesc)" sqf:fix="addMsDesc">A smallform of type 'Manuskript' or 'Typoskript' must contain a msDesc element.</report>
            <sqf:fix id="addMsDesc">
                <sqf:description>
                    <sqf:title>Add msDesc to <name/> element.</sqf:title>
                </sqf:description>
                <sqf:add match="." position="first-child"><msDesc xmlns="http://www.tei-c.org/ns/1.0">
                    <msIdentifier>
                        <repository/>
                        <collection/>
                        <idno/>
                    </msIdentifier>
                </msDesc></sqf:add>
            </sqf:fix>
            
            <report test="not(child::tei:listBibl[@type='related'])" sqf:fix="addListBiblRelated">A smallform or letter must contain a listBibl element of type 'related'.</report>
            <sqf:fix id="addListBiblRelated">
                <sqf:description>
                    <sqf:title>Add listBibl[@type='related'] to <name/> element.</sqf:title>
                </sqf:description>
                <sqf:add match="." position="last-child" xml:space="preserve">   <listBibl xmlns="http://www.tei-c.org/ns/1.0" type="related">
               <listBibl type="online">
                  <bibl/>
               </listBibl>
            </listBibl>
         </sqf:add>
            </sqf:fix>
        </rule>
        
        <!-- msDesc -->
        <rule context="tei:msDesc">
            <report test="ancestor::tei:TEI[@type='dseas-smallform'] and not(following::tei:bibl[@type='Manuskript' or @type='Typoskript'])" sqf:fix="deleteMsDesc">A smallform which is not of type 'Manuskript' or 'Typoskript' must not contain a msDesc element.</report>
            <sqf:fix id="deleteMsDesc">
                <sqf:description>
                    <sqf:title>Delete msDesc element.</sqf:title>
                </sqf:description>
                <sqf:delete match="self::*"/>
            </sqf:fix>
        </rule>
        
        <!-- profileDesc -->
        <rule context="tei:profileDesc">
            <assert test="tei:langUsage">A &lt;<name/>&gt; element must contain a &lt;langUsage&gt; element.</assert>
            <assert test="tei:textClass">A &lt;<name/>&gt; element must contain a &lt;textClass&gt; element.</assert>
            <report test="ancestor::tei:TEI/@type='dseas-letter' and not(tei:correspDesc)">A &lt;<name/>&gt; element of a letter must contain a &lt;correspDesc&gt; element.</report>
        </rule>
        
    </pattern>

    <!-- erroneous encoding -->

    <pattern>
        
        <!-- anchor -->
        <rule context="tei:anchor">
            <report test="@xml:id = preceding::tei:anchor/@xml:id or @xml:id = following::tei:anchor/@xml:id" sqf:fix="addXMLID">A &lt;<name/>&gt; element must contain an unique @xml:id attribute.</report>
            <assert test="@xml:id" sqf:fix="addXMLID">A &lt;<name/>&gt; element must contain an @xml:id attribute.</assert>
            <sqf:fix id="addXMLID">
                <sqf:description>
                    <sqf:title>Add @xml:id attribute to <name/> element.</sqf:title>
                </sqf:description>
                <xsl:variable name="id" select="if (ancestor::element()[last()]//*:anchor/@xml:id[replace(.,'a','') castable as xs:integer]) 
                    then max(for $id in ancestor::element()[last()]//*:anchor/@xml:id[replace(.,'a','') castable as xs:integer]/replace(.,'a','') return xs:int($id)) + 1
                    else count(ancestor::element()[last()]//*:anchor)"/>
                <sqf:add target="xml:id" node-type="attribute"><xsl:value-of select="'a'||$id"/></sqf:add>
            </sqf:fix>
        </rule>
        
        <!-- cb -->
        <rule context="tei:cb">
            <assert test="@type">A &lt;<name/>&gt; element must contain a @type attribute.</assert>
            <report test="@type='start' and not(following::tei:cb[@type='end'])">A &lt;<name/>&gt; element of @type "start" must have a following &lt;cb&gt; of @type "end".</report>
            <report test="@type='end' and not(preceding::tei:cb[@type='start'])">A &lt;<name/>&gt; element of @type "end" must have a preceding &lt;cb&gt; of @type "start".</report>
        </rule>

        <!-- g -->
        <rule context="tei:g">
            <assert test="@ref">A &lt;<name/>&gt; element must contain a @ref attribute.</assert>
            <report test="@ref='#ngem' and text()!='n'">A &lt;<name/>&gt; element with a @ref to "#ngem" must enclose exactly a letter "n".</report>
            <report test="@ref='#mgem' and text()!='m'">A &lt;<name/>&gt; element with a @ref to "#mgem" must enclose exactly a letter "m".</report>
        </rule>

        <!-- gap -->
        <rule context="tei:gap">
            <assert test="@reason">A &lt;<name/>&gt; element must contain a @reason attribute.</assert>
        </rule>
        
        <!-- space -->
        <rule context="tei:space">
            <assert test="@dim">A &lt;<name/>&gt; element must contain a @dim attribute.</assert>
        </rule>
        
        <!-- rs -->
        <rule context="tei:rs">
            <assert test="@type">A &lt;<name/>&gt; element must contain a @type attribute.</assert>
            <assert test="@key">A &lt;<name/>&gt; element must contain a @key attribute.</assert>
            <report test="@xml:id = preceding::tei:rs/@xml:id or @xml:id = following::tei:rs/@xml:id" sqf:fix="addXMLID">A &lt;<name/>&gt; element must contain an unique @xml:id attribute.</report>
            <assert test="@xml:id" sqf:fix="addXMLID">A &lt;<name/>&gt; element must contain an @xml:id attribute.</assert>
            <sqf:fix id="addXMLID">
                <sqf:description>
                    <sqf:title>Add @xml:id attribute to <name/> element.</sqf:title>
                </sqf:description>
                <xsl:variable name="id" select="if (ancestor::element()[last()]//*:rs/@xml:id[replace(.,'r','') castable as xs:integer]) 
                    then max(for $id in ancestor::element()[last()]//*:rs/@xml:id[replace(.,'r','') castable as xs:integer]/replace(.,'r','') return xs:int($id)) + 1
                    else count(ancestor::element()[last()]//*:rs)"/>
                <sqf:add target="xml:id" node-type="attribute"><xsl:value-of select="'r'||$id"/></sqf:add>
            </sqf:fix>
        </rule>
        
        <!-- hi -->
        <rule context="tei:hi[not(ancestor::tei:titleStmt)]">
            <assert test="@rendition">A &lt;<name/>&gt; element needs to have @rendition attribute.</assert>
        </rule>

        <rule context="tei:hi/@rendition">
            <let name="allowedValues" value="'#b #i #u #sub #sup #g'"/>
            <assert test=". = tokenize($allowedValues, ' ')">Unexpected value found in attribute @<name/>. A <name/> attribute may contain only the values <xsl:value-of select="tokenize($allowedValues,' ')[not(position()=last())]" separator=", "/> or <xsl:value-of select="tokenize($allowedValues,' ')[last()]"/>.</assert>
        </rule>
        
        <!-- note (annotation) -->
        <rule context="tei:note[not(@type='global_comment')]">
            <let name="targetEnd" value="@targetEnd => replace('^#','')"/>
            <report test="@targetEnd and not(preceding::tei:anchor[@xml:id=$targetEnd])">A &lt;<name/>&gt; element with a @targetEnd attribute must have a preceding &lt;anchor&gt; element with an according @xml:id.</report>
            <report test="ancestor::tei:text and not(@type='annotation')" sqf:fix="addTypeAnnotation">A &lt;<name/>&gt; element in text must contain a @type attribute with the value 'annotation'.</report>
            <sqf:fix id="addTypeAnnotation">
                <sqf:description>
                    <sqf:title>Add type attribute with value 'annotation' to <name/> element.</sqf:title>
                </sqf:description>
                <sqf:add target="type" node-type="attribute"><xsl:value-of select="'annotation'"/></sqf:add>
            </sqf:fix>
            <report test="@type='annotation' and (@xml:id = preceding::tei:note[@type='annotation']/@xml:id or @xml:id = following::tei:note[@type='annotation']/@xml:id)" sqf:fix="addXMLID">A &lt;<name/>&gt; element must contain an unique @xml:id attribute.</report>
            <report test="@type='annotation' and not(@xml:id)" sqf:fix="addXMLID">A &lt;<name/>&gt; element in text must contain an @xml:id attribute.</report>
            <sqf:fix id="addXMLID">
                <sqf:description>
                    <sqf:title>Add @xml:id attribute to <name/> element.</sqf:title>
                </sqf:description>
                <xsl:variable name="id" select="if (ancestor::element()[last()]//*:note[@type='annotation']/@xml:id[replace(.,'n','') castable as xs:integer]) 
                    then max(for $id in ancestor::element()[last()]//*:note[@type='annotation']/@xml:id[replace(.,'n','') castable as xs:integer]/replace(.,'n','') return xs:int($id)) + 1
                    else count(ancestor::element()[last()]//*:note[@type='annotation'])"/>
                <sqf:add target="xml:id" node-type="attribute"><xsl:value-of select="'n'||$id"/></sqf:add>
            </sqf:fix>
        </rule>
        
        <!-- note (global_comment) -->
        <rule context="tei:note[@type='global_comment']">
            <report test="text()[normalize-space()]">A &lt;<name/>&gt; of type 'global_comment' cannot contain text as child node.</report>
        </rule>
        
        <!-- opener -->
        <rule context="tei:opener">
            <report test="text()[normalize-space()]">An &lt;<name/>&gt; cannot contain text as child node.</report>
        </rule>

        <!-- closer -->
        <rule context="tei:closer">
            <report test="text()[normalize-space()]">A &lt;<name/>&gt; cannot contain text as child node.</report>
        </rule>
        
        <!-- PIs -->
        <rule context="processing-instruction()">
            <assert test="name(.) = 'xml-model'" role="warning">Try to clean up this Oxygen instruction.</assert>
        </rule>

        <!-- persName -->
        <rule context="tei:persName">
            <report test="@key and not(@type)" role="warning">A &lt;<name/>&gt; element must contain a @type attribute.</report>
        </rule>

        <!-- placeName -->
        <rule context="tei:placeName">
            <report test="@key and not(@type)" role="warning">A &lt;<name/>&gt; element must contain a @type attribute.</report>
        </rule>

        <!-- title -->
        <rule context="tei:title">
            <report test="@key and not(@level)" role="warning">A &lt;<name/>&gt; element must contain a @level attribute.</report>
        </rule>
        
        <!-- language -->
        <rule context="tei:langUsage/tei:language">
            <let name="ident" value="@ident"/>
            <report test="preceding-sibling::*/@ident = $ident">Duplicate &lt;<name/>&gt; entry.</report>
        </rule>
        
        <!-- keywords -->
        <rule context="tei:keywords/tei:list/tei:item">
            <let name="sameAs" value="@sameAs"/>
            <report test="preceding-sibling::*/@sameAs = $sameAs">Duplicate &lt;<name/>&gt; in keywords.</report>
        </rule>
        
    </pattern>

    <pattern>
        
        <!-- characters -->
        <rule context="tei:text//text()[not(ancestor::tei:note)]">
            <report test="contains(., '¬')" role="warning">Ungewöhnliches Vorkommen von Negationszeichen "¬". Möglicherweise eine unverarbeitete Silbentrennung?</report>
            <report test="contains(., '[')" role="warning">Ungewöhnliches Vorkommen von eckiger Klammer "[". Möglicherweise ein unverarbeiteter Kommentar?</report>
            <report test="contains(., ']')" role="warning">Ungewöhnliches Vorkommen von eckiger Klammer "]". Möglicherweise ein unverarbeiteter Kommentar?</report>
        </rule>
        
    </pattern>
    
</schema>

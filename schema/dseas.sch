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
            <assert test="tei:note">A &lt;<name/>&gt; element must contain a &lt;note&gt; element.</assert>
        </rule>
        
        <!-- sourceDesc -->
        <rule context="tei:sourceDesc">
            <report test="ancestor::tei:TEI/@type='dseas-letter' and not(tei:msDesc)">A &lt;<name/>&gt; element of a letter must contain a &lt;msDesc&gt; element.</report>
            <report test="ancestor::tei:TEI/@type='dseas-smallform' and not(tei:bibl)">A &lt;<name/>&gt; element of a smallform must contain a &lt;bibl&gt; element.</report>
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
        
        <!-- hi -->
        <rule context="tei:hi">
            <assert test="@rendition">A &lt;<name/>&gt; element needs to have @rendition attribute.</assert>
        </rule>

        <rule context="tei:hi/@rendition">
            <let name="allowedValues" value="'#b #i #u #sub #sup #g'"/>
            <assert test=". = tokenize($allowedValues, ' ')">Unexpected value found in attribute @<name/>. A <name/> attribute may contain only the values <xsl:value-of select="tokenize($allowedValues,' ')[not(position()=last())]" separator=", "/> or <xsl:value-of select="tokenize($allowedValues,' ')[last()]"/>.</assert>
        </rule>
        
        <!-- note -->
        <rule context="tei:note">
            <let name="targetEnd" value="@targetEnd => replace('^#','')"/>
            <report test="@targetEnd and not(preceding::tei:anchor[@xml:id=$targetEnd])">A &lt;<name/>&gt; element with a @targetEnd attribute must have a preceding &lt;anchor&gt; element with an according @xml:id.</report>
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

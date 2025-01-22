<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process" 
    queryBinding="xslt3" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>

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
        
        <!-- profileDesc -->
        <rule context="tei:profileDesc">
            <assert test="tei:textClass">A &lt;<name/>&gt; element must contain a &lt;textClass&gt; element.</assert>
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
            <report test="@ref='#ngem' and text()!='nn'">A &lt;<name/>&gt; element with a @ref to "#ngem" must enclose the text "nn".</report>
            <report test="@ref='#mgem' and text()!='mm'">A &lt;<name/>&gt; element with a @ref to "#mgem" must enclose the text "mm".</report>
        </rule>

        <!-- gap -->
        <rule context="tei:gap">
            <assert test="@reason">A &lt;<name/>&gt; element must contain a @reason attribute.</assert>
        </rule>
        
        <!-- hi -->
        <rule context="tei:hi">
            <assert test="@rendition">A &lt;<name/>&gt; element needs to have @rendition attribute.</assert>
        </rule>
        
        <!-- note -->
        <rule context="tei:note">
            <let name="targetEnd" value="@targetEnd"/>
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
            <assert test="name(.) = 'xml-model'">&lt;<name/>&gt; not allowed. If you are using Oxygen processing instructions (e.g. Highlight Tool), consider using an ordinary XML comment.</assert>
        </rule>

    </pattern>

</schema>

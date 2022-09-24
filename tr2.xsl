<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gr="Gramps Transform">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="text"/>

    <xsl:key name="person" match="person" use="@handle"/>

    <xsl:variable name="persons" select="//person"/>
    <xsl:variable name="person-name" as="map(xs:string, xs:string)"
                  select="map:merge(
                  for
                    $i in (1 to count($persons))
                    return map {
                        string($persons[$i]/@handle) :
                        string-join($persons[$i]/name[@type eq 'Birth Name'][not(@alt)]/(surname/@*, surname, first), ' ')
                    }
                  )"/>

    <xsl:variable name="person-filename" as="map(xs:string, xs:string)"
                  select="map:merge(
                  for
                    $i in (1 to count($persons))
                    return map {
                        string($persons[$i]/@handle) :
                        string-join(($i, map:get($person-name, $persons[$i]/@handle)), ' ')
                    }
                  )"/>

    <xsl:function name="gr:format-listitem" as="xs:string*">
        <xsl:param name="items" as="array(item()*)"/>
        <xsl:param name="templates" as="array(xs:string)"/>
        <!--
        <xsl:message>
            items:<xsl:value-of select="$items" />
        </xsl:message>
        <xsl:message>
            templates: <xsl:value-of select="$templates" />
        </xsl:message>
        <xsl:message>
            <xsl:value-of select="for
            $i in (1 to array:size($templates))
            return concat('item: ', $items($i), ' template: ', $templates($i), '&#xa;')" />
        </xsl:message>
        -->
        <xsl:text>- </xsl:text>
        <xsl:value-of select="for
            $i in (1 to array:size($templates))
            return if ($items($i))
                then replace($templates($i), '_', string-join($items($i), ' '))
                else ''" />
        <xsl:text>&#xa;</xsl:text>
    </xsl:function>

    <xsl:function name="gr:format-personlink" as="xs:string*">
        <xsl:param name="person" as="node()*"/>
        <xsl:for-each select="$person">
            <xsl:variable name="filenév" select="map:get($person-filename, @handle)"/>
            <xsl:variable name="név" select="map:get($person-name, @handle)"/>
            <xsl:value-of select="gr:format-listitem(
                [$filenév, $név],
                ['[[_|','_]]']
            )"/>
        </xsl:for-each>
    </xsl:function>



    <xsl:template match="event">
        <xsl:value-of select="gr:format-listitem(
        [ type, dateval/@val, description, id(place/@hlink)/pname/@value ],
        [ '*_*', '(_)', ': _', '_' ]
        )"/>
    </xsl:template>

    <xsl:template match="address">
        <xsl:value-of select="gr:format-listitem(
        [(daterange, datespan, dateval, datestr)/@val, city, * except (daterange, datespan, dateval, datestr, city)],
        ['(_)', '_,', '_']
        )"/>
    </xsl:template>

    <xsl:template match="object">
        <xsl:variable name="description" select="file/@description"/>
        <xsl:variable name="filename" select="replace(substring-after(file/@src, 'home/annamari/Pictures/'), ' ', '%20')"/>
        <xsl:text>![</xsl:text><xsl:value-of select="$description"/><xsl:text>|200]</xsl:text>
        <xsl:text>(</xsl:text><xsl:value-of select="$filename"/><xsl:text>)</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="childref">
        <xsl:variable name="filename" select="map:get($person-filename, @hlink)"/>
        <xsl:variable name="name" select="map:get($person-name, @hlink)"/>
        <xsl:value-of select="gr:format-listitem(
        [$filename, $name],
        ['[[_|','_]]']
        )"/>
    </xsl:template>

    <xsl:template match="childof">
        <xsl:variable name="filenév-anya" select="map:get($person-filename, id(@hlink)/mother/@hlink)"/>
        <xsl:variable name="név-anya" select="map:get($person-name, id(@hlink)/mother/@hlink)"/>
        <xsl:variable name="filenév-apa" select="map:get($person-filename, id(@hlink)/father/@hlink)"/>
        <xsl:variable name="név-apa" select="map:get($person-name, id(@hlink)/father/@hlink)"/>
        <xsl:value-of select="gr:format-listitem(
        [$filenév-anya, $név-anya],
        ['Anya: [[_|','_]]']
        )"/>
        <xsl:value-of select="gr:format-listitem(
        [$filenév-apa, $név-apa],
        ['Apa: [[_|','_]]']
        )"/>
    </xsl:template>

    <xsl:template match="person" mode="link">
        <xsl:variable name="filenév" select="map:get($person-filename, @handle)"/>
        <xsl:variable name="név" select="map:get($person-name, @handle)"/>
        <xsl:value-of select="gr:format-listitem(
                [gender, $filenév, $név],
                ['_:', '[[_|','_]]']
            )"/>
    </xsl:template>

    <xsl:template match="person">
        <xsl:variable name="person_id" select="@handle"/>
        <xsl:variable name="név" select="map:get($person-name, @handle)"/>
        <xsl:variable name="filenév" select="map:get($person-filename, @handle)"/>
        <xsl:variable name="születés" select="id(eventref/@hlink)[type = 'Birth']"/>
        <xsl:result-document method="text" indent="no" href="md/{$filenév}.md" >
            <xsl:text>## </xsl:text>
            <xsl:value-of select="$név"/>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Alternatív nevek: </xsl:text>
                <xsl:value-of select="string-join(name[@alt]/*, '/')"/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Születési idő: </xsl:text>
                <xsl:value-of select="$születés/dateval/@val"/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Születési hely: </xsl:text>
                <xsl:value-of select="id($születés/place/@hlink)/pname/@value" separator=", "/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Képek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="id(objref/@hlink)"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Események</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="id(eventref/@hlink)">
                <!--<xsl:sort select="if (dateval/@val castable as xs:date) then dateval/@val cast as xs:date? else ()"/>-->
                <xsl:sort select="dateval/@val"/>
            </xsl:apply-templates>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Címek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="address"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Testvérek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="brothers" select="id(id(childof/@hlink)/childref[@hlink ne $person_id]/@hlink)"/>
            <xsl:apply-templates select="$brothers" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Szülők</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="parents" select="id(id(childof/@hlink)/(father|mother)/@hlink)"/>
            <xsl:apply-templates select="$parents" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Házastárs</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="spouses" select="id(id(parentin/@hlink)/(father|mother)[@hlink ne $person_id]/@hlink)"/>
            <xsl:apply-templates select="$spouses" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Gyermekek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="children" select="id(id(parentin/@hlink)/childref/@hlink)"/>
            <xsl:apply-templates select="$children" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>

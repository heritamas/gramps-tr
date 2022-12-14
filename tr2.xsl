<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gr="Gramps Transform">

    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>

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
            items:<xsl:value-of select="$items" separator=""/>
        </xsl:message>
        <xsl:message>
            templates: <xsl:value-of select="$templates" separator=""/>
        </xsl:message>
        <xsl:message>
            <xsl:value-of select="for
            $i in (1 to array:size($templates))
            return concat('item: @', $items($i), '@ template: @', $templates($i), '@&#xa;')" separator=""/>
        </xsl:message>
        -->
        <xsl:text>- </xsl:text>
        <xsl:value-of select="for
            $i in (1 to array:size($templates))
            return if ($items($i))
                then replace($templates($i), '_', string-join($items($i), ' '))
                else ()" separator=""/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:function>

    <xsl:function name="gr:format-personlink" as="xs:string*">
        <xsl:param name="person" as="node()"/>
        <xsl:variable name="filen??v" select="map:get($person-filename, $person/@handle)"/>
        <xsl:variable name="n??v" select="map:get($person-name, $person/@handle)"/>
        <xsl:value-of select="gr:format-listitem(
                [$person/gender, $filen??v, $n??v],
                ['_: ', '[[_|', '_]]']
            )"/>
    </xsl:function>

    <xsl:template match="event">
        <xsl:value-of select="gr:format-listitem(
        [ type, dateval/@val, description, id(place/@hlink)/pname/@value ],
        [ '*_* ', '(_) ', ': _ ', '_' ]
        )"/>
    </xsl:template>

    <xsl:template match="address">
        <xsl:value-of select="gr:format-listitem(
        [(daterange, datespan, dateval, datestr)/@val, city, * except (daterange, datespan, dateval, datestr, city)],
        ['(_) ', '_, ', '_']
        )"/>
    </xsl:template>

    <xsl:template match="attribute">
        <xsl:value-of select="gr:format-listitem(
        [@type, @value],
        ['_: ', '_, ']
        )"/>
    </xsl:template>

    <xsl:template match="object">
        <xsl:variable name="description" select="file/@description"/>
        <xsl:variable name="filename" select="replace(substring-after(file/@src, 'home/annamari/Pictures/'), ' ', '%20')"/>
        <xsl:text>![</xsl:text><xsl:value-of select="$description"/><xsl:text>|200]</xsl:text>
        <xsl:text>(</xsl:text><xsl:value-of select="$filename"/><xsl:text>)</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="person" mode="link">
        <xsl:value-of select="gr:format-personlink(.)" />
    </xsl:template>

    <xsl:template match="person">
        <xsl:variable name="person_id" select="@handle"/>
        <xsl:variable name="n??v" select="map:get($person-name, @handle)"/>
        <xsl:variable name="filen??v" select="map:get($person-filename, @handle)"/>
        <xsl:variable name="sz??let??s" select="id(eventref/@hlink)[type = 'Birth']"/>
        <xsl:result-document method="text" indent="no" href="md/{$filen??v}.md" >
            <xsl:text>## </xsl:text>
            <xsl:value-of select="$n??v"/>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Alternat??v nevek: </xsl:text>
                <xsl:value-of select="string-join(name[@alt]/*, '/')"/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Sz??let??si id??: </xsl:text>
                <xsl:value-of select="$sz??let??s/dateval/@val"/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Sz??let??si hely: </xsl:text>
                <xsl:value-of select="id($sz??let??s/place/@hlink)/pname/@value" separator=", "/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### K??pek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="id(objref/@hlink)"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Esem??nyek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="id(eventref/@hlink)">
                <xsl:sort select="dateval/@val"/>
            </xsl:apply-templates>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Tudnival??k</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="attribute"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### C??mek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="address"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Testv??rek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="brothers" select="id(id(childof/@hlink)/childref[@hlink ne $person_id]/@hlink)"/>
            <xsl:apply-templates select="$brothers" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Sz??l??k</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="parents" select="id(id(childof/@hlink)/(father|mother)/@hlink)"/>
            <xsl:apply-templates select="$parents" mode="link"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### H??zast??rs</xsl:text>
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

<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:mode on-no-match="shallow-skip" />

    <xsl:key name="person" match="person" use="@handle"/>

    <xsl:variable name="persons" select="//person"/>
    <xsl:variable name="person-name" as="map(xs:string, xs:string)"
                  select="map:merge(
                  for
                    $i in (1 to count($persons))
                    return map {
                        string($persons[$i]/@handle) :
                        string-join($persons[$i]/name[@type eq 'Birth Name']/(surname/@*, surname, first), ' ')
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

    <xsl:template match="text()" />

    <xsl:template match="event">
        <xsl:text>- </xsl:text>
        <xsl:text>*</xsl:text><xsl:value-of select="(type,'unknown')[1]"/><xsl:text>*</xsl:text>
        <xsl:text> </xsl:text>
        <xsl:text>(</xsl:text><xsl:value-of select="dateval/@val"/><xsl:text>)</xsl:text>
        <xsl:text>: </xsl:text><xsl:value-of select="description"/><xsl:text>, </xsl:text>
        <xsl:value-of select="id(place/@hlink)/pname/@value"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="address">
        <xsl:variable name="dátum" select="((daterange, datespan, dateval, datestr)/@val)[1]"/>
        <xsl:text>- </xsl:text>
        <xsl:if test="$dátum">
            <xsl:text>(</xsl:text><xsl:value-of select="$dátum"/><xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:value-of select="city"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="* except (daterange, datespan, dateval, datestr, city)"/>
        <xsl:text>&#xa;</xsl:text>
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
        <xsl:text>- [[</xsl:text>
        <xsl:value-of select="$filename"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text>]]</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="childof">
        <xsl:variable name="filenév-anya" select="map:get($person-filename, id(@hlink)/mother/@hlink)"/>
        <xsl:variable name="név-anya" select="map:get($person-name, id(@hlink)/mother/@hlink)"/>
        <xsl:variable name="filenév-apa" select="map:get($person-filename, id(@hlink)/father/@hlink)"/>
        <xsl:variable name="név-apa" select="map:get($person-name, id(@hlink)/father/@hlink)"/>
        <xsl:text>- Anya: </xsl:text>
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="$filenév-anya"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$név-anya"/>
        <xsl:text>]]</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>- Apa: </xsl:text>
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="$filenév-apa"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$név-apa"/>
        <xsl:text>]]</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="person">
        <!-- <xsl:message>person: <xsl:value-of select="@handle"/> ... <xsl:value-of select="map:get($person-filename, @handle)"/></xsl:message> -->

        <xsl:variable name="név" select="map:get($person-name, @handle)"/>
        <xsl:variable name="filenév" select="map:get($person-filename, @handle)"/>
        <xsl:variable name="születés" select="id(eventref/@hlink)[type = 'Birth']"/>
        <xsl:result-document method="text" indent="no" href="md/{$filenév}.md" >
            <xsl:text>## </xsl:text>
            <xsl:value-of select="$név"/>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Születési idő:</xsl:text>
                <xsl:value-of select="$születés/dateval/@val"/>
            <xsl:text>*</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>*Születési hely:</xsl:text>
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

            <xsl:text>### Szülők</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="childof"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

            <xsl:text>### Gyermekek</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="id(parentin/@hlink)/childref"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>

        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>

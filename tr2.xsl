<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:mode on-no-match="shallow-skip" />

    <xsl:key name="person" match="person" use="@handle"/>

    <xsl:template match="/">
        <family>
            <xsl:apply-templates select="database/people/person" />
        </family>
    </xsl:template>

    <xsl:template match="text()" />

    <xsl:template match="placeobj">
        <xsl:element name="place">
            <xsl:value-of select="pname/@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="event">
        <xsl:element name="{(type,'unknown')[1]}">
            <xsl:attribute name="datum" select="dateval/@val"/>
            <xsl:apply-templates select="id(place/@hlink)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="address">
        <address>
            <xsl:variable name="dátum" select="((daterange, datespan, dateval, datestr)/@val)[1]"/>
            <xsl:attribute name="city" select="city"/>
            <xsl:if test="$dátum">
                <xsl:attribute name="datum" select="$dátum"/>
            </xsl:if>
            <xsl:copy-of select="* except (daterange, datespan, dateval, datestr, city)"/>
        </address>
    </xsl:template>

    <xsl:template match="person">
        <xsl:variable name="név" select="name/surname/@*, name/surname, name/first"/>
        <xsl:variable name="filenév" select="position(), $név"/>
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

            <xsl:apply-templates select="id(eventref/@hlink)">
                <!--<xsl:sort select="if (dateval/@val castable as xs:date) then dateval/@val cast as xs:date? else ()"/>-->
                <xsl:sort select="dateval/@val"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="address"/>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>

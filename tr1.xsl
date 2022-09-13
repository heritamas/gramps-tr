<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:mode on-no-match="shallow-skip" />
    <xsl:output indent="true" method="xml"/>

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
            <xsl:attribute name="dátum" select="dateval/@val"/>
            <xsl:apply-templates select="id(place/@hlink)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="address">
        <address>
            <xsl:variable name="dátum" select="((daterange, datespan, dateval, datestr)/@val)[1]"/>
            <xsl:attribute name="city" select="city"/>
            <xsl:if test="$dátum">
                <xsl:attribute name="dátum" select="$dátum"/>
            </xsl:if>
            <xsl:copy-of select="* except (daterange, datespan, dateval, datestr, city)"/>
        </address>
    </xsl:template>

    <xsl:template match="person">
        <person>
            <xsl:attribute name="Név" select="name/surname, name/first"/>
            <xsl:apply-templates select="address"/>
            <xsl:apply-templates select="id(eventref/@hlink)">
                <!--<xsl:sort select="if (dateval/@val castable as xs:date) then dateval/@val cast as xs:date? else ()"/>-->
                <xsl:sort select="dateval/@val"/>
            </xsl:apply-templates>
        </person>
    </xsl:template>
</xsl:stylesheet>

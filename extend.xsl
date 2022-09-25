<xsl:stylesheet version="3.0"
                xpath-default-namespace="http://gramps-project.org/xml/1.7.1/"
                xmlns="http://gramps-project.org/xml/1.7.1/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gr="Gramps Transform">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="person">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(attribute[@type eq 'Religion'])">
                <xsl:element name="attribute" inherit-namespaces="yes">
                    <xsl:attribute name="type">Religion</xsl:attribute>
                    <xsl:attribute name="value">Római katolikus</xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
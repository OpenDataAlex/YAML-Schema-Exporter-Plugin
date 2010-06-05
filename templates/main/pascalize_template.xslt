<?xml version="1.0" encoding="ISO-8859-1"?>

<!--Special thanks to Dimitre Novatchev for writing the Pascalize template
    in response to my question on Stack Overflow
    (http://stackoverflow.com/questions/2647327/how-to-format-a-string-to-camel-case-in-xslt/2647656#2647656)
    as well as helping me better understand xsl:key. -->

<xsl:template name="Pascalize">
    <xsl:param name="pText"/>
     <xsl:if test="$pText">
        <xsl:choose>
            <xsl:when test="$pText = 'sf_guard_user_profile'
                            or $pText = 'sf_guard_user'">
                <xsl:text>s</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(substring($pText,1,1), $vLower, $vUpper)"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="substring-before(substring($pText,2), '_')"/>

        <xsl:call-template name="Pascalize">
            <xsl:with-param name="pText" select="substring-after(substring($pText,2), '_')"/>
        </xsl:call-template>

        <xsl:call-template name="GrabLastPart">
            <xsl:with-param name="pText" select="$pText"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="GrabLastPart">
    <xsl:param name="pText"/>

    <xsl:choose>
        <xsl:when test="contains($pText, '_')">
            <xsl:call-template name="GrabLastPart">
                <xsl:with-param name="pText" expr="substring-after($pText, '_')"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring($pText, 2)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
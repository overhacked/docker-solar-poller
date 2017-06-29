<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>

	<xsl:param name="host">solar-gauge.res.sineya.org</xsl:param>
	<xsl:param name="keyPrefix">solar.</xsl:param>

	<xsl:template match="/data">
		<xsl:apply-templates select="r">
			<xsl:with-param name="ts" select="ts" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="r">
		<xsl:param name="ts"/>
		<line>"<xsl:value-of select="$host"/>"<xsl:text> </xsl:text>
			<xsl:call-template name="getKey">
				<xsl:with-param name="register" select="@n"/>	
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$ts"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="v"/>
			<xsl:text>&#xA;</xsl:text>
		</line>	
	</xsl:template>

	<xsl:template name="getKey">
		<xsl:param name="register"/>
		<key><xsl:value-of select="$keyPrefix"/><xsl:value-of select="translate(normalize-space($register),'ABCDEFGHIJKLMNOPQRSTUVWXYZ +()','abcdefghijlkmnopqrstuvwxyz_P')"/></key>
	</xsl:template>
</xsl:stylesheet>

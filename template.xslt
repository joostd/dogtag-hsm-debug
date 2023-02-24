<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:param name="csr"/>
  <!-- Identity transform -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Attribute[@name='cert_request_type']/Value">
    <Value>pkcs10</Value>
  </xsl:template>

  <xsl:template match="Attribute[@name='cert_request']/Value">
	  <Value><xsl:value-of select="$csr"/></Value>
  </xsl:template>

</xsl:stylesheet>

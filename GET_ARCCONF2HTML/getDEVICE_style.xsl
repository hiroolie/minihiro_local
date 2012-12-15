<?xml version="1.0" encoding="SHIFT_JIS"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="xsl xs fn"
>
  
<!-- 出力文書のフォーマットを指定します。 xml, html, xhtml, text のどれかです -->
<xsl:output method="html"
            indent="yes"
            encoding="SHIFT_JIS"
            media-type="text/html"
            doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

<xsl:template match="/"> <!-- 入力文書のルートにマッチし、変換を行います -->
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="DeviceLog">
  <html>
    <head>
      <title><xsl:value-of select="name()"/></title>
      <link rel="stylesheet" type="text/css" href="style.css"/>
    </head>
    <body>
      <div class="container">
        <div id="page-container">
          <div class="content">
          
            <br><b>controllerID : <xsl:value-of select="ControllerLog/@controllerID"/></b></br>
            <br><b>type : <xsl:value-of select="ControllerLog/@type"/></b></br>
            <xsl:variable name="getdate" select='xs:dateTime("1970-01-01T09:00:00") + ControllerLog/@time * xs:dayTimeDuration("PT1S")'/>
            <br><b>time : <xsl:value-of select='format-dateTime($getdate, "[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]")' /></b></br>
            <br><b>version : <xsl:value-of select="ControllerLog/@version"/></b></br>
            <br><b>tableFull : <xsl:value-of select="ControllerLog/@tableFull"/></b></br>
            <p>-------------------------------</p>
            <h1><xsl:value-of select="name()"/></h1>
            <h2>controllerID : <xsl:value-of select="ControllerLog/@controllerID" /></h2>
            
            <xsl:apply-templates/>

            <p></p>
            <br>PublisedTime</br>
            <xsl:value-of select="current-dateTime()"/>
            <p></p>

          </div>
        </div>
      </div>
    </body>
  </html>
</xsl:template>

<xsl:template match="ControllerLog">
  <table border="1">
    <tr>
      <th>Content</th><th>Value</th>
    </tr>
    <xsl:for-each select="driveErrorEntry"> 
      <xsl:sort select="time" data-type="number" order="descending" />
      <xsl:variable name="date" select='xs:dateTime("1970-01-01T00:00:00") + @time * xs:dayTimeDuration("PT1S")'/>
      <tr>
        <td nowrap="nowrap">Date Time</td>
        <td nowrap="nowrap"><xsl:value-of select='format-dateTime($date, "[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]")' /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">smartError</td>
        <td nowrap="nowrap"><xsl:value-of select="@smartError" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">vendorID</td>
        <td nowrap="nowrap"><xsl:value-of select="@vendorID" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">serialNumber</td>
        <td nowrap="nowrap"><xsl:value-of select="@serialNumber" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">wwn</td>
        <td nowrap="nowrap"><xsl:value-of select="@wwn" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">deviceID</td>
        <td nowrap="nowrap"><xsl:value-of select="@deviceID" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">productID</td>
        <td nowrap="nowrap"><xsl:value-of select="@productID" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">numParityErrors</td>
        <td nowrap="nowrap"><xsl:value-of select="@numParityErrors" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">linkFailures</td>
        <td nowrap="nowrap"><xsl:value-of select="@linkFailures" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">hwErrors</td>
        <td nowrap="nowrap"><xsl:value-of select="@hwErrors" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">abortedCmds</td>
        <td nowrap="nowrap"><xsl:value-of select="@abortedCmds" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">mediumErrors</td>
        <td nowrap="nowrap"><xsl:value-of select="@mediumErrors" /></td>
      </tr>
      <tr>
        <td nowrap="nowrap">smartWarning</td>
        <td nowrap="nowrap"><xsl:value-of select="@smartWarning" /></td>
      </tr>
    </xsl:for-each>
  </table>
</xsl:template>

</xsl:stylesheet>
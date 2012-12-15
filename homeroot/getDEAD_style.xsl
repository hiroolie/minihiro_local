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
            <br></br>
            <br>-------------------------------</br>
            <h1><xsl:value-of select="name()"/></h1>
            <h2>controllerID : <xsl:value-of select="ControllerLog/@controllerID" /></h2>

            <xsl:apply-templates/>

            <h3>Here is a table of what the 'failureReasonCode' parameter means:</h3>
            <br>0 or 0x00 Unknown failure</br>
            <br>1 or 0x01 Device not ready</br>
            <br>2 or 0x02 Selection timout</br>
            <br>3 or 0x03 User marked the drive dead</br>
            <br>4 or 0x04 Hardware error</br>
            <br>5 or 0x05 Bad block</br>
            <br>6 or 0x06 Retries failed</br>
            <br>7 or 0x07 No Response from drive during discovery</br>
            <br>8 or 0x08 Inquiry failed</br>
            <br>9 or 0x09 Probe(Test Unit Ready/Start Stop Unit) failed</br>
            <br>A or 0x0A Bus discovery failed </br>
            
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
      <th>Date</th><th>Time</th><th>vendorID</th><th>serialNumber</th>
      <th>productID</th><th>wwn</th><th>failureReasonCode</th>
    </tr>

    <xsl:for-each select="deadDriveEntry"> 
      <tr>
        <td nowrap="nowrap"><xsl:value-of select="@rtcYear" />/<xsl:value-of select="@rtcMonth" />/<xsl:value-of select="@rtcDay" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@rtcHours" />:<xsl:value-of select="@rtcMinutes" />:<xsl:value-of select="@rtcSeconds" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@vendorID" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@serialNumber" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@productID" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@wwn" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@failureReasonCode" /></td>
      </tr>
    </xsl:for-each>
    
  </table>
</xsl:template>

</xsl:stylesheet>
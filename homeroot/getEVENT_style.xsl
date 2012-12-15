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

<xsl:template match="ControllerLog">
  <html>
    <head>
      <title><xsl:value-of select="name()"/></title>
      <link rel="stylesheet" type="text/css" href="style.css"/>
    </head>
    <body>
      <div class="container">
        <div id="page-container">
          <div class="content">
          
            <br><b>controllerID : <xsl:value-of select="@controllerID"/></b></br>
            <br><b>type : <xsl:value-of select="@type"/></b></br>
            <xsl:variable name="getdate" select='xs:dateTime("1970-01-01T09:00:00") + @time * xs:dayTimeDuration("PT1S")'/>
            <br><b>time : <xsl:value-of select='format-dateTime($getdate, "[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]")' /></b></br>
            <br></br>
            <br></br>
            <br><b>-------------------------------</b></br>
            <h1><xsl:value-of select="name()"/></h1>
            <h2>controllerID : <xsl:value-of select="./@controllerID" /></h2>
            
            <xsl:apply-templates select="eventlog"/>
      
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

<xsl:template match="eventlog">
  <table border="1">
    <tr>
      <th>Date</th><th>Time</th><th>eventType</th><th>eventCode</th>
      <th>controllerID</th><th>logicalDriveID</th>
      <th>generalUpdateEventType</th>
      <th>generalUpdateEventCode</th><th>pmEventType</th><th>pmState</th>
      <th>groupType</th><th>groupCode</th><th>priority</th><th>subType</th>
      <th>subTypeCode</th><th>cdb</th><th>data</th><th>lun</th><th>channelID</th>
      <th>deviceID</th>
    </tr>

    <xsl:for-each select="event"> 

    <xsl:variable name="date" select='xs:dateTime("1970-01-01T09:00:00") + @Date * xs:dayTimeDuration("PT1S")'/>

    <tr>
        <td nowrap="nowrap"><xsl:value-of select='format-dateTime($date, "[Y0001]/[M01]/[D01]")' /></td>
        <td nowrap="nowrap"><xsl:value-of select='format-dateTime($date, "[H01]:[m01]:[s01]")' /></td>
        <td nowrap="nowrap"><xsl:value-of select="@eventType" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@eventCode" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@controllerID" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@logicalDriveID" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@generalUpdateEventType" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@generalUpdateEventCode" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@pmEventType" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@pmState" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@groupType" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@groupCode" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@priority" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@subType" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@subTypeCode" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@cdb" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@data" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@lun" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@channelID" /></td>
        <td nowrap="nowrap"><xsl:value-of select="@deviceID" /></td>
      </tr>
    </xsl:for-each>
  </table>
</xsl:template>

</xsl:stylesheet>
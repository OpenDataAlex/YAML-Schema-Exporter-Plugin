<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    This file is a xslt template for use in SQL Power* Architect.
    The purpose of the template is to convert a database schema into
        a Doctrine schema.yaml file.  Being a Symfony PHP Framework user,
        this will aid in developing your applications.

    (c) 2010 Alex Meadows <alexmeadows@bluefiredatasolutions.com>

    For full copyright and license information, please view the License.txt file
    located in the license folder distributed with this source code.
-->

<xsl:transform
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
  encoding="iso-8859-15"
  method="html"
  indent="yes"
  standalone="yes"
  omit-xml-declaration="yes"
  doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
/>

    <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:template match="/">
        <html>
            <head>
            </head>
            <body>
                <xsl:call-template name="table-definitions"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="table-definitions">
        <xsl:for-each select="/architect-project/target-database/table">
            <xsl:variable name="table-id" select="@id"/>

            <xsl:sort select="@name"/>
            <xsl:call-template name="Pascalize">
                <xsl:with-param name="pText" select="@name"/>
            </xsl:call-template>
            :<br/>
            &#160;&#160;actAs:<br/>
            <xsl:for-each select="folder//column">
                <xsl:if test="@physicalName = 'created_at'
                          or @physicalName = 'updated_at'
                          or @physicalName = 'created_by'
                          or @physicalName = 'updated_by'">
                


                </xsl:if>
            </xsl:for-each>
            &#160;&#160;columns:<br/>
            <xsl:for-each select="folder//column">
                <!-- Testing for any Doctrine behavior columns,
                     since they do not need to be repeated in
                     the columns list. -->
                <xsl:if test="@physicalName != 'id'
                          and @physicalName != 'created_at'
                          and @physicalName != 'updated_at'
                          and @physicalName != 'created_by'
                          and @physicalName != 'updated_by'">
                    
                    &#160;&#160;&#160;&#160;
                    <xsl:value-of select="@physicalName"/>:  {  type:&#160;&#160;

                    <xsl:call-template name="column-type-definition">
                        <xsl:with-param name="type-id" select="@type"/>
                    </xsl:call-template>
                    <xsl:call-template name="size-definition">
                        <xsl:with-param name="precision" select="@precision"/>
                        <xsl:with-param name="scale" select="@scale"/>
                    </xsl:call-template>
                    <xsl:if test="string-length(@primaryKeySeq) &gt; 0">
                        <xsl:text>, primary:  true</xsl:text>
                    </xsl:if>
                    <xsl:if test="@nullable = '0'">
                        <xsl:text>, notnull:  true</xsl:text>
                    </xsl:if>
                    <xsl:if test="@defaultValue">
                        <xsl:text>, default:  </xsl:text><xsl:value-of select="@defaultValue"/>
                    </xsl:if>
                    }<br/>

                </xsl:if>
            </xsl:for-each>
            
            &#160;&#160;relations:<br/>
            <xsl:for-each select="/architect-project/target-database/relationships/relationship[@fk-table-ref=$table-id]">
                <xsl:variable name="pk-id" select="@pk-table-ref"/>
                <xsl:variable name="targetTable" select="/architect-project/target-database/table[@id=$pk-id]/@name"/>
                <xsl:variable name="delete-rule" select="@deleteRule"/>
                <xsl:variable name="update-rule" select="@updateRule"/>

                <xsl:for-each select="column-mapping">
                    <xsl:variable name="fk-col-id" select="@fk-column-ref"/>
                    <xsl:variable name="fk-col-name" select="//column[@id=$fk-col-id]/@name"/>
                    <xsl:variable name="pk-col-id" select="@pk-column-ref"/>
                    <xsl:variable name="pk-col-name" select="//column[@id=$pk-col-id]/@name"/>

                    <xsl:call-template name="relation-definition">
                        <xsl:with-param name="table" select="$targetTable"/>
                        <xsl:with-param name="columnName" select="$fk-col-name"/>
                        <xsl:with-param name="pkColumnName" select="$pk-col-name"/>
                        <xsl:with-param name="updateRule" select="$update-rule"/>
                        <xsl:with-param name="deleteRule" select="$delete-rule"/>
                    </xsl:call-template>

                </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="/architect-project/target-database/relationships/relationship[@pk-table-ref=$table-id]">
                <xsl:variable name="fk-id" select="@fk-table-ref"/>
                <xsl:variable name="targetTable" select="/architect-project/target-database/table[@id=$fk-id]/@name"/>



            </xsl:for-each>
            &#160;&#160;indexes:<br/>
            <br/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="column-type-definition">
       <xsl:param name="type-id"/>
        <xsl:choose>
           <xsl:when test="$type-id = 2005"> <!-- Architect value for CLOB-->
               <xsl:text>clob</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 2011"> <!-- Architect value for NCLOB-->
               <xsl:text>clob</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 2004"> <!-- Architect value for BLOB-->
               <xsl:text>blob</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -3"> <!-- Architect value for VARBINARY-->
               <xsl:text>blob</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -4"> <!-- Architect value for LONGVARBINARY-->
               <xsl:text>blob</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -1"> <!-- Architect value for LONGVARCHAR-->
               <xsl:text>string</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 93"> <!-- Architect value for TIMESTAMP-->
               <xsl:text>timestamp</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 92"> <!-- Architect value for TIME-->
               <xsl:text>time</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 1"> <!-- Architect value for CHAR-->
               <xsl:text>string</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -15"> <!-- Architect value for NCHAR-->
               <xsl:text>string</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 4"> <!-- Architect value for INTEGER-->
               <xsl:text>integer</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 5"> <!-- Architect value for SMALLINT-->
               <xsl:text>integer</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 8"> <!-- Architect value for DOUBLE-->
               <xsl:text>float</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 6"> <!-- Architect value for FLOAT-->
               <xsl:text>float</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 16"> <!-- Architect value for BOOLEAN-->
               <xsl:text>boolean</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 2"> <!-- Architect value for NUMERIC-->
               <xsl:text>decimal</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 3"> <!-- Architect value for DECIMAL-->
               <xsl:text>decimal</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 12"> <!-- Architect value for VARCHAR-->
               <xsl:text>string</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -5"> <!-- Architect value for BIGINT-->
               <xsl:text>integer</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = 91"> <!-- Architect value for DATE-->
               <xsl:text>date</xsl:text>
           </xsl:when>
           <xsl:when test="$type-id = -7"> <!-- Architect value for BIT-->
               <xsl:text>boolean</xsl:text>
           </xsl:when>
           <xsl:otherwise>
               <xsl:text>not-supported</xsl:text><xsl:value-of select="$type-id"/>
           </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="size-definition">
        <xsl:param name="precision"/>
        <xsl:param name="scale"/>

        <xsl:if test="$precision &gt; 0">
            <xsl:text>&#40;</xsl:text><xsl:value-of select="$precision"/><xsl:text>&#41;</xsl:text>
        </xsl:if>

        <xsl:if test="$scale &gt; 0">
            , scale:&#160;&#160;<xsl:value-of select="$scale"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="relation-definition">
        <xsl:param name="table"/>
        <xsl:param name="columnName"/>
        <xsl:param name="pkColumnName"/>
        <xsl:param name="updateRule"/>
        <xsl:param name="deleteRule"/>

        &#160;&#160;&#160;&#160;
        <xsl:call-template name="Pascalize">
            <xsl:with-param name="pText" select="$columnName"/>
        </xsl:call-template>
        <xsl:text>:  { class:  </xsl:text>
            <xsl:call-template name="Pascalize">
                <xsl:with-param name="pText" select="$table"/>
            </xsl:call-template>
        <xsl:text>, local:  </xsl:text><xsl:value-of select="$columnName"/>
        <xsl:text>, foreign:  </xsl:text><xsl:value-of select="$pkColumnName"/>
        <xsl:text>, onUpdate:  </xsl:text>
            <xsl:call-template name="RelationshipRuleCheck">
                <xsl:with-param name="ruleId" select="$updateRule"/>
            </xsl:call-template>
        <xsl:text>, onDelete:  </xsl:text>
            <xsl:call-template name="RelationshipRuleCheck">
                <xsl:with-param name="ruleId" select="$deleteRule"/>
            </xsl:call-template>
        <xsl:text> }</xsl:text>
        <br/>
    </xsl:template>
    
    <xsl:template name="RelationshipRuleCheck">
        <xsl:param name="ruleId"/>
        <xsl:choose>
            <xsl:when test="$ruleId = 0">
                <xsl:text>cascade</xsl:text>
            </xsl:when>
            <xsl:when test="$ruleId = 2">
                <xsl:text>restrict</xsl:text>
            </xsl:when>
            <xsl:when test="$ruleId = 3">
                <xsl:text>noAction</xsl:text>
            </xsl:when>
            <xsl:when test="$ruleId = 4">
                <xsl:text>setNull</xsl:text>
            </xsl:when>
            <xsl:when test="$ruleId = 5">
                <xsl:text>setDefault</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>not-supported</xsl:text><xsl:value-of select="$ruleId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Special thanks to Dimitre Novatchev for writing the Pascalize template
        in response to my question on StackOverflow
        (http://stackoverflow.com/questions/2647327/how-to-format-a-string-to-camel-case-in-xslt/2647656#2647656). -->

    <xsl:template name="Pascalize">
        <xsl:param name="pText"/>

        <xsl:if test="$pText">
            <xsl:value-of select="translate(substring($pText,1,1), $vLower, $vUpper)"/>

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

</xsl:transform>

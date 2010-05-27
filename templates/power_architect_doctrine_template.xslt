<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    This file is a xslt template for use in SQL Power Architect.
    The purpose of the template is to convert a database schema into
        a Doctrine schema.yaml file.

    Copyright (c) 2010 Alex Meadows <alexmeadows@bluefiredatasolutions.com>
    
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


    For full copyright and license information, please view the License.txt file
    located in the license folder distributed with this source code.
-->

<xsl:transform
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
  encoding="iso-8859-15"
  method="text"
  indent="no"
  standalone="yes"
  omit-xml-declaration="yes"
  media-type="text/yaml"
  doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
/>

    
    <xsl:key name="pluginColumnTest" match="column" use="@id/column/@physicalName"/>

    <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    
    <xsl:template match="/">
       <xsl:call-template name="table-definitions"/>
    </xsl:template>

    <xsl:template name="table-definitions">
        <xsl:for-each select="/architect-project/target-database/table">
            <xsl:variable name="table-id" select="@id"/>
            <xsl:variable name="table-name" select="@name"/>
            <xsl:sort select="@name"/>


          <xsl:if test="not(contains($table-name, 'sf_guard'))
                        or $table-name = 'sf_guard_user_profile'">
            <xsl:call-template name="Pascalize">
                <xsl:with-param name="pText" select="@name"/>
            </xsl:call-template>
            <xsl:text>:&#10;</xsl:text>
            <xsl:text>  actAs:&#10;</xsl:text>

            <xsl:if test="key('pluginColumnTest', 'created_by') or key('pluginColumnTest', 'updated_by')">
                <xsl:text>    Blameable:&#10;</xsl:text>
                <xsl:text>      listener:  BlameableSymfony&#10;</xsl:text>
                <xsl:text>      columns:&#10;</xsl:text>
            </xsl:if>
            

            <xsl:text>  columns:&#10;</xsl:text>
            <xsl:for-each select="folder//column">
                <xsl:variable name="physicalName" select="@physicalName"/>
                <!-- Testing for any Doctrine behavior columns,
                     since they do not need to be repeated in
                     the columns list. -->
                <xsl:if test="$physicalName != 'created_at'
                          and $physicalName != 'updated_at'
                          and $physicalName != 'created_by'
                          and $physicalName != 'updated_by'">
                    
                    
                    <xsl:text>    <xsl:value-of select="$physicalName"/></xsl:text>
                    <xsl:text>:  {  type:  </xsl:text>
                    <xsl:call-template name="column-type-definition">
                        <xsl:with-param name="type-id" select="@type"/>
                    </xsl:call-template>
                    <xsl:call-template name="size-definition">
                        <xsl:with-param name="precision" select="@precision"/>
                        <xsl:with-param name="scale" select="@scale"/>
                    </xsl:call-template>
                    <xsl:if test="string-length(@primaryKeySeq) = 0">
                        <xsl:text>, primary:  true</xsl:text>
                    </xsl:if>
                    <xsl:if test="@nullable = '0'">
                        <xsl:text>, notnull:  true</xsl:text>
                    </xsl:if>
                    <xsl:if test="@defaultValue != ''
                                  and string-length(@primaryKeySeq) = 0">
                        <xsl:text>, default:  </xsl:text><xsl:value-of select="@defaultValue"/>
                    </xsl:if>
                    <xsl:text> }&#10;</xsl:text>

                </xsl:if>
            </xsl:for-each>
            
            <xsl:text>  relations:&#10;</xsl:text>
            <xsl:for-each select="/architect-project/target-database/relationships/relationship[@fk-table-ref=$table-id]">
                <xsl:variable name="pk-id" select="@pk-table-ref"/>
                <xsl:variable name="targetTable" select="/architect-project/target-database/table[@id=$pk-id]/@name"/>
                <xsl:variable name="delete-rule" select="@deleteRule"/>
                <xsl:variable name="update-rule" select="@updateRule"/>
                <xsl:variable name="relationship-name" select="@name"/>


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
                        <xsl:with-param name="relationshipName" select="$relationship-name"/>
                    </xsl:call-template>

                </xsl:for-each>
            </xsl:for-each>
            <!-- For each for the M:N relations.-->
            <xsl:for-each select="/architect-project/target-database/relationships/relationship[@pk-table-ref=$table-id]">
                <xsl:variable name="fk-id" select="@fk-table-ref"/>
                <xsl:variable name="targetTable" select="/architect-project/target-database/table[@id=$fk-id]/@name"/>

                <xsl:if test="$targetTable != 'sf_guard_user'">

                    <xsl:for-each select="column-mapping">
                        <xsl:variable name="fk-col-id" select="@fk-column-ref"/>
                        <xsl:variable name="fk-col-name" select="//column[@id=$fk-col-id]/@name"/>
                        <xsl:variable name="pk-col-id" select="@pk-column-ref"/>
                        <xsl:variable name="pk-col-name" select="//column[@id=$pk-col-id]/@name"/>

                        <xsl:for-each select="/architect-project/target-database/relationships/relationship[@fk-table-ref=$fk-id]">
                            <xsl:variable name="fk-id2" select="@pk-table-ref"/>
                            <xsl:variable name="fk-col-id2" select="@pk-column-ref"/>
                            <xsl:variable name="fk-col-name2" select="//column[@id=$fk-col-id2]/@name"/>
                            
                            <xsl:if test="$table-id != $fk-id2
                                          and $fk-id2">
                                <xsl:variable name="fkTable" select="/architect-project/target-database/table[@id=$fk-id2]/@name"/>

                                <xsl:if test="$fkTable != 'sf_guard_user'">
                                    <xsl:text>    </xsl:text>
                                    <xsl:call-template name="Pascalize">
                                        <xsl:with-param name="pText" select="$fkTable"/>
                                    </xsl:call-template>
                                    <xsl:text>:  { class:  </xsl:text>
                                    <xsl:call-template name="Pascalize">
                                        <xsl:with-param name="pText" select="$fkTable"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="$fk-col-name2"/>
                                    <xsl:call-template name="many-many-relation-definition">
                                        <xsl:with-param name="table" select="$targetTable"/>
                                        <xsl:with-param name="columnName" select="$fk-col-name"/>
                                        <xsl:with-param name="pkColumnName" select="$pk-col-name"/>
                                    </xsl:call-template>
                                    <xsl:text>&#10;</xsl:text>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:if>

            </xsl:for-each>
            
            <!--&#160;&#160;indexes:<br/>
            <xsl:for-each select="folder//index">
               <xsl:if test="@primaryKeyIndex = 'false'">
                    <xsl:call-template name="indexes">
                        <xsl:with-param name="indexName" select="@name"/>
                    </xsl:call-template>
               </xsl:if>
            </xsl:for-each>
            <br/>-->

          </xsl:if>
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
            <xsl:text>, scale:  </xsl:text><xsl:value-of select="$scale"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="relation-definition">
        <xsl:param name="table"/>
        <xsl:param name="columnName"/>
        <xsl:param name="pkColumnName"/>
        <xsl:param name="updateRule"/>
        <xsl:param name="deleteRule"/>
        <xsl:param name="relationshipName"/>

        <xsl:text>    </xsl:text>
        <xsl:call-template name="Pascalize">
            <xsl:with-param name="pText" select="$columnName"/>
        </xsl:call-template>
        <xsl:text>:  { class:  </xsl:text>
            <xsl:call-template name="Pascalize">
                <xsl:with-param name="pText" select="$table"/>
            </xsl:call-template>
        <xsl:text>, local:  </xsl:text><xsl:value-of select="$columnName"/>
        <xsl:text>, foreign:  </xsl:text><xsl:value-of select="$pkColumnName"/>
        <xsl:text>, foreignAlias:  </xsl:text>
        <xsl:call-template name="Pascalize">
            <xsl:with-param name="pText" select="$relationshipName"/>
        </xsl:call-template>
        <xsl:if test="$updateRule = '0'
                      or $updateRule = '2'
                      or $updateRule = '4'
                      or $updateRule = '5'">
            <xsl:text>, onUpdate:  </xsl:text>
                <xsl:call-template name="RelationshipRuleCheck">
                    <xsl:with-param name="ruleId" select="$updateRule"/>
                </xsl:call-template>
        </xsl:if>
        <xsl:if test = "$deleteRule = '0'
                      or $deleteRule = '2'
                      or $deleteRule = '4'
                      or $deleteRule = '5'">
            <xsl:text>, onDelete:  </xsl:text>
                <xsl:call-template name="RelationshipRuleCheck">
                    <xsl:with-param name="ruleId" select="$deleteRule"/>
                </xsl:call-template>
        </xsl:if>
        <xsl:text> }&#10;</xsl:text>
        <br/>
    </xsl:template>

    <xsl:template name="many-many-relation-definition">
        <xsl:param name="table"/>
        
        <xsl:text>, refClass:  </xsl:text>
        <xsl:call-template name="Pascalize">
            <xsl:with-param name="pText" select="$table"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
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
            <xsl:when test="$ruleId = 4">
                <xsl:text>setNull</xsl:text>
            </xsl:when>
            <xsl:when test="$ruleId = 5">
                <xsl:text>setDefault</xsl:text>
            </xsl:when>
            <!--<xsl:otherwise>
                <xsl:text>not-supported</xsl:text><xsl:value-of select="$ruleId"/>
            </xsl:otherwise>-->
        </xsl:choose>
    </xsl:template>

    <xsl:template name="indexes">
        <xsl:param name="indexName"/>
        <xsl:param name="primary"/>

        <xsl:if test="not(contains($indexName, 'created_at'))
                      and not(contains($indexName, 'updated_at'))
                      and not(contains($indexName, 'created_by'))
                      and not(contains($indexName, 'updated_by'))">

        &#160;&#160;&#160;&#160;<xsl:value-of select="$indexName"/>:<br />
        &#160;&#160;&#160;&#160;&#160;&#160;fields:<br/>

        <xsl:for-each select="index-column">
            <xsl:param name="sorting" select="@ascendingOrDescending"/>

            &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
            <xsl:value-of select="@name"/>:<br/>
            &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
            sorting:
            <xsl:choose>
                <xsl:when test="$sorting = 'ASCENDING'">&#160;&#160;ASC</xsl:when>
                <xsl:when test="$sorting = 'DESCENDING'">&#160;&#160;DESC</xsl:when>
            </xsl:choose>
            <br/>
        </xsl:for-each>
        
        <xsl:choose>
            <xsl:when test="@unique = 'true'"> &#160;&#160;&#160;&#160;&#160;&#160;type:&#160;&#160;unique</xsl:when>
        </xsl:choose>
        <br/>
        </xsl:if>
    </xsl:template>

    <!--Special thanks to Dimitre Novatchev for writing the Pascalize template
        in response to my question on StackOverflow
        (http://stackoverflow.com/questions/2647327/how-to-format-a-string-to-camel-case-in-xslt/2647656#2647656). -->

    <xsl:template name="Pascalize">
        <xsl:param name="pText"/>

        <xsl:if test="$pText">

            <xsl:choose>
                <xsl:when test="$pText = 'sf_guard_user'">
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

</xsl:transform>

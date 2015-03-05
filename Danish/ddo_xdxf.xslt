<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
<!ENTITY lower_case_from "ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÉ">
<!ENTITY lower_case_to   "abcdefghijklmnopqrstuvwxyzæøåé">
<!ENTITY ndash  "&#8211;" >
<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:str="http://exslt.org/strings"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all">
    
    <xsl:import href="ddo_base.xslt"/>
    <xsl:import href="content.xslt"/>
    <xsl:import href="forkortelser.xslt"/>
    
    <xsl:template match="Artikel">
        <ar id="{@EntryID}">
            <head>
                <xsl:apply-templates select="Iddel/Holem"/>
            </head>
            <xsl:apply-templates select="BøjFon/Bøjdel"/>
            <xsl:call-template name="Udtale"/>
            <def>
                <xsl:call-template name="POS"/>
                <xsl:call-template name="Sideformer"/>
                <xsl:apply-templates select="Etymdel"/>
                <xsl:if test="string-length(Semdel)&gt;4">
                    <xsl:apply-templates select="Semdel"/>
                </xsl:if>
                <xsl:if test="Sulesem">
                    <idiom>
                        <xsl:apply-templates select="Sulesem"/>
                    </idiom>
                </xsl:if>
            </def>
        </ar>

    </xsl:template>
    
    <!-- HEAD -->
    <xsl:template match="Holem">
        <k>
            <xsl:if test="//Komfon/Fon/@Status='fil_findes'">
                <xsl:variable name="aktuelt_holem" select="text()"/>
                <xsl:variable name="aktuel_holem_position" select="position()"/>
                <xsl:variable name="sound_ids_string">
                    <xsl:for-each select="//Komfon[Fon/@Status='fil_findes']|//Eksfon[Fon/@Status='fil_findes']">
                        <xsl:if test="(name(.) = 'Komfon' and not(Kom) and $aktuel_holem_position = 1) 
                            or (not(Kom) and name(preceding-sibling::node())=name(.) 
                            and (preceding-sibling::node()/Kom = $aktuelt_holem
                            or Kom = concat($aktuelt_holem,':')))
                            or Kom = $aktuelt_holem 
                            or Kom = concat($aktuelt_holem,':')
                            or (substring(Kom,1,1)='-'
                                and substring(Kom,2,string-length(Kom)-2)=substring($aktuelt_holem,string-length($aktuelt_holem)-(string-length(Kom)-3)))">
                            <xsl:if test="position() &gt; 1"><xsl:text> </xsl:text></xsl:if>
                            <xsl:value-of select="Fon/@Lydfil"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="normalize-space($sound_ids_string)">
                    <xsl:attribute name="sound_ids"><xsl:value-of select="normalize-space($sound_ids_string)"/>
                    </xsl:attribute> 
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="text()|super|sub"/>
            <xsl:apply-templates select="Homnr"/>
            <xsl:apply-templates select="RegVare"/>
        </k>
    </xsl:template>
    
    <xsl:template match="Homnr">
        <opt>
            <xsl:value-of select="."/>
        </opt>
    </xsl:template>

    <xsl:template match="RegVare">
        <opt>
            <xsl:text>®</xsl:text>
        </opt>
    </xsl:template>
    
    <!-- POS -->
    <xsl:template name="POS">
        <pos>
            <xsl:call-template name="fork-Lemklas">
                <xsl:with-param name="variabel" select="Iddel/Lemklas/text()"/>
            </xsl:call-template>
            <xsl:if test="Iddel/Køn">
                <xsl:text>, </xsl:text>
                <xsl:call-template name="fork-Køn">
                    <xsl:with-param name="variabel" select="Iddel/Køn/Normkøn/Normk/KønFrk"/>
                </xsl:call-template>
                
                <xsl:if test="Iddel/Køn/Normkøn/Normk/KønKom">
                    <xsl:text> (</xsl:text>
                    <xsl:apply-templates select="Iddel/Køn/Normkøn/Normk/KønKom" mode="køn"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                
                <xsl:if test="Iddel/Køn/Normkøn/OgElNorm|Iddel/Køn/Normkøn/OgElNormP">
                    <xsl:text> </xsl:text>
                    <xsl:if test="Iddel/Køn/Normkøn/OgElNormP">
                        <xsl:text>(</xsl:text>
                    </xsl:if>
                    <xsl:text>eller </xsl:text> 
                    <xsl:call-template name="fork-Køn">
                        <xsl:with-param name="variabel" select="Iddel/Køn/Normkøn/OgElNorm/Normk/KønFrk"/>
                    </xsl:call-template>
                    <xsl:call-template name="fork-Køn">
                        <xsl:with-param name="variabel" select="Iddel/Køn/Normkøn/OgElNormP/Normk/KønFrk"/>
                    </xsl:call-template>
                    <xsl:if test="Iddel/Køn/Normkøn/OgElNorm/Normk/KønKom">
                        <xsl:text> (</xsl:text>
                        <xsl:call-template name="fork-Tokenize">
                            <xsl:with-param name="txt" select="Iddel/Køn/Normkøn/OgElNorm/Normk/KønKom"/>
                        </xsl:call-template>
                        
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="Iddel/Køn/Normkøn/OgElNormP">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:if>
                
                <xsl:if test="Iddel/Køn/Ukøn">
                    <xsl:text> (eller </xsl:text> 
                    <xsl:apply-templates select="Iddel/Køn/Ukøn/KønKom" mode="køn"/><xsl:text>: </xsl:text>
                    <xsl:call-template name="fork-Køn">
                        <xsl:with-param name="variabel" select="Iddel/Køn/Ukøn/utxt"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:if>
        </pos>
    </xsl:template>

    <xsl:template match="*|@*" mode="udskriv_kom">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="OrdformKom" mode="udskriv_kom">
        <xsl:apply-templates select="." mode="add_quotes"/>
    </xsl:template>

    <xsl:template match="OrdformKom" mode="bøjkom_mode">
        <xsl:apply-templates select="." mode="add_quotes"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="køn">
        <xsl:call-template name="fork-Tokenize">
            <xsl:with-param name="txt" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="Sideformer">
        <xsl:if test="Iddel/Var/SiholemGrp or Iddel/Var/Fejlsiholem[not(contains(./Kom/text(), 'fejl:'))]
            or Iddel/ExthenvId or Iddel/Var/ExthenvVar">
            <forms>
                <xsl:call-template name="Uofficielle-varianter"/>
                <xsl:call-template name="Sympatiske-stavefejl"/>
                <xsl:call-template name="VariantOplysninger"/>
                <xsl:call-template name="HovedHenvisning"/>
            </forms>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="Uofficielle-varianter">
        <xsl:for-each select="Iddel/Var/SiholemGrp">
            <xsl:apply-templates select="Siholem|OgEl"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="Siholem">
        <xsl:choose>
            <xsl:when test="Kom">
                <xsl:if test="name(preceding-sibling::*[1]) = 'Siholem'">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="./Kom/text()|./Kom/OrdformKom"/>
                <xsl:if test="not(contains(./Kom, ':'))"><xsl:text>:</xsl:text></xsl:if>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="name(preceding-sibling::*[1]) = 'Siholem'">
                <xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <k>
            <xsl:value-of select="./txt"/>
        </k> 
    </xsl:template>
    
    <xsl:template name="Sympatiske-stavefejl">
        <xsl:if test="Iddel/Var/SiholemGrp and Iddel/Var/Fejlsiholem[not(contains(./Kom/text(), 'fejl:'))]">
            <xsl:text> </xsl:text>
        </xsl:if>
        <!--<xsl:variable name="first_kom">
        <xsl:value-of select="Iddel/Var/Fejlsiholem[not(contains(./Kom/text(), 'fejl:'))][1]/Kom"/>
    </xsl:variable>-->
        <xsl:for-each select="Iddel/Var/Fejlsiholem[not(contains(./Kom/text(), 'fejl:'))]">
            <xsl:if test="position()&gt;1">
                <xsl:text> • </xsl:text>
            </xsl:if>
            <xsl:if test="Kom">
                <xsl:call-template name="fork-Tokenize">
                    <xsl:with-param name="txt" select="./Kom"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="./txt"/>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- BØJNING -->
    <xsl:template match="Bøjdel">
        <m>
            <xsl:apply-templates select="Bøjning|Komparation"/>
        </m>
    </xsl:template>

    <xsl:template match="Bøjning">
        <xsl:if test="position()&gt;1">
            <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:if test="Kom">
                <xsl:apply-templates select="Kom/node()|Kom/@*|Kom/text()" mode="bøjkom_mode"/>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="Bform"/>
    </xsl:template>

    <xsl:template match="Sjnorm">
        <xsl:text> (eller </xsl:text> 
        <xsl:apply-templates select="." mode="udskriv"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="Altnorm|Unorm">
        <xsl:text> eller </xsl:text>
        <xsl:apply-templates select="." mode="udskriv"/>
    </xsl:template>

    <xsl:template match="SupP|KompP">
        <xsl:if test="position()&gt;1 and not(preceding-sibling::Sup)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:if test="preceding-sibling::Sup">
            <xsl:text> eller </xsl:text>
        </xsl:if>
        <xsl:text>(</xsl:text><xsl:apply-templates select="." mode="udskriv"/><xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="Norm|Altnorm|Sjnorm|Unorm|Sup|Komp" mode="udskriv">
        <xsl:apply-templates select="KompKom"/>
        <xsl:if test="Kom">
            <xsl:apply-templates select="Kom/text()|Kom/*|Kom/@*" mode="udskriv_kom"/>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="./txt"/>
        <xsl:if test="utxt">
            <xsl:value-of select="./utxt"/>
        </xsl:if>
        <xsl:if test="Ekskom">
            <xsl:text>, for eksempel </xsl:text>
            <xsl:for-each select="Ekskom">
                <xsl:if test="position()&gt;1">
                    <xsl:text> og </xsl:text>
                </xsl:if>          
                <xsl:call-template name="inline-citat">
                    <xsl:with-param name="citat" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Komparation">
        <xsl:if test="position()&gt;1">
            <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="KompPar|KompTxt"/>
    </xsl:template>
    
    <xsl:template match="KompMrk">
        <xsl:text>komparativ: </xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="SupMrk">
        <xsl:text>superlativ: </xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="KompKom">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="fork-Tokenize">
            <xsl:with-param name="txt" select="."/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- UDTALE -->
    <xsl:template name="Udtale">
        <xsl:if test="BøjFon/Fondel and (BøjFon/Fondel//*[@Status='fil_findes'] or BøjFon/Fondel//Fon[text()])">
            <phon>
                <xsl:apply-templates select="BøjFon/Fondel"/>
            </phon>
        </xsl:if>            
    </xsl:template>
    
    <xsl:template match="Fondel">
        <xsl:apply-templates select="Komfon"/>
        <xsl:apply-templates select="Plusfon"/>
    </xsl:template>

    <xsl:template match="Plusfon">
        <xsl:text> • </xsl:text>
        <xsl:apply-templates select="Eksfon|Smsfon"/>
    </xsl:template>
    
    <xsl:template match="Komfon|Eksfon|Smsfon">
        <xsl:if test="position() &gt; 1">
            <xsl:choose>
                <xsl:when test="name(following-sibling::node()) = name(.)">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> eller </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="Kom">
            <xsl:apply-templates select="Kom" mode="udtale"/>
            <xsl:if test="substring(Kom/text(), string-length(Kom/text()))!=':' and not(Kom/kolon)">
                <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="Fon"/>
    </xsl:template>
    
    <xsl:template match="OrdformKom" mode="udtale">
        <xsl:apply-templates select="." mode="add_quotes"/>
    </xsl:template>

    <xsl:template match="Fon">
        <xsl:element name="trans">
            <xsl:if test="count(@Status) &gt; 0 and @Status = 'fil_findes'">
                <xsl:attribute name="id"><xsl:value-of select="@Lydfil"/></xsl:attribute>
            </xsl:if>
            <xsl:variable name="fon_orig" select="text()"/>
            <xsl:if test="$fon_orig">
                <xsl:for-each select="str:tokenize($fon_orig, '')">
                    <xsl:variable name="pointer" select="position()-1"/>
                    <xsl:call-template name="konv-Fon">
                        <xsl:with-param name="fon" select="."/>
                        <xsl:with-param name="prev_fon" select="str:tokenize($fon_orig, '')[$pointer]"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </xsl:element>
        
    </xsl:template>
    
    <!-- ETYM -->
    <xsl:template match="Etymdel">
        <etym>
            <xsl:apply-templates select="Dat|EtymuDat|EtymDat"/>
        </etym>
    </xsl:template>
    
    <xsl:template match="Ordform|OrdformHx" mode="etym">
        <xsl:if test="name(preceding-sibling::node()[1]) = 'Ordform' or name(preceding-sibling::node()[1]) = 'OrdformHx'">
            <xsl:text>, </xsl:text>
        </xsl:if> 
        <xsl:if test="name(preceding-sibling::node()[1])='' and substring(preceding-sibling::node()[1], string-length(preceding-sibling::node()[1]))!=' ' and substring(preceding-sibling::node()[1], string-length(preceding-sibling::node()[1]))!=',' and position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <k>
            <xsl:value-of select="."/>
        </k>
    </xsl:template>

    <xsl:template match="Pordform" mode="etym">
        <xsl:if test="name(preceding-sibling::node()[position()=1])='Pordform'">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <k>
            <xsl:value-of select="."/>
        </k>
    </xsl:template>
    
    <xsl:template match="Aha">
        <xsl:text>; </xsl:text>
        <xsl:apply-templates select="text()|*" mode="etym"/>
    </xsl:template>

    <!-- DEF -->
    <xsl:template match="Semdel|Sublemsem">
        <xsl:variable name="semno" select="position()"/>
        <def>
            <xsl:attribute name="l">
                <xsl:choose>
                    <xsl:when test="count(../Semdel|Subsem|Resthenv|../Sublemsem|Subsubsemem)>1"><xsl:value-of select="$semno"/></xsl:when>
                    <xsl:otherwise><xsl:text>&nbsp;</xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="Semem|Subsemem|Resthenv"/>
            <xsl:apply-templates select="Subsem|Subsubsemem">
                <xsl:with-param name="semno" select="$semno"/>
            </xsl:apply-templates>
        </def>
    </xsl:template>
    
    <xsl:template match="Semem|Subsemem">
        <xsl:call-template name="semstrukt"/>
    </xsl:template>
    
    <xsl:template match="Resthenv">
        <xsl:call-template name="semstrukt"/>
    </xsl:template>
    
    <xsl:template match="Subsem|Subsubsemem">
        <xsl:param name="semno"/>
        <xsl:variable name="subsemno"><xsl:number value="position()" format="a"/></xsl:variable>
        <def l="{$semno}.{$subsemno}">
            <xsl:call-template name="semstrukt"/>
        </def>
    </xsl:template>
    
    <xsl:template name="semstrukt">
        <xsl:if test="Denbet or ExthenvRest or Sublemkl or Restspec or Semspec or Resthenv">
            <dtrn>
                <xsl:apply-templates select="Sublemkl|Restspec/*|Semspec|Resthenv/Sublemkl|Resthenv/Restspec/*|Resthenv/Semspec"/>
                
                <xsl:apply-templates select="Denbet"/>
                <xsl:apply-templates select="ExthenvRest|Resthenv/ExthenvRest"/>
                
                <xsl:if test="Konbet">
                    <xsl:text> • </xsl:text>
                    <xsl:apply-templates select="Konbet"/>
                </xsl:if>
                <xsl:if test="Encykl">
                    <xsl:text> • </xsl:text>
                    <xsl:apply-templates select="Encykl"/>
                </xsl:if>
                
                <xsl:if test="Onym/Symbol">
                    <xsl:text> </xsl:text><xsl:value-of select="'&ndash;'"></xsl:value-of><xsl:text> </xsl:text>
                    <co>
                        <xsl:choose>
                            <xsl:when test="count(Onym/Symbol)&gt;1"><xsl:text>Symboler</xsl:text></xsl:when>
                            <xsl:otherwise><xsl:text>Symbol</xsl:text></xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>:</xsl:text>
                    </co>
                    <xsl:apply-templates select="Onym/Symbol"/>
                </xsl:if>
                <xsl:if test="Onym/Fork">
                    <xsl:text> </xsl:text><xsl:value-of select="'&ndash;'"></xsl:value-of><xsl:text> </xsl:text>
                    <co>
                        <xsl:choose>
                            <xsl:when test="count(Onym/Fork)&gt;1"><xsl:text>Forkortelser</xsl:text></xsl:when>
                            <xsl:otherwise><xsl:text>Forkortelse</xsl:text></xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>:</xsl:text>
                    </co>
                    <xsl:apply-templates select="Onym/Fork"/>
                </xsl:if>
                
                <xsl:if test="Restalm or Resthenv/Restalm">
                    <xsl:text> </xsl:text><xsl:value-of select="'&ndash;'"></xsl:value-of><xsl:text> </xsl:text>
                    <co>
                        <xsl:apply-templates select="Restalm/*|Resthenv/Restalm/*"/>
                    </co>
                </xsl:if>
                <xsl:if test="Semspec/SomEgenn|Resthenv/Semspec/SomEgenn">
                    <xsl:text> </xsl:text><xsl:value-of select="'&ndash;'"></xsl:value-of><xsl:text> </xsl:text>
                    <co>Som egennavn:</co>
                    <xsl:apply-templates select="Semspec/SomEgenn"/>
                </xsl:if>
            </dtrn>
        </xsl:if>
        
        <xsl:call-template name="Onymer"/>
        
        <xsl:apply-templates select="Dok[@DokStatus='a']|Resthenv/Dok[@DokStatus='a']"/>
        
    </xsl:template>

    <xsl:template match="SomEgenn">
        <xsl:if test="position()&gt;1">
            <xsl:text> eller</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>    
    </xsl:template>
    
    <!-- STYLE -->
    <xsl:template match="Sublemkl">
        <style>
            <xsl:call-template name="fork-Tokenize">
                <xsl:with-param name="txt" select="./text()"/>
            </xsl:call-template>
        </style>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="Sysfag"/>
    
    <xsl:template match="Fag|Jargon|Slang">
        <xsl:variable name="text">
            <xsl:call-template name="fork-Fag">
                <xsl:with-param name="variabel" select="text()"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="$text">
            <style>
                <xsl:for-each select="str:tokenize($text, '')">
                    <xsl:value-of select="translate(., '&lower_case_from;', '&lower_case_to;')"/>
                </xsl:for-each>
            </style>
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Semspec">
        <xsl:if test="text()">
            <style>
                <xsl:call-template name="fork-Tokenize">
                    <xsl:with-param name="txt" select="./text()"/>
                </xsl:call-template>
            </style>
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    

    <!-- ONYMER -->
    <xsl:template name="Onymer">
        <xsl:apply-templates select="Onym/Syn"/>
        <xsl:apply-templates select="Onym/Ant"/>
        <xsl:apply-templates select="Onym/Ordfelt"/>
    </xsl:template>
    
    <xsl:template name="OnymLinks">
        <xsl:call-template name="KlikForm">
            <xsl:with-param name="element" select="name(.)"/>
            <xsl:with-param name="position" select="position()"/>
            <xsl:with-param name="mediumkom">
                <xsl:choose>
                    <xsl:when test="Exthenv/Kom">
                        <xsl:call-template name="fork-Tokenize">
                            <xsl:with-param name="txt" select="Exthenv/Kom"/>
                            <xsl:with-param name="name" select="'KomOnym'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="fork-Tokenize">
                            <xsl:with-param name="txt" select="KomOnym"/>
                            <xsl:with-param name="name" select="'KomOnym'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="entry_id" select="Exthenv//ReferOnym/EntryRef|Exthenv//Refer/EntryRef|Exthenv//ReferSublem/EntryRef"/>
            <xsl:with-param name="subentry_id" select="Exthenv//ReferSublem/SubEntryRef|Exthenv//ReferOnym/SubEntryRef"/>
            <xsl:with-param name="def_id" select="Exthenv//ReferOnym/DefRef|Exthenv//ReferOnym/BethenvRef|Exthenv//Refer/DefRef|Exthenv//ReferSublem/DefRef"/>
            <xsl:with-param name="form">
                <xsl:choose>
                    <xsl:when test="txt[1]!=''">
                        <xsl:apply-templates select="txt[1]"/>
                    </xsl:when>
                    <xsl:when test="Exthenv/txt">
                        <xsl:apply-templates select="Exthenv/txt"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="Exthenv//ReferOnym/ArtRef"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="Syn">
        <synonym>
            <xsl:call-template name="OnymLinks"/>
        </synonym>
    </xsl:template>

    <xsl:template match="Ant">
        <antonym>
            <xsl:call-template name="OnymLinks"/>
        </antonym>
    </xsl:template>

    <xsl:template match="Ordfelt">
        <related>
            <xsl:call-template name="OnymLinks"/>
        </related>
    </xsl:template>
    
    <xsl:template match="Symbol|Fork">
        <xsl:text> </xsl:text>
        <xsl:call-template name="KlikForm">
            <xsl:with-param name="element" select="name(.)"/>
            <xsl:with-param name="position" select="position()"/>
            <xsl:with-param name="mediumkom">
                <xsl:choose>
                    <xsl:when test="Exthenv/Kom">
                        <xsl:call-template name="fork-Tokenize">
                            <xsl:with-param name="txt" select="Exthenv/Kom"/>
                            <xsl:with-param name="name" select="'KomOnym'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="fork-Tokenize">
                            <xsl:with-param name="txt" select="KomOnym"/>
                            <xsl:with-param name="name" select="'KomOnym'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="entry_id" select="Exthenv//ReferOnym/EntryRef|Exthenv//Refer/EntryRef"/>
            <xsl:with-param name="def_id" select="Exthenv//ReferOnym/DefRef|Exthenv//ReferOnym/BethenvRef|Exthenv//Refer/DefRef"/>
            <xsl:with-param name="form">
                <xsl:choose>
                    <xsl:when test="txt[1]!=''">
                        <xsl:apply-templates select="txt[1]"/>
                    </xsl:when>
                    <xsl:when test="Exthenv/txt">
                        <xsl:apply-templates select="Exthenv/txt"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="Exthenv//ReferOnym/ArtRef"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="KlikForm">
        <xsl:param name="element"/>
        <xsl:param name="position"/>
        <xsl:param name="mediumkom"/>
        <xsl:param name="minorkom"/>
        <xsl:param name="blackkom"/>
        <xsl:param name="entry_id"/>
        <xsl:param name="subentry_id"/>
        <xsl:param name="def_id"/>
        <xsl:param name="form"/>
        
        <xsl:if test="$mediumkom != ''">
            <co>
                <xsl:copy-of select="$mediumkom"/>
            </co>
        </xsl:if>
        
        <xsl:if test="$blackkom != ''">
            <co>
                <xsl:copy-of select="$blackkom"/>
            </co>
            <xsl:text> </xsl:text>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="$entry_id or $subentry_id">
                <xsl:element name="kref">
                    <xsl:choose>
                        <xsl:when test="$subentry_id">
                            <xsl:attribute name="subid">
                                <xsl:value-of select="$subentry_id"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$entry_id">
                            <xsl:attribute name="id">
                                <xsl:value-of select="$entry_id"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="$def_id">
                        <xsl:attribute name="defid">
                            <xsl:value-of select="$def_id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <k>
                        <xsl:copy-of select="$form"/>
                    </k>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <k>
                    <xsl:copy-of select="$form"/>
                </k>
            </xsl:otherwise>    
        </xsl:choose>
        
        <xsl:if test="($element = 'Vb' or $element = 'Sb' or $element = 'Adj' or $element = 'Adv') and string-length($entry_id)=0">
            <xsl:text> </xsl:text>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$element = 'Vb'">vb.</xsl:when>
            <xsl:when test="$element = 'Sb'">sb.</xsl:when>
            <xsl:when test="$element = 'Adj'">adj.</xsl:when>
            <xsl:when test="$element = 'Adv'">adv.</xsl:when>
        </xsl:choose>    
        
        <xsl:if test="$minorkom != ''">
            <xsl:text> </xsl:text>
                <xsl:text>(</xsl:text>
                <xsl:call-template name="fork-Tokenize">
                    <xsl:with-param name="txt" select="$minorkom"/>
                    <xsl:with-param name="name" select="$element"/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- CITATER -->
    <xsl:template match="Dok">
        <ex>
            <xsl:if test="KomDok">
                <co>
                    <xsl:value-of select="KomDok"/>
                </co>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="Citat/text()|Citat/*" mode="citat"/>
        </ex>
    </xsl:template>
    
    <xsl:template match="sub" mode="citat">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="super" mode="citat">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="OrdformKom" mode="citat">
        <em>
            <xsl:apply-templates select="*|text()"/>
        </em>
    </xsl:template>

    <xsl:template match="Spctgn" mode="citat">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- IDIOMS / FASTE UDTRYK -->
    
    <xsl:template match="Sulesem">
        <idiom id="{@SubEntryID}">
                <xsl:apply-templates select="SublemDelt"/>
                <def>
                    <xsl:apply-templates select="Sublemsem"/>
                </def>
            </idiom>
    </xsl:template>
    
    <xsl:template match="SublemDelt">
        <xsl:if test="position()>1">
            <co>eller</co>
        </xsl:if>
        <k>
            <xsl:apply-templates select="." mode="base">
                <xsl:with-param name="mode" select="'xdxf'"/>
            </xsl:apply-templates>
        </k>
    </xsl:template>
    
    
    <!-- VÆRKTØJ -->
    <xsl:template match="sub">
        <xsl:choose>
            <xsl:when test="./text()='0'">
                <xsl:text>₀</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='1'">
                <xsl:text>₁</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='2'">
                <xsl:text>₂</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='3'">
                <xsl:text>₃</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='4'">
                <xsl:text>₄</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='5'">
                <xsl:text>₅</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='6'">
                <xsl:text>₆</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='7'">
                <xsl:text>₇</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='8'">
                <xsl:text>₈</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='9'">
                <xsl:text>₉</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='12'">
                <xsl:text>₁₂</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='x'">
                <xsl:text>ₓ</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="super">
        <xsl:choose>
            <xsl:when test="./text()='0'">
                <xsl:text>⁰</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='1'">
                <xsl:text>¹</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='2'">
                <xsl:text>²</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='3'">
                <xsl:text>³</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='4'">
                <xsl:text>⁴</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='5'">
                <xsl:text>⁵</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='6'">
                <xsl:text>⁶</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='7'">
                <xsl:text>⁷</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='8'">
                <xsl:text>⁸</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='9'">
                <xsl:text>⁹</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='+'">
                <xsl:text>⁺</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='++'">
                <xsl:text>⁺⁺</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='-'">
                <xsl:text>⁻</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='-5'">
                <xsl:text>⁻⁵</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='-5'">
                <xsl:text>⁻⁵</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='227'">
                <xsl:text>²²⁷</xsl:text>
            </xsl:when>
            <xsl:when test="./text()='13'">
                <xsl:text>¹³</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="inline-citat">
        <xsl:param name="citat"/>
        <xsl:text>“</xsl:text>
        <xsl:value-of select="$citat"/>
        <xsl:text>”</xsl:text>
    </xsl:template>

    <xsl:template match="OrdformKom|OrdformValens|Morfordform">
        <xsl:apply-templates select="." mode="add_quotes"/>
    </xsl:template>
    
    <xsl:template match="Kom/OrdformKom|OrdformHx|Ordform">
        <k>
            <xsl:value-of select="."/>
        </k>
    </xsl:template>
    
    <xsl:template name="dividerDot">
        <xsl:text>; </xsl:text>
    </xsl:template> 
    
    <xsl:template name="dividerSmall">
        <xsl:text>, </xsl:text>
    </xsl:template> 
    
</xsl:stylesheet>
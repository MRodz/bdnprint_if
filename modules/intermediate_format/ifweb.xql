(:~ 
 : ifweb.xql offers a simple interface for creating the website specific BdN
 : intermediate format of a given resource.
 : 
 : @author Michelle Rodzis
 : @version 1.0
 : 
 :)
xquery version "3.1";

module namespace ifweb="http://bdn-edition.de/intermediate_format/ifweb";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace pre="http://bdn-edition.de/intermediate_format/preprocessing" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn-edition.de/intermediate_format/identification" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/identification.xqm";
import module namespace config = "http://bdn-edition.de/intermediate_format/config" at "xmldb:exist:///db/apps/interformat/modules/config.xqm";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";

declare function ifweb:main($resource as xs:string) as xs:string? {
    let $doc := doc($config:sade-data || $resource)
    let $filename := substring-before($resource, '.xml') || "-if.xml"
    
    let $replace-whitespace := true()
    let $preprocessed-data := pre:preprocessing($doc/tei:TEI, $replace-whitespace)
    let $intermediate-format := ident:walk($preprocessed-data, ())
    
    return xmldb:store($config:sade-data, $filename, $intermediate-format)
};
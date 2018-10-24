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

import module namespace console="http://exist-db.org/xquery/console";
import module namespace pre="http://bdn-edition.de/intermediate_format/preprocessing" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn-edition.de/intermediate_format/identification" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/identification.xqm";
import module namespace config = "http://bdn-edition.de/intermediate_format/config" at "xmldb:exist:///db/apps/interformat/modules/config.xqm";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";

declare variable $ifweb:replace-whitespace := true();
declare variable $ifweb:print := false();

declare function ifweb:main($resource as xs:string) as xs:string? {
    let $doc := doc($config:sade-data || $resource)
    let $filename := substring-before($resource, '.xml') || "-if.xml"
    
    return ifweb:transform($doc, $filename)
};


declare function ifweb:transform($doc as node()*, $filename as xs:string) 
as node()* {
    let $preprocessed-data := pre:preprocessing($doc/tei:TEI, $ifweb:replace-whitespace, $ifweb:print)
    let $intermediate-format := ident:walk($preprocessed-data, ())
    let $store := xmldb:store($config:sade-data, $filename, $intermediate-format)
    
    return $intermediate-format
};

declare function ifweb:complete-xml($author as xs:string, $xml as node()*) 
as node()* {
    let $log-dir :=
        if(xmldb:collection-available($config:app-root || "/logs")) then
            $config:app-root || "/logs" 
        else
            xmldb:create-collection($config:app-root, "logs")
    let $log-name := "log.xml"
    let $create := xmldb:store($log-dir, $log-name, <root/>)
            
    let $filename := $author || "-full-if.xml"
    return ifweb:transform($xml, $filename)
};

declare function ifweb:single-xml($resource as node()*, $filename as xs:string) 
as node()* {
    let $filename := substring-before($filename, '.xml') || "-if.xml"
    return ifweb:transform($resource, $filename)
};

declare function ifweb:transform-split-xml($xml as node()*, $filename as xs:string, 
$dir as xs:string) {
    let $preprocessed-data := pre:preprocessing($xml/*, $ifweb:replace-whitespace, $ifweb:print)
    let $intermediate-format := ident:walk($preprocessed-data, ())
    let $content := 
        if(count($intermediate-format) gt 1) then
            element tei:div {$intermediate-format}
        else
            $intermediate-format
    let $store := xmldb:store($dir, $filename, $content)
    
    return $intermediate-format
};

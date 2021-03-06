xquery version "3.0";
(:~
 : WHITESPACE Module ("whitespace", "http://bdn.edition.de/intermediate_format/whitespace_handling")
 : *******************************************************************************************
 : This module contains the functions to handle different whitespace operations on text
 :
 : @version 1.0 (2018-01-02)
 : @status working
 : @author Uwe Sikora
 :)
module namespace whitespace="http://bdn-edition.de/intermediate_format/whitespace_handling";

declare default element namespace "http://www.tei-c.org/ns/1.0";


(:############################# Modules Functions #############################:)

(:~
 : whitespace:text()
 : This function handles whitespace in defined text() nodes
 :
 : @param $text the text-node to be converted
 : @param $escape-char a optional escape-character replacing all whitespace characters
 : @return text()* representing the escaped text()
 :
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function whitespace:text
    ( $text as text()*, $escape-char as xs:string? ) as text()* {

    let $whitespace-node := $text[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
    let $single-whitespace-between-nodes := $text = " "
    return
        if (not($whitespace-node)) then (

            if ($escape-char) then (
                whitespace:escape-text($text, "@")
            ) else ( whitespace:escape-text($text, " ") )

        )
        else ()

};


(:~
 : whitespace:escape-text()
 : This function replaces whitespaces in a text()
 : with a defined preservation character
 :
 : @param $text the text-node to be converted
 : @param $escape the escape-character replacing all whitespace characters
 : @return text()* representing the escaped text()
 :
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function whitespace:escape-text
    ($text as text()*, $escape as xs:string) as text()* {

    text {replace($text, '[\s]+', $escape)}
};

declare function whitespace:remove($nodes as node()*) as node()* {
    for $node in $nodes
    return
        typeswitch ($node)
        case text() return
            if([matches($node, "[\s\n\r\t]") and normalize-space(.) = ""]) then 
                ()
            else
                $node
        default return
            $node
};

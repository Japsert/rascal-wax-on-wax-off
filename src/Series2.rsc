module Series2

import ParseTree;
import IO;
import String;

/*
 * Syntax definition
 * - define a grammar for JSON (https://json.org/)
 */

start syntax JSON
  = Object;

syntax Object
  = "{" {Element ","}* "}";

syntax Element
  = String ":" Value;

syntax Value
  = String
  | Number
  | Array
  | Object
  | Boolean
  | Null
  ;

syntax Null
  = "null";

syntax Boolean
  = "true" | "false";

syntax Array
  = "[" {Value ","}* "]";

lexical String
  = [\"] ![\"]* [\"]; // slightly simplified

lexical Number
  = [1-9][0-9]* ("." [0-9]*)?
  | "0" ("." [0-9]*)?
  ;

layout Whitespace = [\ \t\n]* !>> [\ \t\n];

// import the module in the console
start[JSON] example()
  = parse(#start[JSON],
          "{
          '  \"age\": 42,
          '  \"name\": \"Joe\",
          '  \"address\": {
          '     \"street\": \"Wallstreet\",
          '     \"number\": 102
          '  }
          '}");
start[JSON] example2()
  = parse(#start[JSON],
          "{
          '  \"age\": 42,
          '  \"name\": \"Joe\"
          '}");


// use visit/deep match to find all element names
// - use concrete pattern matching
// - use "<x>" to convert a String x to str
set[str] propNames(start[JSON] json) {
  set[str] names = {};
  visit(json) {
    case (Element) `<String name>: <Value _>`: names += "<name>"[1..-1];
  }
  return names;
}

set[str] propNames_(start[JSON] json) {
  names = for (/(Element) `<String name>: <Value _>` := json)
    append("<name>"[1..-1]);
  return toSet(names);
}

// define a recursive transformation mapping JSON to map[str,value]
// - every Value constructor alternative needs a 'transformation' function
// - define a data type for representing null;

map[str, value] json2map(start[JSON] json) = json2map(json.top);

map[str, value] json2map((JSON)`<Object obj>`) = json2map(obj);
map[str, value] json2map((Object)`{<{Element ","}* elems>}`)
  = (el.name: el.val | Element e <- elems, el := json2map(e));
tuple[str name, value val] json2map((Element)`<String s>: <Value v>`)
  = <json2str(s), json2value(v)>;

str json2str(String s) = unquote("<s>");

str unquote(str s) = s[1..-1];

value json2value((Value)`<String s>`)    = unquote("<s>");
value json2value((Value)`<Number n>`)    = toInt(unquote("<n>"));
value json2value((Value)`<Array a>`)     = a;
value json2value((Value)`<Object obj>`)  = obj;
value json2value((Value)`<Boolean b>`)   = b;
value json2value((Value)`<Null n>`)      = n;
default value json2value(Value v) { throw "No transformation function for `<v>` defined"; }

test bool example2map() = json2map(example()) == (
  "age": 42,
  "name": "Joe",
  "address" : (
     "street" : "Wallstreet",
     "number" : 102
  )
);


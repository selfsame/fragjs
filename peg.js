/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */

start
  = statement*

statement = 
   (w newline)* value:(assign / chain) (w newline)* {return {type:'statement', value:value}}

assign = left:symbol w "=" w right:chain {return {type:'assign', left:left, right:right}}

chain = first:(set / element / string) rest:(slash e:(set / element / string) {return e})* 
{return  {type:'chain', value:[first].concat(rest)}}

set = "[" nlw first:(unit) rest:(nlw "," nlw e:(unit) {return e})* nlw "]" {return {type:'set', value:[first].concat(rest)}}

unit = (arg / string / chain / element )

element = tag:symbol label:label? id:id? classes:cs* json:json?
{
result = {type:'element', tag:tag};
if (id != "") {result.id = id}
if (label != "") {result.label = label}
if (json != "") {result.json = json}
if (classes.length != 0) {result.classes = classes}
return result
}

cs = dot symbol:symbol {return symbol}
id = pound symbol:symbol {return symbol}
label = colon symbol:symbol {return symbol}
symbol = arg / w v:([a-z0-9_]+) w {return {type:'symbol', value:v.join('')}}

slash = w "/" w {return "/"}
dot = w "." w {return "."}
pound = w "#" w {return "#"}
colon = w ":" w {return "#"}
comma = w "," w {return ","}
json = w "{" first:keyprop rest:(comma keyprop )* "}" w {
result = {};
keyprops = [first].concat(rest);
for (var i = 0; i < keyprops.length; i++) {
  k = keyprops[i];
  result[k.key] = k.value
}
return result}

keyprop = key:symbol colon value:(symbol / s:string {return s.value}) {return {key:key.value, value:value}}

string = ("\"" string:['a-zA-Z0-9_\-\+=!@#.,/$%^&*():<> ]* "\"" {return {type:'text', value:string.join("")} } /
"\'" string:[\"a-zA-Z0-9_\-\+=!@#.,$/%^&*():<> ]* "\'" {return {type:'text', value:string.join("")} } )

arg = "%" int:integer w {return {type:'arg', value:int}}

number
  = w number:(float / integer) w
    {return number}

float
  = sign:"-"?
    before:[0-9]* "." after:[0-9]+ {
      return parseFloat(sign+before.join("") + "." + after.join(""));
    }

integer
  = sign:"-"?
    digits:[0-9]+ {
      return parseInt(sign+digits.join(""), 10);
    }

nlw = val:(" " / tab / newline )* {return []}

w
  = string:(" " / tab )* {return string.join('')}

newline =
  [\n] {return "\n" }

tab =
  [\t] {return "\t" }
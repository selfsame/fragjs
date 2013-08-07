{ var indentStack = [], indent = ""; }

start
  = b:block {return b}


block = lines:(SAMEDENT l:(assign / chain) EOL* {return l})+ DEDENT? {return lines}


assign = left:symbol w "=" w right:chain {return {type:'assign', left:left, right:right}}

chain = 
  (  string /
  parts: ( first:element 
           rest:(slash e:(element / string) {return e})* 
           {return [first].concat(rest)})
  
  block: (slash? EOL INDENT b:block {return b})?
  {
    result =  {type:'chain', parts:parts};
    if (block != "") {result.parts.push(block);}
    return result;  
  } )


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



symbol = arg / w v:([a-z0-9_]+) w {return {type:'symbol', value:v.join('')}}

slash = w "/" w {return "/"}



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


tab =
  [\t] {return "\t" }

w
  = string:(" " )* {return string.join('')}

EOL
  = "\r\n" / "\n" / "\r"

newline = [\n] {return "\n" }

SAMEDENT = i:[ \t]* &{ return i.join("") === indent; }

INDENT = i:[ \t]+ &{ return i.length > indent.length; }
    { indentStack.push(indent); indent = i.join(""); pos = offset; }

DEDENT = { indent = indentStack.pop(); }
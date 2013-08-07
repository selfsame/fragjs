body = document.getElementsByTagName("body")[0]
_ = (args...)->
	fn = (args...)->
			#console.log(Array.prototype.slice.call(arguments));
		args = Array::slice.call(args)
		console.log args
		_.old = fn
		result = new _()
		result.__setup args
		result
		#fn.__proto__ = fn.prototype = _.prototype;
	fn:: = fn.__proto__ = _::
	fn.attach_to = fn::attach_to
	fn.nombre = "pancho"
	fn.__inherit_props _.old
	unless fn.__namespace
		fn.__namespace = {}
		fn.__scope = []
		__frag = document.createDocumentFragment()
		fn.__add_symbol "__frag", __frag
		fn.__frag
	_.old = false
		#fn.__note_args(arguments);
	#fn.__setup(args);
	fn

_:: =
	old: false
	constructor: ->
		this
	nombre: "prototype"
	__set_scope: (scope) ->
		console.log "setting scope: ", scope
		@__scope = scope

	__scope_to_namespace: (scope) ->
		console.log "__scope_to_namespace", scope
		target = @__namespace
		i = 0
		while i < scope.length
			part = scope[i]
			if typeof part is 'number'
				if target.__children
					target = target.__children[part]
			else if target[part]
				target = target[part]
			else
				return `undefined`
			i++
		console.log target
		target

	__add_symbol: (symbol, value) ->
		namespace = @__scope_to_namespace(@__scope)
		console.log "add_symbol", namespace, @__scope
		namespace[symbol] = __node: value
		target_scope = @__scope.concat(symbol)
		getter = {}
		getter[symbol] = get: ->
			@__set_scope target_scope
		console.log getter
		Object.defineProperties this, getter

	__register: (head, el)->
		#if head is @__namespace['__frag'].__node
		#	console.log 'root'
		namespace = @__scope_to_namespace(@__scope)
		if not namespace
			console.log "namespace error: ", @__scope
			return
		if not namespace.__children
			namespace.__children = []
		console.log 'register', namespace
		namespace.__children = namespace.__children.concat(el)


	__setup: (args) ->
		@__note_args args
		@__parse this
		@__construct_frag this, @__parsed, @__namespace['__frag'].__node

	__report_props: ->
		result = {}
		for key of this
			result[key] = this[key]  if @hasOwnProperty(key)
		console.log @nombre, result

	__inherit_props: (ancestor) ->
		if ancestor
			for key of ancestor
				this[key] = ancestor[key]  if ["__args", "__parsed", "__template"].indexOf(key) is -1  unless typeof ancestor[key] is "function"  if ancestor.hasOwnProperty(key)
	__note_args: (args) ->
		@__args = Array::slice.call(args)
		#console.log args
		@__template = @__args[0]
		@__args = @__args.slice(1, @__args.length + 1)
		console.log "__args:", @__args

	attach_to: (el) ->
		el.appendChild @__frag

	__resolve_symbol: (token) ->
		return token  if typeof token is "string"
		return token.value  if token.type is "symbol"
		return token  if token.type is "text"
		if token.type is "arg"
			if @__args[parseInt(token.value) - 1]
				type: "text"
				value: @__args[parseInt(token.value) - 1]

	__construct_frag: (me, obj, h) ->
		head = h
		token = obj
		if token.type is "assign"
			#console.log "assign", token
			#f = document.createDocumentFragment()
			me.__construct_frag me, token.right, h
			me.__add_symbol me.__resolve_symbol(token.left), h
			head
		else if token.type is "statement"
			head = me.__frag
			#console.log "statement", token
			me.__construct_frag me, token.value, h
			head
		else if token.type is "chain"
			me.__construct_frag me, token.value, head
			head
		else if token.type is "arg"
			#console.log "arg", token
			if @__args[parseInt(token.value) - 1]
				text = document.createTextNode(@__args[parseInt(token.value) - 1])
				head.appendChild text
			head
		else if token.type is "text"
			text = document.createTextNode(token.value)
			head.appendChild text
			head
		else if token.type is "element"
			tag = me.__resolve_symbol(token.tag)
			#console.log "element", tag
			#if me[tag]
			#	el = me[tag].cloneNode(true)
			if false

			else
				el = document.createElement(tag)
				el.id = me.__resolve_symbol(token.id)  if token.id
				el.className = token.classes.join(" ")  if token.classes
				#head.namespace = {}  unless head.namespace
				#head.namespace[me.__resolve_symbol(token.label)] = el  if token.label
				if token.json
					for key of token.json
						v = me.__resolve_symbol(token.json[key])
						el.setAttribute key, v
			me.__register head, el
			head.appendChild el
			#we use a number for generic children in the tree
			@__scope = @__scope.concat(head.childNodes.length-1)
			el
		else if token.type is "set"
			#console.log "set"
			i = 0
			while i < token.value.length
				t = token.value[i]
				me.__construct_frag me, t, head
				i++
			head
		else if typeof obj is "object" and obj.length > 0
			hh = head
			i = 0
			while i < obj.length
				token = obj[i]
				b = me.__construct_frag(me, token, hh)
				hh = b
				i++

	__parse: (me) ->
		template = me.__template
		i = 0
		while i < @__args.length
			regex = new RegExp("%" + (i + 1), "gi")
			arg = @__args[i]
			if typeof arg is "string"
				arg = "\"" + arg + "\""
			else if arg instanceof Array
				arg = arg.join(", ")
				arg = "[" + arg + "]"  if arg.length > 1
			else if typeof arg is "object"
				set = []
				c = 0
				for key of arg
					c += 1
					set.push key
				arg = set.join(", ")
				arg = "[" + arg + "]"  if set.length > 1
			template = template.replace(regex, arg)
			i++
		#console.log template
		me.__parsed = window.peg.parse(template)

links = [
	title: "Rolling Your Own"
	file: "roll_your_own"
,
	title: "PongScript"
	file: "pongscript"
,
	title: "Hello World"
	file: "hello"
]
links = links.map((part) ->
	icon = "./img/icon1.png"
	"li/a{href:'./posts/" + part.file + ".html'}/[ img{src:'" + icon + "'}, span:text.name/'" + part.title + "']"
)
#console.log links
view = new _("div:main#%1/h1/'Hello..'", "wrapper")
view.nombre = "Joseph Parker"
view = view("thing = div/p")

#view = view("pagelink = li/a#%1{href:'./blog.html'}/[ img{src:%2}, span:text.name/'link']", {symbolic:0}, "./img/icon1.png");
view = view("pagelist = ul:pagelist#pages/%1", links)
view = view("sidebar = div:sidebar#sidebar/[div:logo.logo,  pagelist]")
view = view("post=[h1/'Rolling your own html templates', h3.author/['Author: ', %2], code.date/['Date:', %1], p/ \"After a year of developing a single page web app with only jQuery, I'm hyper aware of the pain points that come with vanilla js/html/css interaction.  I'd put off investigating the popular MVC frameworks, but after looking them over I decided to write my own components to ease the workflow. \", p.right/%3/['- ', %2] ]", "Sun Aug 04 2013", view.nombre,
	i: 0
)
view = view("project = div:main#wrapper/[sidebar, div:blog#blog/post]")
body.appendChild view.project
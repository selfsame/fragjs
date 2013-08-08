


Frag = (args...)->
	if not args[0]?.__fragment__?
		instance = (args...)->
			Array.prototype.splice.call(arguments, 0,0, instance)
			return Frag.apply(Frag, arguments)
		FragConstructor.apply(instance)
	else
		instance = args[0]
		Array.prototype.shift.call(arguments, 1)

	console.log arguments
	instance.__parse.apply(instance, arguments)
	return instance

FragConstructor = ()->
	@__fragment__ = true
	@__root = document.createDocumentFragment()
	@__root.__namespace = {}
	@__scope = @__root
	

	@__parse = (args...) ->
		console.log "parse!"
		template = args[0]
		console.log template
		i = 1
		while i < args.length
			regex = new RegExp("%" + (i + 1), "gi")
			arg = args[i]
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
		@__parsed = window.peg.parse(template)
		console.log template
		console.log @__parsed

		@__construct_frag(@__parsed, @__root)



	@attach_to = (el) ->
		el.appendChild @__root.childNodes[0].cloneNode()

	@__resolve_symbol = (token) ->
		return token  if typeof token is "string"
		return token.value  if token.type is "symbol"
		return token.value  if token.type is "text"
		if token.type is "arg"
			if @__args[parseInt(token.value) - 1]
				return @__args[parseInt(token.value) - 1]


	@__construct_frag = (token, head) ->
		console.log 'construct', token, head
		if token instanceof Array
			for line in token
				head = @__construct_frag line, head
			head
		else if token.type is "assign"
			#f = document.createDocumentFragment()
			@__construct_frag token.right, head
			#@__add_symbol @.__root, @.__resolve_symbol(token.left), f
			head
		else if token.type is "statement"
			hh= @__root
			#console.log "statement", token
			@__construct_frag token.value, hh
			hh
		else if token.type is "chain"
			@__construct_frag token.parts, head
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
			tag = @__resolve_symbol(token.tag)
			#assignments are in the top namespace for now
			if @__root.__namespace[tag]
				el = @__root.__namespace[tag].cloneNode(true)
			else
				el = document.createElement(tag)
				el.id = @__resolve_symbol(token.id)  if token.id
				if token.classes
					total = []
					for c in token.classes
						total.push @__resolve_symbol(c)
					el.className = total.join(" ")  

				if token.json
					for key of token.json
						v = @__resolve_symbol(token.json[key])
						el.setAttribute key, v
				if token.label
					console.log 'label: ', token.label
					#@__add_symbol head, @__resolve_symbol(token.label), el
			head.appendChild el
			el

		else if typeof token is "object" and token.length > 0
			hh = head
			i = 0
			while i < token.length
				token = token[i]
				b = @__construct_frag( token, hh)
				hh = b
				i++


new_font = """
widget = div.new_font
	label.name
		"family name"
		input:family.name
	label.name
		"script url"
		textarea:script.script
	button:done.float_right {disabled:true}/"done"
	button:cancel.float_right/"cancel"
	hr 
"""
#body = document.getElementsByTagName("body")[0]
#view = Frag(new_font)
#view.attach_to(body)


###	




















_ = (args...)->
	fn = (args...)->
			#console.log(Array.prototype.slice.call(arguments));
		args = Array::slice.call(args)
		console.log args
		_.old = fn
		result = new _(args)
		result.__setup args
		result
		#fn.__proto__ = fn.prototype = _.prototype;
	fn:: = fn.__proto__ = _::
	fn.attach_to = fn::attach_to
	#fn.__add_binding = fn::__add_symbol
	fn.nombre = 'fn'
	fn.__inherit_props _.old

	unless fn.__root
		
		fn.__root = document.createDocumentFragment()
		fn.__root.__namespace = {}
		fn.__scope = fn.__root
	_.old = false


		#fn.__note_args(arguments);
	#fn.__setup(args);
	fn

_:: =
	old: false
	constructor: ->
		this
	nombre: "prototype"



	__return_proxy: (master) ->
		proxy = (args...)->
			fn = (args...)->
				return new proxy(args)
			fn.master = master
			fn.__root = master.__scope
			
			return fn
		return proxy()

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

	__add_symbol: (scope, symbol, node) ->
		console.log "add_symbol: ", scope, symbol, node
		if scope?
			if !scope.__namespace
				scope.__namespace = {}
		scope.__namespace[symbol] = node
		console.log "@:", console.dir(@), @.nombre

		@__property symbol,
			get: ->
				console.log "getter ", symbol, "()"
				if not @__scope.__namespace
					@__scope.__namespace = {}
				if @__scope.__namespace[symbol]
					@__scope = @__scope.__namespace[symbol]
				else if @__root.__namespace[symbol]
					@__scope = @__root.__namespace[symbol]
				return @__scope #@__return_proxy(@)


	__property: (prop, desc) ->
		@[prop] = "temp"
		console.log '__property', console.dir(@)
		try
			Object.defineProperty @, prop, desc
		catch error
			console.log "cant define getter for ", prop

	__setup: (args) ->
		@__note_args args
		@__parse @
		@__construct_frag @, @__parsed, @__root

	__report_props: ->
		result = {}
		for key of this
			result[key] = this[key]  if @hasOwnProperty(key)
		console.log @nombre, result

	__inherit_props: (ancestor) ->
		if ancestor
			for key of ancestor
				console.log 'inherit key: ', key
				@[key] = ancestor[key]  

	__note_args: (args) ->
		@__args = Array::slice.call(args)
		#console.log args
		@__template = @__args[0]
		@__args = @__args.slice(1, @__args.length + 1)
		console.log "__args:", @__args

	attach_to: (el) ->
		el.appendChild @__scope

	__resolve_symbol: (token) ->
		return token  if typeof token is "string"
		return token.value  if token.type is "symbol"
		return token.value  if token.type is "text"
		if token.type is "arg"
			if @__args[parseInt(token.value) - 1]
				return @__args[parseInt(token.value) - 1]


	__construct_frag: (me, obj, h) ->
		head = h
		token = obj
		if token instanceof Array
			for line in token
				me.__construct_frag me, line, h
		else if token.type is "assign"
			#console.log "assign", token
			f = document.createDocumentFragment()
			me.__construct_frag me, token.right, f
			me.__add_symbol me.__root, me.__resolve_symbol(token.left), f
			head
		else if token.type is "statement"
			hh= me.__root
			#console.log "statement", token
			me.__construct_frag me, token.value, hh
			hh
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
			#assignments are in the top namespace for now
			if @__root.__namespace[tag]
				el = @__root.__namespace[tag].cloneNode(true)
			else
				el = document.createElement(tag)
				el.id = me.__resolve_symbol(token.id)  if token.id
				if token.classes
					total = []
					for c in token.classes
						total.push me.__resolve_symbol(c)
					el.className = total.join(" ")  

				if token.json
					for key of token.json
						v = me.__resolve_symbol(token.json[key])
						el.setAttribute key, v
				if token.label
					console.log 'label: ', token.label
					@__add_symbol head, me.__resolve_symbol(token.label), el
			#me.__register head, el
			head.appendChild el
			#we use a number for generic children in the tree

			el

		else if typeof obj is "object" and obj.length > 0
			hh = head
			i = 0
			while i < obj.length
				token = obj[i]
				b = me.__construct_frag(me, token, hh)
				hh = b
				i++

	__parse: (me) ->
		console.log "parse!"
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
		console.log template
		console.log me.__parsed

body = document.getElementsByTagName("body")[0]

new_font = """
new_font = div.new_font
	label.name
		"family name"
		input:family.name
	label.name
		"script url"
		textarea:script.script
	button:done.float_right {disabled:true}/"done"
	button:cancel.float_right/"cancel"
	hr 
"""

view = new _("div")
view = view(new_font)


body.appendChild(view.__root)
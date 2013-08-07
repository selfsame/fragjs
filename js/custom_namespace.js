// Generated by CoffeeScript 1.3.3
var body, links, view, _,
  __slice = [].slice;

body = document.getElementsByTagName("body")[0];

_ = function() {
  var args, fn, __frag;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  fn = function() {
    var args, result;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    args = Array.prototype.slice.call(args);
    console.log(args);
    _.old = fn;
    result = new _();
    result.__setup(args);
    return result;
  };
  fn.prototype = fn.__proto__ = _.prototype;
  fn.attach_to = fn.prototype.attach_to;
  fn.nombre = "pancho";
  fn.__inherit_props(_.old);
  if (!fn.__namespace) {
    fn.__namespace = {};
    fn.__scope = [];
    __frag = document.createDocumentFragment();
    fn.__add_symbol("__frag", __frag);
    fn.__frag;
  }
  _.old = false;
  return fn;
};

_.prototype = {
  old: false,
  constructor: function() {
    return this;
  },
  nombre: "prototype",
  __set_scope: function(scope) {
    console.log("setting scope: ", scope);
    return this.__scope = scope;
  },
  __scope_to_namespace: function(scope) {
    var i, part, target;
    console.log("__scope_to_namespace", scope);
    target = this.__namespace;
    i = 0;
    while (i < scope.length) {
      part = scope[i];
      if (typeof part === 'number') {
        if (target.__children) {
          target = target.__children[part];
        }
      } else if (target[part]) {
        target = target[part];
      } else {
        return undefined;
      }
      i++;
    }
    console.log(target);
    return target;
  },
  __add_symbol: function(symbol, value) {
    var getter, namespace, target_scope;
    namespace = this.__scope_to_namespace(this.__scope);
    console.log("add_symbol", namespace, this.__scope);
    namespace[symbol] = {
      __node: value
    };
    target_scope = this.__scope.concat(symbol);
    getter = {};
    getter[symbol] = {
      get: function() {
        return this.__set_scope(target_scope);
      }
    };
    console.log(getter);
    return Object.defineProperties(this, getter);
  },
  __register: function(head, el) {
    var namespace;
    namespace = this.__scope_to_namespace(this.__scope);
    if (!namespace) {
      console.log("namespace error: ", this.__scope);
      return;
    }
    if (!namespace.__children) {
      namespace.__children = [];
    }
    console.log('register', namespace);
    return namespace.__children = namespace.__children.concat(el);
  },
  __setup: function(args) {
    this.__note_args(args);
    this.__parse(this);
    return this.__construct_frag(this, this.__parsed, this.__namespace['__frag'].__node);
  },
  __report_props: function() {
    var key, result;
    result = {};
    for (key in this) {
      if (this.hasOwnProperty(key)) {
        result[key] = this[key];
      }
    }
    return console.log(this.nombre, result);
  },
  __inherit_props: function(ancestor) {
    var key, _results;
    if (ancestor) {
      _results = [];
      for (key in ancestor) {
        if (!(ancestor.hasOwnProperty(key) ? typeof ancestor[key] === "function" : void 0) ? ["__args", "__parsed", "__template"].indexOf(key) === -1 : void 0) {
          _results.push(this[key] = ancestor[key]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  },
  __note_args: function(args) {
    this.__args = Array.prototype.slice.call(args);
    this.__template = this.__args[0];
    this.__args = this.__args.slice(1, this.__args.length + 1);
    return console.log("__args:", this.__args);
  },
  attach_to: function(el) {
    return el.appendChild(this.__frag);
  },
  __resolve_symbol: function(token) {
    if (typeof token === "string") {
      return token;
    }
    if (token.type === "symbol") {
      return token.value;
    }
    if (token.type === "text") {
      return token;
    }
    if (token.type === "arg") {
      if (this.__args[parseInt(token.value) - 1]) {
        return {
          type: "text",
          value: this.__args[parseInt(token.value) - 1]
        };
      }
    }
  },
  __construct_frag: function(me, obj, h) {
    var b, el, head, hh, i, key, t, tag, text, token, v, _results;
    head = h;
    token = obj;
    if (token.type === "assign") {
      me.__construct_frag(me, token.right, h);
      me.__add_symbol(me.__resolve_symbol(token.left), h);
      return head;
    } else if (token.type === "statement") {
      head = me.__frag;
      me.__construct_frag(me, token.value, h);
      return head;
    } else if (token.type === "chain") {
      me.__construct_frag(me, token.value, head);
      return head;
    } else if (token.type === "arg") {
      if (this.__args[parseInt(token.value) - 1]) {
        text = document.createTextNode(this.__args[parseInt(token.value) - 1]);
        head.appendChild(text);
      }
      return head;
    } else if (token.type === "text") {
      text = document.createTextNode(token.value);
      head.appendChild(text);
      return head;
    } else if (token.type === "element") {
      tag = me.__resolve_symbol(token.tag);
      if (false) {

      } else {
        el = document.createElement(tag);
        if (token.id) {
          el.id = me.__resolve_symbol(token.id);
        }
        if (token.classes) {
          el.className = token.classes.join(" ");
        }
        if (token.json) {
          for (key in token.json) {
            v = me.__resolve_symbol(token.json[key]);
            el.setAttribute(key, v);
          }
        }
      }
      me.__register(head, el);
      head.appendChild(el);
      this.__scope = this.__scope.concat(head.childNodes.length - 1);
      return el;
    } else if (token.type === "set") {
      i = 0;
      while (i < token.value.length) {
        t = token.value[i];
        me.__construct_frag(me, t, head);
        i++;
      }
      return head;
    } else if (typeof obj === "object" && obj.length > 0) {
      hh = head;
      i = 0;
      _results = [];
      while (i < obj.length) {
        token = obj[i];
        b = me.__construct_frag(me, token, hh);
        hh = b;
        _results.push(i++);
      }
      return _results;
    }
  },
  __parse: function(me) {
    var arg, c, i, key, regex, set, template;
    template = me.__template;
    i = 0;
    while (i < this.__args.length) {
      regex = new RegExp("%" + (i + 1), "gi");
      arg = this.__args[i];
      if (typeof arg === "string") {
        arg = "\"" + arg + "\"";
      } else if (arg instanceof Array) {
        arg = arg.join(", ");
        if (arg.length > 1) {
          arg = "[" + arg + "]";
        }
      } else if (typeof arg === "object") {
        set = [];
        c = 0;
        for (key in arg) {
          c += 1;
          set.push(key);
        }
        arg = set.join(", ");
        if (set.length > 1) {
          arg = "[" + arg + "]";
        }
      }
      template = template.replace(regex, arg);
      i++;
    }
    return me.__parsed = window.peg.parse(template);
  }
};

links = [
  {
    title: "Rolling Your Own",
    file: "roll_your_own"
  }, {
    title: "PongScript",
    file: "pongscript"
  }, {
    title: "Hello World",
    file: "hello"
  }
];

links = links.map(function(part) {
  var icon;
  icon = "./img/icon1.png";
  return "li/a{href:'./posts/" + part.file + ".html'}/[ img{src:'" + icon + "'}, span:text.name/'" + part.title + "']";
});

view = new _("div:main#%1/h1/'Hello..'", "wrapper");

view.nombre = "Joseph Parker";

view = view("thing = div/p");

view = view("pagelist = ul:pagelist#pages/%1", links);

view = view("sidebar = div:sidebar#sidebar/[div:logo.logo,  pagelist]");

view = view("post=[h1/'Rolling your own html templates', h3.author/['Author: ', %2], code.date/['Date:', %1], p/ \"After a year of developing a single page web app with only jQuery, I'm hyper aware of the pain points that come with vanilla js/html/css interaction.  I'd put off investigating the popular MVC frameworks, but after looking them over I decided to write my own components to ease the workflow. \", p.right/%3/['- ', %2] ]", "Sun Aug 04 2013", view.nombre, {
  i: 0
});

view = view("project = div:main#wrapper/[sidebar, div:blog#blog/post]");

body.appendChild(view.project);

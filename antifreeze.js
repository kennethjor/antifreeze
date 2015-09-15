/*!   - MIT license */
(function() {
  var Antifreeze, Async, Calamity, Crossroads, DeckView, Discrete, Hasher, HelperBroker, ObjectUtil, Presenter, Rivets, RivetsHelper, Route, Router, RoutingPresenter, View, exports, helpers, initBroker, root, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = this;

  if (typeof require === "function") {
    _ = require("underscore");
    Calamity = require("calamity");
    Discrete = require("discrete");
    Rivets = require("rivets");
    if (this.window != null) {
      Hasher = require("hasher");
    }
    Crossroads = require("crossroads");
    Async = require("async");
  } else {
    if (typeof root._ !== "function") {
      throw new Error("Failed to load underscore from global namespace");
    }
    _ = root._;
    if (typeof root.Calamity !== "object") {
      throw new Error("Failed to load Calamity from global namespace");
    }
    Calamity = root.Calamity;
    if (typeof root.Discrete !== "object") {
      throw new Error("Failed to load Discrete from global namespace");
    }
    Discrete = root.Discrete;
    if (typeof root.rivets !== "object") {
      throw new Error("Failed to load Rivets from global namespace");
    }
    Rivets = root.rivets;
    if (typeof root.hasher !== "object") {
      throw new Error("Failed to load Hasher from global namespace");
    }
    if (this.window != null) {
      Hasher = root.hasher;
    }
    if (typeof root.crossroads !== "object") {
      throw new Error("Failed to load Crossroads from global namespace");
    }
    Crossroads = root.crossroads;
    if (typeof root.async !== "object") {
      throw new Error("Failed to load Async from global namespace");
    }
    Async = root.async;
  }

  if (typeof root._ === "undefined" && typeof require === "function") {
    _ = require("underscore");
  }

  if (typeof root.Calamity === "undefined" && typeof require === "function") {
    Calamity = require("calamity");
  }

  Antifreeze = {
    version: ""
  };

  if (typeof exports !== "undefined") {
    exports = Antifreeze;
  } else if (typeof module !== "undefined" && module.exports) {
    module.exports = Antifreeze;
  } else if (typeof define === "function" && define.amd) {
    define(["underscore", "calamity", "discrete", "rivets", "hasher", "crossroads", "async"], Antifreeze);
  } else {
    root["Antifreeze"] = Antifreeze;
  }

  Antifreeze.ObjectUtil = ObjectUtil = {
    configure: function(obj, options, keys) {
      var key, val;
      if (keys) {
        options = _.pick(options, keys);
      }
      for (key in options) {
        if (!__hasProp.call(options, key)) continue;
        val = options[key];
        if (val === void 0) {
          continue;
        }
        if (_.isFunction(obj[key])) {
          obj[key].call(obj, val);
        } else {
          obj[key] = val;
        }
      }
    }
  };

  Antifreeze.HelperBroker = HelperBroker = (function() {
    function HelperBroker(view) {
      initBroker(this, view);
    }

    return HelperBroker;

  })();

  helpers = {};

  HelperBroker.add = function(name, helper) {
    helpers[name] = helper;
    return this;
  };

  initBroker = function(broker, view) {
    var context, helper, name, subHelper, subName;
    for (name in helpers) {
      if (!__hasProp.call(helpers, name)) continue;
      helper = helpers[name];
      if (helper === void 0) {
        continue;
      }
      context = {
        view: view
      };
      if (_.isFunction(helper)) {
        broker[name] = _.bind(helper, context);
      } else if (_.isObject(helper)) {
        broker[name] = {};
      } else {
        throw new Error("Helper must be either function or object, " + typeof helper + " supplied");
      }
      context.helper = broker[name];
      if (_.isEmpty(helper)) {
        continue;
      }
      for (subName in helper) {
        if (!__hasProp.call(helper, subName)) continue;
        subHelper = helper[subName];
        if (typeof subHelper !== "function") {
          continue;
        }
        broker[name][subName] = _.bind(subHelper, context);
      }
    }
    return void 0;
  };

  HelperBroker.getForView = function(view) {
    return new HelperBroker(view);
  };

  Rivets.configure({
    adapter: {
      subscribe: function(obj, keypath, callback) {
        obj.on("change:" + keypath, function() {
          var val;
          val = obj.get(keypath);
          return callback(val);
        });
        return void 0;
      },
      unsubscribe: function(obj, keypath, callback) {
        obj.off("change:" + keypath, callback);
        return void 0;
      },
      read: function(obj, keypath) {
        return obj.get(keypath);
      },
      publish: function(obj, keypath, value) {
        obj.set(keypath, value);
        return void 0;
      }
    }
  });

  RivetsHelper = Antifreeze.RivetsHelper = {
    bind: function() {
      var convertData, data, view;
      view = this.view;
      convertData = this.helper.convertData;
      data = convertData(view.model());
      if (this.rivetsView) {
        this.rivetsView.unbind();
      }
      return this.rivetsView = Rivets.bind(view.element(), data);
    },
    convertData: function(model) {
      var data, k, _i, _len, _ref;
      if (!(model instanceof Discrete.Model)) {
        throw new Error("Model must be a Model");
      }
      data = {};
      _ref = model.keys();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        data[k] = model.get(k);
      }
      return data;
    }
  };

  Antifreeze.View = View = (function() {
    var classOptions;

    Calamity.emitter(View.prototype);

    classOptions = "tagName,className,model,element".split(",");

    View.prototype.tagName = "div";

    function View(options) {
      options || (options = {});
      if (options.$ != null) {
        this.$ = options.$;
      } else if (this.$) {

      } else {
        if (typeof $ === "undefined" || !_.isFunction($)) {
          throw new Error("jQuery not found");
        }
        this.$ = $;
      }
      ObjectUtil.configure(this, options || {}, classOptions);
      this.helpers = new HelperBroker(this);
      this._views = {};
      this._renderScheduled = false;
      this.init();
    }

    View.prototype.init = function() {};

    View.prototype._render = function() {
      return this.element().html(this._callTemplate());
    };

    View.prototype.model = function(model) {
      if (model) {
        if (_.isObject(model) && model instanceof Discrete.Model !== true) {
          model = new Discrete.Model(model);
        }
        if (model !== this._model) {
          this.trigger("newModel");
        }
        this._model = model;
        return;
      }
      return this._model;
    };

    View.prototype.element = function(element) {
      if (element) {
        if (element !== this._element) {
          this.trigger("newElement");
        }
        if (!element.jquery) {
          element = this.$(element);
        }
        this._element = element;
        return;
      }
      if (!this._element) {
        element = this.make(this.tagName, {
          "class": this.className
        });
        this.element(element);
      }
      return this._element;
    };

    View.prototype.make = function(tag, attributes, content) {
      var $element;
      if (tag == null) {
        tag = "div";
      }
      $element = this.$("<" + tag + "></" + tag + ">");
      if (_.isObject(attributes)) {
        $element.attr(attributes);
      }
      if (content) {
        if (_.isString(content)) {
          $element.html(content);
        }
        if (content.jquery) {
          $element.append(content);
        }
      }
      return $element;
    };

    View.prototype.proxyDomEvent = function(selector, domEvent, viewEvent, callback) {
      var $el, bound, handler;
      $el = selector;
      if (!$el.jquery) {
        $el = this.element().find(selector);
      }
      if ($el.length === 0) {
        return false;
      }
      handler = function(domEvent) {
        var data;
        data = {
          view: this
        };
        if (_.isFunction(callback)) {
          data = callback(data);
        }
        return this.trigger(viewEvent, data);
      };
      bound = _.bind(handler, this);
      $el[domEvent](bound);
      return $el;
    };

    View.prototype.render = function() {
      var _this = this;
      if (this._renderScheduled) {
        return;
      }
      this._renderScheduled = true;
      _.defer(function() {
        return _this.trigger("beforeRender");
      });
      _.defer(function() {
        return _this._render();
      });
      _.defer(function() {
        return _this.trigger("afterRender");
      });
      _.defer(function() {
        return _this._renderScheduled = false;
      });
    };

    View.prototype._callTemplate = function() {
      var boundTemplate, data, html, template;
      template = this.template;
      if (!_.isFunction(template)) {
        return void 0;
      }
      data = this._getTemplateData();
      boundTemplate = _.bind(template, this);
      html = boundTemplate(data);
      return html;
    };

    View.prototype._getTemplateData = function() {
      var data;
      data = this.model() || {};
      if (_.isFunction(data.toJSON)) {
        data = data.toJSON();
      }
      return data;
    };

    View.prototype.add = function(name, view) {
      this._views[name] = view;
      view.hide();
      return this;
    };

    View.prototype.has = function(name) {
      return _.has(this._views, name);
    };

    View.prototype.get = function(name) {
      return this._views[name];
    };

    View.prototype.hide = function() {
      return this.element().hide();
    };

    View.prototype.show = function() {
      return this.element().show();
    };

    return View;

  })();

  Antifreeze.DeckView = DeckView = (function(_super) {
    __extends(DeckView, _super);

    function DeckView() {
      _ref = DeckView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DeckView.prototype.init = function() {
      return this.model().on("change:page", _.bind(this._pageChange, this));
    };

    DeckView.prototype.add = function(name, view) {
      DeckView.__super__.add.apply(this, arguments);
      this.element().append(view.element());
      view.hide();
      if (name === this.model().get("page")) {
        view.render();
        return view.show();
      }
    };

    DeckView.prototype._pageChange = function(event) {
      var name, page, view, _ref1, _results;
      page = event.data.value;
      _ref1 = this._views;
      _results = [];
      for (name in _ref1) {
        if (!__hasProp.call(_ref1, name)) continue;
        view = _ref1[name];
        if (name === page) {
          view.render();
          _results.push(view.show());
        } else {
          _results.push(view.hide());
        }
      }
      return _results;
    };

    return DeckView;

  })(View);

  Antifreeze.Presenter = Presenter = (function() {
    var classOptions;

    Calamity.emitter(Presenter.prototype);

    Calamity.proxy(Presenter.prototype);

    classOptions = "view,model,element".split(",");

    function Presenter(options) {
      options || (options = {});
      ObjectUtil.configure(this, options || {}, classOptions);
      if (!options.view) {
        throw new Error("No view provided");
      }
      this._presenters = {};
      this.init();
    }

    Presenter.prototype.init = function() {};

    Presenter.prototype.model = function(model) {
      if (model) {
        if (_.isObject(model) && model instanceof Discrete.Model !== true) {
          model = new Discrete.Model(model);
        }
        this._model = model;
        if (this._view) {
          this._view.model(model);
        }
        return;
      }
      if (!this._model) {
        this.model({});
      }
      return this._model;
    };

    Presenter.prototype.view = function(view) {
      var name, options, _ref1;
      if (view) {
        if (!_.isFunction(view)) {
          throw new Error("View must be a constructor.");
        }
        this._viewConstructor = view;
        this._view = void 0;
        return;
      } else {
        if (!this._view) {
          this._view = new this._viewConstructor({
            model: this.model(),
            element: this.element
          });
          _ref1 = this._presenters;
          for (name in _ref1) {
            if (!__hasProp.call(_ref1, name)) continue;
            options = _ref1[name];
            this._view.add(name, options.presenter.view());
          }
        }
      }
      return this._view;
    };

    Presenter.prototype.onViewEvent = function(event, callback) {
      return this.view().on(event, _.bind(callback, this));
    };

    Presenter.prototype.add = function(name, options) {
      var presenter;
      options || (options = {});
      if (options instanceof Presenter) {
        options = {
          presenter: options
        };
      }
      presenter = options.presenter;
      if (!presenter) {
        throw new Error("Presenter not supplied");
      }
      this._presenters[name] = options;
      if (this._view) {
        this._view.add(name, presenter.view());
      }
      this.trigger("presenterAdded", {
        name: name,
        options: options,
        presenter: presenter
      });
      return this;
    };

    Presenter.prototype.has = function(name) {
      return _.has(this._presenters, name);
    };

    Presenter.prototype.get = function(name) {
      return this._presenters[name];
    };

    return Presenter;

  })();

  Antifreeze.RoutingPresenter = RoutingPresenter = (function(_super) {
    __extends(RoutingPresenter, _super);

    function RoutingPresenter() {
      this.on("presenterAdded", function(event) {
        var data, name, options, presenter, route,
          _this = this;
        data = event.data;
        name = data.name;
        presenter = data.presenter;
        options = data.options;
        route = options.route;
        if (!route) {
          return;
        }
        return route.on("routed", (function(name, presenter) {
          return function(event) {
            var params;
            params = event.data.namedParams;
            _this.model().set({
              page: name
            });
            return presenter.model().set(params);
          };
        })(name, presenter));
      });
      RoutingPresenter.__super__.constructor.apply(this, arguments);
    }

    return RoutingPresenter;

  })(Presenter);

  Antifreeze.Router = Router = (function() {
    Calamity.emitter(Router.prototype);

    function Router() {
      this._attached = false;
      this._routes = [];
      this._crossroads = Crossroads.create();
      this._crossroads.routed.add(_.bind(this._crossroadsRouted, this));
      this.initRoutes();
    }

    Router.prototype.initRoutes = function() {};

    Router.prototype.add = function(pattern, options) {
      var crossroadsRoute, route;
      options || (options = {});
      route = null;
      if (pattern instanceof Route) {
        route = pattern;
        pattern = route.pattern;
      } else {
        route = new Route(pattern);
      }
      crossroadsRoute = this._crossroads.addRoute(pattern);
      route._crossroads = crossroadsRoute;
      route._paramIds = this._crossroads.patternLexer.getParamIds(pattern);
      this._routes.push(route);
      return route;
    };

    Router.prototype._crossroadsRouted = function(hash, event) {
      var crossroadsRoute, namedParams, params, r, route, _i, _len, _ref1;
      params = event.params;
      crossroadsRoute = event.route;
      route = null;
      _ref1 = this._routes;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        r = _ref1[_i];
        if (crossroadsRoute === r._crossroads) {
          route = r;
          break;
        }
      }
      if (route === null) {
        return;
      }
      namedParams = _.object(route._paramIds, params);
      event = {
        hash: hash,
        router: this,
        route: route,
        params: params,
        namedParams: namedParams
      };
      this.trigger("routed", event);
      route.trigger("routed", event);
    };

    Router.prototype.attach = function() {
      var crossroads, parseHash;
      if (this._attached) {
        return;
      }
      crossroads = this._crossroads;
      parseHash = function(hash) {
        return crossroads.parse(hash);
      };
      Hasher.initialized.add(parseHash);
      Hasher.changed.add(parseHash);
      Hasher.init();
      this._attached = true;
    };

    return Router;

  })();

  Antifreeze.Route = Route = (function() {
    Calamity.emitter(Route.prototype);

    function Route(pattern, options) {
      this.pattern = pattern;
      this.options = options;
      this.options || (this.options = {});
      if (!_.isString(this.pattern)) {
        throw new Error("Pattern must be a string, " + (typeof this.pattern) + " supplied");
      }
    }

    return Route;

  })();

}).call(this);

/*
//@ sourceMappingURL=antifreeze.js.map
*/
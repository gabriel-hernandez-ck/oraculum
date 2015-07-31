(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented-method'], function(Oraculum) {
    'use strict';
    var _;
    _ = Oraculum.get('underscore');
    return Oraculum.defineMixin('Subview.ViewMixin', {
      mixinOptions: {
        eventedMethods: {
          render: {}
        }
      },
      mixconfig: function(mixinOptions, arg) {
        var subviews;
        subviews = (arg != null ? arg : {}).subviews;
        return mixinOptions.subviews = Oraculum.composeConfig(mixinOptions.subviews, subviews);
      },
      mixinitialize: function() {
        this._subviews = [];
        this._subviewsByName = {};
        this.on('render:after', (function(_this) {
          return function() {
            return _this.createSubviews();
          };
        })(this));
        return this.on('dispose', (function(_this) {
          return function() {
            return _.each(_this._subviews, function(view) {
              return typeof view.dispose === "function" ? view.dispose() : void 0;
            });
          };
        })(this));
      },
      createSubviews: function() {
        var mutableSubviews, subviews;
        subviews = this.mixinOptions.subviews;
        if (_.isFunction(subviews)) {
          subviews = subviews.call(this);
        }
        mutableSubviews = _.clone(subviews);
        this._createDOMSubviews(mutableSubviews);
        this._createDOMContainerSubviews(mutableSubviews);
        return _.each(mutableSubviews, (function(_this) {
          return function(spec, name) {
            return _this.createSubview(name, spec);
          };
        })(this));
      },
      _createDOMSubviews: function(mutableSubviews) {
        var subviewElements;
        subviewElements = this.$('[data-subview]');
        return _.each(subviewElements, (function(_this) {
          return function(el) {
            var name, spec, viewOptions;
            name = el.getAttribute('data-subview');
            spec = mutableSubviews[name];
            viewOptions = _.extend({}, spec.viewOptions, {
              el: el
            });
            _this.createSubview(name, _.extend({}, spec, {
              viewOptions: viewOptions
            }));
            return delete mutableSubviews[name];
          };
        })(this));
      },
      _createDOMContainerSubviews: function(mutableSubviews) {
        var subviewElements;
        subviewElements = this.$('[data-subview-container]');
        return _.each(subviewElements, (function(_this) {
          return function(container) {
            var name, spec, viewOptions;
            name = container.getAttribute('data-subview-container');
            spec = mutableSubviews[name];
            viewOptions = _.extend({}, spec.viewOptions, {
              container: container
            });
            _this.createSubview(name, _.extend({}, spec, {
              viewOptions: viewOptions
            }));
            return delete mutableSubviews[name];
          };
        })(this));
      },
      createSubview: function(name, spec) {
        return this.subview(name, this.createView(spec));
      },
      createView: function(spec) {
        var viewOptions;
        if (_.isFunction(spec)) {
          spec = spec.call(this);
        }
        viewOptions = _.extend({}, spec.viewOptions);
        if (_.isString(spec.view)) {
          return this.__factory().get(spec.view, viewOptions);
        } else {
          return new spec.view(viewOptions);
        }
      },
      subview: function(name, view) {
        if (!view) {
          return this._resolveSubview(name).view;
        }
        this.removeSubview(name);
        this._subviews.push(view);
        this._subviewsByName[name] = view;
        this.trigger('subviewCreated', view, this);
        return view;
      },
      removeSubview: function(nameOrView, dispose) {
        var name, ref, view;
        if (dispose == null) {
          dispose = true;
        }
        ref = this._resolveSubview(nameOrView), name = ref.name, view = ref.view;
        if (!(name && view)) {
          return;
        }
        view.remove();
        if (dispose) {
          return this.disposeSubview(nameOrView);
        }
      },
      disposeSubview: function(nameOrView) {
        var index, name, ref, view;
        ref = this._resolveSubview(nameOrView), name = ref.name, view = ref.view;
        if (!(name && view)) {
          return;
        }
        if (typeof view.dispose === "function") {
          view.dispose();
        }
        index = this._subviews.indexOf(view);
        if (index !== -1) {
          this._subviews.splice(index, 1);
        }
        return delete this._subviewsByName[name];
      },
      _resolveSubview: function(name) {
        var otherView, ref, view;
        view = _.isString(name) ? this._subviewsByName[name] : name;
        if (_.isString(name)) {
          return {
            name: name,
            view: view
          };
        }
        ref = this._subviewsByName;
        for (name in ref) {
          otherView = ref[name];
          if (view === otherView) {
            return {
              name: name,
              view: view
            };
          }
        }
      }
    }, {
      mixins: ['EventedMethod.Mixin']
    });
  });

}).call(this);

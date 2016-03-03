(function() {
  var slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented'], function(oraculum) {
    'use strict';
    var _;
    _ = oraculum.get('underscore');
    oraculum.defineMixin('URLAppend.ModelMixin', {
      mixinitialize: function() {
        var url;
        url = this.url;
        return this.url = (function(_this) {
          return function() {
            var parentUrl, thisUrl;
            parentUrl = _.result(_this.parent, 'url');
            thisUrl = _.isFunction(url) ? url.apply(_this, arguments) : url;
            return "" + parentUrl + thisUrl;
          };
        })(this);
      }
    });
    return oraculum.defineMixin('Submodel.ModelMixin', {
      mixconfig: function(mixinOptions, attrs, arg) {
        var submodels;
        submodels = (arg != null ? arg : {}).submodels;
        return mixinOptions.submodels = _.extend({}, mixinOptions.submodels, submodels);
      },
      mixinitialize: function() {
        var attributes, set;
        attributes = _.clone(this.attributes);
        _.each(this.attributes, (function(_this) {
          return function(submodel, attr) {
            if (!_this.mixinOptions.submodels[attr]) {
              return;
            }
            if (!_.isFunction(submodel != null ? submodel.on : void 0)) {
              return;
            }
            return _this.configureSubmodelAttribute(submodel, attr);
          };
        })(this));
        _.each(this.mixinOptions.submodels, (function(_this) {
          return function(submodel, attr) {
            if (!submodel["default"]) {
              return;
            }
            submodel = _this.createSubmodelFor(attr);
            return _this.set(attr, submodel, {
              silent: true
            });
          };
        })(this));
        set = this.set;
        this.set = (function(_this) {
          return function(attrs, val, options) {
            if (attrs == null) {
              return;
            }
            if (_.isObject(attrs)) {
              options = val;
            }
            if (!_.isObject(attrs)) {
              attrs = _.object([attrs], [val]);
            }
            if (!(options != null ? options.unset : void 0)) {
              attrs = _this.parseSubmodelAttributes(attrs, options);
            }
            return set.call(_this, attrs, options);
          };
        })(this);
        this.on('dispose', (function(_this) {
          return function(model) {
            if (model !== _this) {
              return;
            }
            return _.each(_this.attributes, function(value, attr) {
              var spec;
              spec = _this.mixinOptions.submodels[attr];
              if (spec && spec.keep) {
                return;
              }
              return value != null ? typeof value.dispose === "function" ? value.dispose() : void 0 : void 0;
            });
          };
        })(this));
        return this.set(attributes, {
          silent: true
        });
      },
      createSubmodelFor: function(attr) {
        var Model, ctorArgs, ref, submodel;
        Model = this.mixinOptions.submodels[attr].model;
        ctorArgs = this.mixinOptions.submodels[attr].ctorArgs;
        if (_.isFunction(ctorArgs)) {
          ctorArgs = ctorArgs.call(this);
        }
        ctorArgs || (ctorArgs = []);
        submodel = _.isString(Model) ? (ref = this.__factory()).get.apply(ref, [Model].concat(slice.call(ctorArgs))) : (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(Model, ctorArgs, function(){});
        return this.configureSubmodelAttribute(submodel, attr);
      },
      configureSubmodelAttribute: function(submodel, attr) {
        submodel.parent = this;
        this.stopListening(submodel);
        this.listenTo(submodel, 'all', (function(_this) {
          return function() {
            var args, eventName;
            eventName = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
            return _this.trigger.apply(_this, [attr + ":" + eventName].concat(slice.call(args)));
          };
        })(this));
        this.listenTo(submodel, 'dispose', (function(_this) {
          return function(target) {
            if (target !== submodel) {
              return;
            }
            return _this.stopListening(submodel);
          };
        })(this));
        this.listenTo(this, "change:" + attr, (function(_this) {
          return function(model, value, options) {
            if (Boolean(value)) {
              return;
            }
            if (!Boolean(options != null ? options.unset : void 0)) {
              return;
            }
            if (_this.mixinOptions.submodels[attr].keep) {
              return;
            }
            if (!options.keep) {
              return typeof submodel.dispose === "function" ? submodel.dispose() : void 0;
            }
          };
        })(this));
        return submodel;
      },
      parseSubmodelAttributes: function(attrs, options) {
        attrs = _.clone(attrs);
        _.each(attrs, (function(_this) {
          return function(value, attr) {
            var isCollection, isModel, isModelOrCollection, spec, submodel, tags;
            if (!(spec = _this.mixinOptions.submodels[attr])) {
              return;
            }
            tags = value != null ? typeof value.__tags === "function" ? value.__tags() : void 0 : void 0;
            isModel = (tags != null) && indexOf.call(tags, 'Model') >= 0;
            isCollection = (tags != null) && indexOf.call(tags, 'Collection') >= 0;
            isModelOrCollection = isModel || isCollection;
            if (isModelOrCollection) {
              return _this.configureSubmodelAttribute(value, attr);
            }
            submodel = _this.get(attr);
            if (_.isFunction(submodel != null ? submodel.set : void 0)) {
              submodel.set(value, _.extend({}, spec.setOptions, options));
              return delete attrs[attr];
            } else {
              submodel = _this.createSubmodelFor(attr);
              submodel.set(value, _.extend({}, spec.setOptions, options));
              return attrs[attr] = submodel;
            }
          };
        })(this));
        return attrs;
      }
    }, {
      mixins: ['Evented.Mixin']
    });
  });

}).call(this);

// This was transpiled from ES6 to ES5 using https://babeljs.io/repl/
'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

// configure the class for runtime loading
if (!window.fbControls) window.fbControls = new Array();
window.fbControls.push(function (controlClass) {

  /**
   * Column Header control class
   */
  var controlColumnHeader = function (_controlClass) {
    _inherits(controlColumnHeader, _controlClass);

    function controlColumnHeader() {
      _classCallCheck(this, controlColumnHeader);

      return _possibleConstructorReturn(this, (controlColumnHeader.__proto__ || Object.getPrototypeOf(controlColumnHeader)).apply(this, arguments));
    }

    _createClass(controlColumnHeader, [{
      key: 'build',
      value: function build() {
        return this.markup('div', null, { id: this.config.name });
      }
    }, {
      key: 'onRender',
      value: function onRender() {
        var $header = $('<h3>Column Header</h3>');
        $('#' + this.config.name).html('').append($header);
      }
    }], [{
      key: 'definition',


      /**
       * Class configuration - return the icons & label related to this control
       * @returndefinition object
       */
      get: function get() {
        return {
          i18n: {
            default: 'Column Header'
          }
        };
      }
    }]);

    return controlColumnHeader;
  }(controlClass);

  // register column-header control with formbuilder


  controlClass.register('column-header', controlColumnHeader);
});

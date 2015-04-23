;(function(win, doc){
	
	/**
	 * window/document.addEventListener polyfill.
	 */
	if(!win.addEventListener) {		//No need to polyfill
		
		function docHijack(p){var old = doc[p];doc[p] = function(v){return addListen(old(v))}}
		function addEvent(on, fn, self){
			return (self = this).attachEvent('on' + on, function(e){
				var e = e || win.event;
				e.preventDefault  = e.preventDefault  || function(){e.returnValue = false}
				e.stopPropagation = e.stopPropagation || function(){e.cancelBubble = true}
				fn.call(self, e);
			});
		}
		function addListen(obj, i){
			if(i = obj.length)while(i--)obj[i].addEventListener = addEvent;
			else obj.addEventListener = addEvent;
			return obj;
		}
		
		addListen([doc, win]);
		if('Element' in win)win.Element.prototype.addEventListener = addEvent;			//IE8
		else{																			//IE < 8
			doc.attachEvent('onreadystatechange', function(){addListen(doc.all)});		//Make sure we also init at domReady
			docHijack('getElementsByTagName');
			docHijack('getElementById');
			docHijack('createElement');
			addListen(doc.all);	
		}
	}
	
	/**
	 * Function.bind polyfill.
	 * Enables functionally binding context and arguments to a function.
	 */
	if (!Function.prototype.bind) {
		Function.prototype.bind = function(oThis) {
			if (typeof this !== 'function') {
				// closest thing possible to the ECMAScript 5
				// internal IsCallable function
				throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
			}
			
			var aArgs   = Array.prototype.slice.call(arguments, 1),
			fToBind = this,
			fNOP    = function() {},
			fBound  = function() {
				return fToBind.apply(this instanceof fNOP && oThis
						? this
								: oThis,
								aArgs.concat(Array.prototype.slice.call(arguments)));
			};
			
			fNOP.prototype = this.prototype;
			fBound.prototype = new fNOP();
			
			return fBound;
		};
	}
	
	/**
	 * Array.filter polyfill
	 */
	if (!Array.prototype.filter) {
		Array.prototype.filter = function(fun/*, thisArg*/) {
			'use strict';
			
			if (this === void 0 || this === null) {
				throw new TypeError();
			}
			
			var t = Object(this);
			var len = t.length >>> 0;
			if (typeof fun !== 'function') {
				throw new TypeError();
			}
			
			var res = [];
			var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
			for (var i = 0; i < len; i++) {
				if (i in t) {
					var val = t[i];
					
					// NOTE: Technically this should Object.defineProperty at
					//       the next index, as push can be affected by
					//       properties on Object.prototype and Array.prototype.
					//       But that method's new, and collisions should be
					//       rare, so use the more-compatible alternative.
					if (fun.call(thisArg, val, i, t)) {
						res.push(val);
					}
				}
			}
			
			return res;
		};
	}
	
	/**
	 * Polyfill for Object.assign
	 * used to copy all the properties from one or more source objects to a destination object.
	 */
	if (!Object.assign) {
		Object.defineProperty(Object, "assign", {
		    enumerable: false,
		    configurable: true,
		    writable: true,
		    value: function(target, firstSource) {
		      "use strict";
		      if (target === undefined || target === null)
		        throw new TypeError("Cannot convert first argument to object");
		      var to = Object(target);
		      for (var i = 1; i < arguments.length; i++) {
		        var nextSource = arguments[i];
		        if (nextSource === undefined || nextSource === null) continue;
		        var keysArray = Object.keys(Object(nextSource));
		        for (var nextIndex = 0, len = keysArray.length; nextIndex < len; nextIndex++) {
		          var nextKey = keysArray[nextIndex];
		          var desc = Object.getOwnPropertyDescriptor(nextSource, nextKey);
		          if (desc !== undefined && desc.enumerable) to[nextKey] = nextSource[nextKey];
		        }
		      }
		      return to;
		    }
	  });
	}
	
	/**
	 * Array.isArray
	 */
	if (!Array.isArray) {
	  Array.isArray = function(arg) {
	    return Object.prototype.toString.call(arg) === '[object Array]';
	  };
	}
	
	/**
	 * Object.isObj
	 */
	if(!Object.isObj) {
		Object.isObj = function(val) {
			return val !== null && typeof val === 'object';
		}
	}
	
	
	/**
	 * Global identifier indicating when the polyfill functions have been loaded.
	 */
	win.isPolyFilled = true;
})(window, document);
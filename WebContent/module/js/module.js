(function(win) {
	var Module = function(m) {

		this._m = m;
		this.vm = {};
		this.ctrl = {};
		this.controller = controller.bind(this);
		this.view = this._m.view.bind(this);
		
		function controller () {
			this._m.controller.call(this.ctrl);
			var ctrl = this.ctrl;
			this.controller = function () {
				return ctrl;
			};
		};
	};

	Module.prototype.controllerInit = function(options) {
		var merge = function merge(opts) {
			if (opts) this.ctrl = Object.assign(this.ctrl, opts);
		}.bind(this);
		
		this.controller();
		merge(options);

		this.controllerInit = merge;
		return this;
	};

	Module.prototype.vmInit = function(options) {
		var merge = function merge(opts) {
			if (opts) this.vm = Object.assign(this.vm, opts);
		}.bind(this);
		
		this._m.viewModel.call(this.vm, this.ctrl);
		merge(options);

		this.vmInit = merge;
		return this;
	};

	Module.prototype.init = function(ctrlOptions, vmOptions) {
		this.controllerInit.call(this, ctrlOptions);
		this.vmInit.call(this, vmOptions);
		return this;
	};
	
	/**
	 * Export Module
	 */
	win.Module = Module;
}(window));
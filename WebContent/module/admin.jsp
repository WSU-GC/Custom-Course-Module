<%@ page import="edu.wsu.*" %>
<%@page import="helper.buildingblock.BuildingBlockHelper"%>
<%@page import="blackboard.data.course.*" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="blackboard.persist.course.*" %>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.google.gson.GsonBuilder" %>
<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.List" %>
<%@taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>


<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<ul>
	<li>search: The value to search for</li>
	<li>operator: contains, equals, notblank, startswith, greaterthan, lessthan</li>
	<li>key: coursedescription, courseid, coursename, term, instructor, datecreated</li>
</ul>

<p>
example: search=2015-spri-onlin&operator=startswith&key=courseid
</p>

<input style="width:400px;" type="text" id="searchParams" />
<button id="submitSearch">Submit</button>

<script>

/* 
* Dynamic script loader. This entire page is loaded by Bb at page load, after the initial DOMLoaded event has fired.
* Therefore you cannot depend on $(function() { ... }) or $(document).ready(...) for resource loading or executing on page load events.
* The function defined below allows you to explicitly listen for when specific globals defined on window have finished loading
* example: ready(function() {// stuff to execute when globals are ready}, "jQuery", "underscore", ...OTHER GLOBALS TO LISTEN FOR);
* It will run for a few seconds before consoling an error and moving on. This must be defined in page as we cannot dynamically load the dynamic loader.
*/
function load(resource) {
	var script = document.createElement("script");
	script.setAttribute("type", "text/javascript");
	script.setAttribute("src", resource);
	document.head.appendChild(script);
}


function ready(cb) {
	//this.__count = 0;
	window.__COUNT_LOADING_ATTEMPTS = window.__COUNT_LOADING_ATTEMPTS || 0;
	var args = Array.prototype.slice.call(arguments, 1);
	
	// Polyfill for array.filter
	var filter = Array.prototype.filter || function(fn) {
		var array = this;
		var l = array.length;
		var res = [];
		
		for(var i = 0; i < l; i++) {
			if(fn.call(this, array[i], i, array))
				res = res.push(array[i]);
		}
		
		return res;
	}
	
	var loading = filter.call(args, function(el) {
		return typeof window[el] == 'undefined';
	});
	
	function run() {
		window.__COUNT_LOADING_ATTEMPTS++;
		if (window.__COUNT_LOADING_ATTEMPTS > 1000) {
			// Unable to load all resources. log error and move on.
			console.error("Error: page failed to load all resources: %s", loading.toString());
			window.__COUNT_LOADING_ATTEMPTS = 0;
			cb();
		} else { 
			ready.apply(this, [cb].concat(args));
		}
	}
	
	// polyfill for function binding.
	run._bind = Function.prototype.bind || function(bThis) {
		var args = Array.prototype.slice.call(arguments, 1);
		var fn = this;
		return function() {
			var _args = args.concat(Array.prototype.slice.call(arguments));
			return fn.apply(bThis, _args);
		}
	};

	/in/.test(document.readyState) || loading.length
		? setTimeout(run._bind(this), 9)
		: (function() {cb(); window.__COUNT_LOADING_ATTEMPTS = 0; }());
	
	/**
	* None of the polyfills in this function override native prototype chains/functionality
	* polyfill.js provides more robust polyfill functions that do extend native prototype chains.
	*/
}

</script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/jquery.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/lodash.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/polyfill.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/blob.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/filesaver.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/mithril.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/module.js") %>'></script>
<script>
ready(function() {
	var $ = jQuery;
	
	load('<%= BuildingBlockHelper.getBaseUrl("module/js/filter-module.js") %>');
	load('<%= BuildingBlockHelper.getBaseUrl("module/js/loading-module.js") %>');
	load('<%= BuildingBlockHelper.getBaseUrl("module/js/ccm-table-module.js") %>');
	load('<%= BuildingBlockHelper.getBaseUrl("module/js/selectedterm-module.js") %>');
	load('<%= BuildingBlockHelper.getBaseUrl("module/js/showchildren-module.js") %>');
	
	ready(function() {
		console.log("dom loaded");
	}, 'filter', 'selectedTerm', "showChildren", "loadingModule", "tableModule");
	
	$('#submitSearch').on('click', function() {
		var params = $('#searchParams').val();
		getSearchResults(params);
	});
	
	function getSearchResults(params) {
		var url = "<%= BuildingBlockHelper.getBaseUrl() %>" + "CourseAdmin?" + params;
		var jxhr;
		
		jxhr = $.ajax(url);
	
		jxhr.done(function(msg) {
			//console.log(msg);
			save(convertToCsv(msg));
		});
	
		jxhr.fail(function(xhr, statusText) {
			console.log('Error: failed to load content from ' + url);
		});
	}
	
	function save(csv) {
		var blob = new Blob([csv], {type: "text/plain;charset=utf-8"});
		saveAs(blob, "data-table-export.csv");
	}
	
	function processEmails(arr) {
		return [].concat(arr).map(function(el, i) {
			if (_.isPlainObject(el)) {
				var values = _.values(el).map(function(el, i) {
					return '<' + el + '>;';
				});
				return _.flatten(_.zip(_.keys(el), values)).join(' ');
			} else {
				return el;
			}
		}).join(' ');
	}
	
	function convertToCsv(data) {
		window.data = data;
		var keys = ['coursePkId', 'courseId', 'courseBatchUid', 'title', 'isAvailable', 'isRoster', 'isOnline', 'isParent', 'isChild', 'parent', 'enrl', 'instructorEmails'];
		var csv = 'coursePkId, courseId, courseBatchUid, title, isAvailable, isRoster, isOnline, isParent, isChild, parent, enrl, instructorEmails\n';
		
		for (var i = 0, l = data.length; i < l; i++) {
			if(i != 0) csv += "\n";
			for (var j = 0, k = keys.length; j < k; j++) {
				if (j != 0) csv += ",";
				if (Array.isArray(data[i][keys[j]]) || Object.isObj(data[i][keys[j]])) {
					csv += '"' + processEmails(data[i][keys[j]]) + '"';
				} else {
					csv += '"' + (data[i][keys[j]] || '' ) + '"';
				}
			}
		}
		return csv;
	}
	
}, 'jQuery', '_', 'isPolyFilled', 'saveAs', 'Blob', 'm', 'Module');
</script>


</bbNG:learningSystemPage>
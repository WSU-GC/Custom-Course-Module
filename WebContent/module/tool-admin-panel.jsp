<%@ page import="edu.wsu.*" %>
<%@page import="helper.buildingblock.BuildingBlockHelper"%>
<%@page import="blackboard.data.course.*" %>
<%@page import="blackboard.data.navigation.*" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="blackboard.persist.course.*" %>
<%@page import="blackboard.persist.navigation.*" %>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.google.gson.GsonBuilder" %>
<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.List" %>
<%@taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>


<bbNG:learningSystemPage  ctxId="bbContext">

<%

Gson gson = new GsonBuilder()
	.registerTypeAdapter(ToolSettings.class, new CourseToolSerializer()).create();

ToolSettingsManager toolManager = ToolSettingsManagerFactory.getInstance();
List<ToolSettings> contentArea = toolManager.loadAllToolSettings(false).get(ToolSettings.Type.ContentHandler);
List<ToolSettings> courseApplications = toolManager.loadAllToolSettings(false).get(ToolSettings.Type.Course);

String contentHandlers = gson.toJson(contentArea);
String applications = gson.toJson(courseApplications);

%>

<bbNG:pageHeader> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<ul>
	<li>search: The value to search for</li>
	<li>operator: contains, equals, notblank, startswith, greaterthan, lessthan</li>
	<li>key: coursedescription, courseid, coursename, term, instructor, datecreated</li>
	<li>operation: enable, disable or list</li>
</ul>

<p>
example: search=2015-spri-onlin&operator=startswith&key=courseid&operation=list
</p>
<br/>

<input style="width:400px;" type="text" id="searchParams" />

<br/>
<br/>

<select id="type">
	<option>Select an option</option>
	<option value="ContentHandler">Content Area</option>
	<option value="Application">Application</option>
</select>

<br/>
<br/>

<select id="ContentHandler" class="hide">
	<option>Please select an option</option>
</select>

<select id="Application" class="hide">
	<option>Please select an option</option>
</select>

<br/>
<br/>

<button class="hide" id="submitSearch">Submit</button>

<div id="toolContentDescription">
</div>

<script id="toolTemplate" type="text/x-jsrender">
	<option value='{{:#index}}'>{{:label}}</option>
</script>

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

var contentHandlers = <%= contentHandlers %>;
var applications = <%= applications %>;
var type;
var tools;

function initialize() {
	contentHandlers = contentHandlers.sort(function(a, b) {
		return a.label.localeCompare(b.label);
	});
	
	applications = applications.sort(function(a, b) {
		return a.label.localeCompare(b.label);
	});
	
	tools = {
		ContentHandler: contentHandlers,
		Application: applications
	};
	
	var $ = jQuery;
	
	var template = $.templates('#toolTemplate');
	var appHtml = template.render(tools.Application);
	var conHtml = template.render(tools.ContentHandler);
	
	
	$('#ContentHandler').html(conHtml);
	$('#Application').html(appHtml);
	
	$('.hide').hide();
	
	$(document).on('change', '#type', function(ev) {
		type = $('#type option:selected').val();
				
		$('.hide').hide();
		$('#' + type).show();
		$('#submitSearch').show();
	});
	
	$(document).on('change', '#ContentHandler, #Application', function(ev) {
		var ind = $('#' + type + ' option:selected').val();
		var tool = tools[type][ind];
		var keys = Object.keys(tool);
		
		$('#toolContentDescription').html('');
		for(var i=0, l=keys.length; i < l; i++) {
			$('#toolContentDescription').append(keys[i] + ": " + tool[keys[i]] + "<br/>");
		}
		
	});
}

ready(function() {
	var $ = jQuery;
	var toolInd;
	var tool;
	
	initialize();
	
	$('#submitSearch').on('click', function() {
		toolInd = $('#' + type + ' option:selected').val();
		tool = tools[type][toolInd];
		var params = $('#searchParams').val() + '&tool-id=' + tool.identifier + '&type=' + type;
		getSearchResults(params);
	});
	
	function getSearchResults(params) {
		var url = "<%= BuildingBlockHelper.getBaseUrl() %>" + "ToolManager?" + params;
		var jxhr;
		
		jxhr = $.ajax(url);
	
		jxhr.done(function(msg) {
			//console.log(msg);
			save(convertToCsv(msg));
		});
	
		jxhr.fail(function(xhr, statusText, error) {
			console.log('Error: failed to load content from %s, %s, %s', xhr.toString(), statusText, error.message);
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
		var keys = ['coursePkId', 'courseId', 'courseBatchUid', 'title', 'isAvailable', 'isRoster', 'isOnline', 'isParent', 'isChild', 'parent', 'enrl', 'instructorEmails', 'tool'];
		var csv = 'coursePkId, courseId, courseBatchUid, title, isAvailable, isRoster, isOnline, isParent, isChild, parent, enrl, instructorEmails, ' + tool.label + '\n';
		
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
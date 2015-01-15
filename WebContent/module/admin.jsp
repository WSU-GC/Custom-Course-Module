<%@ page import="edu.wsu.*" %>
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

<%
String moduleBasePath = PlugInUtil.getUri("wsu", "wsu-custom-course-module", "");
%>

<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<input style="width:400px;" type="text" id="searchParams" />
<button id="submitSearch">Submit</button>

<script>

function ready(cb) {
	typeof jQuery == 'undefined' // in = loadINg
    	? setTimeout('ready('+cb+')', 9)
    	: cb();
}
</script>
<script type="text/javascript" src='<%= moduleBasePath + "module/jquery.js" %>'></script>
<script type="text/javascript" src='<%= moduleBasePath + "module/blob.js" %>'></script>
<script type="text/javascript" src='<%= moduleBasePath + "module/filesaver.js" %>'></script>
<script>
ready(function() {
	var $ = jQuery;
	
	$('#submitSearch').on('click', function() {
		var params = $('#searchParams').val();
		getSearchResults(params);
	});
	
	function getSearchResults(params) {
		var url = "<%= moduleBasePath %>" + "CourseAdmin?" + params;
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
	
	function convertToCsv(data) {
		var keys = ['coursePkId', 'courseId', 'courseBatchUid', 'title', 'isAvailable', 'isRoster', 'isOnline', 'isParent', 'isChild', 'parent', 'enrl'];
		var csv = 'coursePkId, courseId, courseBatchUid, title, isAvailable, isRoster, isOnline, isParent, isChild, parent, enrl\n';
		
		for (var i = 0, l = data.length; i < l; i++) {
			if(i != 0) csv += "\n";
			for (var j = 0, k = keys.length; j < k; j++) {
				if (j != 0) csv += ",";
				csv += '"' + (data[i][keys[j]] || '' ) + '"'
			}
		}
		return csv;
	}
	
});
</script>


</bbNG:learningSystemPage>
## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

<%namespace name="dashboard" file="common_dashboard.mako" />

${ commonheader(None, "impala", user) | n,unicode }

<%dashboard:layout_toolbar>
  <%def name="widgets()">
    <div data-bind="css: { 'draggable-widget': true},
          draggable: {data: draggableResultset(), isEnabled: true,
              options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                        'stop': function(event, ui){$('.card-body').slideDown('fast'); }}}"
         title="${_('Grid Results')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="fa fa-table"></i></a>
    </div>

    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableFacet(), isEnabled: true,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Text Facet')}" rel="tooltip" data-placement="top">
         <a  class="draggable-icon"><i class="fa fa-sort-amount-asc"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggablePie(), isEnabled: true,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Pie Chart')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="hcha hcha-pie-chart"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableBar(), isEnabled: true,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Bar Chart')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="hcha hcha-bar-chart"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableLine(), isEnabled: true,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Line Chart')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="hcha hcha-line-chart"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableHistogram(), isEnabled: true,
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Timeline')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="hcha hcha-timeline-chart"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableFilter(),
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Filter Bar')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="fa fa-filter"></i></a>
    </div>
    <div data-bind="css: { 'draggable-widget': true },
                    draggable: {data: draggableMap(),
                    options: {'start': function(event, ui){lastWindowScrollPosition = $(window).scrollTop();$('.card-body').slideUp('fast');},
                              'stop': function(event, ui){$('.card-body').slideDown('fast', function(){$(window).scrollTop(lastWindowScrollPosition)});}}}"
         title="${_('Map')}" rel="tooltip" data-placement="top">
         <a class="draggable-icon"><i class="hcha hcha-map-chart"></i></a>
    </div>
</%def>
</%dashboard:layout_toolbar>


<div class="search-bar">
  <div class="pull-right" style="padding-right:50px">
    % if user.is_superuser:
      <button type="button" title="${ _('Edit') }" rel="tooltip" data-placement="bottom" data-bind="click: toggleEditing, css: {'btn': true, 'btn-inverse': isEditing}"><i class="fa fa-pencil"></i></button>
    % endif
  </div>


  <form class="form-search" style="margin: 0" data-bind="submit: search">
    <strong>${_("Search")}</strong>
    <span data-bind="text: $root.dashboard.properties()[0].database"></span>.<span data-bind="text: $root.dashboard.properties()[0].table"></span>
      <div class="input-append">

      <span data-bind="foreach: query.qs">
        <input data-bind="clearable: q" maxlength="4096" type="text" class="search-query input-xlarge">
  ##      <!-- ko if: $index() >= 1 -->
  ##      <a class="btn" href="javascript:void(0)" data-bind="click: $root.query.removeQ"><i class="fa fa-minus"></i></a>
  ##      <!-- /ko -->
      </span>

  ##    <a class="btn" href="javascript:void(0)" data-bind="click: $root.query.addQ"><i class="fa fa-plus"></i></a>

      <button type="submit" id="search-btn" class="btn btn-inverse" style="margin-left:10px"><i class="fa fa-search"></i></button>
      </div>
  </form>
</div>


${ dashboard.layout_skeleton() }

<script type="text/html" id="resultset-widget">


<div class="widget-spinner" data-bind="visible: $root.isRetrievingResults()">
  <!--[if !IE]> --><i class="fa fa-spinner fa-spin"></i><!-- <![endif]-->
  <!--[if IE]><img src="/static/art/spinner.gif" /><![endif]-->
</div>

<div data-bind="visible: !$root.isRetrievingResults() && $root.results().length == 0">
  </br>
  ${ _('Your search did not match any documents.') }
</div>

<div data-bind="visible: !$root.isRetrievingResults() && $root.results().length > 0">
  <div id="result-main" style="overflow-x: auto">
    <table id="result-container" style="margin-top: 0; width: 100%">
      <thead>
        <tr>
          <th style="width: 18px">&nbsp;</th>
          <!-- ko foreach: $root.results_cols -->
            <th data-bind="text: $data"></th>
          <!-- /ko -->
        </tr>
      </thead>
      <tbody data-bind="foreach: { data: $root.results, as: 'row'}" class="result-tbody">
        <tr class="result-row">
          <td>
            <a href="javascript:void(0)">
              <i class="fa" data-bind="css: {'fa-caret-right' : true }"></i>
            </a>
          </td>
          <!-- ko foreach: row -->
            <td data-bind="html: $data"></td>
          <!-- /ko -->
        </tr>
      </tbody>
    </table>
  </div>
</div>
</script>


<script type="text/html" id="facet-widget">
  <!-- ko if: $root.getFacetFromResult(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromResult(id())">
    <div data-bind="visible: $root.isEditing, with: $root.dashboard.getFacetById($parent.id())" style="margin-bottom: 20px">
      <input type="text" data-bind="value: field" />
      <input type="text" data-bind="value: properties.limit" />
    </div>
  
    <span data-bind="foreach: data()">
      <a href="javascript: void(0)">
        <span data-bind="text: $data, click: function(){ $root.query.toggleFacet({facet: $data, widget: $parent}) }"></span>
      </a>
    </span>
  </div>
  <!-- /ko -->
  <!-- ko ifnot: $root.getFacetFromResult(id()) -->
    <a href="javascript:void(0)" data-bind="click: $root.dashboard.addFacet">
      <i class="fa fa-plus"></i>
    </a>
  <!-- /ko -->
</script>


<script type="text/html" id="pie-widget">
  <!-- ko if: $root.getFacetFromResult(id()) -->
  <div class="row-fluid" data-bind="with: $root.getFacetFromResult(id())">
    PIE widget
    <div data-bind="visible: $root.isEditing, with: $root.dashboard.getFacetById($parent.id())" style="margin-bottom: 20px">
      <input type="text" data-bind="value: field" />
      <input type="text" data-bind="value: properties.limit" />
    </div>
  
    <span data-bind="foreach: data()">
      <a href="javascript: void(0)">
        <span data-bind="text: $data, click: function(){ $root.query.toggleFacet({facet: $data, widget: $parent}) }"></span>
      </a>
    </span>
  </div>
  <!-- /ko -->
  <!-- ko ifnot: $root.getFacetFromResult(id()) -->
    <a href="javascript:void(0)" data-bind="click: $root.dashboard.addFacet">
      <i class="fa fa-plus"></i>
    </a>
  <!-- /ko -->  
</script>


<link rel="stylesheet" href="/impala/static/css/impala-dashboard.css">
<link rel="stylesheet" href="/static/ext/css/hue-filetypes.css">
<link rel="stylesheet" href="/static/ext/css/hue-charts.css">
<link rel="stylesheet" href="/static/ext/chosen/chosen.min.css">

<script src="/static/ext/js/moment-with-langs.min.js" type="text/javascript" charset="utf-8"></script>

${ dashboard.import_layout() }

<script src="/static/ext/js/bootstrap-editable.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/ko.editable.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/shortcut.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/mustache.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/chosen/chosen.jquery.min.js" type="text/javascript" charset="utf-8"></script>

${ dashboard.import_bindings() }

<script src="/impala/static/js/impala-dashboard.ko.js" type="text/javascript" charset="utf-8"></script>

${ dashboard.import_charts() }


<script type="text/javascript">
  function columnDropAdditionalHandler(widget){
    console.log("column drop")
  }

  function widgetDraggedAdditionalHandler(widget){
    console.log("boom")
  }

  var viewModel = new ImpalaDashboardViewModel(${ query_json | n,unicode }, ${ dashboard_json | n,unicode  });
  ko.applyBindings(viewModel);

  $(document).ready(function(){
    window.setTimeout(function(){
      viewModel.init();
    }, 50);
  });

</script>

${ commonfooter(messages) | n,unicode }

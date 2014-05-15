// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


ko.bindingHandlers.pieChart = {
    init: function (element, valueAccessor) {
      var _options = valueAccessor();
      var _data = _options.transformer(_options.data);
      $(element).css("marginLeft", "auto");
      $(element).css("marginRight", "auto");
      if (typeof _options.maxWidth != "undefined"){
        var _max = _options.maxWidth*1;
        $(element).width(Math.min($(element).parent().width(), _max));
      }

      nv.addGraph(function () {
        var _chart = nv.models.growingPieChart()
                .x(function (d) {
                  return d.label
                })
                .y(function (d) {
                  return d.value
                })
                .height($(element).width())
                .showLabels(true).showLegend(false);

        var _d3 = ($(element).find('svg').length > 0) ? d3.select($(element).find('svg')[0]) : d3.select($(element)[0]).append('svg');

        _d3.datum(_data)
                .transition().duration(150)
                .each("end", _options.onComplete)
                .call(_chart);

        $.each(_options.fqs(), function(cnt, item){
          if (item.field() == _options.field()){
            _chart.selectSlices(item.filter());
          }
        });

        nv.utils.windowResize(_chart.update);
        $(element).height($(element).width());
        $(element).parents(".card-widget").on("resize", function(){
          if (typeof _options.maxWidth != "undefined"){
            var _max = _options.maxWidth*1;
            $(element).width(Math.min($(element).parent().width(), _max));
          }
          $(element).height($(element).width());
          _chart.update();
        });

        return _chart;
      }, function () {
        d3.selectAll(".nv-slice").on('click',
          function (d, i) {
            _options.onClick(d);
          });
      });
    },
    update: function (element, valueAccessor) {
      var value = valueAccessor();
      // do something with the updated value
    }
  };

ko.bindingHandlers.barChart = {
  init: function (element, valueAccessor) {
    barChart(element, valueAccessor(), false);
  },
  update: function (element, valueAccessor) {
    var value = valueAccessor();
    // do something with the updated value
  }
};

ko.bindingHandlers.timelineChart = {
  init: function (element, valueAccessor) {
    barChart(element, valueAccessor(), true);
  },
  update: function (element, valueAccessor) {
    var value = valueAccessor();
    // do something with the updated value
  }
};

ko.bindingHandlers.lineChart = {
  init: function (element, valueAccessor) {
    lineChart(element, valueAccessor());
  },
  update: function (element, valueAccessor) {
    var value = valueAccessor();
    // do something with the updated value
  }
};

ko.bindingHandlers.mapChart = {
  render: function (element, valueAccessor) {

    var _options = valueAccessor();

    $(element).empty();

    $(element).css("position", "relative");
    $(element).css("marginLeft", "auto");
    $(element).css("marginRight", "auto");
//
//    if (typeof _options.maxWidth != "undefined") {
//      var _max = _options.maxWidth * 1;
//      if ($(element).width() > _max) {
//        $(element).width(_max);
//      }
//    }
//
    if (typeof _options.maxWidth != "undefined"){
        var _max = _options.maxWidth*1;
        $(element).width(Math.min($(element).parent().width(), _max));
      }

    $(element).height($(element).width() / 2.23);

    var _scope = typeof _options.data.scope != "undefined" ? String(_options.data.scope) : "world";
    var _data = _options.transformer(_options.data);
    var _maxWeight = 0;
    $(_data).each(function(cnt, item) {
      if (item.value > _maxWeight) _maxWeight = item.value;
    });

    var _chunk = _maxWeight / _data.length;

    var _mapdata = {};
    var _maphovers = {};
    var _fills = {};
    var _noncountries = [];

    if (_options.isScale) {
      _fills["defaultFill"] = HueColors.LIGHT_BLUE;
      var _colors = HueColors.scale(HueColors.LIGHT_BLUE, HueColors.DARK_BLUE, _data.length);
      $(_colors).each(function(cnt, item) {
        _fills["fill_" + cnt] = item;
      });
      $(_data).each(function(cnt, item) {
        var _place = item.label;
        if (_place != null){
          _mapdata[_place] = {
            fillKey: "fill_" + Math.floor(item.value / _chunk),
            id: _place,
            cat: item.obj.cat,
            value: item.obj.value
          };
          _maphovers[_place] = item.value;
        }
        else {
          _noncountries.push(item);
        }
      });
    }
    else {
      _fills["defaultFill"] = HueColors.LIGHT_BLUE;
      _fills["selected"] = HueColors.DARK_BLUE;
      $(_data).each(function(cnt, item) {
    	var _place = item.label.toUpperCase();
        if (_place != null){
          _mapdata[_place] = {
            fillKey: "selected",
            id: _place,
            cat: item.obj.cat,
            value: item.obj.value,
            selected: item.obj.selected
          };
          _maphovers[_place] = item.value;
        }
        else {
          _noncountries.push(item);
        }
      });
    }

    var _map = null;
    function createDatamap(element, options, fills, mapData, nonCountries, mapHovers) {
      _map = new Datamap({
        element: element,
        fills: fills,
        scope: _scope,
        data: mapData,
        onClick: function(data) {
          if (typeof options.onClick != "undefined") {
            options.onClick(data);
          }
        },
        done: function(datamap) {
          var _bubbles = [];
          if (options.enableGeocoding) {
            $(nonCountries).each(function(cnt, item){
                HueGeo.getCityCoordinates(item.label, function(lat, lng){
                    _bubbles.push({
                      fillKey: "selected",
                      label: item.label,
                      value: item.value,
                      radius: 4,
                      latitude: lat,
                      longitude: lng
                    });
                    _map.bubbles(_bubbles, {
                      popupTemplate: function(geo, data) {
                        return '<div class="hoverinfo" style="text-align: center"><strong>'  + data.label + '</strong><br/>' + item.value + '</div>'
                      }
                    });
                });
            });
          }
        },
        geographyConfig: {
          hideAntarctica: true,
          borderWidth: 1,
          borderColor: HueColors.DARK_BLUE,
          highlightOnHover: true,
          highlightFillColor: HueColors.DARK_BLUE,
          highlightBorderColor: HueColors.BLUE,
          selectedBorderColor: HueColors.GRAY,
          popupTemplate: function(geography, data) {
        	var _hover = '';
        	if (data != null) {
        	  _hover = '<br/>' + mapHovers[data.id];
        	}
            return '<div class="hoverinfo" style="text-align: center"><strong>' + geography.properties.name + '</strong>' + _hover + '</div>'
          }
        }
      });
      options.onComplete();
    }

    createDatamap(element, _options, _fills, _mapdata, _noncountries, _maphovers)

    $(element).parents(".card-widget").one("resize", function(){
      ko.bindingHandlers.mapChart.render(element, valueAccessor);
    });
  },
  init: function (element, valueAccessor) {
    ko.bindingHandlers.mapChart.render(element, valueAccessor)
  },
  update: function (element, valueAccessor) {
    ko.bindingHandlers.mapChart.render(element, valueAccessor);
  }
};



function lineChart(element, options) {
  var _datum = options.transformer(options.datum);
  $(element).height(300);

  nv.addGraph(function () {
    var _chart = nv.models.lineWithBrushChart();
    _chart.onSelectRange(options.onSelectRange);
    _chart.xAxis.showMaxMin(false);

    _chart.yAxis
        .tickFormat(d3.format(',0f'));

    var _d3 = ($(element).find('svg').length > 0) ? d3.select($(element).find('svg')[0]) : d3.select($(element)[0]).append('svg');
    _d3.datum(_datum)
        .transition().duration(150)
        .each("end", options.onComplete)
        .call(_chart);

    nv.utils.windowResize(_chart.update);

    return _chart;
  }, function () {
    d3.selectAll(".nv-bar").on('click',
      function (d, i) {
        options.onClick(d);
      });
  });

}


function barChart(element, options, isTimeline) {
  var _datum = options.transformer(options.datum);
  $(element).height(300);

  nv.addGraph(function () {
    var _chart;

    var insertLinebreaks = function (d) {
      var _el = d3.select(this);
      var _mom = moment(d);
      if (_mom != null) {
        var _words = _mom.format("hh:mm:ss YYYY-MM-DD").split(" ");
        _el.text('');
        for (var i = 0; i < _words.length; i++) {
          var tspan = _el.append("tspan").text(_words[i]);
          if (i > 0) {
            tspan.attr("x", 0).attr("dy", '15');
          }
        }
      }
    };

    if (isTimeline) {
      _chart = nv.models.multiBarWithBrushChart();
      if (_datum.length > 0 && _datum[0].values.length > 10){
        _chart.enableSelection();
      }
      _chart.onSelectRange(options.onSelectRange);
      _chart.xAxis.tickFormat(d3.time.format("%Y-%m-%d %H:%M:%S"));
      _chart.multibar.hideable(true);
      _chart.multibar.stacked(typeof options.stacked != "undefined" ? options.stacked : false);
      _chart.onStateChange(options.onStateChange);
      _chart.onChartUpdate(function(){
        _d3.selectAll("g.nv-x.nv-axis g text").each(insertLinebreaks);
      });
    }
    else {
      var _isDiscrete = false;
      for (var j=0;j<_datum.length;j++){
        for (var i=0;i<_datum[j].values.length;i++){
          if (isNaN(_datum[j].values[i].x * 1)){
            _isDiscrete = true;
            break;
          }
        }
      }
      if (_isDiscrete){
        _chart = nv.models.growingDiscreteBarChart()
        .x(function(d) { return d.x })
        .y(function(d) { return d.y })
        .staggerLabels(true);
      }
      else {
        _chart = nv.models.multiBarWithBrushChart();
        _chart.xAxis
          .showMaxMin(true)
          .tickFormat(d3.format(',0f'));
        _chart.multibar.hideable(true);
        _chart.multibar.stacked(typeof options.stacked != "undefined" ? options.stacked : false);
        _chart.onStateChange(options.onStateChange);
      }
    }
    _chart.transitionDuration(100);

    _chart.yAxis
        .tickFormat(d3.format(',0f'));

    var _d3 = ($(element).find('svg').length > 0) ? d3.select($(element).find('svg')[0]) : d3.select($(element)[0]).append('svg');
    _d3.datum(_datum)
        .transition().duration(150)
        .each("end", function(){
          options.onComplete();
          if (isTimeline) {
            _d3.selectAll("g.nv-x.nv-axis g text").each(insertLinebreaks);
          }
        }).call(_chart);

    nv.utils.windowResize(_chart.update);

    return _chart;
  }, function () {
    d3.selectAll(".nv-bar").on("click",
      function (d, i) {
        options.onClick(d);
      });
  });

}

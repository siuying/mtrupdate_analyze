(function() {
  var HeatmapController, heatmap,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HeatmapController = (function() {
    function HeatmapController() {
      this.monthPath = __bind(this.monthPath, this);
      this.setData = __bind(this.setData, this);
      this.getData = __bind(this.getData, this);
      this.load = __bind(this.load, this);
      this.generate = __bind(this.generate, this);
      this.width = 700;
      this.height = 90;
      this.cellSize = 12;
      this.severity = {
        0: "正常",
        1: "服務受阻",
        2: "稍有阻延",
        3: "顯著受阻",
        4: "嚴重受阻",
        5: "限度服務",
        6: "全綫暫停"
      };
      this.day = d3.time.format("%w");
      this.week = d3.time.format("%U");
      this.percent = d3.format(".1%");
      this.format = d3.time.format("%Y-%m-%d");
    }

    HeatmapController.prototype.generate = function() {
      this.calendar = d3.select("body").selectAll("svg").data(d3.range(2012, 2015)).enter().append("svg").attr("width", this.width).attr("height", this.height).attr("class", "mtr").append("g").attr("transform", "translate(" + ((this.width - this.cellSize * 53) / 2) + "," + (this.height - this.cellSize * 7 - 1) + ")");
      this.calendar.append("text").attr("transform", "translate(-6," + this.cellSize * 3.5 + ")rotate(-90)").style("text-anchor", "middle").text(function(d) {
        return d;
      });
      this.cells = this.calendar.selectAll(".day").data(function(d) {
        return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1));
      }).enter().append("rect").attr("class", "day").attr("width", this.cellSize).attr("height", this.cellSize).attr("x", (function(_this) {
        return function(d) {
          return _this.week(d) * _this.cellSize;
        };
      })(this)).attr("y", (function(_this) {
        return function(d) {
          return _this.day(d) * _this.cellSize;
        };
      })(this)).datum(this.format);
      this.cells.append("title").text(function(d) {
        return d;
      });
      return this.calendar.selectAll(".month").data(function(d) {
        return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1));
      }).enter().append("path").attr("class", "month").attr("d", this.monthPath);
    };

    HeatmapController.prototype.load = function(filename) {
      if (filename == null) {
        filename = "heatmap.json";
      }
      return d3.json(filename, (function(_this) {
        return function(error, json) {
          var data;
          data = d3.nest().key(function(d) {
            return d.date;
          }).rollup(function(d) {
            return d[0];
          }).map(json);
          _this.setData(data);
          return _this.cells.filter(function(d) {
            return d in data;
          }).attr("class", function(d) {
            return "day q" + data[d].severity + "-11";
          }).attr("data-date", function(d) {
            return data[d].date;
          }).select("title").text(function(d) {
            return "" + d + ": " + _this.severity[data[d].severity];
          });
        };
      })(this));
    };

    HeatmapController.prototype.getData = function() {
      return this.data;
    };

    HeatmapController.prototype.setData = function(data) {
      return this.data = data;
    };

    HeatmapController.prototype.monthPath = function(t0) {
      var cellSize, d0, d1, path, t1, w0, w1;
      cellSize = this.cellSize;
      t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0);
      d0 = +this.day(t0);
      w0 = +this.week(t0);
      d1 = +this.day(t1);
      w1 = +this.week(t1);
      path = "M" + (w0 + 1) * cellSize + "," + d0 * cellSize;
      path += "H" + w0 * cellSize + "V" + 7 * cellSize;
      path += "H" + w1 * cellSize + "V" + (d1 + 1) * cellSize;
      path += "H" + (w1 + 1) * cellSize + "V" + 0;
      path += "H" + (w0 + 1) * cellSize + "Z";
      return path;
    };

    return HeatmapController;

  })();

  heatmap = new HeatmapController;

  heatmap.generate();

  heatmap.load();

}).call(this);

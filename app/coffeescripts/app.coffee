class HeatmapController
  constructor: () ->
    @cellPad = 2
    @cellSize = 12
    @width = (@cellSize + @cellPad) * 53 + 40
    @height = (@cellSize + @cellPad) * 7 + 10
    @severity =
      0: "正常"
      1: "服務受阻"
      2: "稍有阻延"
      3: "顯著受阻"
      4: "嚴重受阻"
      5: "限度服務"
      6: "全綫暫停"

    @day = d3.time.format("%w")
    @week = d3.time.format("%U")
    @percent = d3.format(".1%")
    @format = d3.time.format("%Y-%m-%d")

  generate: () =>
    @svg = d3.select("#heatmap").selectAll("svg")
      .data(d3.range(2012, 2015))
      .enter().append("svg").attr("width", @width).attr("height", @height).attr("class", "mtr")
      .append("g").attr("transform", "translate(" + ((@width - (@cellSize + @cellPad) * 53) / 2) + "," + (@height -  (@cellSize + @cellPad) * 7 - 1) + ")")

    @svg.append("text")
      .attr("transform", "translate(-6," + @cellSize * 3.5 + ")rotate(-90)")
      .style("text-anchor", "middle")
      .text((d) -> d)

    @cells = @svg.selectAll(".day")
      .data((d) -> d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)))
      .enter().append("rect")
      .attr("class", "day")
      .attr("width", @cellSize)
      .attr("height", @cellSize)
      .attr("x", (d) => @week(d) * (@cellSize + @cellPad) + @cellPad/2 )
      .attr("y", (d) => @day(d) * (@cellSize + @cellPad) + @cellPad/2 )
      .datum(@format)
    @cells.append("title").text((d) -> d)
    @svg.selectAll(".month").data((d) -> d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1)) )
      .enter().append("path").attr("class", "month").attr("d", @monthPath)

  load: (filename="heatmap.json") =>
    d3.json filename, (error, json) =>
      data = d3.nest()
        .key((d) -> d.date)
        .rollup((d) -> d[0])
        .map(json)

      @cells.filter((d) -> d of data)
        .attr("class", (d) -> "day q#{data[d].severity}-11" )
        .attr("data-date", (d) -> data[d].date )
        .select("title")
        .text((d) => "#{d}: #{@severity[data[d].severity]}")

      @setData(json)

  getData: =>
    return @data

  getSvg: =>
    return @svg

  setData: (data) =>
    @data = data
    if @onLoad
      @onLoad(data)

  monthPath: (t0) =>
    cellSize = @cellSize + @cellPad
    t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0)
    d0 =+ @day(t0)
    w0 =+ @week(t0)
    d1 =+ @day(t1)
    w1 =+ @week(t1)
    path = "M" + (w0 + 1) * cellSize + "," + d0 * cellSize
    path += "H" + w0 * cellSize + "V" + 7 * cellSize
    path += "H" + w1 * cellSize + "V" + (d1 + 1) * cellSize
    path += "H" + (w1 + 1) * cellSize + "V" + 0
    path += "H" + (w0 + 1) * cellSize + "Z"
    return path

class RecentController
  constructor: (@records) ->

  loadDays: (days) ->
    today = new Date()
    since = new Date()
    since.setDate(since.getDate() - days)
    @loadDayRange(since, today)

  loadDayRange: (from, to) ->
    result = []
    console.log(from, to)
    for record in @records
      date = new Date(record.date)
      if date >= from && date <= from
        result.push {'date': date, 'events': record.events}
    return result

$ ->
  heatmap = new HeatmapController
  heatmap.generate()
  heatmap.load()

  heatmap.onLoad = (data) ->
    console.log("data loaded")
    recent = new RecentController(data)
    recent.loadDays(0)

  $('.mtr .day').on 'click', (e) ->
    # deselect others
    $('.selected').removeClass('selected')

    # select current target
    target = $(e.currentTarget)
    target.addClass('selected')

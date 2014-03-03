#= require jquery-2.1.0.min
#= require jquery-svg.pack
#= require jquery-svgdom.pack
#= require mustache
#= require d3.v3.min
#= require_tree .

$ ->
  heatmap = new HeatmapController
  heatmap.generate()
  heatmap.load()
  $('#date-picker').val('7')

  heatmap.onLoad = (data) ->
    recent = new RecentController(data)
    recent.loadDays(7)

    $('#date-picker').on 'change', (e) ->
      date = $(e.currentTarget).val()
      if date.id != "selected-date"
        recent.loadDays(date)
      else
        date = new Date($('#selected-date').text())
        recent.loadDayRange(date, date)

    $('.mtr .day').on 'click', (e) ->
      # deselect others
      $('.selected').removeClass('selected')

      # select current target
      target = $(e.currentTarget)
      target.addClass('selected')

      # display selected date
      date = new Date(target.data('date'))
      recent.loadDayRange(date, date)
      $('#date-picker').append('<option value="" id="selected-date"></option>') if $('#selected-date').length == 0
      $('#selected-date').text(target.data('date'))

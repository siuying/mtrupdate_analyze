class RecentController
  constructor: (records) ->
    @records = records 
    formatDate = () ->
      "#{@date.getFullYear()}年 #{@date.getMonth()+1}月 #{@date.getDate()+1}日"

    for record in @records
      record.date = new Date(record.date)
      record.formattedDate = formatDate

  loadDays: (days) ->
    today = new Date()
    since = new Date()
    since.setDate(since.getDate() - days)
    @loadDayRange(since, today)

  loadDayRange: (from, to) ->
    result = []
    result.push(record) for record in @records when record.date >= from and record.date <= to and record.events.length > 0
    result.sort (r1, r2) -> r1.date <= r2.date
    @generateRecent(result)
    return result

  generateRecent: (records) ->
    if records.length > 0
      template = "{{#records}}<h4>{{formattedDate}}</h4><table class='delay'>"
      template += "{{#events}}<tr class='severity{{severity}}'><td class='time' valign='top'>{{time}}</td> <td class='text' valign='top'>{{text}}</td></tr>{{/events}}"
      template += "</table>{{/records}}"
      html = Mustache.render template, {records: records}
    else
      html = "<p>所選期間沒有延誤</p>"
    $("#recent").html(html)

window.RecentController = RecentController
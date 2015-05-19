###
jQuery yacal Plugin v0.2.0
https://github.com/eduludi/jquery-yacal

Authors:
 - Eduardo Ludi @eduludi
 - Some s took from Pickaday: https://github.com/dbushell/Pikaday
   (David Bushell @dbushell and Ramiro Rikkert @RamRik)
 - isLeapYear: Matti Virkkunen (http://stackoverflow.com/a/4881951)
        
Released under the MIT license
###

(( $, doc, win ) ->
  "use strict"

  _name = 'yacal'

  # globals
  _d = null
  _tpl = {}
  _i18n = {}
  _opts = {}

  # placeholders
  _ph = {
    ts: '<#timestamp#>'
    d: '<#day#>'
    we: '<#weekend#>'
    t: '<#today#>'
    s: '<#selected#>'
    a: '<#active#>'
    wn: '<#weekNumber#>'
    wd: '<#weekday#>'
    wdnam: '<#weekdayName#>'
    wdnum: '<#weekdayNumber#>'
    mnam: '<#monthName#>'
    mnum: '<#monthNumber#>'
    md: '<#monthDays#>'
    y: '<#year#>'
  }

  isDate = (obj) ->
    (/Date/).test(Object.prototype.toString.call(obj)) and !isNaN(obj.getTime())

  isWeekend = (date) ->
    date.getDay() in [0,6]

  inRange = (date) ->
    # Validate dates
    vmi = isDate(_opts.minDate)
    vmx = isDate(_opts.maxDate)

    if vmi and vmx
      _opts.minDate <= date and date <= _opts.maxDate
    else if vmi
      _opts.minDate <= date
    else if vmx
      date <= _opts.maxDate
    else
      true

  zeroHour = (date) ->
    date.setHours(0,0,0,0)

  isToday = (date) ->
    zeroHour(date) == zeroHour(new Date())

  isSelected = (date) ->
    zeroHour(_d) == zeroHour(date)

  isLeapYear = (year) ->
    year % 4 == 0 and year % 100 != 0 || year % 400 == 0

  getDaysInMonth = (year, month) ->
    [31, (if isLeapYear(year) then 29 else 28),31,30,31,30,
     31,31,30,31,30,31][month]

  getWeek = (date) ->
    onejan = new Date(date.getFullYear(), 0, 1)
    Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7)

  changeMonth = (date,amount) ->
    new Date(date.getFullYear(),(date.getMonth() + amount),1)

  renderDay = (date) ->
    _tpl.day.replace(_ph.ts, date.getTime())
            .replace(_ph.d, date.getDate())
            .replace(_ph.we, if isWeekend(date) then ' weekend' else '')
            .replace(_ph.t, if isToday(date) then ' today' else '')
            .replace(_ph.s, if isSelected(date) then ' selected' else '')
            .replace(_ph.a, if inRange(date) then ' active' else '')
            .replace(_ph.wd, date.getDay())
  
  renderMonth = (date) ->
    totalDays = getDaysInMonth(date.getYear(),date.getMonth())
    month = date.getMonth()
    year = date.getFullYear()
    out = ''

    # weekdays
    if _opts.showWD
      wd = 0
      out += _tpl.weekOpen.replace(_ph.wn,wd)
      while wd <= 6
        out += _tpl.weekday.replace(_ph.wdnam,_i18n.weekdays[wd])
                            .replace(_ph.wdnum,wd)
        wd++
      out += _tpl.weekClose;

    # month days
    d = 0
    while d < totalDays
      day = new Date(year,month,d+1)

      if 0 in [d,day.getDay()]
        out += _tpl.weekOpen.replace(_ph.wn,getWeek(day))

      out += renderDay(day,_tpl.day)
      
      if (d == totalDays-1 || day.getDay() == 6)
        out += _tpl.weekClose

      d++

    # replace placeholders and return the output
    _tpl.month.replace(_ph.mnum,month)
              .replace(_ph.mnam,_i18n.months[month])
              .replace(_ph.y,year)
              .replace(_ph.md,out)

  _config = (date,tpl,i18n,opts) ->
    _d = date
    _tpl = tpl
    _i18n = i18n
    _opts = opts
    this

  # Plugin definition
  $.fn.yacal = ( options ) ->
    opts = $.extend(true,{}, $.fn.yacal.defaults, options )

    this.each( () ->
      out = '';
      # set config from data-* atrributes
      if ($(this).data())
        opts = $.extend( true, {}, opts, $(this).data() )

      # Ensures get a date
      opts.date = new Date(opts.date)

      # Config
      _config(opts.date,
        opts.tpl,
        opts.i18n,
        {
          nearMonths: parseInt(opts.nearMonths),
          showWD: !!opts.showWeekdays,
          minDate: new Date(opts.minDate) if opts.minDate,
          maxDate: new Date(opts.maxDate) if opts.maxDate,
          firstDay: parseInt(opts.firstDay),
        }
      )

      # Render previous month[s]
      if _opts.nearMonths
        pm = _opts.nearMonths
        while pm > 0
          out += renderMonth(changeMonth(opts.date,-pm))
          pm--

      # Render selected month
      out += renderMonth(opts.date);

      # Render next[s] month[s]
      if _opts.nearMonths
        nm = 1
        while nm <= _opts.nearMonths
          out += renderMonth(changeMonth(opts.date,+nm))
          nm++

      # add the output to the dom element
      $(this).append(out)
    )

  # Defaults
  $.fn.yacal.defaults = {
    date: new Date(),
    nearMonths: 0,
    showWeekdays: true,
    mimDate: null,
    maxDate: null,
    tpl: {
      day: '<a class="day day'+_ph.wd+''+_ph.we+''+_ph.t+''+_ph.s+''+_ph.a+'"
               data-time="'+_ph.ts+'">'+_ph.d+'</a>',

      weekday: '<i class="wday wday'+_ph.wdnum+'">'+
                _ph.wdnam+
                '</i>',
      weekOpen: '<div class="week week'+_ph.wn+'">',
      weekClose: '</div>',
      month: '<div class="month month'+_ph.mnum+'">'+
               '<h4>'+_ph.mnam+' '+_ph.y+'</h4>'+
               _ph.md+
             '</div>',
    },
    i18n: {
      weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
      months: ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sept','Oct','Nov','Dec'],
    }
  }

  # Version number
  $.fn.yacal.version = '0.1.1';

  # Autoinitialize .yacal elements on load
  $('.' + _name).yacal()

)( jQuery, document, window )
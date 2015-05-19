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
    nav: '<#nav#>'
    prev: '<#prev#>'
    next: '<#next#>'
  }

  isDate = (obj) ->
    (/Date/).test(Object.prototype.toString.call(obj)) and !isNaN(obj.getTime())

  isWeekend = (date) ->
    date.getDay() in [0,6]

  inRange = (date,min,max) ->
    # Validate dates
    vmi = isDate(min)
    vmx = isDate(max)

    if vmi and vmx
      min <= date and date <= max
    else if vmi
      min <= date
    else if vmx
      date <= max
    else
      true

  zeroHour = (date) ->
    date.setHours(0,0,0,0)

  isToday = (date) ->
    zeroHour(date) == zeroHour(new Date())

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

  # Plugin definition
  $.fn.yacal = ( options ) ->

    this.each( (index) ->
      # Instance configurations
      _d = _s = null
      _tpl = {}
      _i18n = {}
      _opts = {}

      # Instance Methods
      isSelected = (date) ->
        zeroHour(_s) == zeroHour(date)

      renderNav = () ->
        _tpl.nav.replace(_ph.prev,_i18n.prev)
                .replace(_ph.next,_i18n.next)

      renderDay = (date) ->
        _tpl.day.replace(_ph.ts, date.getTime())
                .replace(_ph.d, date.getDate())
                .replace(_ph.we, if isWeekend(date) then ' weekend' else '')
                .replace(_ph.t, if isToday(date) then ' today' else '')
                .replace(_ph.s, if isSelected(date) then ' selected' else '')
                .replace(_ph.a, if inRange(date,_opts.minDate,_opts.maxDate) then ' active' else '')
                .replace(_ph.wd, date.getDay())
      
      renderMonth = (date,nav=false) ->
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
                  .replace(_ph.nav,if nav then renderNav() else '')
                  .replace(_ph.y,year)
                  .replace(_ph.md,out)

      renderCalendar = (element) ->
        out = ''
        # Render previous month[s]
        if _opts.nearMonths
          pm = _opts.nearMonths
          while pm > 0
            out += renderMonth(changeMonth(_d,-pm))
            pm--

        # Render selected month
        out += renderMonth(_d,true);

        # Render next[s] month[s]
        if _opts.nearMonths
          nm = 1
          while nm <= _opts.nearMonths
            out += renderMonth(changeMonth(_d,+nm))
            nm++

        # add the output to the dom element
        $(element).html('')
        $(element).append($(_tpl.wrap).append(out))

        # Navigation Events
        $(element).find('.yclPrev').on 'click', ->
          _d = changeMonth(_d,-1)
          renderCalendar($(element))
        $(element).find('.yclNext').on 'click', ->
          _d = changeMonth(_d,+1)
          renderCalendar($(element))

      # get config from defaults
      opts = $.extend(true,{}, $.fn.yacal.defaults, options )

      # get config from data-* atrributes
      opts = $.extend( true, {}, opts, $(this).data() ) if ($(this).data())

      # Config
      _d = _s = new Date(opts.date) # Ensures get a date
      _tpl = opts.tpl
      _i18n = opts.i18n
      _opts = {
        nearMonths: parseInt(opts.nearMonths),
        showWD: !!opts.showWeekdays,
        minDate: new Date(opts.minDate) if opts.minDate,
        maxDate: new Date(opts.maxDate) if opts.maxDate,
        firstDay: parseInt(opts.firstDay),
      }

      renderCalendar(this)
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
               _ph.nav+
               '<h4>'+_ph.mnam+' '+_ph.y+'</h4>'+
               _ph.md+
             '</div>',
      nav: '<div class="nav">'+
              '<a class="yclPrev"><span>'+_ph.prev+'</span></a>'+
              '<a class="yclNext"><span>'+_ph.next+'</span></a>'+
           '</div>'
      wrap: '<div class="wrap"></div>'
    },
    i18n: {
      weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
      months: ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sept','Oct','Nov','Dec'],
      prev: 'prev',
      next: 'next',
    }
  }

  # Version number
  $.fn.yacal.version = '0.1.1';

  # Autoinitialize .yacal elements on load
  $('.' + _name).yacal()

)( jQuery, document, window )
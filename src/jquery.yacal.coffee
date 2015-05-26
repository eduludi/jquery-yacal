###
jQuery yacal Plugin v0.2.0
https://github.com/eduludi/jquery-yacal

Authors:
 - Eduardo Ludi @eduludi
 - Some ideas from Pickaday: https://github.com/dbushell/Pikaday
   (thanks to David Bushell @dbushell and Ramiro Rikkert @RamRik)
 - isLeapYear: Matti Virkkunen (http://stackoverflow.com/a/4881951)
        
Released under the MIT license
###

(( $, doc, win ) ->
  "use strict"

  _name = 'yacal' # plugin's name
  _version = '0.3.1'

  _msInDay = 86400000 # milliseconds in a day
  _eStr = '' # empty string

  # placeholders
  _ph =
    d: '#day#'
    dt: '#time#'
    dw: '#dayWeek#'
    we: '#weekend#'
    t: '#today#'
    s: '#selected#'
    a: '#active#'
    w: '#week#'
    ws: '#weekSelected#'
    wt: '#weekTime#'
    wd: '#weekday#'
    wdn: '#weekdayName#'
    m: '#month#'
    mnam: '#monthName#'
    y: '#year#'
    nav: '#nav#'
    prev: '#prev#'
    next: '#next#'

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
    date.setHours(0,0,0,0) # !!!: setHours() returns a timestamp

  isToday = (date) ->
    zeroHour(date) == zeroHour(new Date())

  isLeapYear = (year) ->
    year % 4 == 0 and year % 100 != 0 || year % 400 == 0

  getDaysInMonth = (year, month) ->
    s = 30 # short month
    l = 31 # long month
    f = (if isLeapYear(year) then 29 else 28) # febraury
    [l,f,l,s,l,s,l,l,s,l,s,l][month]

  getWeekNumber = (date) ->
    onejan = new Date(date.getFullYear(), 0, 1)
    Math.ceil((((date - onejan) / _msInDay) + onejan.getDay() + 1) / 7)

  getWeekStart = (date) ->
    new Date(zeroHour(date) - date.getDay()*_msInDay)

  getWeekEnd = (weekStartDate) ->
    new Date(weekStartDate.getTime() + (7 * _msInDay) - 1)

  changeMonth = (date,amount) ->
    new Date(date.getFullYear(),(date.getMonth() + amount),1)

  tag = (name,classes,content,data) ->
    '<'+name+' '+
      (if classes then ' class="'+classes+'"' else _eStr)+
      (if data then ' data-'+data else _eStr)+'>'+
      (if content then content else _eStr) +
    '</'+name+'>'

  # Plugin definition
  $.fn.yacal = ( options ) ->

    this.each( (index) ->
      
      # _d = Current date, _s = Selected date
      _d = _s = null

      # template  & internationalization settings
      _tpl = {}
      _i18n = {}

      # other settings
      _nearMonths = _showWD = _minDate = _maxDate = _firstDay = null

      # runtime templates parts
      _weekPart = _monthPart = null

      # Instance Methods
      isSelected = (date) ->
        zeroHour(_s) == zeroHour(date)

      isSelectedWeek = (wStart) ->
        inRange(_s,wStart,getWeekEnd(wStart))

      renderNav = () ->
        _tpl.nav.replace(_ph.prev,_i18n.prev)
                .replace(_ph.next,_i18n.next)

      renderDay = (date) ->
        _tpl.day.replace(_ph.d, date.getDate())
                .replace(_ph.dt, date.getTime())
                .replace(_ph.dw, date.getDay())
                .replace(_ph.we, if isWeekend(date) then ' weekend' else _eStr)
                .replace(_ph.t, if isToday(date) then ' today' else _eStr)
                .replace(_ph.s, if isSelected(date) then ' selected' else _eStr)
                .replace(_ph.a, if inRange(date,_minDate,_maxDate) then ' active' else _eStr)
      
      renderMonth = (date,nav=false) ->
        d = 0
        out = _eStr
        month = date.getMonth()
        year = date.getFullYear()
        totalDays = getDaysInMonth(date.getYear(),date.getMonth())

        # weekdays
        if _showWD
          wd = 0
          out += _weekPart[0].replace(_ph.w,wd)
                              .replace(_ph.wt,_eStr)
                              .replace(_ph.ws,_eStr)
          while wd <= 6
            out += _tpl.weekday.replace(_ph.wdn,_i18n.weekdays[wd])
                                .replace(_ph.wd,wd++)
          out += _weekPart[1]

        # month weeks and days
        while d < totalDays
          day = new Date(year,month,d+1)

          if 0 in [d,day.getDay()]
            wStart = getWeekStart(day)
            selWeek = if isSelectedWeek(wStart) then ' selected' else _eStr
            out += _weekPart[0].replace(_ph.w, getWeekNumber(day))
                                .replace(_ph.wt, wStart)
                                .replace(_ph.ws, selWeek)
          d++
          out += renderDay(day,_tpl.day)

          if (d == totalDays || day.getDay() == 6)
            out += _weekPart[1]

        # replace placeholders and return the output
        _monthPart[0].replace(_ph.m,month)
                      .replace(_ph.mnam,_i18n.months[month])
                      .replace(_ph.y,year) +
                      out +
                      _monthPart[1]

      renderCalendar = (element,move) ->
        out = ''
        cal = $(element)

        if move
          _d = changeMonth(_d,move)

        # Render previous month[s]
        if _nearMonths
          pm = _nearMonths
          while pm > 0
            out += renderMonth(changeMonth(_d,-pm))
            pm--

        # Render selected month
        out += renderMonth(_d,true);

        # Render next[s] month[s]
        if _nearMonths
          nm = 1
          while nm <= _nearMonths
            out += renderMonth(changeMonth(_d,+nm))
            nm++

        # add wrap, nav, output, and clearfix to the dom element
        cal.html('').append($(_tpl.wrap).append(renderNav())
                                        .append(out)
                                        .append(_tpl.clearfix))

        # Navigation Events
        nav = cal.find('.yclNav')
        nav.find('.prev').on 'click', -> renderCalendar(cal,-1)
        nav.find('.next').on 'click', -> renderCalendar(cal,1)

      # End of instance methods -

      # get config from defaults
      opts = $.extend(true,{}, $.fn.yacal.defaults, options )

      # get config from data-* atrributes
      opts = $.extend( true, {}, opts, $(this).data() ) if ($(this).data())

      # Config
      _d = _s = new Date(opts.date) # Ensures get a date
      _tpl = opts.tpl
      _i18n = opts.i18n
      _nearMonths = +opts.nearMonths
      _showWD = !!opts.showWeekdays
      _minDate = new Date(opts.minDate) if opts.minDate
      _maxDate = new Date(opts.maxDate) if opts.maxDate
      # _firstDay = +opts.firstDay # TODO

      _weekPart = _tpl.week.split('|')
      _monthPart = _tpl.month.split('|')

      renderCalendar(this)
    )

  # Defaults
  $.fn.yacal.defaults =
    date: new Date()
    nearMonths: 0
    showWeekdays: 1
    minDate: null
    maxDate: null
    firstDay: 0
    tpl:
      day: tag('a','day d'+_ph.dw+''+_ph.we+''+_ph.t+''+_ph.s+''+_ph.a,
               _ph.d,'time="'+_ph.dt+'"')
      weekday: tag('i','wday wd'+_ph.wd,_ph.wdn)
      week: tag('div','week w'+_ph.w+_ph.ws,'|','time="'+_ph.wt+'"')
      month: tag('div','month m'+_ph.m,tag('h4',null,_ph.mnam+' '+_ph.y) + '|')
      nav: tag('div','yclNav',
                tag('a','prev',tag('span',null,_ph.prev))+
                tag('a','next',tag('span',null,_ph.next)))
      wrap: tag('div','wrap')
      clearfix: tag('div','clearfix')
    i18n:
      weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
      months: ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec'],
      prev: 'prev',
      next: 'next',

  # Version number
  $.fn.yacal.version = _version;

  # Autoinitialize .yacal elements on load
  $('.' + _name).yacal()

)( jQuery, document, window )
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
    d: '<#day#>'
    dt: '<#time#>'
    we: '<#weekend#>'
    t: '<#today#>'
    s: '<#selected#>'
    a: '<#active#>'
    w: '<#week#>'
    ws: '<#weekSelected#>'
    wt: '<#weekTime#>'
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

  tag = (name,classes,content,data) ->
    '<'+name+' '+ (if classes then ' class="'+classes+'" ' else '')+
                  (if data then 'data-'+data else '')+'>'+
                  (if content then content+'</'+name+'>' else '')

  # Plugin definition
  $.fn.yacal = ( options ) ->

    this.each( (index) ->
      # Instance configurations
      _d = _s = null
      _tpl = {}
      _i18n = {}
      _nearMonths = _showWD = _minDate = _maxDate = _firstDay = null

      # Instance Methods
      isSelected = (date) ->
        zeroHour(_s) == zeroHour(date)

      # Instance Methods
      isSelectedWeek = (wStart) ->
        wEnd = new Date(wStart.getTime() + (((7-wStart.getDay()) * 86400000) - 1))
        inRange(_s,wStart,wEnd)

      renderNav = () ->
        _tpl.nav.replace(_ph.prev,_i18n.prev)
                .replace(_ph.next,_i18n.next)

      renderDay = (date) ->
        _tpl.day.replace(_ph.d, date.getDate())
                .replace(_ph.dt, date.getTime())
                .replace(_ph.we, if isWeekend(date) then ' weekend' else '')
                .replace(_ph.t, if isToday(date) then ' today' else '')
                .replace(_ph.s, if isSelected(date) then ' selected' else '')
                .replace(_ph.a, if inRange(date,_minDate,_maxDate) then ' active' else '')
                .replace(_ph.wd, date.getDay())
      
      renderMonth = (date,nav=false) ->
        totalDays = getDaysInMonth(date.getYear(),date.getMonth())
        month = date.getMonth()
        year = date.getFullYear()
        out = ''
        d = 0

        # weekdays
        if _showWD
          wd = 0
          out += _tpl.weekOpen.replace(_ph.w,wd)
                              .replace(_ph.wt,'')
                              .replace(_ph.ws,'')
          while wd <= 6
            out += _tpl.weekday.replace(_ph.wdnam,_i18n.weekdays[wd])
                              .replace(_ph.wdnum,wd)
            wd++
          out += _tpl.weekClose;

        # month weeks and days
        while d < totalDays
          day = new Date(year,month,d+1)

          if 0 in [d,day.getDay()]
            out += _tpl.weekOpen
                    .replace(_ph.w, getWeek(day))
                    .replace(_ph.wt, day.getTime())
                    .replace(_ph.ws, if isSelectedWeek(day) then ' selected' else '')

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

        # add the output to the dom element
        $(element).html('')
        $(element).append($(_tpl.wrap).append(out))

        # Navigation Events
        nav = $(element).find('.yclNav')
        nav.find('.prev').on 'click', ->
          _d = changeMonth(_d,-1)
          renderCalendar($(element))
        nav.find('.next').on 'click', ->
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
      _nearMonths = parseInt(opts.nearMonths)
      _showWD = !!opts.showWeekdays
      _minDate = new Date(opts.minDate) if opts.minDate
      _maxDate = new Date(opts.maxDate) if opts.maxDate
      _firstDay = parseInt(opts.firstDay) # TODO

      renderCalendar(this)
    )

  # Defaults
  $.fn.yacal.defaults = {
    date: new Date(),
    nearMonths: 0,
    showWeekdays: 1,
    minDate: null,
    maxDate: null,
    tpl: {
      day: tag('a','day day'+_ph.wd+''+_ph.we+''+_ph.t+''+_ph.s+''+_ph.a,
              _ph.d,'time="'+_ph.dt+'"')
      weekday: tag('i','wday wday'+_ph.wdnum,_ph.wdnam)
      weekOpen: tag('div','week week'+_ph.w+_ph.ws,null,'time="'+_ph.wt+'"')
      weekClose: '</div>'
      month: tag('div','month month'+_ph.mnum,
               _ph.nav + tag('h4',null,_ph.mnam+' '+_ph.y) + _ph.md)
      nav: tag('div','yclNav',
              tag('a','prev',tag('span',null,_ph.prev))+
              tag('a','next',tag('span',null,_ph.next)) )
      wrap: tag('div','wrap')
    }
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
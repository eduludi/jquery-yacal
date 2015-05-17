/*!
 * jQuery yacal Plugin v0.1.0
 * https://github.com/eduludi/jquery-yacal
 *
 * Author: Eduardo Ludi
 *         Some functions took from Pickaday: https://github.com/dbushell/Pikaday 
 *         (David Bushell @dbushell and Ramiro Rikkert @RamRik)
 *         
 * Released under the MIT license
 */
(function ( $, doc, win ) {
    "use strict";
    var name = 'yacal',
    _d,
    _tpl,
    _i18n,
    isDate = function(obj) {
        return (/Date/).test(Object.prototype.toString.call(obj)) && !isNaN(obj.getTime());
    },
    isWeekend = function(date) {
        var day = date.getDay();
        return day === 0 || day === 6;
    },
    isToday = function(date) {
        var today = new Date();
        return date.setHours(0,0,0,0) === today.setHours(0,0,0,0);
    },
    isSelected = function(date) {
        return _d.setHours(0,0,0,0) === date.setHours(0,0,0,0);
    },
    isLeapYear = function(year) {
        // solution by Matti Virkkunen: http://stackoverflow.com/a/4881951
        return year % 4 === 0 && year % 100 !== 0 || year % 400 === 0;
    },
    getDaysInMonth = function(year, month) {
        return [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
    },
    getWeek = function(date) {
        var onejan = new Date(date.getFullYear(), 0, 1);
        return Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
    },
    changeMonth = function (date,amount) {
        date = new Date(date.getFullYear(),(date.getMonth() + amount),1);
        return date;
    },
    renderDay = function (date) {
        return _tpl.day.replace('<#timestamp#>',date.getTime())
                      .replace('<#day#>',date.getDate())
                      .replace('<#weekend#>',isWeekend(date) ? ' weekend' : '')
                      .replace('<#today#>',isToday(date) ? ' today' : '')
                      .replace('<#selected#>',isSelected(date) ? ' selected' : '')
                      .replace('<#weekday#>',date.getDay());
    },
    renderMonth = function (date) {
        var totalDays = getDaysInMonth(date.getYear(),date.getMonth()),
            month = date.getMonth(),
            year = date.getFullYear(),
            // monthNumber = '',
            monthName = _i18n.months[month],
            out = '';

        out += _tpl.weekOpen.replace('<#weekNumber#>','');
        for (var wd = 0; wd < _i18n.weekdays.length; wd++) {
            out += _tpl.weekday.replace('<#weekdayName#>',_i18n.weekdays[wd])
                              .replace('<#weekdayNumber#>',wd);
        }
        out += _tpl.weekClose;
        for (var i = 0; i < totalDays; i++) {
            var day = new Date(year,month,i+1);
            if (i === 0 || day.getDay() === 0) {
                out += _tpl.weekOpen.replace('<#weekNumber#>',getWeek(day));
            }
            out += renderDay(day,_tpl.day);
            if (i+1 === totalDays || day.getDay() === 6) {
                out += _tpl.weekClose;
            }
        }
        return _tpl.month.replace('<#monthNumber#>',month)
                            .replace('<#monthName#>',monthName)
                            .replace('<#year#>',year)
                            .replace('<#monthDays#>',out);
    },
    _config = function (date,tpl,i18n) {
        _d = date;
        _tpl = tpl;
        _i18n = i18n;
        return _d;
    };
    $.fn.yacal = function( options ) {
        var opts = $.extend(true,{}, $.fn.yacal.defaults, options );

        return this.each(function () {
            var out = '';
            // set config from
            if ($(this).data()) {
                opts = $.extend(true, {}, opts, $(this).data() );
            }
            // Ensures get a date
            opts.date = new Date(opts.date); 
            // Config
            _config(opts.date,opts.tpl,opts.i18n);
            // Render previous month[s]
            for (var p=opts.nearmonths; p>0 ; p--) {
                out += renderMonth(changeMonth(opts.date,-p));
            }
            // Render selected month
            out += renderMonth(opts.date);
            // Render next[s] month[s]
            for (var n=1; n<=opts.nearmonths; n++) {
                out += renderMonth(changeMonth(opts.date,+n));
            }
            // add the output to the dom element
            $(this).append(out);
        });
    };
    $.fn.yacal.defaults = {
        date: new Date(),
        nearmonths: 0,
        tpl: { 
            day: '<a class="day day<#weekday#><#weekend#><#today#><#selected#>" href="#<#timestamp#>"><#day#></a>',
            weekday: '<small class="weekday weekday<#weekdayNumber#>"><#weekdayName#></small>',
            weekOpen: '<div class="week week<#weekNumber#>">',
            weekClose: '</div>',
            month: '<div class="month <#monthNumber#>"><h4><#monthName#> <#year#></h4><#monthDays#></div>',
        },
        i18n: {
            weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
            months: ['January','February','Marz','April','May','June','July','August','September','October','November','December'],
        }
    };
    $('.' + name).yacal();
    $.fn.yacal.version = '0.1.0';
}( jQuery, document, window ));
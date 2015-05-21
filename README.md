# jQuery yacal
**Y**et **A**nother **Cal**endar plugin for jQuery.

## What is yacal?
Yacal is a lightweight (~3.5KB min / ~1.5kb gzip) **jQuery calendar plugin**, easy to configure and use. It comes with a default template, but you can tune up at your taste, and it also supports some basic internationalization. 

The main idea behind yacal is getting a basic calendar DOM structure that you can use as you please. So, do whatever you want with it. 

## What is not?
* It's **not a Date Picker** (but you can build one with it adding some lines of jQuery and Monent.js in your project)
* It's **not a Events Calendar** (again, you can do some basic jQuery stuff and get events calendar working too)

## Demo

Here is a **[Demo page](http://eduludi.github.io/jquery-yacal/demo.html)**

## Installation

**yacal** only requires [jQuery](http://jquery.com) (>= v1.8.x) as dependency. So, just include the script *after* the jQuery library (unless you are packaging scripts somehow else):


```html
<!-- uncompressed (~7.2kb, for development) --> 
<script src="/path/to/jquery.yacal.js"></script>

<!-- OR compressed (~3.5kb, for production) --> 
<script src="/path/to/jquery.yacal.min.js"></script>
```

> Note: yacal's javascripts and stylesheets are located in project's `dist` folder

## Usage

### With `data-*` attributes

```html
<div class="yacal" data-date="2020/10/26" data-near-months="2"></div>
```

### with Javascript

```html
<div id="calendar2000"></div>
```

```javascript
$('#calendar2000').yacal({
	date: '2000/1/1',
	nearmonths: 1,
});
```

### Default Configurations

```javascript
options = {
	date: new Date(),    // Sets the date. i.e: '2010/10/10', '2012/06' , default is now
	nearMonths: 0,       // How many months will be displayed to each side. Default is 0
	showWeekdays: true,  // Toggles the week days ('Su','Mo','Tu',etc). Default is true
	minDate: null,       // Sets the minimal date range (inclusive). For markup only. Default is null
	maxDate: null,       // Sets the maximal date range (inclusive). For markup only. Default is null
	//firstDay: 0,       // Sets the first day of the week. Default is 0 (Sunday) (TODO)
});

$('#aDefaultCalendar').yacal(options);
```

## CSS Styles

There is a CSS file in the project (`dist/jquery.yacal.css`) with some basic definitions for yacal's default template.

## Templates

In yacal is possible to configure the resulting output. The plugin provides access to all the templates used in the rendering. Just keep in mind that every month has this structure:

```html
<!-- pseudo-html -->
<wrap>
	<nav/>
	<month>
		<monthTitle/>
		<weeksdays/>
		<week>
			<day /> 
			<day /> 
			...
		<week/>
		...
	</month>
	...
	<clearfix/>
</wrap>
``` 

Default templates:

```javascript
$('.calendar').yacal({
  tpl: { 
    day: '<a class="day d#weekday##weekend##today##selected#" href="##timestamp#">#day#</a>',
    weekday: '<i class="weekday wd#weekday#">#weekdayName#</i>',
    week: '<div class="week week#week##weekSelected#" data-time="#weekTime#">|</div>',
    month: '<div class="month #monthNumber#"><h4>#monthName# #year#</h4>|</div>',
    nav: '<div class="yclNav">'+
           '<a class="prev"><span>#prev#</span></a>'+
           '<a class="pext"><span>#next#</span></a>'+
         '</div>'
    wrap: '<div class="wrap"></div>'
    clearfix: '<div class="clearfix"></div>'
  }
});
```
> **Note A**: in `nav`'s template, `yclNav`, `prev` and `next` should stay within the `class` attributes of both nav links and the `yclNav` wrapper, as they are required to navigate between months. Is possible to add your own classes, but don't remove these original ones. Example:

> ```javascript
$('.calendar').yacal({
  tpl: {
    // adds new classes ('myNav' and 'myNext'), 
    // but keeping the originals (`yclNav`, `prev` and `next`)
    nav: '<div class="yclNav myNav">'+
           '<a class="prev"><strong>#prev#</strong></a>'+ 
           '<a class="next myNext"><strong>#next#</strong></a>'+
         '</div>'
  }
});
> ```

> **Note B**: in `week`'s and `month`'s templates, there are pipe characters, `|`, that are also required. Is there where week's days will be placed. Example:

> ```javascript
$('.calendar').yacal({
  tpl: {
  	// Don't render weeks
    week: '|',
    // Simplifies the month header
    month: '<div class="month"><h2>#monthName#</h2>|</div>',
  }
});
> ```


#### Templates Placeholders

The plugin provides several _placeholders_ for each template. These placeholders will return specific information about current element. Except a couple of them, most are not required to be used.

##### Day's placeholders

- `#day#`: day's number in the month, from `1` to `31`
- `#weekday#`: day's number in the week, from `0` to `6`
- `#time#`: day's timestamp 
- `#weekend#`: returns 'weekend' if day is Sunday or Saturday
- `#today#`: returns 'today' if is today 
- `#selected#`: returns 'selected' if day the selected one

##### Weekday's placeholders

- `#weekday#`: day number in the week, from `0` to `6`
- `#weekdayName#`: day's name (i.e. 'Su','Mo',etc). It will depend on the i18n configurations under `tpl.weekdays`.
- `|`: here is where weeks's days will be rendered. **REQUIRED**

##### Week's placeholders

- `#week#`: week's number in the year
- `#weekTime#`: week's timestamp (millisecons since January 1st, 1970)
- `#weekSelected#`: returns 'selected' if the selected date is in this week.

##### Month's placeholders

- `#year#`: Year number (i.e. '1999','2010',etc).
- `#monthName#`: Month's name (i.e. 'January','February',etc). It will depend on the i18n configurations under `tpl.months`.
- `#monthNumber#`: Month's number, form `0` to `11`
- `|`: here is where month's days will be rendered. **REQUIRED**

##### Nav paceholders

- `#prev#`: label for "prev" navigation link. It will depend on the i18n configurations under `tpl.prev`. **Required for navigation**.
- `#next#`: label for "next" navigation link. It will depend on the i18n configurations under `tpl.next`. **Required for navigation**.

## I18n

Defaults:

```javascript
$('.calendar').yacal({
  i18n: {
    weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
    months: ['Jan','Feb','Mar','Apr','May','Jun',
             'Jul','Aug','Sep','Oct','Nov','Dec'],
    prev: 'prev', // prev month label
    next: 'next', // next month label
  }
});
```

#### Examples:

Spanish version

```javascript
$('.calendar').yacal({
  i18n: {
    weekdays: ['Do','Lu','Ma','Mi','Ju','Vi','Sa'],
    months: ['Ene','Feb','Mar','Abr','May','Jun',
             'Jul','Ago','Sep','Oct','Nov','Dic'],
  }
});
```

English long months names

```javascript
$('.calendar').yacal({
  i18n: {
    months: ['January','February','Marz','April','May','June',
             'July','August','September','October','November','December'],
  }
});
```

## ToDos and ideas

* Timezone support
* Configurations: 
	* First day of the week
	* Ideas?
* Move I18n and Localization to a separate file. 
* Bower support (do some testing)
* Navigation (prev/next year) ?

## Authors

- [Eduardo Ludi](http://github.com/eduludi)

- Some functions took from [Pickaday](https://github.com/dbushell/Pikaday)
(David Bushell @dbushell and Ramiro Rikkert @RamRik)

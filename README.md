# jQuery Yacal
**Y**et **A**nother **Cal**endar plugin for jQuery.

## What is yacal?
It is a lightweight jQuery calendar plugin, easy to configure and use. 
It comes with a default template, but you can tune up at your taste. 
Also supports some basic internationalization. 

The main idea behind yacal is getting a basic calendar DOM structure that you can use as you please. So, do whatever you whant with it. 

## What is not?
* It's **not a Date Picker** (but you can build one with it adding some lines of jQuery and Monent.js in your project)
* It's **not a Events Calendar** (again, you can do some basic jQuery stuff and get events calendar working too)

## Demo

Here is a **[Demo page](http://eduludi.github.io/jquery-yacal/demo.html)**

## Installation

Include script *after* the jQuery library (unless you are packaging scripts somehow else):

```html
<script src="/path/to/jquery.yacal.js"></script>
```

## Usage

### With `data-*` attributes

```html
<div class="yacal" data-date="2020/10/26" data-nearmonths="2"></div>
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

## CSS Styles

There is a CSS file in the project (`styles.css`) with some basic definitions for yacal's default template.

### Templates

In yacal is possible to configure the resulting output. The plugin provides access to all the templates used in the rendering. Just keep in mind that every month has this structure:

```html
<!-- pseudo-html -->
<month>
	<monthTitle/>
	<weeksdays/>
	<weekOpen />
		<day /> 
		<day /> 
		...
	<weekClose/>
	...
</month>
``` 

Default templates:

```javascript
$('.calendar').yacal({
	tpl: { 
		day: '<a class="day day<#weekday#><#weekend#><#today#><#selected#>" href="#<#timestamp#>"><#day#></a>',
		weekday: '<small class="weekday weekday<#weekdayNumber#>"><#weekdayName#></small>',
		weekOpen: '<div class="week week<#weekNumber#>">',
		weekClose: '</div>',
		month: '<div class="month <#monthNumber#>"><h4><#monthName#> <#year#></h4><#monthDays#></div>',
	}
});
```

Example:

```javascript
$('.calendar').yacal({
	tpl: { 
		// Adds a strong wrapping the day and remove day's taggings (today, selected, etc)
		day: '<a class="day day<#weekday#>"><strong><#day#></strong></a>',
		// Simplifies the month header
		month: '<div class="month"><h2><#monthName#></h2><#monthDays#></div>',
	}
});
```

#### - Day template

- `<#day#>`: day's number in the month, from `1` to `31`
- `<#weekday#>`: day's number in the week, from `0` to `6`
- `<#timestamp#>`: day's timestamp 
- `<#weekend#>`: returns 'weekend' if day is Sunday or Saturday
- `<#today#>`: returns 'today' if is today 
- `<#selected#>`: returns 'selected' if day the selected one

#### - Weekday template

- `<#weekdayNumber#>`: day number in the week, from `0` to `6`
- `<#weekdayName#>`: day's name (i.e. 'Su','Mo',etc). It will depend on the i18n configurations under `tpl.weekdays`.

#### - Week Open template

- `<#weekNumber#>`: week's number in the year

#### - Week close template

- (has no placeholders}

#### - Month template

- `<#monthName#>`: Month's name (i.e. 'January','February',etc). It will depend on the i18n configurations under `tpl.months`.
- `<#year#>`: Year number (i.e. '1999','2010',etc).
- `<#monthDays#>`: here is where month's days will be placed.
- `<#monthNumber#>`: Month's number, form `0` to `11`

## I18n

Defaults:

```javascript
$('.calendar').yacal({
	i18n: {
		weekdays: ['Su','Mo','Tu','We','Th','Fr','Sa'],
		months: ['January','February','Marz','April','May','June','July','August','September','October','November','December'],
	}
});
```

Example:

```javascript
$('.calendar').yacal({
	i18n: {
		// Spanish version
		weekdays: ['Do','Lu','Ma','Mi','Ju','Vi','Sa'],
		months: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
	}
});
```

## ToDos

* Navigation (prev/next month/year)
* Configurations: 
	* First day of the week
	* Date Ranges (min/max)
	* Ideas?
* Add a min/compressed version
* Bower support (testing)
* Coffescript version

## Authors

- [Eduardo Ludi](http://github.com/eduludi)

- Some functions took from [Pickaday](https://github.com/dbushell/Pikaday)
(David Bushell @dbushell and Ramiro Rikkert @RamRik)

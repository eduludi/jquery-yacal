var gulp = require('gulp');
var watch = require('gulp-watch');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var size = require('gulp-size');
// var sourcemaps = require('gulp-sourcemaps');

var src = ['src/**/*.coffee'];
var dist = 'dist';

// Compile JSs task
gulp.task('compileCoffee', function() {
	gulp.src(src)
				// .pipe(sourcemaps.init())
				.pipe(size({title: 'JS Before:'}))
				.pipe(coffee({ bare: true }))
				.pipe(concat('jquery.yacal.js'))
				.pipe(gulp.dest(dist))
				.pipe(uglify())
				.pipe(size({title: '    After:'}))
				.pipe(size({title: '    After:', gzip: true}))
				.pipe(concat('jquery.yacal.min.js'))
				// .pipe(sourcemaps.write())
				.pipe(gulp.dest(dist));
});

// Watch task
gulp.task('watch',function() {
	gulp.watch(src,['compileCoffee']);
});

gulp.task('default', ['compileCoffee', 'watch']);
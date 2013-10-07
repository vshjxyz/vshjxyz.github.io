---
layout: post
title: "Setting up Yeoman and Angular using Coffeescript"
date: 2013-10-04 16:09
comments: true
categories: [programming,frontend]
keywords: yeoman,angular,tastypie,angular.js,angularjs,coffeescript,cs,howto,tutorial
description: Brief tutorial of how to setup correctly yeoman with angular and coffeescript using Tastypie as the API backend
---

Hey! it's been a while I know, but I've been into the deep gaming world and I basically burnt all my spare time playing [Dota2](http://dota2.com/) (which btw is pretty awesome!).

Well, actually I also had the chance to study [Angular.js](http://angularjs.org/) especially after I saw that the Yeoman's [generator-angular](https://github.com/yeoman/generator-angular) has introduced the `--coffee` option to bootstrap a whole angular application written with the beloved CoffeeScript.

Unfortunately, the s**t doesn't work. I mean... there are still a few things to setup.
<!--more-->
Initial setup
---
Be sure to have installed Yeoman and his generator-angular so just basically copy this line to the shell
{% codeblock lang:bash %}
npm install -g yo generator-angular
{% endcodeblock %}
put a `sudo` in front of it if you have the global NPM packages under `/usr/lib/node_modules/` (be aware that using `sudo npm` is not the right way to install global packages, but whatever).

Let's rock the generator on a directory using
{% codeblock lang:bash %}
mkdir testapp && cd testapp && yo angular Test --coffee
{% endcodeblock %}
Yeoman will ask you a series of question, you can just take the default answers by pressing Enter.

Using the latest Angular.js library
---
So here's the first problem. The version that is included with the generator is actually outdated (`1.0.8` right now, while Angular is at `1.2.0rc` with the latest stable `1.1.5`).

{% blockquote %}
OMFG you are a retard, just use the f**king 1.0.8
{% endblockquote %}

Nice observation. Except that it's stupid and you sureley dont want to start a new project with an outdated library. I also need the latest version to make it easily work using my API backend ([Tastypie](http://tastypieapi.org/)). I need in particular the `transformResponse` option introduced in the `1.1.x` branch as seen [here](http://stackoverflow.com/a/17332903/771589).

To fix this issue, you have to change the `bower.json` file that you find in the root of the project that you've just created.
{% codeblock lang:javascript %}
{
  "name": "Test",
  "version": "0.0.1",
  "dependencies": {
    "angular-latest": "latest",
    "json3": "~3.2.4",
    "jquery": "~1.9.1",
    "bootstrap-sass": "~2.3.1",
    "es5-shim": "~2.0.8"
  },
  "devDependencies": {
  }
}
{% endcodeblock %}
Then launch this in the shell to remove the outdated libraries and install the new one:
{% codeblock lang:bash %}
bower uninstall angular angular-cookies angular-mocks angular-resource angular-sanitize angular-scenario
bower install
# These lines are used to compile angular
cd app/bower_components/angular-latest/
npm install
grunt package
cd ../../
{% endcodeblock %}

We also need to fix the paths in a couple of files, open up `app/index.html` and update the new path for the angular libraries
{% codeblock lang:html %}
<script src="bower_components/jquery/jquery.js"></script>
<script src="bower_components/angular-latest/build/angular.js"></script>

<!-- build:js scripts/plugins.js -->
...
<!-- endbuild -->

<!-- build:js scripts/modules.js -->
<script src="bower_components/angular-latest/build/angular-resource.js"></script>
<script src="bower_components/angular-latest/build/angular-cookies.js"></script>
<script src="bower_components/angular-latest/build/angular-sanitize.js"></script>
<!-- endbuild -->
{% endcodeblock %}

Open also the `karma.conf.js` and update the paths aswell
{% codeblock lang:javascript %}
// list of files / patterns to load in the browser
files: [
  'app/bower_components/angular-latest/build/angular.js',
  'app/bower_components/angular-latest/build/angular-mocks.js',
  'app/scripts/*.coffee',
  'app/scripts/**/*.coffee',
  'test/mock/**/*.coffee',
  'test/spec/**/*.coffee'
],
{% endcodeblock %}

Setting up the tests
---
Somehow the e2e tests are not contemplated with this generator. We need to set them up opening the `Gruntfile.js`
{% codeblock lang:javascript %}
karma: {
  unit: {
    configFile: 'karma.conf.js',
    singleRun: true
  }
},
// Substitute this piece of code with this
karma: {
  e2e: {
    configFile: 'karma-e2e.conf.js',
  },
  unit: {
    configFile: 'karma.conf.js',
  }
},
{% endcodeblock %}
And at the bottom of the file
{% codeblock lang:javascript %}
  // REMOVE THIS TASK
  grunt.registerTask('test', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma'
  ]);

  // Change that piece of code with these two, to enable the test:unit and test:e2e tasks
  grunt.registerTask('test:unit', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma:unit'
  ]);

  grunt.registerTask('test:e2e', [
    'clean:server',
    'concurrent:test',
    'autoprefixer',
    'connect:livereload',
    'karma:e2e'
  ]);
{% endcodeblock %}
This operation will enable two different tasks that you can launch with `grunt test:unit` and `grunt test:e2e` with their respective behaviour.

Basic example of a RESTful Angular service calling Tastypie API
---
So, if you have followed the steps you should be able to run the application using `grunt server` and see the typical Yeoman greeting:

[{% imgcap center /images/setting-up-yeoman-and-angular-using-coffeescript/alloallo.png 400 223 The Yeoman base view - click to zoom %}](/images/setting-up-yeoman-and-angular-using-coffeescript/alloallo.png)

Let's get and display a list via AJAX then. First, we have to create a new service using `yo angular:factory MyObject`. This will create two files, one is the real service, the other is the corresponding test file.

Open the new file under `app/scripts/services/MyObject.coffee` and substitute it with this:
{% codeblock lang:coffeescript %}
'use strict';

angular.module('TestApp.services', ['ngResource']).factory 'MyObject',['$resource', '$http', ($resource, $http) ->
    $resource 'http://localhost:8000\:8000/your/api/endpoint/', {}, {
        query:
            method: 'GET'
            isArray: true
            transformResponse: $http.defaults.transformResponse.concat [(data, headersGetter) ->
                if data? and data isnt ''
                    result = data.objects
                    result.meta = data.meta
                    result
            ]
    }
]
{% endcodeblock %}
This will:
* Inject the `ngResource` object inside the factory, allowing us to define a new `$resource`
* Inject the `$http` object inside the factory to allow us to extend the `transformResponse` method (mandatory if you are using Tastypie as your API backend)
* Define your new resource as MyObject
* Define the module `TestApp.services` where you will can all the services of this app

This is what the main controller has become:
{% codeblock lang:coffeescript %}
'use strict'

angular.module('TestApp.controllers', []).controller 'MainCtrl', ['$scope', 'MyObject', ($scope, MyObject) ->
    MyObject.query().$then (objects) ->
        $scope.objects = objects.data
]
{% endcodeblock %}

This code will inject our factory object inside the main controller. The controller will then query the object and then inject in the `$scope` the resulting items.

Finally, we can add some super simple code in our main controller view (HTML) to dump the list:
{% codeblock lang:html %}
{% raw %}
<div class="hero-unit">
  <h1>Here's my list of objects</h1>
  <ul>
      <li ng-repeat="object in objects">{{object.name}}</li>
  </ul>
</div>
{% endraw %}
{% endcodeblock %}

Running the application with a proper Tastypie API, will return you the list of objects name:

[{% imgcap center /images/setting-up-yeoman-and-angular-using-coffeescript/objects.png 400 168 The Yeoman base view - click to zoom %}](/images/setting-up-yeoman-and-angular-using-coffeescript/objects.png)

This is pretty straightforward and I know that the tests are lacking but **I'M WORKING ON IT** OK??!

:) well, I'll try to update / post more stuff about AngularJS as soon as I discover new 'things'. Peace out.
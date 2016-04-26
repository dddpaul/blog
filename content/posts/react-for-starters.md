+++
date = "2016-04-15T13:00:00+03:00"
draft = false
title = "Быстрое погружение в React"
tags = [ "React", "JavasScript" ]
+++

Для разогрева:

* [React tutorial](https://facebook.github.io/react/docs/tutorial.html)
* [Курс на Хекслете](https://ru.hexlet.io/courses/reactjs)

После этого более-менее должно оформиться понимание, что:

* React - это V в MVC;
* основа React - это компоненты;
* у компонента есть главный метод render(), который дергается React'ом, когда нужно отобразить или перерисовать компонент;
* компоненты инициализируется через properties, и хранят state;
* компоненты пишутся на JSX - специальный синтаксис, который "бесшовно" внедряет HTML в JS;
* компоненты можно связывать в иерархические структуры;
* состояние нельзя менять напрямую, а только через специальный метод setState() - таким образом React точно узнает, что состояние изменилось и объект надо перерисовать;
* состояние принято хранить в родительском компоненте, и передавать его в дочерние компоненты через properties.

Далее надо слегка погрузиться в ECMAScript 6 aka ES2015:

* [ES-2015 сейчас](https://learn.javascript.ru/es-modern-usage) - введение
* [Learn ES2015](https://babeljs.io/docs/learn-es2015/) - кратенько про отличия от ES5
* [ECMAScript 6: classes](http://www.2ality.com/2012/07/esnext-classes.html) - новый синтаксис классов
* [ECMAScript 6: arrow functions and method definitions](http://www.2ality.com/2012/04/arrow-functions.html) - лямбды!
* [Learning ES6: Enhanced object literals](http://www.benmvp.com/learning-es6-enhanced-object-literals/) - less boilerplate in objects
* [React на ES6+](https://habrahabr.ru/post/262183/) - кратко обо всем, пока не читал

Теперь рекомендую форкнуть [React tutorial](https://github.com/reactjs/react-tutorial) и поиграться с ним, например:

* перевести проект на Webpack для дальнейшей работы с модулями, см. [Setting up React for ES6 with Webpack and Babel](https://www.twilio.com/blog/2015/08/setting-up-react-for-es6-with-webpack-and-babel-2.html)
* подключить live and [hot reload](http://gaearon.github.io/react-hot-loader/getstarted/);
* заменить "var" на "let/const";
* заменить определения методов внутри объектов (Enhanced object literals);
* заменить потенциально опасные манипуляции со сложным стейтом (объекты, массивы) с помощью [Array.prototype.splice()](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Array/splice) или [Array.prototype.concat()](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Array/concat) на изменения с помощью идеологически верных [Immutability Helpers](https://facebook.github.io/react/docs/update.html);
* заменить XHR-вызовы через jQuery на что-то более REST'овое, например [fetch API](https://github.com/github/fetch).

---

Кракая выжимка для начала работы с Webpack:

```
npm install --save react
npm install --save react-dom
npm install --save-dev webpack
npm install --save-dev babel-loader
npm install --save-dev babel-core
npm install --save-dev babel-preset-es2015
npm install --save-dev babel-preset-react
npm install --save-dev react-hot-loader
```

Для запуска webpack-dev-server надо запустить в $HOME:

```
npm install webpack-dev-server
```

В этом случае webpack-dev-server будет установлен в $HOME/node_modules, и симлинк на него будет в $HOME/node_modules/.bin. Этот каталог уже можно включить в $PATH и запускать webpack и webpack-dev-server из любого места.

Типовое содержимое webpack.config.js:

{{< highlight javascript >}}
var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: './public/scripts/example.js',
  output: {
    path: __dirname + "/public/build",
    filename: 'bundle.js'
  },
  module: {
    loaders: [{
      test: /.jsx?$/,
      loaders: ["react-hot", "babel-loader?presets[]=react,presets[]=es2015"],
      exclude: /node_modules/
    }]
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(), // don't reload if there is an error
  ]
};
{{< /highlight >}}

Теперь можно запустить `webpack -w` и, при любых изменениях js-файлов, будет автоматически пересобираться bundle.js. Reload в браузере все-таки придется сделать. Полноценный hot&live reload можно организовать только с помощью webpack-dev-server.
 
---

Про модули:

* [Модули в ECMAScript 6: будущее уже сейчас](http://frontender.info/es6-modules/)
* [Babel and CommonJS modules](http://www.2ality.com/2015/12/babel-commonjs.html)
* [Пакуем как боги](http://frontender.info/packing-the-web-like-a-boss/)
* [Как мы готовим React, Require и Backbone](https://habrahabr.ru/post/250103/)
* [Webpack — The Confusing Parts](https://medium.com/@rajaraodv/webpack-the-confusing-parts-58712f8fcad9#.7ffl30blv)

Про компоненты:

* [Reusable Components](https://facebook.github.io/react/docs/reusable-components.html) - пока не читал

---

Внедрение [fetch API](https://github.com/github/fetch):

```
npm install --save whatwg-fetch
npm install --save imports-loader exports-loader
```

Остальные ссылки по fetch:

* [fetch API](https://davidwalsh.name/fetch)
* [Введение в fetch](https://habrahabr.ru/post/252941/)
* [This API is so Fetching!](https://hacks.mozilla.org/2015/03/this-api-is-so-fetching/)
* [Using webpack with shims and polyfills](http://mts.io/2015/04/08/webpack-shims-polyfills/)

---

Переходим к тяжелым упражнениям:

* [React.js and Spring Data REST](https://spring.io/guides/tutorials/react-and-spring-data-rest/) - мегаматериал про связку со Spring Boot

Чтобы не ставить nodejs, npm и bower локально, можно использовать:

* [Frontend maven plugin](https://github.com/eirslett/frontend-maven-plugin) - для проектов на Java
* Docker-образ [Node.js w/ Bower & Grunt](https://github.com/DigitallySeamless/docker-nodejs-bower-grunt) - для всего остального

Но проще всего установить nodejs & npm с https://nodejs.org.

Дополнительные компоненты:

* [React-Bootstrap](https://react-bootstrap.github.io/) - Bootstrap-компоненты, переписанные на React
* [react-bootstrap-table](https://github.com/AllenFang/react-bootstrap-table) - крутая Bootstrap-compartible табличка

Тестирование:

* [ReactTestUtils](http://facebook.github.io/react/docs/test-utils.html)

Просто интересные ресурсы:

* [Spring Boot and React hot loader](http://geowarin.github.io/spring-boot-and-react-hot.html) - пока не читал
* [The React.js Way: Getting Started Tutorial](https://blog.risingstack.com/the-react-way-getting-started-tutorial/) - пока не читал
* [Spring Boot React Example](https://github.com/winterbe/spring-react-example)

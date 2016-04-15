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

* [Learn ES2015](https://babeljs.io/docs/learn-es2015/) - кратенько про отличия от ES5
* [ECMAScript 6: classes](http://www.2ality.com/2012/07/esnext-classes.html)
* [ECMAScript 6: arrow functions and method definitions](http://www.2ality.com/2012/04/arrow-functions.html)
* [Learning ES6: Enhanced object literals](http://www.benmvp.com/learning-es6-enhanced-object-literals/)

Теперь рекомендую форкнуть [React tutorial](https://github.com/reactjs/react-tutorial) и поиграться с ним, например:

* заменить "var" на "let/const";
* заменить определения методов внутри объектов (Enhanced object literals);
* заменить потенциально опасные манипуляции со сложным стейтом (объекты, массивы) с помощью [Array.prototype.splice()](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Array/splice) или [Array.prototype.concat()](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Array/concat) на изменения с помощью идеологически верных [Immutability Helpers](https://facebook.github.io/react/docs/update.html).

Про модули:

* [Модули в ECMAScript 6: будущее уже сейчас](http://frontender.info/es6-modules/)
* [Как мы готовим React, Require и Backbone](https://habrahabr.ru/post/250103/)

Переходим к тяжелым упражнениям:

* [React.js and Spring Data REST](https://spring.io/guides/tutorials/react-and-spring-data-rest/) - мегаматериал про связку со Spring Boot

Чтобы не ставить nodejs, npm и bower локально, можно использовать:

* [Frontend maven plugin](https://github.com/eirslett/frontend-maven-plugin) - для проектов на Java
* [Node.js w/ Bower & Grunt](https://github.com/DigitallySeamless/docker-nodejs-bower-grunt) - для всего остального

Дополнительные компоненты:

* [React-Bootstrap](https://react-bootstrap.github.io/) - Bootstrap-компоненты, переписанные на React
* [react-bootstrap-table](https://github.com/AllenFang/react-bootstrap-table) - крутая Bootstrap-compartible табличка

Тестирование:

* [ReactTestUtils](http://facebook.github.io/react/docs/test-utils.html)

Просто интересные ресурсы:

* [Spring Boot and React hot loader](http://geowarin.github.io/spring-boot-and-react-hot.html) - пока не читал
* [The React.js Way: Getting Started Tutorial](https://blog.risingstack.com/the-react-way-getting-started-tutorial/) - пока не читал
* [Spring Boot React Example](https://github.com/winterbe/spring-react-example)

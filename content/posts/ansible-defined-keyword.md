+++
date = "2015-11-29T10:45:00+03:00"
draft = false
title = "Ansible: \"defined\" keyword"
series = [ "Ansible tips and tricks" ]
tags = ["Ansible", "Python"]

+++

Some hidden knowledge for the start:

First of all, the Ansible ```when``` clause contains a Jinja2 expression (see [Ansible playbook conditionals](http://docs.ansible.com/ansible/playbooks_conditionals.html)). It's confirmed with a quote from [Ansible: Up And Running](http://shop.oreilly.com/product/0636920035626.do), page 41:

> Ansible also uses the **Jinja2 template engine** to evaluate variables in playbooks.

Secondly, that how [Jinja2](http://jinja.pocoo.org/docs/dev/templates/) interprets the ```if``` condition:

> The if statement in Jinja is comparable with the Python if statement. In the simplest form, you can use it to test if **a variable is defined, not empty or not false**.

Third, a bit of truth about [Python](https://www.python.org/dev/peps/pep-0008/):
                  
> For sequences, (strings, lists, tuples), use the fact that **empty sequences are false**.

More detailed — [5.1. Truth Value Testing](https://docs.python.org/2/library/stdtypes.html):

> Any object can be tested for truth value, for use in an if or while condition or as operand of the Boolean operations below. The following values are considered false:
>
> * `None`
> * `False`
> * zero of any numeric type, for example, `0`, `0L`, `0.0`, `0j`
> * any empty sequence, for example, `''`, `()`, `[]`
> * any empty mapping, for example, `{}`
> * instances of user-defined classes, if the class defines a `__nonzero__()` or `__len__()` method, when that method returns the integer zero or bool value False.
>
> All other values are considered true — so objects of many types are always true.
>
> Operations and built-in functions that have a Boolean result always return 0 or False for false and 1 or True for true, unless otherwise stated. (Important exception: the Boolean operations or and and always return one of their operands.)

At last, a quote from [Ansible: Up And Running](http://shop.oreilly.com/product/0636920035626.do), page 23:

> Ansible is pretty flexible on how you represent truthy and falsey values in playbooks. Strictly speaking, module arguments (like ```update_cache=yes```) are treated differently from values elsewhere in playbooks (like ```sudo: True```). Values elsewhere are handled by the YAML parser and so use the YAML conventions of truthiness, which are:
>
> *YAML truthy:* true, True, TRUE, yes, Yes, YES, on, On, ON, y, Y
>
> *YAML falsey:* false, False, FALSE, no, No, NO, off, Off, OFF, n, N
>
> Module arguments are passed as strings and use Ansible’s internal conventions, which are:
>
> *module arg truthy:* yes, on, 1, true
>
> *module arg falsey:* no, off, 0, false

Why all of these are important? Because there are plenty of redundant ```if``` and ```when``` conditionals usage in Ansible playbooks and templates. For example in [debops/ansible-nginx](https://github.com/debops/ansible-nginx/blob/master/tasks/main.yml):

```
- name: Manage local server definitions - create symlinks
  file:
    src: '/etc/nginx/sites-local/{{ item.0 }}'
    path: '/etc/nginx/sites-enabled/{{ item.1 }}'
    state: 'link'
    owner: 'root'
    group: 'root'
    mode: '0644'
  with_together:
    - '{{ nginx_local_servers.values() }}'
    - '{{ nginx_local_servers.keys() }}'
  notify: [ 'Test nginx and reload' ]
  when: ((nginx_local_servers is defined and nginx_local_servers) and
         (item.0 is defined and item.0))
```

See that overbloated ```when``` condition? Wouldn't be that simpler with ```when: nginx_local_servers and item.0```?
 
Though it's not a complete equivalent because it evaluates to False when nginx_local_servers **is defined and empty**. But it's definitely correct behaviour — surely we have no usage for the empty servers string.
  
It's all just mere words without proper testing, so let's test long version ```var is defined and var```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if var is defined and var %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(var=None)
 False 
>>> print tmpl.render(var='')
 False 
>>> print tmpl.render(var='abc')
 True 
>>> print tmpl.render(var=' ')
 True 
>>> print tmpl.render(var=[])                                                                                                                                                                                                                                           
 False 
>>> print tmpl.render(var=['list'])
 True 
>>> print tmpl.render(var={})                                                                                                                                                                                                                                           
 False 
>>> print tmpl.render(var={'key': 'value'})                                                                                                                                                                                                                             
 True 
{{< /highlight >}}

And the short version — ```var```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if var %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(var=None)
 False 
>>> print tmpl.render(var='')
 False 
>>> print tmpl.render(var='abc')
 True 
>>> print tmpl.render(var=' ')
 True 
>>> print tmpl.render(var=[])
 False 
>>> print tmpl.render(var=['list'])
 True 
>>> print tmpl.render(var={})
 False 
>>> print tmpl.render(var={'key': 'value'})
 True 
{{< /highlight >}}

So there are no differences at all. For the sake of thrust, let's test ```var is defined```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if var is defined %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(var=None)
 True 
>>> print tmpl.render(var='')
 True 
>>> print tmpl.render(var='abc')
 True 
>>> print tmpl.render(var=' ')
 True 
{{< /highlight >}}

So just use ```var``` and not ```var is defined and var```, Luke!

+++
date = "2015-11-29T10:45:00+03:00"
draft = false
title = "Proper conditions in Ansible playbooks"
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
  
It's all just mere words without proper testing, so let's test long version ```str is defined and str```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if str is defined and str %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(str=None)
 False 
>>> print tmpl.render(str='')
 False 
>>> print tmpl.render(str='abc')
 True 
>>> print tmpl.render(str=' ')
 True 
{{< /highlight >}}

And the short version — ```str```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if str %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(str=None)
 False 
>>> print tmpl.render(str='')
 False 
>>> print tmpl.render(str='abc')
 True 
>>> print tmpl.render(str=' ')
 True 
{{< /highlight >}}

So there are no differences at all. For the sake of thrust, let's test ```str is defined```:

{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{% if str is defined %} True {% else %} False {% endif %}')
>>> print tmpl.render()
 False 
>>> print tmpl.render(str=None)
 True 
>>> print tmpl.render(str='')
 True 
>>> print tmpl.render(str='abc')
 True 
>>> print tmpl.render(str=' ')
 True 
{{< /highlight >}}

So just use ```str``` and not ```str is defined and str```, Luke!

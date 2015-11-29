+++
date = "2015-11-29T10:45:00+03:00"
draft = false
title = "Proper conditions in Ansible playbooks"
tags = ["Ansible", "Python"]

+++

**1.** First, a quote from http://docs.ansible.com/ansible/playbooks_conditionals.html:

---

...

This is easy to do in Ansible, with the when clause, which **contains a Jinja2 expression** (see [Variables](http://docs.ansible.com/ansible/playbooks_variables.html)).

...

If a required variable has not been set, you can skip or fail using Jinja2’s defined test. For example:

```
tasks:
    - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
      when: foo is defined

    - fail: msg="Bailing out. this play requires 'bar'"
      when: bar is undefined
```

---

**2.** Second, a quote from [Ansible: Up And Running](http://shop.oreilly.com/product/0636920035626.do), page 41:

> Ansible also uses the **Jinja2 template engine** to evaluate variables in playbooks.

**3.** Then, conditions for [Jinja2]:http://jinja.pocoo.org/docs/dev/templates/

> The if statement in Jinja is comparable with the Python if statement. In the simplest form, you can use it to test if **a variable is defined, not empty or not false**.

**4.** At last, Python - https://www.python.org/dev/peps/pep-0008/:
                  
> For sequences, (strings, lists, tuples), use the fact that **empty sequences are false**.

Why all of these are important? Because there are plenty of redundant "if" and "when" conditionals usage in Ansible playbooks and templates. For example in [debops/ansible-nginx](https://github.com/debops/ansible-nginx/blob/master/tasks/main.yml):

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

See that overbloated "when" condition? Wouldn't be that simpler with ```when: nginx_local_servers and item.0```? It's not a complete equivalent because it evaluates to False when nginx_local_servers is defined and empty. But it's definitely correct behaviour — surely we have no usage for empty servers string.
  
It's all just mere words without proper testing, so lets test long version **str is defined and str**:

```
>>> from jinja2 import Template
>>> tmpl = Template('{% if str is defined and str %} True {% else %} False {% endif %}')
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
```

And the short version - just **str**:

```
>>> from jinja2 import Template
>>> tmpl = Template('{% if str %} True {% else %} False {% endif %}')
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
```

So there are no differences at all.

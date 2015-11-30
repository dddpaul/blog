+++
date = "2015-11-30T10:45:00+03:00"
draft = false
title = "Ansible: \"default\" and \"bool\" filters"
series = [ "Ansible tips and tricks" ]
tags = ["Ansible", "Python"]

+++

There are plenty of ```bool``` and ```default``` filters usage in Ansible playbooks and templates. For example, in [debops/ansible-docker](https://github.com/debops/ansible-docker/blob/master/tasks/main.yml): ```when: docker_upstream| d() | bool```.

Where ```docker_upstream``` is an YAML boolean: ```docker_upstream: False```. It seems like "when" condition is [overbloated again]({{< ref "posts/ansible-conditions.md" >}}) :)  

The ```var | d() | bool``` construction is spread all over the place, for example, in [docker config template](https://github.com/debops/ansible-docker/blob/master/templates/etc/default/docker.j2):
 
```
{% if docker_listen | d() | bool %}
```

Where ```docker_listen``` is an YAML list: ```docker_listen: [ '{{ docker_tcp_listen }}' ]```.

Is there a more simpler way to express things? Maybe ```when: docker_upstream``` or ```%{ if docker_listen %}``` will be enough?

---

First of all, ```d``` is an alias for ```default```, and ```default``` filter is defined in [jinja2/filters.py](https://github.com/mitsuhiko/jinja2/blob/master/jinja2/filters.py):

{{< highlight python >}}
def do_default(value, default_value=u'', boolean=False):
    """If the value is undefined it will return the passed default value,
    otherwise the value of the variable:

    .. sourcecode:: jinja

        {{ my_variable|default('my_variable is not defined') }}

    This will output the value of ``my_variable`` if the variable was
    defined, otherwise ``'my_variable is not defined'``. If you want
    to use default with variables that evaluate to false you have to
    set the second parameter to `true`:

    .. sourcecode:: jinja

        {{ ''|default('the string was empty', true) }}
    """
    if isinstance(value, Undefined) or (boolean and not value):
        return default_value
    return value
{{< /highlight >}}

So, the default "default value" is an empty string.

### "str | d()" test

With ```default``` filter:
{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{{ str | d() }}')
>>> print tmpl.render()
                                  # An empty string
>>> print tmpl.render(str=None)
None
>>> print tmpl.render(str='')
                                  # An empty string
>>> print tmpl.render(str='abc')
abc
>>> print tmpl.render(str=' ')
                                  # A space
>>> print tmpl.render(str=[])
[]
>>> print tmpl.render(str=['list'])
['list']
{{< /highlight >}}

Without ```default``` filter:
{{< highlight python >}}
from jinja2 import Template
tmpl = Template('{{ str }}')
>>> print tmpl.render()
                                  # An empty string
>>> print tmpl.render(str=None)
None
>>> print tmpl.render(str='')
                                  # An empty string
>>> print tmpl.render(str='abc')
abc
>>> print tmpl.render(str=' ')
                                  # A space
>>> print tmpl.render(str=[])
[]
>>> print tmpl.render(str=['list'])
['list']
{{< /highlight >}}

Pretty same, eh?

### "str | d() | bool" test

With ```default``` filter:
{{< highlight python >}}
from jinja2 import Template
from ansible.runner.filter_plugins.core import bool
Template('').environment.filters['bool'] = bool
tmpl = Template('{{ str | d() | bool }}')
>>> print tmpl.render()
False
>>> print tmpl.render(str=None)
None
>>> print tmpl.render(str='')
False
>>> print tmpl.render(str='abc')
False
>>> print tmpl.render(str=' ')
False
>>> print tmpl.render(str='True')
True
>>> print tmpl.render(str=[])
False
>>> print tmpl.render(str=['list'])
False
{{< /highlight >}}

Without ```default``` filter:
{{< highlight python >}}
from jinja2 import Template
from ansible.runner.filter_plugins.core import bool
Template('').environment.filters['bool'] = bool
tmpl = Template('{{ str | bool }}')
>>> print tmpl.render()
False
>>> print tmpl.render(str=None)
None
>>> print tmpl.render(str='')
False
>>> print tmpl.render(str='abc')
False
>>> print tmpl.render(str=' ')
False
>>> print tmpl.render(str='True')
True
>>> print tmpl.render(str=[])
False
>>> print tmpl.render(str=['list'])
False
{{< /highlight >}}

Pretty same again. So, it seems that ```default()``` or ```d()``` usage in conditions has no sense at all.

---

And what about ```bool``` filter?

Remember ```when: docker_upstream | d() | bool```, where ```docker_upstream``` is an YAML boolean.

Or ```{% if docker_listen | d() | bool %}```, where ```docker_listen``` is an YAML list.

The ```bool``` filter is the part of [Ansible plugins](https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/filter/core.py):

{{< highlight python >}}
def bool(a):
    ''' return a bool for the arg '''
    if a is None or type(a) == bool:
        return a
    if type(a) in types.StringTypes:
        a = a.lower()
    if a in ['yes', 'on', '1', 'true', 1]:
        return True
    else:
        return False
{{< /highlight >}}

You can clearly see from ```bool``` function implementation that ```{% if docker_listen | d() | bool %}``` results in ```True``` only if ```docker_listen: True```. If ```docker_listen``` is an arbitrary string or a list (as expected) ```{% if docker_listen | d() | bool %}``` results in ```False``` always.
 
Therefore ```{% if docker_listen %}``` gives us a correct behaviour for strings and lists. The reason is explained [here](({{< ref "posts/ansible-conditions.md" >}}) (see "Secondly" and "Third" quotes): 

> The if statement in Jinja is comparable with the Python if statement. In the simplest form, you can use it to test if **a variable is defined, not empty or not false**.
>
> For sequences, (strings, lists, tuples), use the fact that **empty sequences are false**.

But for booleans you have to use ```bool``` filter — ```when: docker_upstream | bool```, because ```when: docker_upstream``` results in ```True``` when ```docker_upstream: False```.

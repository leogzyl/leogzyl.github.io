---
layout: post
title: "Dataclass auto IDs"
date: 2023-01-21 17:40
comments: true
categories: [Python, dataclass, dataclasses, refactoring, context manager, contextlib]
---


Imagine you are working on a project and have some code like this:

```python
@dataclass
class Foo:
    bar: int
    baz: str
...

for ...
    ...
    foo = Foo(bar=the_bar, baz=the_baz)
    ...
# do something with the foo's 
```

Now you receive the requirement to assign serial ids to dataclasses being created (`Foo`s and others), for reference/ordering, etc.

It's worth mentioning that the objects are not going to be persisted, so as long as IDs are sequential per invocation/run/session, all is well.

After some digging around in the `itertools` module, you settle for something like this:

```python
@dataclass
class Foo:
    id: int
    bar: int
    baz: str
```

```python
from itertools import count

ids = count(1)

for ...
    ...
    foo = Foo(id=next(ids), bar=the_bar, baz=the_baz)
    ...
```

This works like a charm, except for the fact that you end up repeating the same code everywhere `Foo`s and other dataclasses are being instantiated.

Time to refactor!

The obvious place to move this is inside the dataclass itself, something like this:

```python
from dataclasses import dataclass, field
from itertools import count


@dataclass
class AutoId():
    id: int = field(init=False)

    def __post_init__(self):
        if not getattr(self.__class__, "_ids", None):
            self.__class__._ids = count(1)
        self.id = next(self._ids)

@dataclass
class Foo(AutoId):
    bar: int
    baz: str
```

This encapsulates the counter logic in a dataclass that you can mix in with your existing ones. Each inheriting dataclass gets its own independent counter and `id` field. Nice!

But there's one more thing that doesn't quite work with this approach. The generated ids for each class will keep increasing for the duration of the python process, you need some sort of scope...

Scope? that's what context managers are for. Let's try that:

```python
from contextlib import contextmanager
from dataclasses import dataclass, field
from itertools import count


@dataclass
class AutoId():
    id: int = field(init=False)

    @classmethod
    @contextmanager
    def auto_ids(cls):
        try:
            cls._ids = count(1)
            yield
        finally:
            del cls._ids

    def __post_init__(self):
        if getattr(self.__class__, "_ids", None):
            self.id = next(self._ids)
        else:
            self.id = None

@dataclass
class Foo(AutoId):
    bar: int
    baz: str
```

This would be used in the wild like so:

```python
with Foo.auto_ids():
    f1 = Foo(bar=1, baz="baz")
    f2 = Foo(bar=2, baz="baz")

...

with Foo.auto_ids():
    f3 = Foo(bar=1, baz="baz")
    f4 = Foo(bar=2, baz="baz")

print(f1, f2, f3, f4)
```

Output:
{% highlight text %}
Foo(id=1, bar=1, baz='baz')
Foo(id=2, bar=2, baz='baz')
Foo(id=1, bar=1, baz='baz')
Foo(id=2, bar=2, baz='baz')
{% endhighlight %}

You could save a couple of parenthesis by making `auto_ids` a class property, but keep in mind that will [no longer work after python 3.11](https://docs.python.org/3.11/library/functions.html#classmethod)

Granted, we ended up with a bit more complexity, but it's neatly hidden away in the core of your domain, giving you a clean API to work with.
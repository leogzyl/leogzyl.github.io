---
layout: post
title: "Pythonic Anti-IF: Single Dispatch"
date: 2022-12-26 12:10
comments: true
categories: [Python, Functional Programming]
---

A bunch of years ago, I became aware of the [Anti-IF campaign](https://francescocirillo.com/products/the-anti-if-campaign#). It was (and still is) an excellent practice in any software project.

At the time, I was doing a lot of OOP. I recall advocates of the Anti-IF campaign claimed something along the lines of: 


_"Every time you use an IF statement, you miss an opportunity to use polymorphism"._

It seemed a little extreme to apply this when dealing with _any_ IF statement, though.

Recently I was working on a Python library for document analysis where I wanted to make the user interface as simple as possible. After some configuration, the end-user would call a single method with a single parameter (a document to be analyzed), the type of the parameter being:

- `str`: a path to a document (local file or URI)
- `pathlib.Path`: a path to a local file
- `bytes`: a stream of bytes representing the document
- `BytesIO`: In memory buffer with contents representing the document
- a file-like object resulting from `open`ing the document in binary mode

The actual analysis was performed by backend providers that had APIs for either binary data or URLs, so I needed to accommodate the above into one of those two categories.

A first short-lived implementation started out as something like this (uglier code omitted):

```python 
from abc import ABC, abstractmethod
from pathlib import Path
from typing import BinaryIO

from utils import is_local_file

class AbstractDocumentAnalyzer(ABC):

    @abstractmethod
    def _from_url(self, document: str):
        """ Provide results when document is a URL """
        pass
    
    @abstractmethod
    def _from_bytes(self, document: BinaryIO):
        """ Provide results when document is binary data """
        pass

    def analize_document(self, source: Any):
        if isinstance(source, str):
            if is_local_file(str):
                ... # open the file and call self._from_bytes
            else:
                ...  # call self._from_url

        elif isinstance(source, Path):
            ...  # open the file and call self._from_bytes
        elif isinstance(source, bytes):
            ... # call self._from_bytes
        
        ...
        
        else:
            raise ValueError(f"Don't know how to handle {type(source)} :(")
```

As the IF's quickly popped up, I could almost hear Raymond Hettinger:

![image](/assets/images/better-way.png)

Luckily for us, Python provides a way to build polymorphic functions that dispatch [on the type of the first argument](https://docs.python.org/3/library/functools.html#functools.singledispatch) ([or second, for methods](https://docs.python.org/3/library/functools.html#functools.singledispatchmethod)).

This allows us to cleanly separate each case into its own handler method:

```python
from abc import ABC, abstractmethod
from functools import singledispatchmethod
from pathlib import Path
from typing import BinaryIO

from src.utils import is_local_file

class AbstractDocumentAnalyzer(ABC):

    @abstractmethod
    def _from_url(self, document: str):
        """ Provide results when document is a URL """
        pass
    
    @abstractmethod
    def _from_bytes(self, document: BinaryIO):
        """ Provide results when document is binary data """
        pass

    @singledispatchmethod
    def analize_document(self, source: Any):
        raise ValueError(f"Don't know how to handle {type(source)} :(")

    @analize_document.register
    def _(self, source: Path):
        with open(source, 'rb') as file:
            return self._from_bytes(file)
        
    @analize_document.register
    def _(self, source: str):
        return self.analize_document(Path(source)) 
            if is_local_file(source) 
            else self._from_url(source)

    @analize_document.register
    def _(self, source: bytes | BufferedReader | BytesIO):
        return self._from_bytes(source)
```

Now that's a lot cleaner, isn't it?!


Notice how in the first implementation we `open`ed the file at two places. The improved code allows for some level of reuse (the `str` handler calls the `Path` handler).

Notice also that you can use union types for dispatching only after Python 3.11. For earlier versions, you must create a handler for each type.

<font size=2>
_I know, there's still an IF in there, but let's not be too extreme ;)_
</font>
Regular expressions (aka RegEx)
===============================

Regular expressions are often feared by a lot of people because of their freaking weird syntax, which may put anyone off at first.

The first time I looked at this:

.. code::

    "((?<=;)|(?<=^))\s*\*[^;]*;"

I thought it was an absolute nightmare. Here's a little meme to represent better the way I felt when I started:

.. |studio3T_picture| image:: /src/python/images/regex_meme.png
   :width: 200px

|studio3T_picture|

But after a little time, it all became a lot better!!

**In this page, we will cover the following points:**

0. Regex cheatsheet
1. What is a regex, where are they used and what are their limits
2. What actually happens when you try to match a regex in a string?
3. Regex syntax and applications in Python (re package and str methods in pandas)
4. Exercises to test your skills!


1. What is a regex, where are they used and what are their limits
-----------------------------------------------------------------

A regex is a sequence of characters which specify a certain pattern to match in a string. Its syntax was developped
in 1951 and has evolved to become how it is known today. It can be used in many different programming languages, such as 
Python (with the re package for example which we will discover later). 

With this in mind, let's see some of the different use cases:

Suppose I have the following Series of absolute paths for some files:

.. list-table::
   :widths: 25 
   :header-rows: 1

   * - file_abspaths
   * - /example/path.test/home/file1.sas
   * - /example/path.test/home/file1.py
   * - /example/path.test2/home/test.sas
   * - /example/path.test2/home/thomas/test.hello.sas.what.txt

Suppose we want to know the file extensions of all the associated files. Without regex, we could try the following method (which I find not very clean), supposing our series is called `abspath_s`:

.. code:: python

    abspath_df.str.rsplit("/", n=1, expand=True).iloc[:,-1].str.rsplit(".", n=1, expand=True).iloc[:, -1]


I'm not a huge fan of this solution, it is the kind of thing I used to do before using regex, and I wasn't entirely satisfied.
I'm not quite sure it works in any given situation either.

With regex, you can actually do this in one line, and when you learn to read regex, it is a lot cleaner and quicker:

.. code:: python

    abspath_df.str.split(r".*\.(?=[^\.]+)", expand=True).iloc[:, -1]

In this example, which remained relatively simple, we can already see that regex expressions can be a lot more powerful than simple pandas methods on str.
Even though we can see we can still do it in Python, I personnally fail to see how we can possibily scale up the method for more complex cases.

Let's consider quickly another example I have come accross which explains a lot better just how powerful regex expressions can be (one of the first regex I have used on iSMA)

Suppose I have a script I want to extract keywords from. In scripts, writers often have the possibility to comment some sections (either because a section of the code is not used
or just because they are being nice to others to help them understand for when they'll have to read the coder's work).

In SAS, comments come in two forms:

- Either it is a single line comment (after a ";", if there is a \*, then anything that comes after is a comment until the next ";")
- Either it is a block comment (anything between \\* and \*\\)

I wish you luck if you want to do this without regex (I have not considered doing it using them here by the way haha)

Here is what the code should do:

.. code:: 

    \* This is a 
    block comment *\; %let n=2023; * this is a single line comment;
    *Yet another line comment; %let hello="world";

should be transformed into:

.. code::

    %let n=2023;
    %let hello="world";

With regex, I only had to use two lines:
    
.. code:: python

    text = re.sub(r"/\*(.|\n)*?\*/", "", text) # for block line comments
    text = re.sub(r"((?<=;)|(?<=^))\s*\*[^;]*;", "", text, flags=re.MULTILINE) # for single line comments comments

It works like a charm! 

I bet you a beer you cannot find a better solution without using regex.
I'm open to any suggestions if you can further optimise this code by the way.

Now that we have explored some personal use cases, let's take a look at some more general ones. Regex are very widely used in:

- Search engines
- Language tokenizers used for code compilation
- Language linters and syntax checkers and more generally language servers (which people who use VScode should be very familiar with)

Blah blah blah a lot more for sure, just some examples I find interesting.


**Limitations**

The only limitation of regex is that they can be quite slow. As we shall see in the next part, a regex expression is translated by a regex engine into
a state machine to analyse strings. This process can be quite slow, so if you are doing some very basic stuff, I would still suggest to use 
basic methods, such as ones we use everyday in pandas.


2. What actually happens when you try to match a regex in a string?
-------------------------------------------------------------------

There is an old and a new algorithm to determine wether a certain regex matches a certain string (the source of this all of this is not from the top of my head, parts come from Wikipedia and some over sources, I have just
summarized here).

- **NFA/DFA algorithm:**

This is also the oldest implementation of the algorithm, which involves generating a finite state automaton (a machine with a finite amount of states, I can write another page all about it, just ask, but this subject quickly becomes very
mathematical). The basic idea is to generate a machine which has different states.

Let's look at a very basic example to illustrate this point:

.. mermaid::

    stateDiagram-v2
    [*] --> a
    a --> b
    b --> b
    b --> c
    c --> [*]


The previous diagram, which corresponds to the regex `ab+c`, matches any string of the form abc, abbc, abbbbbbbbbbc. The algorithm simply reads the regex, transforms it into a structure which looks much like the one above. It then takes the string, and if by starting at the starting state, we can go through each letter of the string and end up in the 
end state, then this means we have a match.

It takes a lot of memory space to create such a state machine (exponential space), but is on the other hand very efficient to test if a string matches a pattern (linear)

- **Backtracking algorithms**

This algorithm provides a lot more flexibility in regex expressions, such as lookbacks (which we will look at right after, and were introduced when regular expressions were implemented for Perl) which cannot be handled by the above algorithm. The only thing is that its running time can be exponential.
It is this kind of algorithm which is used in Python. I won't go too much in the details, just keep in mind that this allows to do more things with regex than then previous method

Some implementations use both: if the regex doesn't use any lookbacks etc, then the NFA/DFA is used. Otherwise, a backtracking algorithm is used.

3. Regex syntax and applications in Python
------------------------------------------

This part aims to progressively build more and more complex regex expressions by starting from the very basics, all the while introducing the different functions of the re package.
By following the examples in here step by step, you should by the end have a pretty good knowlegde of regex syntax, enough to be able to implement your own!

Having said that, let's get started with some basics.




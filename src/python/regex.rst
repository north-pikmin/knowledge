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

This part aims to progressively build more and more complex regex expressions by starting from the very basics, all the while introducing the different functions of the re package (which will come quickly after we have learned some basics in regex).
By following the examples in here step by step, you should by the end have a pretty good knowlegde of regex syntax, enough to be able to implement your own!

Having said that, let's get started with some basics.

A regular expression, as we have seen from the previous examples, contains a number of characters, which can be split up into two categories:

    - Basic characters: these are characters which can be interpreted as such by the regex engine. For example, in my regex, when I write `a`, that is to actually match the letter "a"
    - Special characters: These include \*, +, [] etc, and are not interpreted as such by the regex engine


Before diving into some examples, let's give some explanations on the most common special characters: \*, +, ., $, ^ and []

.. tab:: \* 

    \* (the Kleene star) is by far one of the most common regex special characters. It is signifies that the character written before is to be repeated zero or 
    more times. 
    
    For example, the regex expression `a*` matches either the empty string (""), or a string composed only of the letter "a" any number of times
    ("a", "aa", "aaaa" etc).


.. tab:: +

    + is very similar to \*, except that you do not want to include the empty string in the possible matches. To take the same example as the \* special
    character, the regex expression `a+` will match any string composed only of the letter "a", the null string not included ("a", "aa", "aaaa" etc).


.. tab:: .

    . is a special character representing any character except from the \n (newline). The regex `.` therefore matches any one letter string.

.. tab:: $

    This is a character which signifies the end of the string. For example, `.*H$` would match any string ending with the letter "H".

.. tab:: ^

    This is a character which signifies the beginning of a string. For example, `^H.*` would match any string starting with the letter "H"

.. tab:: []

    [] is called a character class. It is a set of character to match at a certain place. A basic example would be: `[abc]`. This matches the strings "a", "b" or "c".
    You can also specify a range of characters in a character class. For example, `[a-z]` matches all the lowercase letters in the alphabet, `[0-9]` matches any digits and
    `[a-zA-Z0-9_]` matches all string composed of digits and letters, may they be lowercase or uppercase. You can also negate a character class using ^: `[^a]` will match
    all single letter strings except from "a".


**Note**: Sometimes, we may want to match an actual \* or + in our actual string. In this case, we need to escape our special character using a \\. For example, if we wanted to match
strings composed of any number of the character "+", we would have to write `\+*`.

Having said that, let's give some very basic examples on how to use all of this together. You can try solving these little problems on your own before looking 
at my way of doing.

Suppose we want to do the following:

.. code::

    Write a regex matching any word containing only "a" and "b", allowing the empty word. 


To do this, we could write the following:

.. code::

    [ab]*



The star applies to the entire character class. Pretty basic stuff for now :).

Let's do the following:

.. code::

    Write a regex which matches all strings starting with "a", and then having one or more "b"

The following could work:

.. code::

    ab+

The + applies only to the latest character/character class, so in this case it is only "b". The same goes for \*.

Let's do a few more before moving on:

.. code::

    Match all the strings starting with A and finishing with c, containing at least four letters

My solution with what is known:

.. code::

    A..+c

Last one for the road. 

.. code::

    Match all strings starting with a capital letter, ending with an s and for which all the other letters are in lowercase

Solution:

.. code::

    [A-Z][a-z]*s

Let's look at a few more special characters before diving in to some Python


.. tab:: \\s

    Pretty basic, it represents a space character.

.. tab:: \\w and \\W

    \\w represents all the characters in `[a-zA-Z0-9_]`. It is called a word character. \\W is the complementary of \\w

.. tab:: \\b

    This is a zero width representing the boundary of a word (string composed only of \\w characters).

.. tab:: \\d

    This matches any digits.

Let's give a few more examples.

.. code::

    Match all the strings composed of two words

Solution:

.. code::

    \w+\s\w+

And another one:

.. code::

    Match strings containing at least one digit

Solution

.. code::

    .*\d.*


Let's now give a brief presentation of how regex can be used in the re python package.

re is a package containing a lot of different useful functions. We have already seen the sub functions, but it is not the only one!


.. tab:: re.findall

    This function returns all the matches in a provided string, scanned from left to right (according to the documentation).


.. tab:: re.search

    This function returns a match anywhere in the string


.. tab:: re.sub

    Subs the matched string with another string passed as an argument.


Let's give some examples of these before going deeper into regex syntax.

Suppose we have the following Python string:

.. code:: python

    "Hello from Toulouse and Barcelona"

Let's say we want to extract all the words which contain at least one "o".

We would use re.findall:

.. code:: python

    re.findall(r"\w*o\w*", test) # returns a list of all the non overlapping matches from left to right
    # Returns: ['Hello', 'from', 'Toulouse', 'Barcelona']


Now if we do the same using re.search:

.. code:: python

    re.search(r"\w*o\w*", test).group()
    # Returns: 'Hello'


Now suppose we want to remove the Barcelona part and replace it with Paris:

.. code:: python

    re.sub(r"Barcelona", "Paris", test)
    # Returns "Hello from Toulouse and Paris"


The search returns only the first match, and we use the group method to access the actual match.

Before diving in to some more python, let's look at some features of Perl's implementation of regex which allow 
what we call lookahead and lookbehind, which are very powerful. Note that these will make a lot more sense when we will
combine them with the python functions in the re package.

.. tab:: Positive/Negative lookahead

    The positive regex lookahead allows the engine to match certain part of a string which are followed by certain characters.
    It is written : 
    
    .. code:: python

        (?=<regex_expression>)
    
    For example, `a(?=;)` will match all "a" strings which are followed by ";". 
    
    The negative lookahead is very similar, it is written:
    
    .. code:: python
    
        (?!<regex_expression>) 
    
    For example, `a(?!;)` will match all "a" which are **not** followed by ";".

    Note that the term used here in the positive/negative lookahead is an actual regex expression: we can pass any kind 
    of regex expression (so not necessarily of fixed width, unlike the lookbehind).


.. tab:: Positive/negative lookbehind

    The positive lookbehind allows to match certain part of a string which are preceded by certain characters.
    It is written:

    .. code::

        (?<=<regex_expression>)

    For example, `(?<=A)b` will match all the "b" for which the previous letter was an "A".

    The negative lookbehind is very similar. Here is the syntax:

    .. code::

        (?<!<regex_expression>)

    For example, `(?<!A)b` will match all the "b" for which the previous letter was **not** an "A".

    Note that unlike the regex lookahead, the regex expression in the lookbehind must be of fixed length.


Now that we have some very solid tools for regex, let's do a few examples using Python, and a little problem to summarize a lot of what we have seen.

Suppose have the following string:

.. code::  python

    text = "test.sas, test2.txt, test3.sas, test4.py"

Our goal is to extract all the files for which the extension is ".sas" (but without the extension). To do this, we can do the following:

.. code:: python

    re.findall(r"[^\.,]+(?=\.sas)", text)

Now suppose we want to extract all the file extensions. In our case, we can do the following:

.. code:: python

    re.findall(r"(?<=\.)[^\s\.]+(?=,)", text)


Of course, if we were in the more general case, we would have to make the functions above a lot more robust, but it is still a nice example.


Now that we are starting to have a nice understanding, let's dive into a little problem.

Suppose we have the following string:

.. code:: python

    text = """%let a=2023; %let b=2022 * 1;/*this is the end of the variables
     \ndefinition */ LIBNAME test \"/path/to/test\"; * test FILENAME; 
     data test.test&a; SET test.test_file;"""

This is an extract of a basic SAS code which we could want to do some parsing on. It is also very convenient to use
in order to show some examples.

We will often say "SAS line". This refers to any bit of code which are contained between a ";" and another ";" or between a line start and a ";". In the example above,
"%let a=2023;" and "%let b=2022 * 1;" are both distinct SAS lines.

Suppose we have the following goal: we want to write a Python script that extracts the absolute paths to the inputs and outputs of this SAS code.
In this case, we have

- One input, "test.test_file" (which comes right after the SET), which should be resolved to "path/to/test/test_file" (the part before the "." corresponds to the LIBNAME defined before, and we concatenated it with the part after the ".")
- One output, "test.test&a" (which comes right after the DATA), which after some basic parsing, should be resolved to "path/to/test/test2023" (&a is a reference to the variable a which was defined earlier)

In order to do this, we need to perform the following tasks:

1. Extract all the variables in this script and store them in a sort of dictionnary to be used later on (variables are defined using a %let macro statement)
2. Extract all the LIBNAMEs in the same manner (in our example, test would be the name of the LIBNAME and the /path/to/test would be the associated value)
3. Extracts the keywords associated to the inputs/outputs (so in our case )
4. Recreate the actual abspaths

No worries, all these different tasks have an expected output each time so you can better understand what is expected

Note that the script also contains comments, which come in two forms:

- Line comments (\* right after a ";" or at the beginning of a new line and ending with ;). In our example, we have a line comment ("\* test filename;" needs to be removed), and an actual multiplication, which needs to be kept
- Block comments (between \\* and \*\\)

Feel free to give it a go on your own!

**0. Comments removal**

Having "text" as the input, the expected output would be:

.. code:: python

    '%let a=2023; %let b=2022 * 1; LIBNAME test "/path/to/test"; \n     data test.test&a; SET test.test_file;'


Let's start by removing the comments. Let's first start with the block comments, which are the easiest. 

We can do the following:

.. code:: python

    sas_code = re.sub(r"/\*(.|\n)*\*/", "", text)

For the line comments, it is a bit trickier, since the multiplication in SAS also uses the \* symbol. As said earlier, the line comments
are identifed by \* either at the beginning of a new line or by \* right after a ";" and possibily a few whitespaces. We therefore have the following 
rule:

.. code:: python

    sas_code = re.sub(r"((?<=^)|(?<=;))(\s)*\*[^;]*;", "", sas_code)


Here, we:

- Look behind to see if we are at the beginning of a new line (\^ or ;)
- Take into account all the possible whitespaces that may come before our \*
- Check if after all of that, we do actually have a \*
- Extract anything that may come after until the next ;

Nice! With both of these combined, we can fully remove all the comments from the code. Next, let's extract the variables, again using
some regex. 

**1. Variable extraction**

Here is the expected output:

.. code:: python

    {'a': '2023', 'b': '2022 * 1'}


The input would be the sas_code variable defined above.

We want to extract all the SAS lines which have a %let, and then get the associated variable mapping. To do the %let SAS line
extraction, we can use the following:

.. code:: python

    let_args_list = re.findall(r"(?<=%let)[^;]+(?=;)", sas_code)

After, using some basic python string methods, we can get our variable mapping:

.. code:: python

    variable_mapping = dict()
    for let_arg in let_args_list:
        var_name, var_val = let_arg.strip().split("=")
        variable_mapping[var_name.strip()] = var_val.strip()

Nice! Sure, we haven't actually evaluated the value of b, but this goes out of the scope of this tutorial.

Having done this
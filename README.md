# Fantastic Books and Where To Find Them

An expert system is one of the first successful forms of AI and was popular in the 80's (yes, pre-Python and Java design patterns, but after the start of great ML and AI academic research). This expert system uses a __rule engine__ written in late 1995 by an engineer at Sandia National Labs. 

The rule engine itself is based on an implementation of the [Rete algorithm](https://en.wikipedia.org/wiki/Rete_algorithm), which optimizes on a simple looping through conditionals by implementing a trie of left hand side patterns to match, and marking nodes as they are fulfilled (not necessarily in sequential order). When a leaf node is reached, the corresponding rule is fired.

## Dependencies 

- Jess rule engine, Java-based, can integrate with JSR94 rule engine API 
- CLIPS functional programming language
- Maven build system, install dependency by downloading *jess.jar*, running `mvn install`, referencing under a `<dependency>` tag in `pom.xml`

## Functionality

- Asks series of questions based on characteristics of books in dataset
- Guaranteed recommendation when one remaining book that fits user written characteristics in dataset
- Uses a CLI and string-built questions 

## How to Run

This expert system is currently standalone, so this is the process to run the CLI recommendation system. A future improvement is to write a driver to run the code using Java then package into a `.jar` file.

1. Download `jess.exe` from https://www.jessrules.com/jess/download.shtml. (Fun fact: I got to interact with the Jess creator during this process).
2. Save `book_recs.clp` in the examples/jess folder.
3. Run `jess.exe` using `bin/jess`.
4. Run `(batch "examples/jess/book_recs.clp")`.

## Future Improvements

This program is not actively worked on at the moment, but forks and pull requests are certainly welcome. The following example
extensions are not time consuming to implement.

* Move build to Maven and write Java driver.
* Add length of book as a characteristic. 
* Make it so that if the first question is given a book the system doesn't know, it saves that book into the database.
* Standardize which characteristics go with which appeal factor.
* Output the reason why the book was chosen along with the recommendation.

## Easy Contributions

* Add a book! Genres can be verified by looking at the Wikipedia page of the book. 
* Update the characteristics of a book.

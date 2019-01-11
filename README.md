# fantastic-books-in-clips
An expert system to recommend fiction to the casual reader. 
Tentatively named "Fantastic Books and Where To Find Them" or "Book Guru".

# description
An expert system is a form of AI software popular in the 1980's - in fact, it was one of the first successful forms of AI. An expert system is supposed to emulate the expertise of a human who has practiced their craft for tens of thousands of hours. It does this by having a set of rules and facts.

My expert system currently recommends teen fiction using the Java based rule engine Jess and the CLIPS programming language. I wrote rules for asking questions and facts for all possible books that the engine can recommend. Jess doesn't sequentially go through code, but instead executes a rule whenever the left hand side of the rule is satisfied (basically like an if statement). It is unpredictable when a rule will be executed and at the same time possible for a rule to be executed multiple times. My particular system questions the user using the question rules until the recommend rule is fired. The recommend rule is fired when there is only one book left in the library. Whenever a question is answered books are retracted from the library until there is only one book in the library.

# instructions
1. Download Jess from https://www.jessrules.com/jess/download.shtml. This should give you a 30 day trial to the software. I am currently working on finding a workaround or different language which doesn't involve downloading a free trial of a software.
2. Save book_recs.clp in the examples/jess folder.
3. Run Jess using jess.exe in bin. Command would be bin/jess.
4. Run (batch "examples/jess/book_recs.clp") in Jess.

# future improvements
* Add more books to the library, preferably adult fiction and literature.
* Add length of book as a characteristic. Short, medium, long?
* Convert code into LISP or another rule engine based coding schema which doesn't have a 30 day trial.
* Fix the plot-driven vs character-driven question - people find it confusing.
* Get rid of compelling as a characteristic.
* Make it so that if the first question is given a book the system doesn't know, it saves that book into the database.


# sources of knowledge
Wikipedia, Dr. Nelson, Ms. Cranston & Ms. Vaughan

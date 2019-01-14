/*

(batch "examples/Jess/bookrec.clp")

Author: Monica Kumaran
Project: Fantastic Books and Where to Find Them 

This expert system recommends fiction.

It starts out with an enormous list of books, and it will ask the user questions
until it has whittled the huge list down to one book to recommend.

Instead of using subjects (e.g. whether the book has dragons in it), my system
uses appeal factors, which describe the general reading experience rather than a specific
element in the book. They are more indicative of the user's general reading 
preferences than subjects.  

There are four categories of appeal factors used in this system - genre, story, overall tone,
and writing style. 

There are a TON of appeal factors and no reliable relationships between them, so to make this
work for a large database I asserted all the books and retracted them based on characteristics
the user either liked or did not.

Note: The system will actually become more accurate with more books in the database. For some tags
it doesn't have enough other examples of that tag to make a very good recommendation.

Also, the system will always recommend a book.

Credits: A big thanks to my experts, Ms. Cranston and Ms. Vaughan!

Next step: If the user gives a book the system doesn't recognize, after the recommendation a module
is triggered which would ask backward-chained questions to make an entry for that new book. 
Also, include a way for the user to look up definitions for some of these appeal terms.

*/


;;;;;;;;;;;;;;;
/* TEMPLATES */
;;;;;;;;;;;;;;;

/*

The template book is used to store information about each book.
It has a slot t for title and a for author. 

The tags describing the book are split into four multislot
categories (which hold a list of descriptors that apply): 
genre for genres, story for story plotting/pacing, tone for overall tone of book,
and style for writing style.

*/

(deftemplate book (slot t) (slot a) (slot era) (slot length) (multislot genre) (multislot story) (multislot tone) (multislot style))

/*

The book mentioned by the user is asserted under the foundbook template. The template 
only needs the slot t for title, because it is used by the system to recognize a book.
If the title of a foundbook is the same as a book in the database, then the book is recognized
and the questions directed at the user will be specific to the information known about the book.

*/

(deftemplate foundbook (slot t))

;;;;;;;;;;;;;;;
/* FUNCTIONS */
;;;;;;;;;;;;;;;

/*

For Jess to recognize the values in the template slots as symbols, they cannot have any spaces.
Therefore, using strings to store the titles of books etc.
and then using string-assert to assert these gave issues too. So instead of spaces I used underscores,
and then replaced them with spaces before printing.

The printthis function takes in a string which needs to be printed out, replaces any underscores with spaces,
and then prints out the string.

*/

(deffunction printthis (?string)
	(bind ?i 1); a counter

	/*
 	The while loop goes letter by letter through the string. When it finds an underscore it
	concatenates the two pieces of string around the underscore
	with a space where the underscore used to be. 
	*/
	(while (< ?i (str-length ?string))
	(if (eq (str-compare (sub-string ?i ?i ?string) "_") 0) then 
	(bind ?string (str-cat (sub-string 1 (- ?i 1) ?string) " " (sub-string (+ ?i 1) (str-length ?string) ?string))) )
	(++ ?i))

	(printout t ?string crlf)
)

/*

The function readthis does the opposite of printthis. It takes in a user input string and returns it with the 
spaces replaced with underscores, so the system can use the input as a symbol in internal assertions.

*/

(deffunction readthis (?string)
	(bind ?i 1); a counter

	/*
 	The while loop goes letter by letter through the string. When it finds a space it concatenates
	the two pieces of string around the space with an underscore where the space used to be. 
	*/
	(while (< ?i (str-length ?string))
	(if (eq (str-compare (sub-string ?i ?i ?string) " ") 0) then 
	(bind ?string (str-cat (sub-string 1 (- ?i 1) ?string) "_" (sub-string (+ ?i 1) (str-length ?string) ?string))) )
	(++ ?i))

	(return ?string)
)

/*

The function ncontains is used to take in a list stored in a multislot
and check whether a key phrase is in it. It checks by using the member$ function. If the member$ function
gives back an integer (meaning it found the phrase) then ncontains returns FALSE. Otherwise it returns true.

ncontains takes in the ?char key phrase and the list ?multislot from the multislot.
It is used to avoid clutter in the LHSs of rules.

*/

(deffunction ncontains (?char ?multislot)
	(if (integerp (member$ ?char ?multislot)) then (return FALSE) else (return TRUE))
)

/*

The function prefer is given a list of characteristics and prints out the question "Do you prefer ___, ____, or  ___ books?"
It will then take in the user response and assert that as something the recommended book must have.

Is used to ask questions involving multiple characteristics.
*/


(deffunction prefer (?list)
	(bind ?i 1)
	(bind ?string "Do you prefer "); first part of question
	
	(if (< (length$ ?list) 2) then 
	/* A while loop adds in all (except the last) elements of the list */
	((while (< ?i (length$ ?list))
	(bind ?string (str-cat ?string (nth$ ?i ?list) ", ")); adds in i-th element from i = 1 to i = list length - 1
	(++ ?i)))
	else (bind ?string (str-cat ?string (first$ ?list))));if the list has two elements it adds in the first element
							     ;without a comma

	;the last element is added, in the form "or ____ books?"
	(bind ?string (str-cat ?string " or " (nth$ (length$ ?list) ?list) " books?"))
	
	;question asked and answer received
	(printthis ?string)
	(bind ?ans (readthis (readline)))
	(assert-string (str-cat "(must " ?ans ")"))
	
)



;;;;;;;;;;;;;;;;;;;
/* INITIAL FACTS */
;;;;;;;;;;;;;;;;;;;

/*

The deffacts construct will assert all the books in the database when Jess passes the initial-fact with the (reset) command.
Deffacts construct is used for clarity.

Book Length (pages):
Short x <= 150
Medium 150 < x <= 500
Long x > 500

*/

(deffacts library
	(book (t The_Harry_Potter_series) (a J.K._Rowling) (era 20) (length long) (genre fantasy) (story plot-driven world-building series) (tone atmospheric suspenseful))
	(book (t The_Lightning_Thief) (a Rick_Riordan)  (era 21) (length medium) (genre fantasy adventure book_to_movie mythological) (story plot-driven series) (tone funny))
	(book (t The_Fault_in_Our_Stars) (a John_Green) (era 21) (length medium) (genre realistic) (story character-driven))
	(book (t Looking_for_Alaska) (a John_Green) (era 21) (genre coming-of-age mystery realistic) (story character-driven))
	(book (t The_Hunger_Games) (a Suzanne_Collins) (era 21) (genre book_to_movie science_fiction dystopia) (story plot-driven series))	
	(book (t Little_Brother) (a Cory_Doctorow) (era 21) (genre science_fiction dystopia) (story plot-driven) (tone thought_provoking) (style jargon-filled))
	(book (t Catch-22) (a Joseph_Heller) (era 20) (story character-driven) (genre antiwar_story black_humor book_to_movie war_story satirical multiple_perspectives) (tone darkly_humorous moving sobering) (style stylistically_complex witty))
	(book (t The_Catcher_in_the_Rye) (era 20) (a J.D._Salinger) (genre coming-of-age first_person psychological) (tone darkly_humorous moving reflective))
	(book (t Howl's_Moving_Castle) (era 20) (a Diana_Wynne_Jones) (genre book_to_movie fantasy humorous) (style compelling) (tone atmospheric funny offbeat romantic) (story world-building))
	(book (t Ready_Player_One) (a Ernest_Cline) (genre coming-of-age first_person science_fiction) (story action-packed intricately_plotted) (tone funny offbeat nostalgic) (style jargon-filled))
	(book (t The_Oracle_Betrayed) (a Catherine_Fisher) (genre fantasy) (story plot-driven world-building) (tone suspenseful) (style compelling))
	(book (t The_Da_Vinci_Code) (a Dan_Brown) (genre book_to_movie suspense) (story plot-driven intricately-plotted) (tone atmospheric suspenseful) (style descriptive jargon-filled))		
	(book (t Pride_and_Prejudice) (a Jane_Austen) (genre book_to_movie domestic_fiction love_story) (story character-driven) (tone atmospheric romantic) (style engaging))
	(book (t The_Great_Gatsby) (a F.Scott_Fitzgerald) (genre book_to_movie) (story character-driven) (tone atmospheric romantic) (style lyrical stylistically_complex))
	(book (t The_Time_Traveler's_Wife) (a Audrey_Niffenegger) (genre literary multiple_perspectives domestic first_person) (story character-driven intricately-plotted) (tone romantic thought-provoking) (style witty lyrical))
	(book (t The_Hobbit) (a J.R.R._Tolkien) (genre book_to_movie epic fantasy) (story world-building plot-driven series) (tone upbeat) (style stylistically_complex))
	(book (t Interworld) (a Neil_Gaiman) (genre fantasy science_fiction) (story plot-driven) (tone sarcastic) (style compelling descriptive))
	(book (t The_Godfather) (a Mario_Puzo) (genre book_to_movie family_saga) (story character-driven) (tone dramatic haunting violent) (style compelling gritty))
	(book (t The_House_of_the_Scorpion) (a Nancy_Farmer) (genre science_fiction dystopia) (story world-building series) (tone suspenseful))
	(book (t The_Shadow_Speaker) (a Nnedi_Okorafor-Mbachu) (genre science_fiction fantasy adventure bildungsroman historical_drama) (story world-building African plot-driven) (tone serious))
	(book (t The_Thief_Series) (a Megan_Whalen_Turner) (era 20) (length medium) (genre young_adult fantasy adventure historical) (story deceit series political) (tone humorous snarky) (style witty))
	(book (t The_Song_of_The_Lionness_Quartet) (a Tamora_Pierce) (era 20) (length medium) (genre young_adult fantasy) (story magic deceit political series) (tone serious fantastical))
	(book (t Circle_of_Magic) (a Tamora_Pierce) (era 20) (length medium) (genre young_adult fantasy bildungsroman) (story multiple_main_characters political magic deceit) (tone serious))

)


;;;;;;;;;;;
/* RULES */
;;;;;;;;;;; 

/*

The startup rule starts by asking about the last fiction book the user enjoyed. 
If the book is in the database, the system will use the stored information about the book to ask questions. 

It then asks what did they enjoy the book and if there was anything the user did not 
enjoy about the book. The answers are used to narrow down the list of possible books
to recommend (doesn't matter whether the book is recognized or not).

Note: the last question isn't a yes/no question, but it doesn't affect much if the user 
writes yes/no instead of a characteristic (because none of the books have yes/no as characteristics)

*/

(defrule startup
	=>
	(printout t crlf)
	(printout t "Welcome to the Book Guru!" crlf)
	(printout t "I will recommend your next perfect fiction read.")
	(printout t crlf)
	(printout t "For most questions, y or n is sufficient." crlf)
	(printout t "You can skip the first question by typing in \"skip\"!" crlf)
	(printout t "If the last fiction you have enjoyed is in the library, I will try to recommend a similar book." crlf)
	(printout t crlf)
	(printout t "What was the last fiction you enjoyed?" crlf)
	(bind ?lastbook (readthis (readline)))
	(if (neq (str-compare ?lastbook "skip") 0);user can skip first question by typing "skip"
	then 
	(assert-string (str-cat "(foundbook (t " ?lastbook "))"));asserts as foundbook b/c might be recognized
	
	(printout t "What about it did you enjoy?" crlf)
	(bind ?appeal (readthis (readline)))
	(assert (must (sym-cat ?appeal))); the user given appeal factor is asserted 
		
	(printout t "Was there anything you did not like? (If so, enter the characteristic)" crlf)
	(bind ?dislike (readthis (readline)))
	(assert (must-not (sym-cat ?dislike)))
	
	else (assert (question)));if user skips question will assert (question)
				 ;to trigger question asking rules
	
)

/*

The rule must-have and must-not-have are the backbone of the book recommendation system. 
Whenever a new characteristic under the head must is added, the rule must-have will retract any book which does
not contain that characteristic. Must-not-have retracts any book with a given characteristic asserted under the 
must-not-have head.

Combined, these rules are how the enormous list of books is eventually whittled down to one. 

*/

(defrule must-have
	(must ?char)

	/* For each slot of book the value there is checked to make sure it does not contain ?char. For
	slot a the function neq is used to compare the slot value and ?char. The rest of the slots are multislots, 
	so the list contained in the multislot is assigned to a variable and sent through the function ncontains.*/

	?book <- (book (a ?a&:(neq ?char ?a)) (genre $?genre&:(ncontains ?char ?genre)) (story $?story&:(ncontains ?char ?story))
	(tone $?tone&:(ncontains ?char ?tone)) (style $?style&:(ncontains ?char ?style)))

	/* This makes sure that there is at least one book in the database which has the required characteristic.
	Otherwise, all the books could be retracted, giving an inaccurate recommendation. */
	(exists (or 
	(book (a ?char))
	(book (era ?char))
	(book (length ?char))
	(book (genre $? ?char $?))
	(book (story $? char $?))
	(book (tone $? ?char $?))
	(book (style $? ?char $?))))
	=>
	(retract ?book)	
)

(defrule must-not-have
	(must-not ?char)

	/* 
	
	The or constraint is used to find books which have the ?char.
	For each slot of book the value there is checked to make sure it does not contain ?char. For
	the slots t and a the function eq is used to compare the slot value and ?char. The rest of the slots are multislots, 
	so the list contained in the multislot is assigned to a variable and sent through the function contains.
	
	*/

	?book <- (or (book (a ?char))
		(book (era ?char))
		(book (length ?char))
		(book (genre $? ?char $?))
		(book (story $? char $?))
		(book (tone $? ?char $?))
		(book (style $? ?char $?)))
	=>
	(retract ?book)	
)



/*

The recommEND rule will fire when there is only one book in the list - 
the one which will be recommended. 

It prints a statement recommending
that last book to the user, and then clears the memory.

*/

(defrule recommEND
	(declare (salience 1));this rule must fire as soon as it's activated so I gave it a higher salience
	?count <- (accumulate (bind ?bookcount 0);the accumulate function lets me keep a count for how many times
			(++ ?bookcount)		 ;a pattern, in this case a book, passes through
			?bookcount
			(book (t ?t) (a ?a)))
	(test (= ?count 1)); if there is only one book left
	(book (t ?t) (a ?a)); the book is matched for here so I have a handle for the title and author I'm printing out
	=>
	(printthis (str-cat "I recommend " ?t " by " ?a "!"))
	(clear)	
)




/*

The rule askq works like a function. It takes an adjective characteristic (in this case asserted as (ask ?char))
and prints out the generic question "Do you want to read a _____ novel?"
If the user says yes then the characteristic is asserted as (must characteristic)
otherwise it is asserted as (must-not characteristic)
The reason why askq is a rule and not a function is so that I can make sure that
at least one book contains the characteristic it's asking for and that the system hasn't already asked for 
the characteristic already.

Because it's a rule, however, I don't know for sure when it will end up asking the question.

*/

(defrule askq 
	(ask ?char)

	;makes sure that at least one book has that ?char
	(exists (or 
	(book (a ?char))
	(book (genre $? ?char $?))
	(book (story $? char $?))
	(book (tone $? ?char $?))
	(book (style $? ?char $?))))

	;and that ?char has not already been asked about
	(not (or (must ?char) (must-not ?char)))
	=>
	(printthis (str-cat "Do you want to read a " ?char " novel?")); before printing out the string, all underscores are replaced with spaces
	(bind ?ans (read)); takes in user response
	
	;if response is yes then asserted as must, if no then asserted as must-not
	(if (eq (str-compare (sub-string 1 1 ?ans) "y") 0) then (assert-string (str-cat "(must " ?char ")")) )
	(if (eq (str-compare (sub-string 1 1 ?ans) "n") 0) then (assert-string (str-cat "(must-not " ?char ")")) )
)


/*

The function ask-multifield is used by the rule recognize-book to ask questions about every 
characteristic in a given list.

*/

(deffunction ask-multifield (?list)
	(bind ?i 1)
	(while (<= ?i (length$ ?list)) (assert (ask (nth$ ?i ?list))) (++ ?i))	
)

/*

The rule recognize-book is fired if the system has the book which the user mentions in the database.
It will ask questions based on all known information of the book.

*/

(defrule recognize-book	

	;if book and foundbook have same title
	?book <- (book (t ?t))
	(foundbook (t ?t))

	=>
	;this will allow other question-asking rules to begin asking questions
	(assert (question))
	
	;will ask questions about every known characteristic about the recognized book
	;the first few questions have a tendency to render the following planned questions
	;obsolete
	(ask-multifield ?book.genre)
	(ask-multifield ?book.tone)
	(ask-multifield ?book.style)
	(ask-multifield ?book.story)

	;retracts book so system won't recommend the book the person has already read
	(retract ?book)	
)

/*

dont-recognize-book will skip the questions tailored to the user's specific book and allow 
the main question asking rules to start firing by asserting (question).

*/
(defrule dont-recognize-book
	(foundbook (t ?t))
	(not (book (t ?t)))
	=>
	(assert (question))
)


/* THE MAIN QUESTION ASKING RULES */


/*
(defrule ask-question-about-length
	(question)
	=>
	(printthis (str-cat "Do you want to read a short, medium, or long length novel? s, m, l, or n (none) is sufficient."))
	(bind ?ans (read)); takes in user response
	
	(if (eq (str-compare (sub-string 1 1 ?ans) "s") 0) then (assert-string "(must short)"))
	(if (eq (str-compare (sub-string 1 1 ?ans) "m") 0) then (assert-string "(must medium)"))
	(if (eq (str-compare (sub-string 1 1 ?ans) "l") 0) then (assert-string "(must long)"))
)


(defrule ask-question-about-era
	(question)
	=>
	(printthis (str-cat "From which century do you want your novel to be? Warning- currently only novels from the 20th and 21st centuries are in the library, so if you want a recommendation I (Book Guru) recommend picking one of those!"))
	(bind ?ans (read)); takes in user response
	
	(if (eq (str-compare (sub-string 1 2 ?ans) "21") 0) then (assert-string (str-cat "(must 21)")) )
	(if (eq (str-compare (sub-string 1 2 ?ans) "20") 0) then (assert-string (str-cat "(must 20)")) )
	(if (eq (str-compare (sub-string 1 2 ?ans) "19") 0) then (assert-string (str-cat "(must 19)")) )
	(if (eq (str-compare (sub-string 1 2 ?ans) "18") 0) then (assert-string (str-cat "(must 18)")) )
	(if (eq (str-compare (sub-string 1 2 ?ans) "17") 0) then (assert-string (str-cat "(must 17)")) )
)
*/

(defrule ask-question-about-genre
	(question);the requirement of the (question) assertion is to make sure that 
		  ; recognize-book would be able to ask questions before this rule
	(dont-fire)
	;takes two books which have at least one characteristic in the the genre field
	?book1 <- (book (genre $?genre&:(> (length$ ?genre) 0)))
	?book2 <- (book (genre $?genre2&:(> (length$ ?genre2) 0)))
	
	;testing to make sure that the books don't have the exact same genres.
	;&~ constraint doesn't work because the genres can have the same characteristics
	;written in different orders and the system will think
	;they have different genres, so I created a list of the genres in ?genre2
	;that ?genre doesn't have and made sure that there's something in it

	(test (neq (length$ (complement$ ?genre ?genre2)) 0))

	=>
	;creates list of genres from both books that the other book doesn't have
	(bind ?list (create$ (complement$ ?genre ?genre2) (complement$ ?genre2 ?genre)))
		
	;asks about characteristics in list
	(bind ?i 1)
	(while (< ?i (length$ ?list)) (assert (ask (nth$ ?i ?list))) (++ ?i))
)

(defrule ask-question-about-tone
	(question)
	(dont-fire)
	?book1 <- (book (tone $?tone&:(> (length$ ?tone) 0)))
	?book2 <- (book (tone $?tone2&:(> (length$ ?tone2) 0)))
	
	(test (neq (length$ (complement$ ?tone ?tone2)) 0))

	=>
	(bind ?list (create$ (complement$ ?tone ?tone2) (complement$ ?tone2 ?tone)))
	(bind ?i 1)
	(while (< ?i (length$ ?list)) (assert (ask (nth$ ?i ?list))) (++ ?i))
)


(defrule ask-question-about-story
	(question)
	(dont-fire)
	?book1 <- (book (story $?story&:(> (length$ ?story) 0)))
	?book2 <- (book (story $?story2&:(> (length$ ?story2) 0)))
	
	(test (neq (length$ (complement$ ?story ?story2)) 0))

	=>
	(bind ?list (create$ (complement$ ?story ?story2) (complement$ ?story2 ?story)))
	(if (= (length$ ?list) 1) then (assert (ask ?list)) else (prefer ?list))
	
)


(defrule ask-question-about-style
	(question)
	(dont-fire)
	?book1 <- (book (style $?style&:(> (length$ ?style) 0)))
	?book2 <- (book (style $?style2&:(> (length$ ?style2) 0)))
	
	(test (neq (length$ (complement$ ?style ?style2)) 0))

	=>
	(bind ?list (create$ (complement$ ?style ?style2) (complement$ ?style2 ?style)))
	;characteristics are asked one by one rather than in the prefer construct b/c the 
	;values in the style slot tend not to have too much distinction between them
	(bind ?i 1)
	(while (< ?i (length$ ?list)) (assert (ask (nth$ ?i ?list))) (++ ?i))
)


(reset)

(run)

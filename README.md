NotQuiteTher is an e-reader with some gaming values. 

# Default view — the virtual typewriter

The user, in this view, is the book’s author. The view is first-person. It is what you’d get sitting down at a typewriter. The user “types” on their keyboard and produces the text of a randomly selected book. The graphics and sound effects are that of a classic typewriter. It is designed to be immersive and fully responsive.

Each page is typed to completion, unless the user chooses to break off early. In either case, the page is removed from the typewriter and displayed for review. The user decides, like a writer, whether to scrap their work and start on a new book or to push forward instead. In either case, the virtual typewriter is re-loaded and typing continues.

# Read view — the quick flip

The user can, at any time, exit the virtual typewriter and enter “Read” view. In so doing, the user-as-author premise is broken. The user takes their distance from the text instead. They can flip the pages quickly. They can skip ahead to the next chapter. They can jump from book to book. 

# My folder — archive and metadata

Books seen over the course of a session are collected in the user folder. The user folder is accessible at any time. Inside are details about each book: title, author, current popularity, Library of Congress designations as well as the portion of the book the user has already viewed. The user can reopen any book in their folder and pick up where they left off with it in read view or in the virtual typewriter.

# Navigation — hot keys

The user experience is intended to be dynamic. Sink in with a text if you choose, or skip lightly instead, picking up books and putting them down, flipping through the pages, shuffling through your folder and just generally browsing at arm’s length, like you might have in an old book store. There are buttons for navigation with the mouse. But it’s quicker and more fun to learn the hot keys and use them. Click the info buttons or press ‘i’ for a key guide.

# Code and technical functioning

NQT runs on books from Project Gutenberg (gutenberg.org). The app comes loaded with metadata for about 15k of the +60k books in the Project Gutenberg library. The texts of the books are fetched one-by-one as needed during runtime from the web server (). Each text is downloaded and processed it in two steps, first using pattern matching to find the start of the book and each chapter break, then subbing out two- and three-byte characters to ensure UTF-8 compatibility. The text is then paired with its metadata in a table and paginated, unpaginated and repaginated over and over again to suit all views and animations that arise from user choices.

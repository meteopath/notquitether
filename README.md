## NotQuiteTher
An e-reader/Project Gutenberg portal.

App for desktop/laptop. Library of over 15 thousand books from Project Gutenberg. Books are presented at random. The user has two choices for reading:

1. The Virtual Typewriter for an immersive, first-person writer experience
2. The Bookshop for a breezy, arm's-distance view

Read or flip through at your own pace. "Close" one book and move on to the next. Each book, once closed, is added to a session catalog called "My Folder", where the user can go to view metadata for all the books seen or to reopen one and read some more.

### Virtual Typewriter
The Virtual Typewriter requires users to "type" (pressing any keys) to reveal the text of the book bit by bit. Type to the end of the page. The page is removed from the Typewriter and presented for review. The user is asked to choose whether to continue to the next page or to load the next book. Typing in the typewriter can always be interrupted or bypassed completely. Pressing "1" interrupts typing at the current place. Pressing "2" jumps straight to the end of the page. In both cases, the page is removed from the Virtual Typewriter and presented for immediate review. Press "escape" or click the typewriter icon in the upper left of the screen to close the Virtual Typewriter and move to the Bookshop view.

### Bookshop
The Bookshop view allows for hot-key navigation -- "o" to page forward, "j" to page back, "l" to skip to the next chapter, and "u" to load a new book. Skip lightly. The Bookshop is the anti-Virtual Typewriter. It is anti-immersive. Engage with the texts from a distance, like in the old days walking the stacks in Barnes & Noble. 

### My Folder
My Folder, the session catalog, is also hot-key enabled. It is designed for the same arm's-distance, breezy experience as the Bookshop. "My Folder" is accessed from any page by opening Settings. (To open Settings, either click on the mug icon in the upper right of the screen or press the "backspace" key.) Note that only "closed" books are added to My Folder. My Folder is empty at the start of every session. Your first book is added to My Folder when you "close" it and move on to your second book. 

### Settings
Settings gives the user options to target the kind of books they want to see ("Search criteria") and to increase the app speed. For Search criteria, the user can choose to see books within certain bands of popularity (quantified as downloads/mo. from the Project Gutenberg website) or books that were more recently uploaded to the Project Gutenberg site. Game speed, which regulates the Virtual typewriter, can be raised to 1.25x, 1.5x or 2x.

### Navigation
App navigation is best with hot-keys. The mouse is not needed or recommended. Hot-key navigation is faster and more fun. Press "i" for the key map to the functionality on every page (or click the "i" icon in the bottom left of the screen). There is a key shortcut for every button and icon. Mouse navigation, while not recommended, is enabled. Toggle between the Virtual Typewriter and the Bookshop by clicking the typewriter icon in the upper left of the screen (or just press "escape"). Access settings by clicking the mug icon in the upper right of the screen (or just press "backspace"). Click the on-screen buttons to navigate the Bookshop and My Folder.

### Development
NotQuiteTher is written in the Lua programming language. It runs on the LOVE 2D framework. It is a learn-by doing project. The code was refactored and expanded three times as I learned more about the language and framework and about the constraints of deployment. I got lots of help and inspiration from the LOVE 2D forum and from countless resources online. The latest code refactoring was based almost entirely on object-oriented design presented in [this demo](https://github.com/WeebNetsu/YouTube-Projects/tree/main/Lua/Love2D/Asteroids%20Game). 

### Functioning
NQT runs on books from Project Gutenberg (gutenberg.org). The app comes loaded with metadata for about 15k of the +60k books in the Project Gutenberg library. The actual texts of the books are not included. The texts are fetched one-by-one as needed during runtime from [this web address](http://gutenberg.readingroo.ms). Each text is downloaded and then processed in two steps, first using pattern matching to find the start of the book and each chapter break, then subbing out two- and three-byte characters to ensure UTF-8 compatibility. This is all carried out by functions in the file "textPrep.lua". The text, once processed, is passed (along with its chapter indexing) from textPrep.lua to "bookManager.lua." bookManager.lua is the NQT command center. It is in charge of all of the app's data. It is the central node. All functions in peripheral files pass the data they collect to bookManager. These functions then make requests to bookManager for all the data they need to run. In bookManager, the processed text and chapter index is paired with the book's metadata (title, author, downloads/month, subjects, weblink) to create a BOOK object (a Lua table). Most data requests are filled with an object (a Lua table) that includes a chapter's worth of text and some of the attributes and methods required to carry out the various animations, paginations and repaginations that make up the substance of the app functioning. Further attributes and methods are added by the functions in peripheral files responsible for displaying the data to the user.

- "**typewriter.lua**" manages the Virtual Typewriter interface.
- "**eval.lua**" manages the review interface presented at the end of every page "typed" in the Virtual Typewriter.
- "**read.lua**" manages the Bookshop interface.
- "**Settings.lua**" manages the settings and My Folder interfaces.
- "**navigation.lua**" helps with settings/My Folder navigation.
- "**icons.lua**" handles the transitions among the Virtual Typewriter -- Bookshop -- Settings interfaces.
- "**infoPopup.lua**" handles some hot-key maps.
- "**explainer.lua**" handles other hot-key maps.
- "**main.lua**" is the LOVE 2D keystone. It is the first file called when the app opens.
- "**load.lua**" loads the static assets when he app opens.
- "**intro.lua**" runs the opening animation/title sequence.
- "**conf.lua**" haș project settings.


### Lua/Python to Pure Lua
For most of its time in development, NQT was a hybrid Lua/Python app. It was mostly Lua, but I needed libraries written in Python to do two jobs, one job that was essential -- the weblink to Project Gutenberg to download books -- and one job that was nice to have, but inessential -- a gif maker that allowed users to select portions of a text and create downloadable typewriter gifs. I couldn't find Lua libraries to do the same job, so I wrote the functionalities in two Python files: a getbook downloader supported by the Python library c-w gutenberg and a gif maker supported by Python PIL. I linked the Lua and Python files through the command line. When the core Lua app needed a new book or a gif, it made a command to the Python files via io.popen and passed the necessary arguments in a string. The Python files filled the request to specification and outputted json files and gifs to the LOVE save folder, where the core Lua app found them and read them into memory for use in the run. This struck me as inefficient. But it worked in development on my machine. The problem came when I had to zip things up for deployment. The commands issued via io.popen no longer found their way to the Python files. I was stuck for a few weeks reading and trying things that didn't work. I was bailed out by the LOVE forum, where a contributor looked at my problem and wrote me a socket in Lua (I inserted it into my code as "get_gutenberg_text()" on line 13 of textPrep.lua), which was something I'd tried and failed to do for myself. At that point I was free to dump Python altogether. I tried get a Lua image library to replace PIL, but I couldn't figure it out, so I cut the gif making functionality and was left with a slightly slimmer and much more efficient app.

### Next steps
I would like to get this app on the App Store. But I've been stuck for a month. My builds and archives are successful in Xcode. But every attempt to upload fails with a message "Error Analyzing App Version". If you have any insight, I would be very happy to hear it. I have a [post](https://love2d.org/forums/viewtopic.php?f=4&t=93621&p=250107&hilit=version#p250107) on the LOVE forum with a few more details.

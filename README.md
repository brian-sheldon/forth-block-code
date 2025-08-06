# forth-block-code
A method to transmit data via imaes using a simple block code on a retro system

After reading a blog post for a small Forth interpreter project, I checked out the link to a demo and the source ocde on a github repository.  The forth was a fairly easy to follower minimal Forth written in Z80 assembler.  After a quick look at the source code, I realized the code using some atypical directives and there was even at least one non-existent Z80 instruction.  I was immediately curious to see the generated binary code.  So I wrote a few simple forth words to view the code in hex on the online demo.  Working between the browser and the source code winodows was a bit tedious, so I decided to try using AI to quickly convert an image of the screen to text.  This mostly worked, but the AI was only about 70% accurate.

It then occurred to me, text is great for us humans, but not so much for computers.  So I decided to write some forth words to display the data using a simple block code system, that can be more easily decoded by a computer.  The next day, I was able to easily come up with and create the Forth words to generate the block code on the demo's display.  As there was no way to store my code on the demo, I found a way to simulate typing the code in from the linux command line.  This provided the way of sending to the demo.  Next I found a way to automate the screenshots.  The next day, I managed to write the python code to decode the generated image.

Following is an image of a hex block of data.  Easy for us humans, not so easy for a computer to decode.

<image>



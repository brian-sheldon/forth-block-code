# forth-block-code
A method to transmit data via imaes using a simple block code on a retro system

After reading a blog post for a small Forth interpreter project, I checked out the link to a demo and the source ocde on a github repository.  The forth was a fairly easy to follower minimal Forth written in Z80 assembler.  After a quick look at the source code, I realized the code using some atypical directives and there was even at least one non-existent Z80 instruction.  I was immediately curious to see the generated binary code.  So I wrote a few simple forth words to view the code in hex on the online demo.  Working between the browser and the source code winodows was a bit tedious, so I decided to try using AI to quickly convert an image of the screen to text.  This mostly worked, but the AI was only about 70% accurate.  It would have probably worked better if I used screenshots rather than taking pictures.

What I did next was not entirely the easiest way to accomplish what I wanted, but I realized it would be a fun and interesting challenge.  I needed a refresher on Forth and what better way than to make use of it.  Although this code is not specifically useful, it does demonstrate a fairly quick and easy way to generate a usable block coding system, mind you one that requires reasonably high quality images.  The techniques used in scanning are similar to how one would get data from a serial communication system, using sync blocks to identify where the data starts.  So a useful learning exercise.  Plus the tools I discovered to assist with automation are definitely useful for other tasks.

It then occurred to me, text is great for us humans, but not so much for computers.  So I decided to write some forth words to display the data using a simple block code system, that can be more easily decoded by a computer.  The next day, I was able to easily come up with and create the Forth words to generate the block code on the demo's display.  As there was no way to store my code on the demo, I found a way to simulate typing the code in from the linux command line.  This provided the way of sending to the demo.  Next I found a way to automate the screenshots.  The next day, I managed to write the python code to decode the generated image.

Following is an image of a hex block of data.  Easy for us humans, not so easy for a computer to decode.

![First of the original text based screenshots](/images/text.8000.png)

Here is an image of a block code version of a hex dump.  Now this is what computers like to see.

![First block code image, cropped from screenshot](/images/code.8000.png)

Note: This is actually a cropped version of the image for easier display here.  The original screenshot includes the entire page, so the decoder must be able to find the image within the page.

## Forth Words

The following Forth words were created to produce the original hex dump.

endianswap - as the system is little endian, this allows the word to be converted to big endian byte order

``` Forth
: endianswap
    dup 8>>
    swap 8<<
    + ;
```

hex4       - output the 16 bit word on the stack as hex with leading zeros

``` Forth
: hex4
    dup $1000 < if $30 emit then
    dup  $100 < if $30 emit then
    dup   $10 < if $30 emit then
    hex u. ;
```

hexline    - generate a line including the memory address followed by 8 words

``` Forth
: hexline
    dup hex4 $20 emit $20 emit
    8 0 do
        dup @ endianswap hex4
        $20 emit
        2 +
    loop
    cr ;"
```

hexblock   - display 8 hex lines

``` Forth
: hexblock
    8 0 do
        hexline
    loop ;
```

For the graphics block code dump, only the endianswap word is needed.  The following new words were created

font       - used to display the character set, used to test ouputing various characters

``` Forth
: font
    cls
    192 0 do
        i 32 < if
            $20 emit
        else
            i emit
        then
    loop
    cr ;
```

gsync      - creates an easy to find sync pattern for the decoder

``` Forth
: gsync
    $bf emit
    3 0 do
        $20 emit
        $bf emit
    loop ;
```

gmap       - creates a legend of the characters used, not necessary

``` Forth
: gmap
    16 0 do
        i u.
        i $81 + emit
    loop ;
```

gsp        - emits spaces to align the varous components on the screen

``` Forth
: gsp
    0 do
        $20 emit
    loop ;
```

gheader    - output a left sync block, the legend and the right sync block

``` Forth
: ghead
    cls
    gsync
    9 gsp
    gmap
    9 gsp
    gsync ;
```

gword      - output a 16 bit word as block characters

``` Forth
: gword
    dup 8>> $f0 and $10 / $81 + emit
    dup 8>> $0f and $81 + emit
    dup $f0 and $10 / $81 + emit
    $0f and $81 + emit ;
```

gline      - output a line of 32 encoded words as the line width is 64 characters

``` Forth
: gline
    16 0 do
        dup @ endianswap dup gword
        rot + swap
        2 +
    loop ;
```

gblock     - output 8 lines of encoded words

``` Forth
: gblock
    8 0 do
        gline
    loop ;
```

gfoot      - output a left sync block, start address, end address, chksum and right sync block

``` Forth
: gfoot
    gsync 10 gsp
    dup $100 - dup gword $20 emit hex4 $20 emit
    dup 1 - dup gword $20 emit hex4 $20 emit
    swap dup gword $20 emit hex4 $20 emit
    10 gsp gsync ;
```

gbody      - outputs the header, code block and footer

``` Forth
: gbody
    0 swap
    ghead
    gblock
    gfoot cr ;
```

gstart     - sets the starting address and puts the forth into hex output mode

``` Forth
: gstart
    hex
    $8000
    gbody ;
```

The Forth code for these words is in block-code.fs

## Python Decoder

The Python module Pillow was used for scanning the generated image.  First the image is loaded.  It is then scanned row by row to find the sync blocks.  The locations of the sync blocks are recorded.  Once the scan is complete, the minumum and maximum coordinates of the sync blocks are determines.  Thse are used to calculate the location of the block data and the size of each screen character.  With this information it is then fairly easy to recognize the various block characters.  Due to the high quality of the image, due to it being a screenshot, it is only necessary to get the value of a single pixel for each block within the character, preferably in the central region as the edges vary due to anti-aliasing.  The characters are made of six block in a 2x3, 2 wide by 3 high format.  Each of these six bits are then used to determine the value of the character and an array is used to determine the hex nibble the graphic block represents.  Once the block is scanned, the footer is used to read the start and end address of the block, in addition to a chksum to verify no errors occurred.

I then tested the Forth encoder, took a screenshot and tested the Python decoder.  The data transfer appeared to be reliable.  As there were a number of the blocks I wanted to transfer, I decided to look into automating this process.  The following tools were used for the automation.

## Automation

As this demo system has no way to save the Forth code I created, I found a tool to simulate typing in the code for these words.  The tool I used is "xdotool".  I installed it in Raspberry Pi Os (Bookworm) using the following command.

``` sh
sudo apt install xdotool
```

I then found the tool, "gnome-screenshot", to do screenshots from the linux command line.  It is installed using this command.

``` sh
sudo apt install gnome-screenshot
```

Then I created some bash scripts to do the automation.  The first, "xdo.words.sh", on uses the xdotool to send the Forth code to the browser.  It is also able to automatically find the browser window using the title of the window.  I found it necessary to have it automatically put the window in focus before sending the code to the browser.  The firefox browser worked with no issues, but the window had to be left in focus until complete.  I was unable to get the chrome browser to work reliably.  It seemed unable to receive the ":" character.

The next bash script, "xdo.sh", was used to automate the process of generating a graphic block with Forth, taking a screenshot and running the Python decoder.




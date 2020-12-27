# The super project Bitcoin2Delphi for this conversion attempt is here:  

https://github.com/SkybuckFlying/Bitcoin2Delphi  

For now it is advised to simply clone the super project.  

The/this delphicoin repository below will function as a collector to collect the converted delphi code ! =D  

# Delphicoin  

#### Bitcoin for Pascal/Delphi programming language !  

This project converts the bitcoin c/c++ source code into Pascal/Delphi source code.  

### Two important rules when converting a c/c++ file to Delphi must be followed:  

## 1. The original file paths must be recorded in the Delphi file/unit at the top:  

(Preferably below the copyright text with one empty line between it)  

For example unit_Tchain.pas:  

    // Copyright (c) 2009-2010 Satoshi Nakamoto
    // Copyright (c) 2009-2019 The Bitcoin Core developers
    // Copyright (c) 2020-2020 Skybuck Flying
    // Copyright (c) 2020-2020 The Delphicoin Developers
    // Distributed under the MIT software license, see the accompanying
    // file COPYING or http://www.opensource.org/licenses/mit-license.php.

    // Bitcoin file: src/chain.h
    // Bitcoin file: src/chain.cpp
    // Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c 
    
Another example unit_TBlockStatus.pas:  

    // Copyright (c) 2009-2010 Satoshi Nakamoto
    // Copyright (c) 2009-2019 The Bitcoin Core developers
    // Copyright (c) 2020-2020 Skybuck Flying
    // Copyright (c) 2020-2020 The Delphicoin Developers
    // Distributed under the MIT software license, see the accompanying
    // file COPYING or http://www.opensource.org/licenses/mit-license.php.

    // Bitcoin file: src/chain.h
    // Bitcoin file: src/chain.cpp
    // Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c     

(This unit also came from chain.h and chain.cpp it was split into a seperate unit, even though the path indicates this, this is not assured since  
bitcoin may have it's own subfolders, this could lead to confusion there it is very beneficial to record the origins/file paths of the source code like this.)  

## 2. The converted delphi file must contain the bitcoin commit hash against which it was ported.  

For example unit_Tchain.pas:  

    // Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c
    
Another example unit_TBlockStatus.pas:  

    // Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

(Identical since it come from the same bitcoin commit/hash in the working tree).  

This will allow to do a git diff in the future against the converted bitcoin commit/hash and any future bitcoin commit/hash to detect any changes that may need porting to Delphi.  

For now the conversion attempt will be done against a moving target. This means some delphi units may have been converted    
against an older bitcoin commit/hash these may have to be re-converted or updated later once a new bitcoin release happens.    
At some point in the future we will try and stabilize the conversion process against a certain stable release/tag of bitcoin.    

## The aim of the project is to:

1. Convert all necessary bitcoin c/c++ source code to Pascal/Delphi for easier studieing of bitcoin's operation.    
2. Work together with other Delphi/Pascal developers for fun and profit ! =D    
3. Learn how to use GIT in bigger team effort and have fun with it.    
4. Perhaps also learn a little bit more about C/C++ latest language features.    
5. After conversion is done perhaps find ways to speed up bitcoin with delphi technology.    
  
Requirements to take part in this project:
  
1. Must have a recent version of Delphi, for example Delphi 10.2 will do.    
2. Anybody with pascal/delphi coding experience may join this project.    
3. For now the workflow will be to fork this project or set upstream to it and issue pull request to incorporate your conversions into this main project.    
4. The branch for the delphi conversion will be called: "Delphicoin" as a nickname for this project ! :)    
5. It's ok to be messy everything helps ! =D    
6. It is preferred to use tab characters for indentation.    
    
   In Delphi->Tools->Options:    
   Use Tab Character Checked V    
   Block Ident = 4    
   Tab Stops = 4    
   Cursor through tabs Checked V    
   Optimal Fill Checked V    
   Backspace unindents Checked V    
   
   Tip: With these settings enabled an easy but slower way to convert these spaces to tabs is to enable:\
   Show tab character Checked V  
   Show space character Checked V  
     
   Then process the entire file by simply moving the cursor from top to bottom through the file with the down arrow on the keyboard.  
   Another possibility is to use textpad editor and a plugin called "tabout"  
    
7. One big class per unit. C/C++/H/HPP files containing multiple classes, enums or other data structures must be split up into multiple files.  
   The orginal file name will be used as a subfolder to keep these files together to indicate the presence of a "module" or belonging together.  
   ( For now at least, perhaps in future these moved to parent folder for more easy browsing however delphi's project file should be sufficient  
     for easily browsing sub folders and units/files in there as long as they are added to the project file which should be done !)  

8. All technical units should start with unit_ prefix in their filenames.  
  
9. Form units for gui can simple be called UnitFormSomething.pas without the underscore.  
  
10. Normally speaking all types should start with a capital letter T. Any C's for classes are to be replaced by capital letter T.  
  
11. The name of the type should be reflected in the filename as follows: for type Texample: Unit_TExample.pas  
  
12.  Comment blocks like these:  

    /**  
    *   
    */  
    
will be converted to:  

    // /**  
    // *  
    // */  
    
instead of    

    {**  
     *  
     *}  
     
to avoid re-introducing any c syntax like { }  
  
13. Commits should be done with git commit. Enter a short 50 character yellow description line at the top by pressing insert. Leave one blank line below that.  
    Optionally enter a gray longer message below that, max character length should be 72. Then press escape and write :wq    (for write and quite)  
        
#### Required software:  
  
1. Git: https://git-scm.com/   
2. Tortoise Git:  https://tortoisegit.org/  
3. Delphi: https://www.embarcadero.com/products/delphi   
4. Microsoft Windows: https://www.microsoft.com/en-us/windows  
  
5. (Optional) Lazarus: https://www.lazarus-ide.org/  
6. (Optional) Visual Studio 2019 community edition: https://visualstudio.microsoft.com/vs/  
(Recommended to only install the bare minimum like c/c++ to avoid (unrecoverable) installation issues)  
        
#### Helpfull conversion tools:   
http://rvelthuis.de/programs/convertpack.html    
https://github.com/WouterVanNifterick/C-To-Delphi     

#### Helpfull conversion links:    
http://rvelthuis.de/articles/articles-convert.html    
  
## Join discord Bitcoin2Delphi server to coordinate conversion effort    
https://discord.gg/9UrvSxzh    
Here we can meet and discuss who will convert what file so that duplicate efforts are/can be avoided.   

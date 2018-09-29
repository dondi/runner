# Runner
Runner is a macOS application that provides services for executing selected text as fragments of code. It takes its inspiration from the Smalltalk user interface, which always allowed “do it,” “print it,” and “inspect it” operations on selected text, assuming that said text was written in Smalltalk. Runner seeks to the same for any selected text in macOS, again assuming that the selected text is written in a supported programming language.

## How to Build
As a macOS application, Runner is written in Swift and managed by Xcode. It also uses this [Algorithmia API](https://algorithmia.com/algorithms/PetiteProgrammer/ProgrammingLanguageIdentification) for programming language “guessing,” as well as the [Siesta library](https://bustoutsolutions.github.io/siesta/) for contacting this API. Siesta is integrated into the project as a `git` submodule.

Due to these characteristics, you’ll need to take the following steps to get going with Runner:
1. Clone this repository
2. Acquire an API key from [Algorithmia](https://algorithmia.com)
3. Edit the _Source/KeysAndTokens.swift_ file so that it has this API key
4. Refresh the Siesta submodule with the command:

    git submodule update --init

Once these steps have been taken, the project should be buildable/runnable through Xcode in the usual way. Upon building, you will then want to place the application in the _Applications_ folder so that its _Run This_ service becomes available in the _Services_ menu.

## How to Use
Once Runner has been built and installed, the macOS _Services_ menu should have a new item, _Run This_, that becomes available when text is selected in any application. Select the text (which is presumably runnable code) then access the _Services_ menu either through the text’s contextual menu or the application menu. Choosing _Run This_ should launch Runner with a window containing the selected text/code.

Runner may take some moments to guess the code’s programming language (as determined by the aforementioned programming language identification service hosted by Algorithmia). Once it has guessed the language, the language appears in the window and Runner attempts to execute the code. If the language is supported, then you should see the program’s output in the bottom half of the window.

If the code’s language isn’t supported by Runner, then unfortunately your adventure ends here. However, if the language _is_ supported but just not guessed correctly, you can go to the _Run_ menu in the menu bar and choose from the _Run This as…_ menu items that are available there.

## Supported Languages
At this writing, Runner can execute code in these languages. Note that, with the exception of JavaScript, your machine should have the standard packages for these languages installed. Fortunately, macOS comes with most of these languages out of the box:
* JavaScript
* Perl
* Python
* Rubby
* Swift

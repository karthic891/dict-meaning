# dict-meaning

dict-meaning is a simple Emacs plugin to get the meaning(s) of a word from Oxford Dictionary. Place the cursor on any word in the buffer and invoke the command to get the meaning.

## Installation Steps
1. Clone the repository somewhere
	```
	$ cd ~/.emacs.d/plugins
	$ git clone https://github.com/karthic891/dict-meaning.git
	```
2. Because the plugin uses Oxford Dictionary to get the meaning, you need to provide the credential to Oxford Dictionary API. Create an account [here](https://developer.oxforddictionaries.com) and get the `application id` and `application key`. 
3. Replace the empty string `""` for app-id and app-key, lines `87` and `88` respectively, in `~/.emacs.d/plugins/dict-meaning/dict-meaning.el` with the `application id` and `application key` obtained from the previous step
4. Add the following to your `.emacs` file

	```elisp
	(add-to-list 'load-path "~/.emacs.d/plugins/dict-meaning")
	(require 'dict-meaning)
	```	
5. Restart the emacs for the changes to take effect
6. Place the cursor over any word and press `M-x dict-meaning` The definition(s) and usage(s) will be displayed in separate buffer named `WordOfTheDay` You can press `q` to quit from that buffer to return back to original buffer
7. Optional: You can bind `dict-meaning` to any key combination that you like by adding the following to your `.emacs` file
	```
	(global-set-key (kbd "C-c C-m") 'dict-meaning)
	```

Finally, feedback is not only welcome, but encouraged. Thank you very much for using dict-meaning!
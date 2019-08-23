(require 'cl-lib)

(cl-defstruct meaning definitions usages)
(cl-defstruct word key meanings)

(defun parse-definitions (definitions)
  ;; (print (format "Definitions: %s" definitions))
  (setq final-definitions nil)
  (let (definitions-len i definition)
    (setq definitions-len ( length definitions))
    (setq i 0)
    (while (< i definitions-len)
      (setq definition (elt definitions i))
      (push definition final-definitions)
      (setq i (1+ i))))
  final-definitions)

(defun parse-examples (examples)
  (setq final-examples nil)
  (let (examples-len i example-pair example)
    (setq examples-len (length examples))
    (setq i 0)
    (while (< i examples-len)
      (setq example-pair (elt examples i))
      (setq example (cdr (assoc 'text example-pair)))
      (push example final-examples)
      (setq i (1+ i))))
  final-examples)

(defun pretty-print-definitions (definitions)
  "Pretty print Definitions list"
  (let (definition)
    ;; Only when definitions is not empty
    (when definitions
      (print "Definition(s)")
      (while (not (null definitions))
	(setq definition (car definitions))
	(print (format "%s" definition))
	(setq definitions (cdr definitions))))))

(defun pretty-print-usages (usages)
  "Pretty print Usages list"
  (let (usage)
    ;; Only when usages is not empty
    (when usages
      (print "Usage(s)")
      (while (not (null usages))
	(setq usage (car usages))
	(print (format "%s" usage))
	(setq usages (cdr usages))))))

(defun pretty-print-word (word)
  (print "Word")
  (print (format "%s" (word-key word)))
  (let (meanings-list meaning i definitions-list definition usages-list usage)
    (setq i 1)
    (setq meanings-list (word-meanings word))
    (print "Meaning(s)")
    (while (not (null meanings-list))
      ;; (print (format "%d. %s" i (car meanings-list)))
      (setq meaning (car meanings-list))
      (setq definitions-list (meaning-definitions meaning))
      (setq usages-list (meaning-usages meaning))
      (pretty-print-definitions definitions-list)
      (pretty-print-usages usages-list)
      (setq meanings-list (cdr meanings-list))
      (setq i (1+ i)))))

(defun print-nonsense (buffer-name)
  (with-help-window buffer-name
    (print "nonsense")))

(defun dict-meaning ()
  (interactive)
  (let (word)
    (setq word (current-word))
    (get-meaning-from-oxford-dict word)
    ))


(defun get-meaning-from-oxford-dict (word1)
  ;; Get the definition and usage from Oxford Dictionary
  ;; Sign into: https://developer.oxforddictionaries.com to get app_id and app_key
  (let (oxford-dict-url accept-header app-id-header app-key-header)
    (setq oxford-dict-url (concat "https://od-api.oxforddictionaries.com/api/v2/entries/en-gb/" word1 "?strictMatch=false"))
    (setq accept-header "application/json")
    (setq app-id-header "")  ;; Replace "" with your app-id
    (setq app-key-header "") ;; Replace "" with yoru app-key
    ;; The passing of headers may look a little weird, that's because addition of variables to emacs alist doesn't substitute the values in the variable. We've to use escape character ` instead of single quote ' to evaluate it
    ;; Reference: https://stackoverflow.com/questions/1664202/emacs-lisp-evaluate-variable-in-alist
    (request oxford-dict-url
	     :headers `(("Accept" . ,accept-header) ("app_id" . ,app-id-header) ("app_key" . ,app-key-header))
	     :parser 'json-read
	     :success (cl-function
		       (lambda (&key data &allow-other-keys)
			 (setq result-definitions '())
			 (setq result-examples '())
			 (setq result-meanings '())
			 (setq myBuff (get-buffer-create "*WordOfTheDay*"))
			 (with-help-window myBuff
			   ;; (print (format "I sent: %S" data))
			   (setq word-from-response (cdr (assoc 'word data)))
			   (setq result (cdr (assoc 'results data)))
			   ;; (print (format "%s" result))
			   (setq res (elt result 0))
			   (setq lexicalEntries (cdr (assoc 'lexicalEntries res)))
			   ;; (print (format "%s" lexicalEntries))
			   (setq def-len (length lexicalEntries))
			   ;; (print (format "Length: %d" def-len))
			   (setq i 0)
			   (while (< i def-len)
			     (setq lexical-entry (elt lexicalEntries i))
			     ;; (print (format "%d. %s" i lexical-entry))
			     ;; (print (format "%s" (cdr (assoc 'entries lexical-entry))))
			     (setq entries (cdr (assoc 'entries lexical-entry)))
			     ;; (print (format "%s" entries))
			     (setq entry-len (length entries))
			     (setq j 0)
			     (while (< j entry-len)
			       (setq entry (elt entries j))
			       (setq senses (cdr (assoc 'senses entry)))
			       (setq senses-len (length senses))
			       (setq k 0)
			       (while (< k senses-len)
				 (setq sense (elt senses k))
				 (setq definitions (cdr (assoc 'definitions sense)))
				 (setq examples (cdr (assoc 'examples sense)))
				 (push (parse-definitions definitions) result-definitions)
				 (push (parse-examples examples) result-examples)
				 (setq word-meaning (make-meaning :definitions (parse-definitions definitions) :usages (parse-examples examples)))
				 (push word-meaning result-meanings)
				 (setq k (1+ k)))
			       (setq j (1+ j)))
			     (setq i (1+ i)))
			   (setq word-val (make-word :key word-from-response :meanings (reverse result-meanings)))
			   (pretty-print-word word-val)
			   ;; (set-window-point (get-buffer-window "*WordOfTheDay*") (point-max))
			   ))))))

(provide 'dict-meaning)

(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(unless (package-installed-p 'use-package) 
  (package-refresh-contents) 
  (package-install 'use-package))

;; If there are no archived package contents, refresh them
(when (not package-archive-contents) 
  (package-refresh-contents))

(setq byte-compile-warnings '(cl-functions))
(require 'cl-lib)

;; spacemacs dark theme in default emacs
(load-theme 'spacemacs-dark t)

;; spacemacs mode line in default emacs
(require 'spaceline-config)
(spaceline-spacemacs-theme)
(spaceline-helm-mode 1)

;; have mode icons instead of names
;; (mode-icons-mode)

;; -------------------------------------------- org

(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () 
			   (org-bullets-mode 1)))

;; change default org-level fontsizes
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1)))))

(setq org-todo-keywords '((sequence "TODO(t!)" "IN-PROGRESS(i!)" "PROCESSING(p!)" "WAITING(w!)" "CANCELED(c!)" "DONE(d!)")))

(setq org-todo-keyword-faces '(("IN-PROGRESS" . "orange") 
			       ("PROCESSING" . "orange") 
			       ("WAITING" . "orange") 
			       ("CANCELED" . "yellow") ))

(setq inhibit-startup-screen t)

(add-hook 'org-mode-hook 'org-indent-mode)

(setq org-log-done 'time)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(csv-separators '("," "	" ";"))
 '(custom-safe-themes
   '("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default))
  '(org-agenda-files
   '("~/org/agenda.org"))
 '(package-selected-packages
   '(diff-hl cl-libify cl-lib sphinx-mode sphinx-doc loccur org-cliplink eglot julia-repl julia-mode markdown-mode vc-msg json-mode yaml-mode helm-ag org-ref-prettify org-ref ibuffer-vc csv-mode lispy elisp-format spacemacs-theme helm-bibtex dumb-jump tree-mode tree-sitter vscode-dark-plus-theme code-cells cdlatex lean-mode yasnippet-classic-snippets yasnippet-snippets autothemer display-theme hydra magit eink-theme flycheck-pos-tip zenburn-theme use-package org-bullets python-cell hlinum pyenv-mode material-theme flycheck exec-path-from-shell elpy ein color-theme-sanityinc-tomorrow blacken better-defaults anaconda-mode))
 '(safe-local-variable-values
   '((eval when
	   (require 'rainbow-mode nil t)
	   (rainbow-mode 1)))))


;; spell checking
; (setq ispell-program-name (executable-find "hunspell") ispell-dictionary "en_US")
(setq ispell-program-name "ispell")
; (setq ispell-local-dictionary "en_GB")
(setq ispell-local-dictionary-alist
      '(("en_GB" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)))

(use-package 
    flyspell-correct-ivy 
  :ensure t 
  :demand t)

;; enable flyspell
(add-hook 'org-mode-hook #'turn-on-flyspell)

;; correct word
(eval-after-load 'org '(define-key org-mode-map (kbd "C-c c")
			 #'flyspell-correct-word-before-point))

;; insert org-mode link with title of page found in URL
(eval-after-load 'org '(define-key org-mode-map (kbd "C-c C-i")
			 'org-cliplink))

;; move to org header
(eval-after-load 'org '(define-key org-mode-map (kbd "C-c i")
			 'imenu))

;; stop preparing agenda buffers on startup
(setq org-agenda-inhibit-startup t)

;; open org-agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;; org-agenda setup
(setq org-agenda-custom-commands
      `(("A" "Daily agenda and top priority tasks"
         ((tags-todo "*"
                     ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                      (org-agenda-skip-function
                       `(org-agenda-skip-entry-if
                         'notregexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                      (org-agenda-block-separator nil)
                      (org-agenda-overriding-header "Important tasks without a date\n")))
          (agenda "" ((org-agenda-span 1)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-scheduled-past-days 0)
                      ;; We don't need the `org-agenda-date-today'
                      ;; highlight because that only has a practical
                      ;; utility in multi-day views.
                      (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                      (org-agenda-format-date "%A %-e %B %Y")
                      (org-agenda-overriding-header "\nToday's agenda\n")))
          (agenda "" ((org-agenda-start-on-weekday nil)
                      (org-agenda-start-day "+1d")
                      (org-agenda-span 3)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "\nNext three days\n")))
          (agenda "" ((org-agenda-start-on-weekday nil)
                      ;; We don't want to replicate the previous section's
                      ;; three days, so we start counting from the day after.
                      (org-agenda-start-day "+4d")
                      (org-agenda-span 14)
                      (org-agenda-show-all-dates nil)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-agenda-entry-types '(:deadline))
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "\nUpcoming deadlines (+14d)\n")))
	  (agenda "" ((org-agenda-start-on-weekday nil)
                      (org-agenda-start-day "+1d")
                      (org-agenda-span 21)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "\nNext three weeks\n")))))
        ("P" "Plain text daily agenda and top priorities"
         ((tags-todo "*"
                     ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                      (org-agenda-skip-function
                       `(org-agenda-skip-entry-if
                         'notregexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                      (org-agenda-block-separator nil)
                      (org-agenda-overriding-header "Important tasks without a date\n")))
          (agenda "" ((org-agenda-span 1)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-scheduled-past-days 0)
                      ;; We don't need the `org-agenda-date-today'
                      ;; highlight because that only has a practical
                      ;; utility in multi-day views.
                      (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                      (org-agenda-format-date "%A %-e %B %Y")
                      (org-agenda-overriding-header "\nToday's agenda\n")))
          (agenda "" ((org-agenda-start-on-weekday nil)
                      (org-agenda-start-day "+1d")
                      (org-agenda-span 3)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "\nNext three days\n")))
	  (agenda "" ((org-agenda-start-on-weekday nil)
                      (org-agenda-start-day "+1d")
                      (org-agenda-span 21)
                      (org-deadline-warning-days 0)
                      (org-agenda-block-separator nil)
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "\nNext three weeks\n"))))
         ((org-agenda-with-colors nil)
          (org-agenda-prefix-format "%t %s")
          (org-agenda-fontify-priorities nil)
          (org-agenda-remove-tags t)))))

;; resolve Windmove conflicts (like org state looping)
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "S-<right>")  'windmove-right)))
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "S-<left>")  'windmove-left)))
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "C-<up>")  'org-shiftup)))
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "S-<up>")  'windmove-up)))
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "C-<down>")  'org-shiftdown)))
(add-hook 'org-mode-hook (lambda () 
			   (local-set-key (kbd "S-<down>")  'windmove-down)))

;; quickly open a note document in org mode
(defun open-notes ()
  (interactive)
  (let ((daily-name (format-time-string "%y%m%d_%H%M%S")))
    (find-file (format "~/Notes/Notes_%s.org" daily-name))))

;; setup emacs popups for org-alert
(require 'org-alert)
(setq alert-default-style 'libnotify)

;; set org-alert to check your agenda file every 5 minutes,
;; start notifying you of a scheduled event 10 minutes before the event,
;; and stop notifying you of the event 10 minutes after the scheduled time
;; has passed.
(setq org-alert-interval 300
      org-alert-notify-cutoff 30
      org-alert-notify-after-event-cutoff 10)
(org-alert-enable)

;; enable auto fill in org files
(add-hook 'org-mode-hook #'auto-fill-mode)
(setq-default fill-column 70)

;; -------------------------------------------- yaml

(require 'yaml-mode) 
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; -------------------------------------------- json

(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
;; (add-hook 'json-mode-hook 'json-mode-beautify)

;; -------------------------------------------- tex

(require 'tex-site)
;; flychecks needs ispell, aspell, hunspell
(add-hook 'LaTeX-mode-hook '(lambda () 
			      (reftex-mode) 
			      (flyspell-mode)))
(setq reftex-plug-into-AUCTeX t)
;; (setq reftex-load-hook (quote (imenu-add-menubar-index)))
;; (setq reftex-mode-hook (quote (imenu-add-menubar-index)))
(setq TeX-view-program-list (quote ("Okular" ("output-pdf" "okular"))))


;; ;; cdlatex
(autoload 'cdlatex-mode "cdlatex" "CDLaTeX Mode" t)
(autoload 'turn-on-cdlatex "cdlatex" "CDLaTeX Mode" t)
(add-hook 'LaTeX-mode-hook 'turn-on-cdlatex) ; with AUCTeX LaTeX mode

;; break line after 80 characters
(add-hook 'LaTeX-mode-hook #'auto-fill-mode)
(setq-default fill-column 70)

(add-hook 'LaTeX-mode-hook #'turn-on-flyspell)

;;(setq TeX-source-correlate-mode t)
(setq TeX-view-program-list (quote (("okular" ("okular" (mode-io-correlate " -p %(outpage)") "
%o")))))
(setq TeX-view-program-selection (quote (((output-dvi style-pstricks) "dvips and gv") 
					 (output-dvi "xdvi") 
					 (output-pdf "okular") 
					 (output-html "xdg-open"))))

(setq ring-bell-function 'ignore)

(add-hook 'flyspell-mode-hook #'flyspell-buffer)

;; correct word
(eval-after-load 'latex '(define-key LaTeX-mode-map (kbd "C-c c")
			   #'flyspell-correct-word-before-point))

;; get synonyms from Thesaurus.com (get-synonyms)
(add-to-list 'load-path "~/.emacs.d/custom-modes/thesaurus.el")
(require 'thesaurus)
(eval-after-load 'latex '(define-key LaTeX-mode-map (kbd "C-c t")  #'get-synonyms))

;; complete citations by scanning bibtex file
(use-package citar
  :custom
  (citar-bibliography '("~/bib/references.bib"))
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup))
(eval-after-load 'latex '(define-key LaTeX-mode-map (kbd "C-c C-p")  #'citar-insert-citation))

;; enable automatic parsing of tex files
(setq TeX-parse-self t)

;; -------------------------------------------- useful global settings

;; restore the last saved desktop on startup
(desktop-save-mode 1)

;; remember recent files
(recentf-mode 1)
(setq recentf-max-menu-items 30)
(setq recentf-max-saved-items 30)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; Save minibuffer prompts (M-n and M-p to access them)
(setq history-length 50)
(savehist-mode 1)

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; hide menu-bar and tool-bar forever
(menu-bar-mode -1)
(tool-bar-mode -1)

;; show parentheses
(show-paren-mode 1)

;; enable icicle
;; (add-to-list 'load-path "~/.emacs.d/icicles")
;; (require 'icicles)

;;;  format elisp code
;; (add-hook 'emacs-lisp-mode-hook (lambda ()
;; 				  (add-hook 'after-save-hook 'elisp-format-buffer)))

;; always reload files if they changed on disk
(setq global-auto-revert-mode t)

;; make Pg-Up Pg-Down return to the same point
(setq scroll-preserve-screen-position t)

;; start emacs as server
;; (server-start)

;; simple window traveling
(windmove-default-keybindings)

;; Default mode for unknown files
(setq default-major-mode 'text-mode)

;; Don’t compact font caches during GC.
(setq inhibit-compacting-font-caches t)

;; Jump multiple lines at once (efficient travelling)
(global-set-key (kbd "C-d") 
		(lambda () 
		  (interactive) 
		  (previous-line 10)))
(global-set-key (kbd "C-f") 
		(lambda () 
		  (interactive) 
		  (next-line 10)))

;; move to the middle of the current line
(defun my/move-to-middle () 
  (interactive) 
  (let* ((begin (line-beginning-position)) 
	 (end (line-end-position)) 
	 (middle (/ (+ end begin) 2))) 
    (goto-char middle)))
(global-set-key (kbd "M-s") 'my/move-to-middle)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; revert but keep undo history
(defun revert-buffer-keep-undo (&rest -)
  "Revert buffer but keep undo history."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert-file-contents (buffer-file-name))
    (set-visited-file-modtime (visited-file-modtime))
    (set-buffer-modified-p nil)))
(setq revert-buffer-function 'revert-buffer-keep-undo)

;; some upper limits on sizes
(setq max-lisp-eval-depth '40000)
(setq max-specpdl-size '100000)
(setq undo-limit 40000
      undo-outer-limit 8000000
      undo-strong-limit 100000)

;; simple window switch
(windmove-default-keybindings)

;; auto bullet mode
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () 
			   (org-bullets-mode 1)))

;; enable tree-sitter
;; (global-tree-sitter-mode)

;; enable dumb jump (M-.)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;; show current match and number of matches
(global-anzu-mode +1)
;; let spaceline take car of matches
(setq anzu-cons-mode-line-p nil)

;; activate csv-mode for csv and txt files
(add-to-list 'auto-mode-alist '("\\.csv\\'" . csv-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'" . csv-mode))
;; add some other common separators
(setq csv-separators '(";" "," "\t"))

;; facilite move to beginning/end of buffer
(global-set-key (kbd "C-,") 'beginning-of-buffer)
(global-set-key (kbd "C-.") 'end-of-buffer)

;; give a DOI, get a bibtex entry (complementary to org-ref)
(defun get-bibtex-from-doi (doi) 
  "Get a BibTeX entry from the DOI" 
  (interactive "MDOI: ") 
  (let ((url-mime-accept-string "text/bibliography;style=bibtex")) 
    (with-current-buffer (url-retrieve-synchronously (format "http://dx.doi.org/%s"
							     (replace-regexp-in-string
							      "http://dx.doi.org/" "" doi))) 
      (switch-to-buffer (current-buffer)) 
      (goto-char (point-max)) 
      (setq bibtex-entry 
	    (buffer-substring 
	     (string-match "@" (buffer-string)) 
	     (point))) 
      (kill-buffer (current-buffer)))) 
  (insert (decode-coding-string bibtex-entry 'utf-8)) 
  (bibtex-fill-entry))
(global-set-key (kbd "C-c b") 'get-bibtex-from-doi)

(use-package 
  org-ref 
  :custom (reftex-default-bibliography '("~/org/references.bib")) 
  (org-ref-bibliography-notes "~/org/notes.org") 
  (org-ref-default-bibliography '("~/org/references.bib")) 
  (org-ref-pdf-directory "~/org/books") ;; keep the final slash off
  )

;; write bibtex entry in bib from DOI
(global-set-key (kbd "C-c u") 'org-ref-url-html-to-bibtex)

;; run a shell command quickly
(global-set-key (kbd "C-c s") 'shell-command)

;; facilitate string replacement
(global-set-key (kbd "C-x r") 'replace-string)

;; git blame
(defun vc-msg-hook-setup (vcs-type commit-info)
  ;; copy commit id to clipboard
  (message (format "%s\n%s\n%s\n%s" (plist-get commit-info 
					       :id) 
		   (plist-get commit-info 
			      :author) 
		   (plist-get commit-info 
			      :author-time) 
		   (plist-get commit-info 
			      :author-summary))))
(add-hook 'vc-msg-hook 'vc-msg-hook-setup)

;; show file VC historic
(global-set-key (kbd "C-x c") 'magit-log-buffer-file)

;; list pattern occurences in current buffer and go
(use-package loccur
  :bind ((
          ("C-o" .  loccur-isearch)
          )))

;; show clipboard history (in buffer)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

;; loop over clipboard history (in minibuffer)
(global-set-key (kbd "C-t") 'yank-pop)

;; use helm mainly for pattern search
(add-to-list 'load-path "~/.emacs.d/helm")
(require 'helm-config)

;; find file or buffer matching pattern and open
(setq helm-locate-command "locate %s -wAe --regex %s")
(setq helm-find-files-sort-directories t)
(setq helm-semantic-fuzzy-match t)
(setq helm-completion-in-region-fuzzy-match t)
(global-set-key (kbd "M-X")  'helm-M-x)
(global-set-key (kbd "C-o")  'helm-occur)
(global-set-key (kbd "C-x C-d")  'helm-for-files)

;; show kill ring history
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

;; use helm mainly for pattern search
(add-to-list 'load-path "~/.emacs.d/color-moccur.el")
(require 'color-moccur)

;; vertical completion in minibuffer
(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))

;; add useful annotations to completion candidates
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; use bufler to group buffers per project
(use-package bufler
  :config (bind-key "C-c C-b" #'bufler-list))

;; -------------------------------------------- git

;; make shell-command to pick up .bashrc aliases
(setq shell-file-name "bash")
(setq shell-command-switch "-ic")

;; easy git add commit and push
(defun push-all (comment) 
  (interactive "Mcomment:") 
  (save-some-buffers t)			; save all buffer
  (shell-command (format "git add -A; git commit -a -m \" %s\"; git push &" comment)))

(global-set-key (kbd "C-c g") 'push-all)

;; easy git add commit and push
(defun update-gitignore (comment)
  (interactive "Mcomment:") 
  (save-some-buffers t)			; save all buffer
  (shell-command (format "git rm -r --cached .; git add -A; git commit -a -m \" %s\"; git push &" comment)))

(global-set-key (kbd "C-c t") 'update-gitignore)

;; Scrape own private and public Github repositories
;; for existing code matching input
;; consult-gh-search-my-code currently used instead
(defun find-gh-code (code) 
  (interactive "Mcode:") 
  (shell-command (format "ghcode -ri %s" code)))

;; (global-set-key (kbd "C-c f") 'find-gh-code)

;; a GitHub CLI client inside GNU Emacs using Consult
;; note: make sure gh CLI is setup (gh auth login)
(add-to-list 'load-path "~/.emacs.d/custom-modes/consult-gh")
(require 'consult-gh)

;; add your main GitHub account (replace "armindarvish" with your user or org)
(add-to-list 'consult-gh-default-orgs-list "AdrienWehrle")

;; ;; use "gh org list" to get a list of all your organizations and adds them to default list
(setq consult-gh-default-orgs-list (append consult-gh-default-orgs-list (remove "" (split-string (or (consult-gh--command-to-string "org" "list") "") "\n"))))

;; ;; set the default folder for cloning repositories, By default Consult-GH will confirm this before cloning
(setq consult-gh-default-clone-directory "~/")

;; show previews
(setq consult-gh-show-preview t)

;; highlight code matches
(setq consult-gh-highlight-matches t)

;;show previews on demand by hitting "M-o"
(setq consult-gh-preview-key "M-o")

;;show previews in org-mode
(setq consult-gh-preview-buffer-mode 'org-mode)

;;open files that contain code snippet in an emacs buffer
(setq consult-gh-code-action 'consult-gh--code-view-action)

;;open files in an emacs buffer
(setq consult-gh-file-action 'consult-gh--files-view-action)

;;open file tree of repo on selection
(setq consult-gh-repo-action 'consult-gh--repo-browse-files-action)

;; only search my own codebase
(defun consult-gh-search-my-code (&optional initial repo noaction)
  "Search my own code"
  (interactive)
  (let ((consult-gh-search-code-args (append consult-gh-search-code-args '("--owner=AdrienWehrle"))))
    (consult-gh-search-code initial repo noaction)))

(global-set-key (kbd "C-c f") 'consult-gh-search-my-code)

;; -------------------------------------------- MOOSE

;; syntax highlighting for MOOSE input and test files
;; https://github.com/dylanjm/emacs-moose-mode
(add-to-list 'load-path "~/.emacs.d/custom-modes/emacs-moose-mode")
(require 'moose-mode)

;; -------------------------------------------- modify buffers

;; Originally from stevey, adapted to support moving to a new directory.
(defun rename-file-and-buffer (new-name) 
  "Renames both current buffer and file it's visiting to NEW-NAME." 
  (interactive (progn (if (not (buffer-file-name)) 
			  (error 
			   "Buffer '%s' is not visiting a file!"
			   (buffer-name)))
		      ;; Disable ido auto merge since it too frequently jumps back to the original
		      ;; file name if you pause while typing. Reenable with C-z C-z in the prompt.
		      (let ((ido-auto-merge-work-directories-length -1)) 
			(list (read-file-name (format "Rename %s to: " (file-name-nondirectory
									(buffer-file-name)))))))) 
  (if (equal new-name "") 
      (error 
       "Aborted rename")) 
  (setq new-name (if (file-directory-p new-name) 
		     (expand-file-name (file-name-nondirectory (buffer-file-name)) new-name) 
		   (expand-file-name new-name)))
  ;; Only rename if the file was saved before. Update the
  ;; buffer name and visited file in all cases.
  (if (file-exists-p (buffer-file-name)) 
      (rename-file (buffer-file-name) new-name 1)) 
  (let ((was-modified (buffer-modified-p)))
    ;; This also renames the buffer, and works with uniquify
    (set-visited-file-name new-name) 
    (if was-modified (save-buffer)
      ;; Clear buffer-modified flag caused by set-visited-file-name
      (set-buffer-modified-p nil))) 
  (setq default-directory (file-name-directory new-name)) 
  (message "Renamed to %s." new-name))
(global-set-key (kbd "C-c r")  #'rename-file-and-buffer)

(defun delete-file-and-buffer () 
  "Kill the current buffer and deletes the file it is visiting." 
  (interactive) 
  (let ((filename (buffer-file-name))) 
    (when filename (if (vc-backend filename) 
		       (vc-delete-file filename) 
		     (progn (delete-file filename) 
			    (message "Deleted file %s" filename) 
			    (kill-buffer))))))
(global-set-key (kbd "C-c d")  #'delete-file-and-buffer)

;; -------------------------------------------- ibuffer

(require 'ibuffer)

(global-set-key (kbd "C-x C-b") 'ibuffer) ;; Use Ibuffer for Buffer List

(setq ibuffer-saved-filter-groups '(("default" ("elisp" (mode . emacs-lisp-mode)) 
				     ("org" (or (mode . org-mode) 
						(filename . "OrgMode"))) 
				     ("python" (or (mode . python-mode))) 
				     ("C++" (or (mode . c-mode) 
						(mode . c++-mode))) 
				     ("folders" (mode . dired-mode)) 
				     ("tex" (mode . latex-mode)) 
				     ("csv" (mode . csv-mode)) 
				     ("txt" (mode . text-mode)) 
				     ("bash" (mode . sh-mode)) 
				     ("yml" (mode . yaml-mode))
				     ("vterminals" (mode . vterm-mode)) 
				     ("magit" (or (mode . magit-status-mode) 
						  (mode . magit-diff-mode) 
						  (mode . magit-revision-mode))) 
				     ("MOOSE" (mode . moose-mode)))))

(setq ibuffer-expert t)
(setq ibuffer-show-empty-filter-groups nil)

(add-hook 'ibuffer-mode-hook '(lambda () 
				(ibuffer-switch-to-saved-filter-groups "default")))

;; automatically refresh ibuffer
(add-hook 'ibuffer-mode-hook (lambda () 
			       (ibuffer-auto-mode 1)))

;; human readable size column
(defun ajv/human-readable-file-sizes-to-bytes (string) 
  "Convert a human-readable file size into bytes." 
  (interactive) 
  (cond ((string-suffix-p "G" string t) 
	 (* 1000000000 (string-to-number (substring string 0 (- (length string) 1))))) 
	((string-suffix-p "M" string t) 
	 (* 1000000 (string-to-number (substring string 0 (- (length string) 1))))) 
	((string-suffix-p "K" string t) 
	 (* 1000 (string-to-number (substring string 0 (- (length string) 1))))) 
	(t (string-to-number (substring string 0 (- (length string) 1))))))

(defun ajv/bytes-to-human-readable-file-sizes (bytes) 
  "Convert number of bytes to human-readable file size." 
  (interactive) 
  (cond ((> bytes 1000000000) 
	 (format "%10.1fG" (/ bytes 1000000000.0))) 
	((> bytes 100000000) 
	 (format "%10.0fM" (/ bytes 1000000.0))) 
	((> bytes 1000000) 
	 (format "%10.1fM" (/ bytes 1000000.0))) 
	((> bytes 100000) 
	 (format "%10.0fk" (/ bytes 1000.0))) 
	((> bytes 1000) 
	 (format "%10.1fk" (/ bytes 1000.0))) 
	(t (format "%10d" bytes))))

;; Use human readable Size column instead of original one
(define-ibuffer-column size-h 
  (:name "Size" 
	 :inline t 
	 :summarizer (lambda (column-strings) 
		       (let ((total 0)) 
			 (dolist (string column-strings) 
			   (setq total
				 ;; like, ewww ...
				 (+ (float (ajv/human-readable-file-sizes-to-bytes string)) total))) 
			 (ajv/bytes-to-human-readable-file-sizes total))) ;; :summarizer nil
	 ) 
  (ajv/bytes-to-human-readable-file-sizes (buffer-size)))

;; Modify the default ibuffer-formats
(setq ibuffer-formats '((mark modified read-only locked " " (name 20 20 

								  :left 
								  :elide) " " (size-h 11 -1 
										      :right) " "
										      (mode 16 16 

											    :left 
											    :elide)
										      " "
										      filename-and-process) 
			(mark " " (name 16 -1) " " filename)))

(defun ibuffer-advance-motion (direction) 
  (forward-line direction) 
  (beginning-of-line) 
  (if (not (get-text-property (point) 'ibuffer-filter-group-name)) t (ibuffer-skip-properties
								      '(ibuffer-filter-group-name)
								      direction) nil))

;; Improve line movement in ibuffer
(defun ibuffer-previous-line 
    (&optional 
     arg)
  "Move backwards ARG lines, wrapping around the list if necessary." 
  (interactive "P") 
  (or arg 
      (setq arg 1)) 
  (let (err1 err2) 
    (while (> arg 0) 
      (cl-decf arg) 
      (setq err1 (ibuffer-advance-motion -1) err2 (if (not (get-text-property (point)
									      'ibuffer-title)) t
						    (goto-char (point-max)) 
						    (beginning-of-line) 
						    (ibuffer-skip-properties '(ibuffer-summary
									       ibuffer-filter-group-name)
									     -1) nil))) 
    (and err1 
	 err2)))

(defun ibuffer-next-line 
    (&optional 
     arg)
  "Move forward ARG lines, wrapping around the list if necessary." 
  (interactive "P") 
  (or arg 
      (setq arg 1)) 
  (let (err1 err2) 
    (while (> arg 0) 
      (cl-decf arg) 
      (setq err1 (ibuffer-advance-motion 1) err2 (if (not (get-text-property (point)
									     'ibuffer-summary)) t
						   (goto-char (point-min)) 
						   (beginning-of-line) 
						   (ibuffer-skip-properties '(ibuffer-summary
									      ibuffer-filter-group-name
									      ibuffer-title) 1)
						   nil))) 
    (and err1 
	 err2)))

;; Improve header movement in ibuffer
(defun ibuffer-next-header () 
  (interactive) 
  (while (ibuffer-next-line)))

(defun ibuffer-previous-header () 
  (interactive) 
  (while (ibuffer-previous-line)))

(define-key ibuffer-mode-map (kbd "<up>") 'ibuffer-previous-line)
(define-key ibuffer-mode-map (kbd "<down>") 'ibuffer-next-line)
(define-key ibuffer-mode-map (kbd "<right>") 'ibuffer-next-header)
(define-key ibuffer-mode-map (kbd "<left>") 'ibuffer-previous-header)

;; -------------------------------------------- julia

(require 'julia-mode)
(require 'julia-repl)
(add-hook 'julia-mode-hook 'julia-repl-mode)
(add-hook 'julia-mode-hook 'eglot-jl-init)
(add-hook 'julia-mode-hook 'eglot-ensure)

(add-hook 'julia-mode-hook '(lambda () 
			      (local-set-key (kbd "C-d") 'julia-repl-send-line) 
			      (local-set-key (kbd "C-c C-c") 'julia-repl-send-buffer)))

;; -------------------------------------------- matlab/octave

;; octave mode on matlab files
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))

;; turn on the abbrevs, auto-fill and font-lock features
(add-hook 'octave-mode-hook
          (lambda ()
            (abbrev-mode 1)
            (auto-fill-mode 1)
            (if (eq window-system 'x)
                (font-lock-mode 1))))

;; run line and block
(add-hook 'octave-mode-hook '(lambda () 
			      (local-set-key (kbd "<C-return>") 'octave-send-line) 
			      (local-set-key (kbd "C-c C-c") 'octave-send-region)))

;; -------------------------------------------- python

;; myPackages contains a list of package names
(defvar myPackages 
  '(better-defaults ;; Set up some better Emacs defaults
    elpy	    ;; Emacs Lisp Python Environment
    flycheck	    ;; On the fly syntax checking
    blacken	    ;; Black formatting on save
    magit	    ;; Git integration
    ))

(setq inhibit-startup-message t) ;; Hide the startup message
;; (global-linum-mode t)		 ;; Enable line numbers globally
;; (global-display-line-numbers-mode t)

;; Enable elpy
(elpy-enable)

;; Enable Black
(add-hook 'elpy-mode-hook #'blacken-mode)

;; Enable flycheck
(add-hook 'elpy-mode-hook #'flycheck-mode)

;; Enable Flycheck
(when 
    (require 'flycheck nil t) 
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules)) 
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; activate EO-IO environment on start
(add-hook 'elpy-mode-hook '(lambda () 
			     (pyvenv-activate "~/mambaforge3/envs/EO-IO")))

;; run ipython instead of python with run-python
(setq python-shell-interpreter "ipython3" python-shell-interpreter-args "-i --simple-prompt")

;; display errors and warnings in pos-tip popups
(with-eval-after-load 'flycheck (flycheck-pos-tip-mode))

;; make flycheck inline errors red
;; (set-face-attribute 'flycheck-error nil :underline '(:color "red2" :style wave))

;; disable flycheck warnings and infos
(set-face-attribute 'flycheck-fringe-warning nil 
		    :foreground (face-attribute 'fringe 
						:background ))
(set-face-attribute 'flycheck-fringe-info nil 
		    :foreground (face-attribute 'fringe 
						:background ))
(set-face-attribute 'flycheck-warning nil 
		    :underline nil)
(set-face-attribute 'flycheck-info nil 
		    :underline nil)

;; automatic python header
(auto-insert-mode 1)
(eval-after-load 'autoinsert '(define-auto-insert '("\\.\\py\\'" . "python-UZH-header") 
				'("" "#!/usr/bin/env python3" \n "# -*- coding: utf-8 -*-" \n
				  "\"\"\"" \n \n
				  "@author: Adrien Wehrlé, University of Zurich, Switzerland" \n \n
				  "\"\"\"" \n \n \n)))

;; automatic tex header
(auto-insert-mode 1)
(eval-after-load 'autoinsert '(define-auto-insert '("\\.\\tex\\'" . "latex-header") 
				'("" "\\documentclass{article}" \n "\\usepackage[utf8]{inputenc}" \n \n
				  "\\title{template}" \n "\\author{Adrien Wehrlé}" \n
				  (format-time-string "\\date{%B %Y}") \n \n
				  "\\begin{document}" \n \n "\\maketitle" \n \n
				  "\\section{Introduction}" \n \n "\\end{document}")))


;; disable indentation marks
(add-hook 'elpy-mode-hook (lambda () 
			    (highlight-indentation-mode -1)))

;; prevent very long ipython buffers
(add-hook 'inferior-python-mode-hook #'my-inferior-python-mode-hook)

(defun my-inferior-python-mode-hook () 
  "Custom `inferior-python-mode' behaviours."
  (setq-local comint-buffer-maximum-size 2000) ;; maximum lines
  (add-hook 'comint-output-filter-functions 'comint-truncate-buffer nil 
	    :local))

;; handy keybinding for matching history
(add-hook 'inferior-python-mode-hook (lambda () 
				       (local-set-key (kbd "C-c <C-up>")
						      'comint-previous-matching-input-from-input)))
(add-hook 'inferior-python-mode-hook (lambda () 
				       (local-set-key (kbd "C-c <C-down>")
						      'comint-next-matching-input-from-input)))

;; go to specific indxe
(eval-after-load 'python '(define-key python-mode-map (kbd "C-c i")
			 'imenu))

;; rename existing python instance to use a new one at next call
(defun new-python-instance (inactive_instance_name)
  (interactive (list (read-string "Rename inactive instance: " "*Python1*")))
  (switch-to-buffer "*Python*")
  (rename-buffer inactive_instance_name))

;; activate existing python instance (many steps because
;; buffer can't rename with an existing name (*Python42* is temporary)
(defun switch-python-instance (instance_name)
  (interactive (list (read-string "Activate instance: " "*Python1*")))
  (switch-to-buffer instance_name)
  (rename-buffer "*Python42*")
  (switch-to-buffer "*Python*")
  (rename-buffer instance_name) 
  (switch-to-buffer "*Python42*")
  (rename-buffer "*Python*"))
		    
;; detect jupyter notebook cells with code-cell
(add-to-list 'load-path "~/.emacs.d/code-cells.el")
(require 'code-cells)

;; mark and run cell
(defun run-pycell () 
  (interactive) 
  (code-cells-mark-cell)
  (elpy-shell-send-region-or-buffer)
  (forward-line 1)
  (code-cells-forward-cell)
  (keyboard-quit))

(add-hook 'elpy-mode-hook (lambda () 
			    (local-set-key (kbd "C-c <C-return>")
					   'run-pycell)))

;; switch to ipython buffer
;; switch to ipython buffer
(defun switch-to-ipython-buffer ()
  (interactive)
  (if (get-buffer "*Python*")
      (switch-to-buffer "*Python*")
    ((run-python)
     (switch-to-buffer "*Python*"))))
  
(global-set-key (kbd "C-c p")  #'switch-to-ipython-buffer)

;; insert docstring skeleton for Python functions and methods
(add-hook 'python-mode-hook (lambda ()
                                  (require 'sphinx-doc)
                                  (sphinx-doc-mode t)
				  ))

;; set linum (line numbering) colors
(require 'linum)
(set-face-background 'linum "#222b35")
(set-face-foreground 'linum "#999999")

;; highlight current line
(require 'hlinum)
(hlinum-activate)
(set-face-foreground 'linum-highlight-face "#ffffff")
(set-face-background 'linum-highlight-face "#222b35")

;; customise fringe
(set-face-background 'fringe "#222b35")
(set-face-foreground 'flycheck-fringe-error "#FF0000")
(fringe-mode '(14 . 0))

;; -------------------------------------------- terminal emulator

;; start terminal
(global-set-key (kbd "C-c v") 'multi-vterm)

;; toggle to previous terminal instance
(add-hook 'vterm-mode-hook (lambda () 
				       (local-set-key (kbd "C-x <C-prior>")
						      'multi-vterm-prev)))

;; toggle to next terminal instance
(add-hook 'vterm-mode-hook (lambda () 
				       (local-set-key (kbd "C-x <C-next>")
						      'multi-vterm-next)))

;; start terminal
(global-set-key (kbd "C-c v") 'multi-vterm)

;; switch to ipython buffer
(defun switch-to-vterm-buffer ()
  (interactive)
  (if (get-buffer "*vterminal<1>*")
      (switch-to-buffer "*vterminal<1>*")))
(global-set-key (kbd "C-c l")  #'switch-to-vterm-buffer)

;; -------------------------------------------- tramp

;; Faster than the default scp (for small files)
(setq tramp-default-method "ssh")

(provide '.emacs)

;;;.emacs ends here


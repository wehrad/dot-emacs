;; package.el and MELPA setup
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)
(package-initialize)

;; Install use-package via package.el if missing
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; If there are no archived package contents, refresh them
(when (not package-archive-contents) 
  (package-refresh-contents))

(setq byte-compile-warnings '(cl-functions))
(require 'cl-lib)

;; spacemacs dark theme
(use-package spacemacs-theme
  :ensure t
  :config
  (load-theme 'spacemacs-dark t))

;; spacemacs mode line
(use-package spaceline
  :ensure t
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme)
  (spaceline-helm-mode 1))

;; have mode icons instead of names
;; (mode-icons-mode)

;; -------------------------------------------- org

;; org-bullets: prettier org headings
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; Custom faces for org-level fontsizes (keep as-is)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1)))))

;; Org TODO keywords and colors (keep as-is)
(setq org-todo-keywords
      '((sequence "TODO(t!)" "IN-PROGRESS(i!)" "PROCESSING(p!)" "WAITING(w!)" "CANCELED(c!)" "DONE(d!)")))

(setq org-todo-keyword-faces
      '(("IN-PROGRESS" . "orange") 
        ("PROCESSING" . "orange") 
        ("WAITING" . "orange") 
        ("CANCELED" . "yellow")))

(setq inhibit-startup-screen t)

;; Enable org-indent-mode in org buffers
(add-hook 'org-mode-hook #'org-indent-mode)

(setq org-log-done 'time)

;; Spell checking in org-mode
(use-package flyspell-correct-ivy
  :ensure t
  :demand t)

(add-hook 'org-mode-hook #'turn-on-flyspell)

(eval-after-load 'org
  '(progn
     ;; Correct word keybinding
     (define-key org-mode-map (kbd "C-c c") #'flyspell-correct-word-before-point)

     ;; Insert org link with title of page found in URL
     (define-key org-mode-map (kbd "C-c C-i") 'org-cliplink)

     ;; Jump to org header (imenu)
     (define-key org-mode-map (kbd "C-c i") 'imenu)))

;; Org agenda settings
(setq org-agenda-inhibit-startup t)
(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-custom-commands
      ;; Keep your full custom commands as is
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
                      (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                      (org-agenda-format-date "%A %-e %B %Y")
                      (org-agenda-overriding-header "\nToday's agenda\n")))
          ;; ... other agenda blocks ...
          ))))

;; Fix windmove conflicts in org-mode by rebinding keys locally
(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "S-<right>") 'windmove-right)
            (local-set-key (kbd "S-<left>")  'windmove-left)
            (local-set-key (kbd "C-<up>")    'org-shiftup)
            (local-set-key (kbd "S-<up>")    'windmove-up)
            (local-set-key (kbd "C-<down>")  'org-shiftdown)
            (local-set-key (kbd "S-<down>")  'windmove-down)))

;; Quick notes function
(defun open-notes ()
  (interactive)
  (let ((daily-name (format-time-string "%y%m%d_%H%M%S")))
    (find-file (format "~/notes/notes_%s.org" daily-name))))

;; org-alert setup
(use-package org-alert
  :ensure t
  :config
  (setq alert-default-style 'libnotify
        org-alert-interval 300
        org-alert-notify-cutoff 30
        org-alert-notify-after-event-cutoff 10)
  (org-alert-enable))

;; Enable auto-fill mode in org buffers
(add-hook 'org-mode-hook #'auto-fill-mode)
(setq-default fill-column 70)

;; -------------------------------------------- yaml

(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" . yaml-mode))

;; -------------------------------------------- json

(use-package json-mode
  :ensure t
  :mode ("\\.json\\'" . json-mode))

;; -------------------------------------------- tex

(use-package tex-site
  :ensure auctex
  :defer t
  :hook
  (LaTeX-mode . reftex-mode)
  (LaTeX-mode . flyspell-mode)
  (LaTeX-mode . turn-on-cdlatex)
  (LaTeX-mode . auto-fill-mode)
  (flyspell-mode . flyspell-buffer)
  :config
  ;; set font size for the different section titles
  (with-eval-after-load 'font-latex
  (dolist (face '(font-latex-sectioning-0-face  ; \part
                  font-latex-sectioning-1-face  ; \chapter
                  font-latex-sectioning-2-face  ; \section
                  font-latex-sectioning-3-face  ; \subsection
                  font-latex-sectioning-4-face  ; \subsubsection
                  font-latex-sectioning-5-face)) ; \paragraph
    (when (facep face)
      (set-face-attribute face nil :height 1.1))))
  
  (setq reftex-plug-into-AUCTeX t)
  (setq fill-column 70)
  (setq ring-bell-function 'ignore)

  ;; Setup TeX view programs
  (setq TeX-view-program-list
        '(("Okular" ("output-pdf" "okular"))
          ("okular" ("okular" (mode-io-correlate " -p %(outpage)") "%o"))))
  (setq TeX-view-program-selection
        '(((output-dvi style-pstricks) "dvips and gv")
          (output-dvi "xdvi")
          (output-pdf "okular")
          (output-html "xdg-open")))

  ;; Keybindings for LaTeX mode
  (eval-after-load 'latex
    '(progn
       (define-key LaTeX-mode-map (kbd "C-c c") #'flyspell-correct-word-before-point)
       (define-key LaTeX-mode-map (kbd "C-c t") #'get-synonyms)
       (define-key LaTeX-mode-map (kbd "C-c C-p") #'citar-insert-citation)))

  ;; Enable TeX parsing
  (setq TeX-parse-self t))

;; Cdlatex autoloads
(use-package cdlatex
  :defer t)

;; citar setup for citations
(use-package citar
  :ensure t
  :custom
  (citar-bibliography '("~/bib/references.bib"))
  :hook ((LaTeX-mode . citar-capf-setup)
         (org-mode . citar-capf-setup)))

;; prevent cdlatex from inserting sub/superscripts
(with-eval-after-load 'cdlatex
  (define-key cdlatex-mode-map "_" nil)
  (define-key cdlatex-mode-map "^" nil))

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
;; 				  (add-hook 'after-save-hook
;; 					    'elisp-format-buffer)))

;; always reload files if they changed on disk
(setq global-auto-revert-mode t)

;; make Pg-Up Pg-Down return to the same point
(setq scroll-preserve-screen-position t)

;; start emacs as server
(server-start)

;; simple window traveling
(windmove-default-keybindings)

;; Default mode for unknown files
(setq default-major-mode 'text-mode)

;; Don’t compact font caches during GC.
(setq inhibit-compacting-font-caches t)

;; Jump multiple lines at once (efficient travelling)
(defun my/move-up-10-lines ()
  "Move cursor up 10 lines."
  (interactive)
  (previous-line 10))
(defun my/move-down-10-lines ()
  "Move cursor up 10 lines."
  (interactive)
  (next-line 10))

(global-set-key (kbd "C-d") 'my/move-up-10-lines)
(global-set-key (kbd "C-f") 'my/move-down-10-lines)

(global-set-key (kbd "C-c C-<up>") #'scroll-down-command)
(global-set-key (kbd "C-c C-<down>") #'scroll-up-command)

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
(setq undo-limit 400000
      undo-outer-limit 80000000
      undo-strong-limit 1000000)

;; simple window switch
(windmove-default-keybindings)

;; auto bullet mode
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; enable dumb jump (M-.)
(use-package dumb-jump
  :ensure t
  :hook (xref-backend-functions . dumb-jump-xref-activate))

;; show current match and number of matches
(use-package anzu
  :ensure t
  :config
  (global-anzu-mode +1)
  ;; let spaceline take car of matches
  (setq anzu-cons-mode-line-p nil))

;; activate csv-mode for csv and txt files
(use-package csv-mode
  :ensure t
  :mode ("\\.csv\\'" "\\.txt\\'")
  :config
  ;; add some other common separators
  (setq csv-separators '(";" "," "\t")))

;; give a DOI, get a bibtex entry (complementary to org-ref)
(defun get-bibtex-from-doi (doi)
  "Get a BibTeX entry from the DOI"
  (interactive "MDOI: ")
  (let ((url-mime-accept-string "text/bibliography;style=bibtex"))
    (with-current-buffer
	(url-retrieve-synchronously
	 (format "http://dx.doi.org/%s"
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

;; write bibtex entry in bib from DOI
(global-set-key (kbd "C-c u") 'org-ref-url-html-to-bibtex)

;; run a shell command quickly
(global-set-key (kbd "C-c s") 'shell-command)

;; facilitate string replacement
(global-set-key (kbd "C-x r") 'replace-string)

;; git blame
(defun vc-msg-hook-setup (vcs-type commit-info)
  ;; copy commit id to clipboard
  (message (format "%s\n%s\n%s\n%s"
		   (plist-get commit-info :id)
		   (plist-get commit-info :author)
		   (plist-get commit-info :author-time)
		   (plist-get commit-info :author-summary))))
(add-hook 'vc-msg-hook 'vc-msg-hook-setup)

;; show file VC historic
(global-set-key (kbd "C-x c") 'magit-log-buffer-file)

;; list pattern occurences in current buffer and go
(use-package loccur
  :ensure t
  :bind (("C-o" . loccur-isearch)))

;; show clipboard history (in buffer)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

;; loop over clipboard history (in minibuffer)
(global-set-key (kbd "C-t") 'yank-pop)

;; use helm mainly for pattern search
(use-package helm
  :ensure t
  :config
  (setq helm-locate-command "locate %s -wAe --regex %s")
  (setq helm-find-files-sort-directories t)
  (setq helm-semantic-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)
  (global-set-key (kbd "M-X") 'helm-M-x)

  (defun my/right-window ()
    "Return the rightmost window in the current frame."
    (car (last (window-list))))

  ;; run helm-for-files in right window instead of minibuffer
  (setq helm-display-function
	(lambda (buf _)
          (let ((win (my/right-window)))
            (if (window-live-p win)
		(set-window-buffer win buf)
              (display-buffer-pop-up-window buf)))))
  
  (global-set-key (kbd "C-x C-d") 'helm-for-files)
  (global-set-key (kbd "M-y") 'helm-show-kill-ring))

;; use color-moccur from MELPA
(use-package color-moccur
  :ensure t)

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
  :ensure t
  :bind ("C-c C-b" . bufler-list))

;; updatedb settings for better helm locate
;; 0 * * * * updatedb -o ~/.cache/mydb.db -U $HOME
(setq locate-db-file "~/.cache/locate.db")

;; (completion-preview-mode 1)

;; -------------------------------------------- git

(use-package shell
  :config
  ;; Make shell-command pick up .bashrc aliases
  (setq shell-file-name "bash")
  (setq shell-command-switch "-ic")

  ;; Easy git add, commit, and push
  (defun push-all (comment)
    (interactive "Mcomment:")
    (save-some-buffers t)  ;; save all buffers
    (shell-command (format
                    "git add -A; git commit -a -m \" %s\"; git push &"
                    comment)))

  (global-set-key (kbd "C-c g") #'push-all)

  ;; Easy git add, commit, push after updating .gitignore cache
  (defun update-gitignore (comment)
    (interactive "Mcomment:")
    (save-some-buffers t)
    (shell-command (format
                    "git rm -r --cached .; git add -A; git commit -a -m \" %s\"; git push &"
                    comment)))

  (global-set-key (kbd "C-c t") #'update-gitignore))

(use-package consult-gh
  :ensure t
  :after consult
  :config
  ;; Add main GitHub account
  (unless (boundp 'consult-gh-default-orgs-list)
    (defvar consult-gh-default-orgs-list nil))
  (unless (member "wehrad" consult-gh-default-orgs-list)
    (add-to-list 'consult-gh-default-orgs-list "wehrad"))

  ;; Add all GitHub organizations to the default list
  (setq consult-gh-default-orgs-list
        (append consult-gh-default-orgs-list
                (remove "" (split-string
                            (or (consult-gh--command-to-string "org" "list") "")
                            "\n"))))

  ;; Default clone directory
  (setq consult-gh-default-clone-directory "~/")

  ;; Enable previews and highlighting
  (setq consult-gh-show-preview t)
  (setq consult-gh-highlight-matches t)

  ;; Preview key and buffer mode
  (setq consult-gh-preview-key "M-o")
  (setq consult-gh-preview-buffer-mode 'org-mode)

  ;; Code, file, and repo actions open in Emacs buffers
  (setq consult-gh-code-action #'consult-gh--code-view-action)
  (setq consult-gh-file-action #'consult-gh--files-view-action)
  (setq consult-gh-repo-action #'consult-gh--repo-browse-files-action)

  ;; Search only own codebase
  (defun consult-gh-search-my-code (&optional initial repo noaction)
    "Search my own code only."
    (interactive)
    (let ((consult-gh-search-code-args
           (append consult-gh-search-code-args
                   '("--owner=wehrad"))))
      (consult-gh-search-code initial repo noaction)))

  (global-set-key (kbd "C-c f") #'consult-gh-search-my-code))

;; -------------------------------------------- MOOSE

;; syntax highlighting for MOOSE input and test files
(use-package moose-mode
  :load-path "~/.emacs.d/lisp/emacs-moose-mode"
  :mode ("\\.i\\'" . moose-mode))

(with-eval-after-load 'moose-mode
  (add-to-list 'auto-mode-alist '("\\.i\\'" . moose-mode)))

;; -------------------------------------------- C++

;; override to keep global keybindings
(with-eval-after-load 'cc-mode
  (define-key c++-mode-map (kbd "C-d") 'my/move-up-10-lines))
(with-eval-after-load 'cc-mode
  (define-key c++-mode-map (kbd "C-f") 'my/move-down-10-lines))

;; -------------------------------------------- modify buffers

;; Originally from stevey, adapted to support moving to a new directory.
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive
   (progn
     (if (not (buffer-file-name))
         (error "Buffer '%s' is not visiting a file!" (buffer-name)))
     ;; Disable ido auto merge since it too frequently jumps back to
     ;; the original file name if you pause while typing.
     ;; Reenable with C-z C-z in the prompt.
     (let ((ido-auto-merge-work-directories-length -1))
       (list (read-file-name
              (format "Rename %s to: "
                      (file-name-nondirectory (buffer-file-name))))))))
  (if (equal new-name "")
      (error "Aborted rename"))
  (setq new-name
        (if (file-directory-p new-name)
            (expand-file-name
             (file-name-nondirectory (buffer-file-name)) new-name)
          (expand-file-name new-name)))
  ;; Only rename if the file was saved before. Update the
  ;; buffer name and visited file in all cases.
  (if (file-exists-p (buffer-file-name))
      (rename-file (buffer-file-name) new-name 1))
  (let ((was-modified (buffer-modified-p)))
    ;; This also renames the buffer, and works with uniquify
    (set-visited-file-name new-name)
    (if was-modified
        (save-buffer)
      ;; Clear buffer-modified flag caused by set-visited-file-name
      (set-buffer-modified-p nil)))
  (setq default-directory (file-name-directory new-name))
  (message "Renamed to %s." new-name))

(global-set-key (kbd "C-c r") #'rename-file-and-buffer)

(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
          (vc-delete-file filename)
        (progn
          (delete-file filename)
          (message "Deleted file %s" filename)
          (kill-buffer))))))

(global-set-key (kbd "C-c d") #'delete-file-and-buffer)

;; -------------------------------------------- ibuffer

(require 'ibuffer)

(global-set-key (kbd "C-x C-b") 'ibuffer) ;; Use Ibuffer for Buffer List

(setq ibuffer-saved-filter-groups
      '(("default"
         ("elisp" (mode . emacs-lisp-mode))
         ("org" (or (mode . org-mode) (filename . "OrgMode")))
         ("python" (or (mode . python-mode)))
         ("C++" (or (mode . c-mode) (mode . c++-mode)))
         ("folders" (mode . dired-mode))
         ("tex" (or (mode . latex-mode)
                    (mode . LaTeX-mode)))
         ("csv" (mode . csv-mode))
         ("txt" (mode . text-mode))
         ("bash" (mode . sh-mode))
         ("yml" (mode . yaml-mode))
         ("julia" (mode . julia-mode))
         ("vterminals" (mode . vterm-mode))
         ("magit" (or (mode . magit-status-mode)
                      (mode . magit-diff-mode)
                      (mode . magit-revision-mode)))
         ("MOOSE" (mode . moose-mode)))))

(setq ibuffer-expert t)
(setq ibuffer-show-empty-filter-groups nil)

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))

;; automatically refresh ibuffer
(add-hook 'ibuffer-mode-hook (lambda () (ibuffer-auto-mode 1)))

;; human readable size column
(defun ajv/human-readable-file-sizes-to-bytes (string)
  "Convert a human-readable file size into bytes."
  (interactive)
  (cond
   ((string-suffix-p "G" string t)
    (* 1000000000
       (string-to-number (substring string 0 (- (length string) 1)))))
   ((string-suffix-p "M" string t)
    (* 1000000
       (string-to-number (substring string 0 (- (length string) 1)))))
   ((string-suffix-p "K" string t)
    (* 1000
       (string-to-number (substring string 0 (- (length string) 1)))))
   (t (string-to-number (substring string 0 (- (length string) 1))))))

(defun ajv/bytes-to-human-readable-file-sizes (bytes)
  "Convert number of bytes to human-readable file size."
  (interactive)
  (cond
   ((> bytes 1000000000) (format "%10.1fG" (/ bytes 1000000000.0)))
   ((> bytes 100000000) (format "%10.0fM" (/ bytes 1000000.0)))
   ((> bytes 1000000) (format "%10.1fM" (/ bytes 1000000.0)))
   ((> bytes 100000) (format "%10.0fk" (/ bytes 1000.0)))
   ((> bytes 1000) (format "%10.1fk" (/ bytes 1000.0)))
   (t (format "%10d" bytes))))

;; Use human readable Size column instead of original one
(define-ibuffer-column size-h
  (:name "Size"
         :inline t
         :summarizer
         (lambda (column-strings)
           (let ((total 0))
             (dolist (string column-strings)
               (setq total
                     ;; like, ewww ...
                     (+ (float (ajv/human-readable-file-sizes-to-bytes string))
                        total)))
             (ajv/bytes-to-human-readable-file-sizes total))))
  (ajv/bytes-to-human-readable-file-sizes (buffer-size)))

;; Modify the default ibuffer-formats
(setq ibuffer-formats
      '((mark modified read-only locked
              " "
              (name 20 20 :left :elide)
              " "
              (size-h 11 -1 :right)
              " "
              (mode 16 16 :left :elide)
              " "
              filename-and-process)
        (mark " " (name 16 -1) " " filename)))

(defun ibuffer-advance-motion (direction)
  (forward-line direction)
  (beginning-of-line)
  (if (not (get-text-property (point) 'ibuffer-filter-group-name))
      t
    (ibuffer-skip-properties '(ibuffer-filter-group-name) direction)
    nil))

;; Improve line movement in ibuffer
(defun ibuffer-previous-line (&optional arg)
  "Move backwards ARG lines, wrapping around the list if necessary."
  (interactive "P")
  (or arg (setq arg 1))
  (let (err1 err2)
    (while (> arg 0)
      (cl-decf arg)
      (setq err1 (ibuffer-advance-motion -1)
            err2 (if (not (get-text-property (point) 'ibuffer-title))
                     t
                   (goto-char (point-max))
                   (beginning-of-line)
                   (ibuffer-skip-properties '(ibuffer-summary ibuffer-filter-group-name) -1)
                   nil)))
    (and err1 err2)))

(defun ibuffer-next-line (&optional arg)
  "Move forward ARG lines, wrapping around the list if necessary."
  (interactive "P")
  (or arg (setq arg 1))
  (let (err1 err2)
    (while (> arg 0)
      (cl-decf arg)
      (setq err1 (ibuffer-advance-motion 1)
            err2 (if (not (get-text-property (point) 'ibuffer-summary))
                     t
                   (goto-char (point-min))
                   (beginning-of-line)
                   (ibuffer-skip-properties
                    '(ibuffer-summary ibuffer-filter-group-name ibuffer-title) 1)
                   nil)))
    (and err1 err2)))

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

 ;; Group buffers by version control project on request
(require 'ibuffer-vc)

(defvar my/ibuffer-vc-groups-active nil
  "Non-nil if VC grouping is active in ibuffer.")

(defun my/ibuffer-toggle-vc-groups ()
    "Toggle VC root grouping in ibuffer."
    (interactive)
    (if my/ibuffer-vc-groups-active
        (progn
          (ibuffer-switch-to-saved-filter-groups "default")
          (setq my/ibuffer-vc-groups-active nil)
          (message "ibuffer: default filter groups"))
      (ibuffer-vc-set-filter-groups-by-vc-root)
      (setq my/ibuffer-vc-groups-active t)
      (message "ibuffer: VC root filter groups"))
    (ibuffer-update nil t))

(with-eval-after-load 'ibuffer
  (define-key ibuffer-mode-map (kbd "v") 'my/ibuffer-toggle-vc-groups))

;; -------------------------------------------- julia

(use-package julia-mode
  :ensure t
  :mode "\\.jl\\'"
  :hook ((julia-mode . julia-repl-mode)
         (julia-mode . eglot-jl-init)
         (julia-mode . eglot-ensure)
         (julia-mode .
          (lambda ()
            (local-set-key (kbd "C-d") #'julia-repl-send-line)
            (local-set-key (kbd "C-c C-c") #'julia-repl-send-buffer)))))

;; Eglot for LSP support in Julia
;; (use-package eglot
;;   :hook ((julia-mode . eglot-ensure))
;;   :config
;;   (setq eglot-extend-to-xref t)
;;   (add-to-list 'eglot-server-programs
;;                '(julia-mode . ("julia"
;;                                "--startup-file=no"
;;                                "--history-file=no"
;;                                "-e"
;;                                "using LanguageServer, SymbolServer; runserver()"))))

;; (add-hook 'julia-mode-hook
;;           (lambda ()
;;             (add-hook 'before-save-hook #'eglot-format-buffer -10 t)))

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

;; Disable startup message
(setq inhibit-startup-message t)

;; Enable elpy with use-package
(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  :hook
  ((elpy-mode . blacken-mode)
   (elpy-mode . flycheck-mode)
   (elpy-mode . (lambda () (pyvenv-activate "~/miniconda3/envs/oo")))
   (elpy-mode . (lambda () (highlight-indentation-mode -1)))
   (elpy-mode . (lambda () (local-set-key (kbd "C-c <C-return>") 'run-pycell))))
  :config
  ;; Replace flymake with flycheck
  (when (require 'flycheck nil t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  ;; Use ipython for run-python
  (setq python-shell-interpreter "ipython"
	python-shell-interpreter-args "--simple-prompt -i"))

;; Blacken package for auto-formatting Python code
(use-package blacken
  :ensure t)

;; Flycheck setup with pos-tip integration and face adjustments
(use-package flycheck
  :ensure t
  :defer t
  :config
  (with-eval-after-load 'flycheck
    (flycheck-pos-tip-mode))
  ;; Disable warnings and infos in fringe and underline
  (set-face-attribute 'flycheck-fringe-warning nil
                      :foreground (face-attribute 'fringe :background))
  (set-face-attribute 'flycheck-fringe-info nil
                      :foreground (face-attribute 'fringe :background))
  (set-face-attribute 'flycheck-warning nil :underline nil)
  (set-face-attribute 'flycheck-info nil :underline nil))

;; Magit for Git integration
(use-package magit
  :ensure t)

;; sphinx-doc for docstring skeletons in python
(use-package sphinx-doc
  :ensure t
  :hook (python-mode . sphinx-doc-mode))

;; linum for line numbers colors
(use-package linum
  :ensure nil
  :config
  (set-face-background 'linum "#222b35")
  (set-face-foreground 'linum "#999999"))

;; hlinum for highlighting current line number
(use-package hlinum
  :ensure t
  :config
  (hlinum-activate)
  (set-face-foreground 'linum-highlight-face "#ffffff")
  (set-face-background 'linum-highlight-face "#222b35"))

;; code-cells package for jupyter notebook cell detection and running
(use-package code-cells
  :ensure t
  :commands (code-cells-mark-cell code-cells-forward-cell))

;; Define your custom function to run a python cell
(defun run-pycell ()
  "Run current code cell with elpy."
  (interactive)
  (code-cells-mark-cell)
  (elpy-shell-send-region-or-buffer)
  (forward-line 1)
  (code-cells-forward-cell)
  (forward-line 1)
  (keyboard-quit))

;; Inferior Python mode tweaks
(defun my-inferior-python-mode-hook ()
  "Customizations for inferior-python-mode."
  (setq-local comint-buffer-maximum-size 2000)
  (add-hook 'comint-output-filter-functions 'comint-truncate-buffer nil t)
  ;; Keybindings for matching input history navigation
  (local-set-key (kbd "C-c <C-up>") 'comint-previous-matching-input-from-input)
  (local-set-key (kbd "C-c <C-down>") 'comint-next-matching-input-from-input))

(add-hook 'inferior-python-mode-hook 'my-inferior-python-mode-hook)

;; Automatically insert headers with auto-insert
(auto-insert-mode 1)
(eval-after-load 'autoinsert
  '(progn
     (define-auto-insert
       '("\\.py\\'" . "python-header")
       '("" "#!/usr/bin/env python3\n"
          "# -*- coding: utf-8 -*-\n"
          "\"\"\"\n\n"
          "@author: wehrad\n\n"
          "\"\"\"\n\n"))
     (define-auto-insert
       '("\\.tex\\'" . "latex-header")
       '("" "\\documentclass{article}\n"
          "\\usepackage[utf8]{inputenc}\n\n"
          "\\title{template}\n"
          "\\author{Adrien Wehrlé}\n"
          (format-time-string "\\date{%B %Y}\n\n")
          "\\begin{document}\n\n"
          "\\maketitle\n\n"
          "\\section{Introduction}\n\n"
          "\\end{document}"))))

;; Customize fringe appearance and size
(set-face-background 'fringe "#222b35")
(set-face-foreground 'flycheck-fringe-error "#FF0000")
(fringe-mode '(14 . 0))

;; Handy keybinding for replace-string
(global-set-key (kbd "C-x r") 'replace-string)

;; Switch to or start ipython buffer
(defun switch-to-ipython-buffer ()
  (interactive)
  (if (get-buffer "*Python*")
      (switch-to-buffer "*Python*")
    (run-python)
    (switch-to-buffer "*Python*")))
(global-set-key (kbd "C-c p") #'switch-to-ipython-buffer)

;; Go to specific imenu index in python-mode
(eval-after-load 'python
  '(define-key python-mode-map (kbd "C-c i") 'imenu))

;; Functions to rename and switch python interpreter buffers
(defun new-python-instance (inactive-instance-name)
  (interactive (list (read-string "Rename inactive instance: " "*Python1*")))
  (switch-to-buffer "*Python*")
  (rename-buffer inactive-instance-name))

(defun switch-python-instance (instance-name)
  (interactive (list (read-string "Activate instance: " "*Python1*")))
  (switch-to-buffer instance-name)
  (rename-buffer "*Python42*")
  (switch-to-buffer "*Python*")
  (rename-buffer instance-name)
  (switch-to-buffer "*Python42*")
  (rename-buffer "*Python*"))

(defun my/python-close-all-figures ()
  "Send plt.close('all') to the Python process."
  (interactive)
  (when (python-shell-get-process)
    (python-shell-send-string
     "import matplotlib.pyplot as plt; plt.close('all')")))

;; Bind to C-c f in both editing and REPL modes
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c f")
    #'my/python-close-all-figures)
  (define-key inferior-python-mode-map (kbd "C-c f")
    #'my/python-close-all-figures))

(defun my/python-activate-interactive-mode ()
  "Send plt.ion() to the Python process."
  (interactive)
  (when (python-shell-get-process)
    (python-shell-send-string
     "import matplotlib.pyplot as plt; plt.ion()")))

(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c i")
    #'my/python-activate-interactive-mode)
  (define-key inferior-python-mode-map (kbd "C-c i")
    #'my/python-activate-interactive-mode))

;; move across ipython prompts
(add-hook 'inferior-python-mode-hook
          (lambda ()
            (local-set-key (kbd "M-<up>") #'comint-previous-prompt)
            (local-set-key (kbd "M-<down>") #'comint-next-prompt)))

;; Enable company-mode in the Python REPL for variable completion
(add-hook 'inferior-python-mode-hook #'company-mode)
(add-hook 'inferior-python-mode-hook
          (lambda ()
            (local-set-key (kbd "TAB") #'company-complete)))

;; ;; Install and configure Jedi with company completion
(use-package jedi
  :ensure t
  :config
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'inferior-python-mode-hook 'jedi:setup)
  (add-hook 'inferior-python-mode-hook 'company-mode))

;; -------------------------------------------- terminal emulator

(use-package multi-vterm
    :ensure t
    :config
    ;; Start terminal
    (global-set-key (kbd "C-c v") #'multi-vterm)

    ;; Toggle to previous terminal instance in vterm-mode
    (add-hook 'vterm-mode-hook
              (lambda ()
                (local-set-key (kbd "C-x <C-prior>")
                               #'multi-vterm-prev)))

    ;; Toggle to next terminal instance in vterm-mode
    (add-hook 'vterm-mode-hook
              (lambda ()
                (local-set-key (kbd "C-x <C-next>")
                               #'multi-vterm-next)))

    ;; Switch to first vterm buffer if it exists
    (defun switch-to-vterm-buffer ()
      (interactive)
      (when (get-buffer "*vterminal<1>*")
        (switch-to-buffer "*vterminal<1>*")))

    (global-set-key (kbd "C-c l") #'switch-to-vterm-buffer))

;; -------------------------------------------- tramp

;; Faster than the default scp (for small files)
(setq tramp-default-method "ssh")

;; fix tramp on guix
(connection-local-set-profile-variables
 'guix-system
 '((tramp-remote-path . (tramp-own-remote-path))))
(connection-local-set-profiles
 `(:application tramp :ssh "sudo" :tux2 ,(system-name))
 'guix-system)

;; Disable flycheck on tramp python buffers
(when (require 'flycheck -1 t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'jj/flycheck-mode))
(defun jj/flycheck-mode ()
  "Don't enable flycheck mode for remote buffers."
  (interactive)
  (if (file-remote-p default-directory)
      (flycheck-mode -1)
    (flycheck-mode t)))

(global-set-key (kbd "C-x C-d")  'helm-for-files)
(global-set-key (kbd "C-o")  'helm-occur)

(put 'scroll-left 'disabled nil)

(scroll-bar-mode -1)

(define-key override-global-map (kbd "C-,") #'beginning-of-buffer)
(define-key override-global-map (kbd "C-.") #'end-of-buffer)

(setq elpy-log-level 'debug)

(provide '.emacs)

;;;.emacs ends here

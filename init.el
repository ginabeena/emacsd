;; Window Init
(when window-system
  (set-frame-position nil 0 660)
  (set-frame-size nil 80 49))
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)



;; I dislike dialog boxes. 
(setq use-dialog-box nil
      user-full-name "Gina Maini"
      user-mail-address "drawginadraw@gmail.com")

;; Giving myself this helpful buffer, otherwise way to many damn key
;; bindings to remember! (Thanks Edgar)
((lambda ()
   (with-temp-buffer 
     (insert-file-contents "~/.emacs.d/custom_scratch_message.txt")
     (setq initial-scratch-message (buffer-string)))))

;; El-get stuff to sync up most stuff
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))
(el-get 'sync)

;; this took many, many hours to get working correctly. 
(load-file "~/.emacs.d/cedet/cedet-devel-load.elc")

(autoload 'window-number-mode "window-number")
(autoload 'company-mode "company")

;;Melpa stuff, elpa is the offical package archive, melpa is the
;;community extension with stuff on github and melpa itself.
(add-to-list 'package-archives 
	     '("melpa" . "http://melpa.milkbox.net/packages/"))
;;Not sure what the . is, not function composition...
;; (add-to-list 'package-archives 
;;	     '("marmalade" . "http://marmalade-repo.org/packages/"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-insert-query nil)
 '(browse-url-browser-function (quote browse-url-chromium))
 '(column-number-mode t)
 '(custom-safe-themes
   (quote
    ("8fed5e4b89cf69107d524c4b91b4a4c35bcf1b3563d5f306608f0c48f580fdf8" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "442c946bc5c40902e11b0a56bd12edc4d00d7e1c982233545979968e02deb2bc" "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "ee6081af57dd389d9c94be45d49cf75d7d737c4a78970325165c7d8cb6eb9e34" default)))
 '(display-battery-mode t)
 '(display-time-default-load-average nil)
 '(display-time-mode t)
 '(font-use-system-font t)
 '(mail-user-agent (quote gnus-user-agent))
 '(merlin-use-auto-complete-mode nil)
 '(org-startup-indented t)
 '(show-paren-mode t)
 '(solarized-use-more-italic t)
 '(tool-bar-mode nil)
 '(web-mode-attr-indent-offset 2))


(global-set-key(kbd "TAB") 'neotree-toggle)

;; Skeletons definitions for common includes.
(define-skeleton my-org-defaults
  "Org defaults I use"
  nil
  "#+AUTHOR:   Gina Maini\n"
  "#+EMAIL:    drawginadraw@gmail.com\n"
  "#+LANGUAGE: en\n"
  "#+LATEX_HEADER: \\usepackage{lmodern}\n"
  "#+LATEX_HEADER: \\usepackage[T1]{fontenc}\n"
  "#+OPTIONS:  toc:nil num:0\n")

(define-skeleton my-html-defaults
  "Minimum HTML needed"
  nil
  "<!DOCTYPE html>\n"
  "<meta charset=\"utf-8\">\n"
  "<body>\n"
  "<script src=></script>\n"
  "</body>\n")

(define-skeleton my-c-defaults
  "Usual includes that I use for C coding"
  nil
  "#include <stdio.h>\n"
  "#include <stdlib.h>\n"
  "#include <unistd.h>\n"
  "#include <ctype.h>\n"
  "#include <string.h>\n"
  "\n"
  "\n"
  "int main (int argc, char **argv)\n"
  "{\n"
  "\treturn 0;\n"
  "}")
(define-skeleton my-js-defaults
  "strict mode declaration for js"
  nil
  "\"use strict\";\n")

;; Custom Functions
(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files, think git use case"
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name)
		 (file-exists-p (buffer-file-name))
		 (not (buffer-modified-p)))
	(revert-buffer t t t) )))
  (message "Refreshed open files."))

;; Came from dgutov, https://github.com/company-mode/company-mode/issues/50
(defun add-pcomplete-to-capf ()
  (add-hook 'completion-at-point-functions
	    'pcomplete-completions-at-point nil t))

;; Switch top and bottom buffers. 
(defun transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
	    (next-win (window-buffer (funcall selector))))
	(set-window-buffer (selected-window) next-win)
	(set-window-buffer (funcall selector) this-win)
	(select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

;; Issue about call-process not working well in CEDET over tramp 
(defun my-call-process-hack (orig program &rest args)
  (apply (if (equal program cedet-global-command) #'process-file orig)
         program args))

(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the linux kernel."
  (interactive)
  (setq c-set-style "linux")
  (setq c-brace-offset -8)
  (setq c-default-style "linux")
  (setq c-basic-offset 8)
  (setq tab-width 8))

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(defadvice push-mark
    (around semantic-mru-bookmark activate)
  "Push a mark at LOCATION with NOMSG and ACTIVATE passed to `push-mark’.
   If `semantic-mru-bookmark-mode’ is active, also push a tag
   onto the mru bookmark stack."
  (semantic-mrub-push semantic-mru-bookmark-ring (point) 'mark)
  ad-do-it)

(defun semantic-ia-fast-jump-back ()
  (interactive)
  (if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
      (error "Semantic Bookmark ring is currently empty"))
  (let* ((ring (oref semantic-mru-bookmark-ring ring))
	 (alist (semantic-mrub-ring-to-assoc-list ring))
	 (first (cdr (car alist))))
    (if (semantic-equivalent-tag-p (oref first tag)
				   (semantic-current-tag))
	(setq first (cdr (car (cdr alist)))))
    (semantic-mrub-switch-tags first)))

(defun read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun irc-connect ()
  "Connect to IRC, register nick, open commonly used channels"
  (interactive)
  (setq erc-max-buffer-size 20000)
  (setq erc-autojoin-channels-alist '(("freenode.net"
				       "#css"
				       "#node"
				       "#ocaml")))
  (setq erc-hide-list '("JOIN" "PART" "QUIT"))
  ;; This is what actually does the connection
  (erc :server "irc.freenode.net" :port 6667
       :nick "_chess" :full-name "Anon Andonandon"))

;; Misc things
(global-set-key (kbd "C-M-e") 'irc-connect)
(global-set-key (kbd "C-M-p") 'run-python)
(global-set-key (kbd "C-c C-g") 'google-this-noconfirm)

;; Love Ido
(setq ido-everywhere t)
(ido-mode 1)

;; Use the path set up by zsh, aka the ~/.zshrc. 
(exec-path-from-shell-initialize)

;; Annoying issue with TRAMP constantly asking for password
(setq password-cache-expiry nil)

;; Keep the history between sessions
(savehist-mode 1)

(global-set-key (kbd "M-/") 'company-complete)
;; Just kill the shell, don't ask me.
;; I do a lambda so that its not evaluated at init load time. 
(add-hook 'shell-mode-hook (lambda ()
			     (set-process-query-on-exit-flag
			      (get-process "shell") nil)))

;; Don't prompt me when I want to clear the buffer
(put 'erase-buffer 'disabled nil)

;; Visuals, but note that some visuals also set in custom.
(show-paren-mode)
(auto-insert-mode)
(abbrev-mode -1)
(scroll-bar-mode -1)

(define-auto-insert "\\.org\\'" 'my-org-defaults)
(define-auto-insert "\\.c\\'" 'my-c-defaults)
(define-auto-insert "\\.m\\'" 'my-objc-defaults)
(define-auto-insert "\\.mm\\'" 'my-objc-defaults)
(define-auto-insert "\\.html\\'" 'my-html-defaults)
(define-auto-insert "\\.js\\'" 'my-js-defaults)

(display-battery-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
;;(this-linum-mode 1)
(setq inhibit-startup-message t
      scroll-step 1)
(setq visible-bell 1)
(window-number-mode)
(mouse-avoidance-mode 'banish)
(column-number-mode)
(window-number-meta-mode)
(display-time-mode t)
(fringe-mode 10)
(tool-bar-mode 1)
(setq-default indicate-empty-lines t)

;; Default for emacs jumps like crazy, this is the sane answer. 
;; Gives me the full name of the buffer, hate just having foo.c
(add-hook 'find-file-hooks
	  '(lambda ()
	     (setq mode-line-buffer-identification 'buffer-file-truename)))

;; Obviously the following two key bindings are only for two buffers
(global-set-key (kbd "C-'") 'toggle-window-split)
(global-set-key (kbd "M-'") 'transpose-windows)

;; Revert all buffers, usually related to a git stash/pull/*
(global-set-key (kbd "C-\\") 'revert-all-buffers)

;; Just for cycling through in the same buffer
(global-set-key (kbd "<C-return>") 'next-buffer)

;; Shift focus to next buffer, same thing as C-x o, but faster.
(global-set-key (kbd "<C-M-right>") 'other-window)
(global-set-key (kbd "<C-M-left>") 'previous-multiframe-window)

;; Native full screen, pretty nice.
(global-set-key (kbd "<M-return>") 'toggle-frame-fullscreen)

;; I hate this (its the list-buffer), always mistakenly call it and
;; never want it.
(global-unset-key (kbd "C-x C-b"))

;; Undefine the regex searches so that they can be better used elsewhere
(global-unset-key (kbd "C-M-s"))
(global-unset-key (kbd "C-M-r"))

;; Make searches be regex searches!
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)

;; Such a great theme
(add-hook 'after-init-hook
	  (lambda () (load-theme 'cyberpunk t)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:height 100 :family "Hermit" :foundry "PfEd" :slant normal :weight normal :width normal))))
 '(dired-warning ((t (:background "dark red" :foreground "red" :slant italic))))
 '(font-lock-builtin-face ((t (:foreground "#FF6400"))))
 '(font-lock-function-name-face ((t (:foreground "#2BEF3A" :weight bold)))))

(add-to-list 'default-frame-alist '(foreground-color . "#2BD4EF"))
(setq-default indent-tabs-mode nil)
(setq tab-width 4)

;; Semantic Stuff, very important to me, should probably refactor this for
;; the appropriate modes, eitherwise the globalness of it is annoying when
;; doing say Python and C, or rather anything else and C. 
(global-semantic-idle-scheduler-mode 1)
(global-semantic-idle-summary-mode 1)
(global-semantic-stickyfunc-mode 1)
(global-semantic-idle-local-symbol-highlight-mode 1)
(global-semantic-mru-bookmark-mode 1)
(global-semanticdb-minor-mode 1)
(global-semantic-decoration-mode 1)
(global-cedet-m3-minor-mode 1)
(semanticdb-enable-gnu-global-databases 'c-mode t)
(global-semantic-show-unmatched-syntax-mode t)

;; Company Backends
(setq company-backends '(company-clang
			 company-semantic
			 company-c-headers
			 company-bbdb
			 company-ghc
			 company-capf))

;; Doc-view mode, think viewing pdfs in emacs, pretty robust actually. 
(add-hook 'doc-view-mode-hook (lambda ()
				;; Improves resolution at cost of computation
				(setq doc-view-resolution 300)
				;; Basically poll the file for changes. 
				(auto-revert-mode)))

;; SQL Stuff
;; Just remember,
;; http://truongtx.me/2014/08/23/setup-emacs-as-an-sql-database-client/
;; (load-file "~/.emacs.d/sql_dbs.el")
(add-hook 'sql-interactive-mode-hook
	  (lambda ()
	    (toggle-truncate-lines)))

;; Haskell Stuff
(add-hook 'haskell-mode-hook (lambda ()
			       (interactive-haskell-mode)
			       (ghc-init)
			       (auto-complete-mode -1)
			       (company-mode 1)))


;; Ocaml code
;; the eliom file description is for web programming stuff. 
(add-to-list 'auto-mode-alist '("\\.eliom\\'" . tuareg-mode))
(add-to-list 'auto-mode-alist '("\\.options\\'" . makefile-mode))
(autoload 'camldebug "camldebug" "Run the Caml Debugger" t)
(add-hook 'tuareg-mode-hook (lambda ()
			      (dolist (var
				       (car (read-from-string
					     (shell-command-to-string "opam config env --sexp"))))
				(setenv (car var) (cadr var)))
			      ;; Update the emacs path
			      (setq exec-path (split-string (getenv "PATH") path-separator))
			      ;; Update the emacs load path
			      (push (concat (getenv "OCAML_TOPLEVEL_PATH") "/../../share/emacs/site-lisp") load-path)
			      ;; Automatically load utop.el
			      (autoload 'utop "utop" "Toplevel for OCaml" t)
			      (autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
			      (utop-setup-ocaml-buffer)

			      (setq merlin-command "/usr/gina/.opam/rwo/bin/ocamlmerlin")
			      (autoload 'merlin-mode "merlin" "Merlin mode" t)
			      (auto-complete-mode -1)
			      (setq-local indent-tabs-mode nil)
			      (require 'ocp-index)
			      (company-mode)
			      (require 'ocp-indent)
			      (setq-local show-trailing-whitespace t)
			      (merlin-mode)))

(add-hook 'utop-mode-hook (lambda ()
			    (set-process-query-on-exit-flag
			     (get-process "utop") nil)))

(add-hook 'org-mode-hook (lambda ()
			   ;; Orgmode Stuff
			   ;; This is for syntax highling in pdf exports
			   (require 'ox-md)
			   (add-to-list 'org-latex-packages-alist '("" "minted"))
			   (setq org-latex-listings 'minted
				 org-latex-create-formula-image-program 'imagemagick
				 org-latex-pdf-process
				 '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
				   "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
				   "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
;;			   (flyspell-mode)
			   (auto-fill-mode)
			   (company-mode)
			   (semantic-mode -1)
			   (define-key org-mode-map
			     (kbd "C-c p")
			     'org-publish-current-project)))

;; TODO, this shouldn't need to be a separate call, should be
;; part of the hook above.
;; https://github.com/company-mode/company-mode/issues/50
(add-hook 'org-mode-hook #'add-pcomplete-to-capf)

;; Basic text files
(add-hook 'text-mode-hook 'auto-fill-mode)

;;Javascript hook, this is a better major mode than default one
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . js2-mode))

(add-hook 'js2-mode-hook (lambda ()
			   (define-key js2-mode-map (kbd "M-/") 'tern-ac-complete)
			   (tern-mode)))

(eval-after-load 'tern
  '(progn
     (require 'tern-auto-complete)
     (tern-ac-setup)))

;; C++ stuff, basically just be aware of it.
(add-to-list 'auto-mode-alist '("\\.cc\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c-mode))

;; emacs lisp stuff
(add-hook 'emacs-lisp-mode-hook '(lambda ()
				   (global-set-key (kbd "C-M-s") 'eval-buffer)
				   (semantic-mode)
				   ;;(paredit-mode)
;;				   (flycheck-mode)
				   (global-set-key (kbd "C-c C-f") 'helm-command-prefix)
				   (define-key semantic-mode-map (kbd "M-]") 'semantic-ia-fast-jump)
				   (define-key semantic-mode-map (kbd "M-[") 'semantic-ia-fast-jump-back)
				   (global-unset-key (kbd "C-x c"))))

;; C Code
(add-hook 'c-mode-hook '(lambda ()
			  (semantic-mode)
			  (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-select)
			  (helm-gtags-mode)
			  (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
			  (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
			  (define-key c-mode-map (kbd "C-c C-c") 'compile)
			  (semantic-mru-bookmark-mode)
			  (define-key semantic-mode-map (kbd "M-]") 'semantic-ia-fast-jump)
			  (define-key semantic-mode-map (kbd "M-[") 'semantic-ia-fast-jump-back)
			  (ggtags-mode)
			  (define-key ggtags-mode-map (kbd "M-.") nil)
			  (define-key ggtags-mode-map (kbd "M-<") nil)
			  (define-key ggtags-mode-map (kbd "M->") nil)
			  (define-key ggtags-mode-map (kbd "M-n") nil)
			  (define-key ggtags-mode-map (kbd "M-p") nil)
			  (define-key ggtags-mode-map (kbd "M-,") nil)
			  (define-key ggtags-mode-map (kbd "M-]") nil)
			  (define-key ggtags-mode-map (kbd "M--") 'ggtags-find-reference)))

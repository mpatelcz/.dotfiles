(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (misterioso)))
 '(exec-path
   (quote
    ("/home/mpatelcz/bin" "/usr/local/sbin" "/usr/local/bin" "/usr/sbin" "/usr/bin" "/sbin" "/bin" "/usr/games" "/usr/local/games" "/snap/bin" "/home/mpatelcz/golang/bin" "/home/mpatelcz/go/bin" "/home/mpatelcz/bin" "/usr/lib/x86_64-linux-gnu/emacs/25.3/x86_64-linux-gnu" "/home/mpatelcz/.local/bin")))
 '(package-selected-packages
   (quote
    (forest-blue-theme lua-mode dockerfile-mode company auto-complete-clang clang-format irony company-rtags flycheck-rtags helm-rtags rtags cmake-font-lock cmake-ide cmake-mode cmake-project ggtags helm-gtags yaml-mode elpy window-number vagrant smooth-scroll py-autopep8 project-explorer markdown-mode magit-stgit magit-gh-pulls magit-find-file magit-filenotify magit-annex helm-go-package helm go-stacktracer go-snippets go-scratch go-rename go-playground go-impl go-guru go-gopath go-errcheck go-eldoc go-direx go-complete go-autocomplete go-add-tags fill-column-indicator docker-compose-mode docker buffer-move bash-completion))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Emacs configuratrion


(setq inhibit-startup-screen t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(setq backup-directory-alist '(("." . ".emacs_backups")))


(require 'package)
(add-to-list
 'package-archives
 '("melpa" . "http://melpa.org/packages/")
 t)
(package-initialize)

(defvar my-packages
  '(;;;; Go shit
    go-mode
    go-eldoc
    go-autocomplete

        ;;;;;; Markdown
    markdown-mode

        ;;;;;; Javascript
    json-mode
        ;;;;;; Env
    project-explorer
    smooth-scroll
    buffer-move
    window-number)
  "My packages!")

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; install the missing packages
(dolist (package my-packages)
  (unless (package-installed-p package)
    (package-install package)))


(require 'fill-column-indicator)

;; Fill Column Indicator for Go Mode
(defun go-mode-fci ()
  (setq fci-rule-width 1)
  (setq fci-rule-color "red")
  (setq fci-rule-column 80)
  (setq show-trailing-whitespace t))



;;Custom Compile Command
(defun go-mode-setup ()
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet && golint && errcheck"))
  (define-key (current-local-map) "\C-c\C-c" 'compile)
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
  (local-set-key (kbd "C-c i") 'go-goto-imports)
  (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
  (define-key go-mode-map (kbd "C-c t") #'go-add-tags)
  (auto-complete-mode 1)
  ;; FCI mode
  (go-mode-fci)
  )
(add-hook 'go-mode-hook 'go-mode-setup)


;;Load auto-complete
(ac-config-default)
(require 'auto-complete-config)

(with-eval-after-load 'go-mode
   (require 'go-autocomplete))


(add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))
(require 'golint)


;;Project Explorer
(require 'project-explorer)
(global-set-key (kbd "M-e") 'project-explorer-toggle)


					; Magit Status
(global-set-key (kbd "C-x g") 'magit-status)

;; Helm is global
(require 'helm-config)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x m") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;; (custom-set-variables
;;  '(go-add-tags-style 'lower-camel-case))

;; (define-key go-mode-map (kbd "C-c C-j") 'go-direx-pop-to-buffer)


(global-linum-mode t)
(show-paren-mode t)

(require 'linum)
(linum-mode t)

(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
(elpy-enable)

;; Enabled find-grep as f7
(global-set-key (kbd "<f7>") 'find-grep)


;; C++ related stuff
;; (require 'setup-helm-gtags)
;; (require 'setup-helm)

(require 'ggtags)

(add-hook 'c-mode-common-hook
	  (lambda ()
	    (when (derived-mode-p 'c-mode 'c++-mode)
	      (ggtags-mode 1))))

(setq
 helm-gtags-ignore-case t
 helm-gtags-auto-update t
 helm-gtags-use-input-at-cursor t
 helm-gtags-pulse-at-cursor t
 helm-gtags-prefix-key "\C-cg"
 helm-gtags-suggested-key-mapping t)

(require 'helm-gtags)
(add-hook 'dired-mode-hook 'helm-gtags-mode)
(add-hook 'eshell-mode-hook 'helm-gtags-mode)
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)

(eval-after-load "helm-gtags"
  '(progn
     (define-key helm-gtags-mode-map (kbd "M-t") 'helm-gtags-find-tag)
          (define-key helm-gtags-mode-map (kbd "M-r") 'helm-gtags-find-rtag)
          (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
          (define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
          (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
          (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
          (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

(define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
(define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
(define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
(define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

;; C++ mode
(require 'rtags)
(cmake-ide-setup)

;;(if (display-graphic-p) () ())
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(setq require-final-newline t)

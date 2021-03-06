;;; note.el ---                                      -*- lexical-binding: t; -*-

;; Copyright (C) 2021  meetcw

;; Author: meetcw <meetcw@outlook.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(use-package
  org
  :ensure org-plus-contrib
  :defer t
  :init                                 ;
  (setq org-preview-latex-image-directory (expand-file-name "ltximg/" user-emacs-directory))
  (setq org-hide-emphasis-markers t) ; 隐藏强调符号（加粗，下划线等等）
  (setq org-pretty-entities nil)       ; 可以显示上标下标
  (setq org-edit-src-content-indentation 2) ; 设置代码内容缩进
  (setq org-src-preserve-indentation nil)
  (setq org-src-tab-acts-natively t)
  ;; (setq org-fontify-done-headline t) ; 标题状态为 Done 的时候修改标题样式
  (setq org-hide-leading-stars t)       ; 隐藏标题多余的星号
  (setq org-startup-folded 'nofold)     ; 是否默认开启折叠
  (setq org-cycle-separator-lines 2)
  (setq org-return-follows-link t)      ; 回车链接跳转
  (setq org-image-actual-width nil) ; 图片宽度
  ;; (setq org-html-head-include-default-style nil) ;默认导出不要包含样式
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  (add-hook 'org-mode-hook (lambda ()
                             (setq prettify-symbols-alist '(("#+BEGIN_SRC" . "  ")
                                                            ("#+END_SRC" . "  ")
                                                            ("#+begin_src" . "  ")
                                                            ("#+end_src" . "  ")
                                                            ("#+BEGIN_QUOTE" . "  ")
                                                            ("#+END_QUOTE" . "  ")
                                                            ("#+begin_quote" . "  ")
                                                            ("#+end_quote" . "  ")))
                             ;; (setq prettify-symbols-unprettify-at-point 'right-edge)
                             ;; (prettify-symbols-mode 1)
                             (setq truncate-lines nil)
                             (org-display-inline-images t t) ; 显示图片
                             
                             ;; (org-indent-mode 1) ; 缩进模式 (和 truncate-lines 同时使用会导致 wrap-prefix 背景色总是使用默认的背色)
                             (visual-fill-column-mode 1)
                             (org-align-tags t)
                             (add-hook 'before-save-hook (lambda()
                                                           ;; 保存时 对齐 tag
                                                           (org-align-tags t)) nil 'local)))

  (defun +org-rename-buffer()
    (interactive)
    (when-let ((title (pcase (org-collect-keywords '("TITLE"))
                        (`(("TITLE" . ,val))
                         (org-link-display-format (car val)))))
               (filename (when buffer-file-name (file-name-nondirectory buffer-file-name))))
      (rename-buffer (format "%s<%s>" title filename) t))
    (add-hook 'after-save-hook #'+org-rename-buffer nil t))

  (add-hook 'org-mode-hook #'+org-rename-buffer)

  (setq-default org-confirm-babel-evaluate nil)
  :config                               ;
  (require 'ob-dot)
  (setq-default org-plantuml-exec-mode 'plantuml)
  (setq-default org-plantuml-jar-path "")
  (require 'ob-plantuml)
  (require 'ob-python)
  (require 'ob-shell)
  (require 'ob-java)
  (require 'ob-js)
  (require 'ob-python)
  (require 'ob-latex)
  (require 'ox-freemind)
  (require 'org-tempo))

(use-package
  org-appear;自动切换预览元素
  :ensure t
  :custom ;
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  :hook (org-mode . org-appear-mode))

(use-package
  org-fragtog;自动切换预览 Latex 公式
  :ensure t
  :hook (org-mode . org-fragtog-mode))

(use-package
  org-superstar
  :ensure t
  :defer t
  :hook (org-mode . org-superstar-mode)
  :custom                               ;
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("✿" "❖" "●" "◉" "◍" "◎" "○" "◌"))
  (org-superstar-prettify-item-bullets t)
  (org-superstar-item-bullet-alist '((?* . ?*)
                                     (?+ . ?+)
                                     (?- . ?-)))
  (org-superstar-special-todo-items t)
  (org-superstar-todo-bullet-alist '(("TODO" . ?☐)
                                     ("DONE" . ?☑)))
  :hook (org-mode . org-superstar-mode)
  :init                                 ;
  (setq org-superstar-prettify-item-bullets t))

(use-package
  org-download
  :ensure t
  :defer 10
  :custom ;
  (org-download-image-dir "./Assets")
  (org-download-file-format-function +org-download-file-format-default)
  :init;
  (defun +org-download-file-format-default (filename)
    "It's affected by `org-download-timestamp'."
    (when-let ((filename filename)
               (extension (file-name-extension filename)))
      (if extension
          (concat
           (format-time-string org-download-timestamp)
           extension)
        (concat
         (format-time-string org-download-timestamp)
         "00")))))


(use-package
  visual-fill-column                    ;设置正文宽度
  :ensure t
  :defer t
  :commands (visual-fill-column-mode)
  :config                               ;
  (setq-default visual-fill-column-width 100)
  (setq-default visual-fill-column-center-text t))


(defcustom machine:note-directory (expand-file-name "notes" temporary-file-directory)
  "Note root directory"
  :type 'string
  :group 'machine)
(unless (file-directory-p machine:note-directory)
  (mkdir machine:note-directory))


(use-package
  org-roam
  :straight (:host github
                   :repo "org-roam/org-roam"
                   :branch "v2")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find))
  :custom ;
  (org-roam-directory machine:note-directory)
  (org-roam-dailies-directory "DAILY")
  (org-roam-capture-templates '(("d" "default" plain "%?"
                                 :if-new (file+head "%<%Y%m%d%H%M%S>.org"
                                                    "#+title: ${title}\n* ${title}\n")
                                 :unnarrowed t) ))
  (org-roam-capture-immediate-template '("d" "default" plain "%?"
                                         :if-new (file+head "%<%Y%m%d%H%M%S>.org"
                                                            "#+title: ${title}\n* ${title}\n")
                                         :unnarrowed t
                                         :immediate-finish t))
  (org-roam-dailies-capture-templates '(("d" "default" plain "%?" :if-new
                                         (file+head "DAILY/%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n* %<%Y-%m-%d>"))))
  :commands (org-roam-setup org-roam-dailies-find-today)
  :init;
  (modal-leader-set-key "n d" '(org-roam-dailies-find-today :which-key "today"))
  (modal-leader-set-key "n f" '(org-roam-node-find :which-key "find note"))
  (modal-leader-set-key-for-mode 'org-mode "n b" '(org-roam-buffer-toggle :which-key
                                                                          "backlink"))
  (modal-leader-set-key-for-mode 'org-mode "n g" '(org-roam-graph :which-key "graph"))
  (modal-leader-set-key-for-mode 'org-mode "n i" '(org-roam-node-insert :which-key "insert node"))
  :config (org-roam-setup))

;; (use-package
;;   org-roam
;;   :ensure t
;;   :defer t
;;   :commands (org-roam-buffer-toggle-display org-roam-dailies-find-today org-roam-db-clear
;;                                             org-roam-db-build-cache)
;;   :hook(org-mode . org-roam-mode)
;;   :custom                               ;
;;   (org-roam-title-to-slug-function (lambda (title)
;;                                      (upcase (org-roam--title-to-slug title))))
;;   ;; (org-roam-db-update-method 'immediate)
;;   (org-roam-buffer "*Backlink*")
;;   ;; (org-roam-buffer-position 'bottom)
;;   ;; (org-roam-buffer-width 0.3)
;;   ;; (org-roam-buffer-window-parameters '((no-delete-other-windows . t)
;;   ;;                                      (mode-line-format "")
;;   ;;                                      (window-slot . 0)
;;   ;;                                      (window-side . bottom)))
;;   (org-roam-directory machine:note-directory)
;;   (org-roam-index-file "Index.org")
;;   (org-roam-dailies-directory "Journals")
;;   (org-roam-title-sources '(headline))
;;   (org-roam-tag-sources '(vanilla))
;;   (org-roam-capture-templates '(("d" "default" plain #'org-roam-capture--get-point "%?"
;;                                  :file-name "${slug}"
;;                                  :head "* ${title} :Default:\n\n"
;;                                  :unnarrowed t)))
;;   (org-roam-capture-immediate-template '("d" "default" plain #'org-roam-capture--get-point "%?"
;;                                          :file-name "${slug}"
;;                                          :head "* ${title} :Default:\n\n"
;;                                          :unnarrowed t
;;                                          :immediate-finish t))
;;   (org-roam-dailies-capture-templates '(("d" "default" entry #'org-roam-capture--get-point "%?"
;;                                          :file-name "Journals/%<%Y-%m-%d>"
;;                                          :head
;;                                          "* %<%d %B, %Y> :Journal:%<%A>:\n\n** 🍀 晨间日记\n\n*** 昨天发生的事\n\n*** 今天要做的事\n\n*** 一些想法\n\n** 🌟 随手记\n\n"
;;                                          :unnarrowed t)))
;;   :custom-face                          ;
;;   (org-roam-link ((t
;;                    (:foreground ,(color-lighten-name (face-foreground 'default) 10)
;;                                 :inherit 'org-link))))
;;   (org-roam-link-current ((t
;;                            (:inherit 'org-roam-link))))
;;   :init                                 ;
;;   (modal-leader-set-key "n d" '(org-roam-dailies-find-today :which-key "today"))
;;   (modal-leader-set-key "n f" '(org-roam-find-file :which-key "find note"))
;;   (modal-leader-set-key "n DEL" '(org-roam-db-clear :which-key "delete cache"))
;;   (modal-leader-set-key "n RET" '(org-roam-db-build-cache :which-key "build cache"))
;;   (modal-leader-set-key-for-mode 'org-mode "n b" '(org-roam-buffer-toggle-display :which-key
;;                                                                                   "backlink"))
;;   (modal-leader-set-key-for-mode 'org-mode "n g" '(org-roam-graph :which-key "graph"))
;;   (modal-leader-set-key-for-mode 'org-mode "n i" '(org-roam-insert :which-key "insert node"))
;;   :config                               ;
;;   (require 'org-roam-protocol))


;; (defcustom machine:note-server-host "127.0.0.1"
;;   "Note server host"
;;   :type 'string
;;   :group 'machine)

;; (defcustom machine:note-server-port 10101
;;   "Note server port"
;;   :type 'integer
;;   :group 'machine)

;; (use-package
;;   org-roam-server
;;   :ensure t
;;   :defer t
;;   :custom                               ;
;;   (org-roam-server-host machine:note-server-host )
;;   (org-roam-server-port machine:note-server-port )
;;   (org-roam-server-authenticate nil)
;;   (org-roam-server-export-inline-images t)
;;   (org-roam-server-serve-files nil)
;;   (org-roam-server-served-file-extensions '("pdf" "mp4" "ogv"))
;;   (org-roam-server-network-poll t)
;;   (org-roam-server-network-arrows nil)
;;   (org-roam-server-network-label-truncate t)
;;   (org-roam-server-network-label-truncate-length 60 )
;;   (org-roam-server-network-label-wrap-length 20)
;;   :init                                 ;
;;   (modal-leader-set-key "ns" '((lambda ()
;;                                  (interactive)
;;                                  (when (not (bound-and-true-p org-roam-server-mode))
;;                                    (org-roam-server-mode t))
;;                                  (browse-url (format "http://%s:%s" org-roam-server-host
;;                                                      org-roam-server-port))) :which-key "server"))
;;   :config )

(defcustom machine:agenda-directory (expand-file-name "agenda" temporary-file-directory)
  "Agenda root directory"
  :type 'string
  :group 'machine)
(unless (file-directory-p machine:agenda-directory)
  (mkdir machine:agenda-directory))

(unless (file-exists-p machine:agenda-directory)
  (mkdir machine:agenda-directory))
(setq org-agenda-files (mapcar (lambda (file)
                                 (expand-file-name file machine:agenda-directory))
                               (directory-files machine:agenda-directory nil ".*\.org")))
(setq org-refile-targets '((nil :maxlevel . 9)
                           (org-agenda-files :maxlevel . 9)))

(use-package
  valign
  :ensure t
  :hook (org-mode . valign-mode))
(provide 'purpose/note)
;;; note.el ends here

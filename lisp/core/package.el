;;; 基础
(use-package
  gcmh                                  ; 优化GC
  :ensure t
  :config                               ;
  (gcmh-mode 1))

(use-package
  restart-emacs
  :ensure t)

;; 性能统计
(use-package
  benchmark-init
  :ensure t
  :disabled
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

(use-package
  memory-usage
  :ensure t
  :defer t
  :disabled)

(use-package
  exec-path-from-shell
  ;; :if (memq window-system '(ns mac))
  :ensure t
  :custom                               ;
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-check-startup-files nil)
  :config (when (or (memq window-system '(mac ns x))
                    (daemonp))
            (exec-path-from-shell-initialize)))

(use-package
  xclip
  :ensure t
  :if (not (display-graphic-p))
  :config (xclip-mode 1))

;;; 交互增强

(use-package
  ivy
  :ensure t
  :defer t
  :custom (ivy-use-virtual-buffers nil)
  (ivy-count-format "(%d/%d) ")
  (ivy-initial-inputs-alist nil)
  (ivy-use-selectable-prompt t)         ;允许选择输入提示行
  :config (ivy-mode t)
  (define-key ivy-minibuffer-map (kbd "S-RET") 'ivy-immediate-done)
  (define-key ivy-minibuffer-map (kbd "S-<return>") 'ivy-immediate-done))

(use-package
  ivy-rich                              ; 在 M-x 和帮助中显示文档
  :ensure t
  :init
  :config (ivy-rich-mode +1)
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line))

(use-package
  counsel                               ;基于ivy的命令文件补全工具
  :ensure t
  :defer t
  :init                                 ;
  (modal-leader-set-key "RET" '(counsel-bookmark :which-key "bookmark"))
  (modal-leader-set-key "ff" '((lambda()
                                 (interactive)
                                 (let ((counsel-find-file-ignore-regexp "^\\."))
                                   (counsel-find-file))) :which-key "find file"))
  (modal-leader-set-key "fF" '(counsel-find-file :which-key "find all file"))
  (modal-leader-set-key "fr" '(counsel-recentf :which-key "recent file"))
  (modal-leader-set-key "bb" '((lambda()
                                 (interactive)
                                 (let ((ivy-ignore-buffers '("\\` " "\\`\\*")))
                                   (counsel-switch-buffer))) :which-key "switch buffer"))
  (modal-leader-set-key "bB" '(counsel-switch-buffer :which-key "switch all buffer"))
  (modal-leader-set-key "SPC" '(counsel-M-x :which-key "command"))
  :bind (("M-x" . counsel-M-x))
  :config)

(use-package
  flx ;; Improves sorting for fuzzy-matched results
  :after ivy
  :defer t
  :init (setq ivy-flx-limit 10000))

(use-package
  prescient
  :ensure t
  :after counsel
  :config (prescient-persist-mode 1))

(use-package
  ivy-prescient
  :ensure t
  :after prescient
  :config (ivy-prescient-mode 1))

(use-package
  swiper                                ;基于ivy的增量搜索工具
  :ensure t
  :defer t
  :init                                 ;
  (modal-leader-set-key "cs" '(swiper :which-key "swipe"))
  (modal-leader-set-key "cS" '(swiper-all :which-key "swipe in all buffers"))
  :bind                                 ;
  ("C-S-s" . swiper-all)
  ("C-s" . swiper))

(use-package
  command-log-mode                      ; 记录历史命令
  :ensure t
  :defer t
  :config (global-command-log-mode))


(use-package
  buffer-move                           ; 交换两个window的buffer
  :ensure t
  :defer t
  :init                                 ;
  (modal-leader-set-key "b <left>" '(buf-move-left :which-key "move to left window"))
  (modal-leader-set-key "b <down>" '(buf-move-down :which-key "move to down window"))
  (modal-leader-set-key "b <up>" '(buf-move-up :which-key "move to up window"))
  (modal-leader-set-key "b <right>" '(buf-move-right :which-key "move to right window"))
  (setq buffer-move-stay-after-swap t)
  (setq buffer-move-behavior 'move))

(use-package
  windresize                            ;调整window大小
  :ensure t
  :defer t
  :init                                 ;
  (modal-leader-set-key "wr" '(windresize :which-key "resize window")))

(use-package
  ace-window                            ; 窗口跳转
  :ensure t
  :defer t
  :init                                 ;
  (modal-leader-set-key "ww" '(ace-window :which-key "select window"))
  :config (setq aw-keys '(?h ?j ?k ?l ?a ?s ?d ?f ?g)))

(use-package
  projectile                            ;project 插件
  :ensure t
  :custom       ;
  ;; (projectile-track-known-projects-automatically nil)
  ;; (projectile-indexing-method 'native)
  (projectile-sort-order 'access-time)
  (projectile-find-dir-includes-top-level t)
  :init                                 ;
  (modal-leader-set-key "pk" '(project-kill-buffers :which-key "close all project buffers"))
  (modal-leader-set-key "pi" '(projectile-project-info :which-key "project info"))
  (modal-leader-set-key "pd" '(projectile-remove-known-project :which-key "remove project"))
  :config (projectile-mode +1))

(use-package
  counsel-projectile                    ;projectile 使用 counsel前端
  :ensure t
  :custom                               ;
  (counsel-projectile-sort-files t)
  (counsel-projectile-sort-directories t)
  (counsel-projectile-sort-buffers t)
  (counsel-projectile-sort-projects t)
  :init (modal-leader-set-key "pp" '(counsel-projectile-switch-project :which-key "switch project"))
  (modal-leader-set-key "pf" '(counsel-projectile-find-file :which-key "find file in project"))
  (modal-leader-set-key "ps" '(counsel-projectile-git-grep :which-key "search in project by git"))
  (modal-leader-set-key "pS" '(counsel-projectile-grep :which-key "search in project"))
  :config (counsel-projectile-mode t))

(use-package
  magit
  :ensure t
  :commands (magit-status magit-get-current-branch)
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :init                                 ;
  (modal-leader-set-key "pg" '(magit-status :which-key "git")))
(use-package
  neotree
  :ensure t
  :defer t
  :custom                               ;
  (neo-smart-open t)
  (neo-window-width 35)
  (neo-mode-line-type 'none)
  ;; (neo-vc-integration 'face); 和doom主题冲突
  (neo-hide-cursor t)
  :bind                                 ;
  ("C-<tab>" . neotree-toggle)
  ("C-TAB" . neotree-toggle)
  :init                                 ;
  (modal-leader-set-key "fv" '(neotree-toggle :which-key "file view")))


(use-package
  disable-mouse
  :ensure t
  :disabled
  :config (when (boundp 'evil-mode)
            (mapc #'disable-mouse-in-keymap (list evil-motion-state-map evil-normal-state-map
                                                  evil-visual-state-map evil-insert-state-map)))
  (global-disable-mouse-mode))


(use-package
  diff-hl
  :ensure t
  :defer 1
  :config                               ;
  (global-diff-hl-mode))

(use-package
  avy
  :ensure t
  :defer t
  :init                                 ;
  )


(use-package
  beacon                                ; 跳转后,显示光标位置
  :if (display-graphic-p)
  :ensure t
  :disabled
  :config (beacon-mode t))

(use-package
  rainbow-delimiters                    ;彩虹括号
  :ensure t
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode))
(use-package
  highlight-parentheses                 ;高亮当前括号
  :ensure t
  :disabled
  :defer t
  :custom (hl-paren-highlight-adjacent t)
  (hl-paren-colors '("cyan"))           ; 设置高亮括号颜色
  :hook (prog-mode . highlight-parentheses-mode))

(use-package
  auto-sudoedit                         ;自动请求sudo权限
  :if (or (eq system-type 'gnu/linux)
          (eq system-type 'darwin))
  :ensure t
  :config (auto-sudoedit-mode 1))

(use-package
  popwin                                ; 使用弹出窗口显示部分Buffer
  :ensure t
  :config                               ;
  (popwin-mode 1))

(use-package
  rainbow-mode
  :ensure t
  :defer 1
  :hook (prog-mode . rainbow-mode)
  :config
  ;; 默认的会文本属性背景色显示颜色，会与高亮行插件冲突，通过重写这个方法，调换前景与背景色来解决这个问题
  (defun rainbow-colorize-match (color &optional match)
    "Return a matched string propertized with a face whose
  background is COLOR. The foreground is computed using
  `rainbow-color-luminance', and is either white or black."
    (let* ((match (or match
                      0))
           (color-string
            (buffer-substring-no-properties
             (match-beginning match)
             (match-end match))))
      ;; (message "color : %s" color-string)
      (put-text-property (match-beginning match)
                         (match-end match) 'face
                         `(:foreground ,color)))))

(use-package
  highlight-indent-guides               ;高亮缩进
  :ensure t
  :defer t
  :custom                               ;
  (highlight-indent-guides-suppress-auto-error t)
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-character ?┊)
  :hook ((prog-mode conf-mode) . highlight-indent-guides-mode)
  :config                               ;
  (unless (display-graphic-p)
    (set-face-foreground 'highlight-indent-guides-character-face "black")))

(use-package
  visual-fill-column                    ;设置正文宽度
  :ensure t
  :defer t
  :commands (visual-fill-column-mode)
  :config                               ;
  (setq-default visual-fill-column-width 100)
  (setq-default visual-fill-column-center-text t))

(use-package
  sis                                   ; 自动切换输入法
  :ensure t
  :config                                  ;
  (setq sis-respect-prefix-and-buffer nil) ;开启会导致 which-key 翻页失效
  (cond ((eq system-type 'darwin)
         (if (executable-find "macism")
             (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.apple.inputmethod.SCIM.ITABC")
           (message
            "SIS need to install macism. use ‘brew tap laishulu/macism;brew install macism’ to install it.")))
        ((eq system-type 'gnu/linux)
         (sis-ism-lazyman-config "1" "2" 'fcitx)))
  (sis-global-respect-mode t))

(use-package
  multi-vterm
  :ensure t)

(use-package
  vterm-toggle
  :ensure t
  :bind                                 ;
  ("C-`" . vterm-toggle)
  ("C-~" . vterm-toggle-cd)
  :init                                 ;
  (add-to-list 'display-buffer-alist '((lambda(bufname _)
                                         (with-current-buffer bufname (equal major-mode
                                                                             'vterm-mode)))
                                       (display-buffer-reuse-window display-buffer-in-direction)
                                       (direction . bottom)
                                       (dedicated . t) ;dedicated is supported in emacs27
                                       (reusable-frames . visible)
                                       (window-height . 0.3))))
(use-package
  centaur-tabs
  :ensure t

  :demand
  :disabled
  :custom                               ;
  (centaur-tabs-style "bar")
  (centaur-tabs-height 32)
  (centaur-tabs-set-icons t)
  ;; (centaur-tabs-plain-icons t)
  (centaur-tabs-gray-out-icons 'buffer)
  (centaur-tabs-set-bar 'over)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-show-navigation-buttons t)
  (centaur-tabs-cycle-scope 'tabs)
  :bind                                 ;
  (:map evil-normal-state-map
        ("g t" . centaur-tabs-forward)
        ("g T" . centaur-tabs-backward))
  :config (centaur-tabs-mode t)
  :bind ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :config                               ;
  (centaur-tabs-group-by-projectile-project))
;; ;;;; ==============================================
;; ;;;; 编辑增强
;; ;;;; ==============================================

;; 自动完成
(use-package
  company
  :ensure t
  :defer t
  :hook ;; (prog-mode . company-mode)
  (after-init . global-company-mode)
  :init ;; Don't convert to downcase.
  (defun modal-set-complete()
    (interactive)
    (or (yas/expand)
        (company-indent-or-complete-common nil)))
  (setq-default company-dabbrev-downcase nil)
  :bind (:map company-mode-map
              ("<tab>" . modal-set-complete)
              ("TAB" . modal-set-complete)
              ;;
              :map company-active-map   ;
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("C-s" . company-filter-candidates)
              ("<tab>" . company-complete-selection)
              ("TAB" . company-complete-selection)
              ("<return>" . company-complete-selection) ; 终端下无效
              ("RET" . company-complete-selection)      ; 终端下生效
              :map company-search-map                   ;
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("<tab>" . company-complete-selection)
              ("TAB" . company-complete-selection)
              ("<return>" . company-complete-selection) ; 终端下无效
              ("RET" . company-complete-selection))     ; 终端下生效
  :custom                                               ;
  (company-minimum-prefix-length 2)
  (company-idle-delay 0.01)
  (company-echo-delay 0.2)
  (company-show-numbers t)
  :config                               ;
  (setq company-selection-default 0)
  (setq company-backends '(;; (:separate company-yasnippet
                           ;;            company-capf)
                           (company-capf company-dabbrev-code company-keywords company-files)
                           (company-dabbrev)))
  (setq company-frontends '(company-pseudo-tooltip-frontend company-echo-metadata-frontend)))

(use-package
  company-box
  :ensure t
  :requires company
  :hook (company-mode . company-box-mode)
  :init                                 ;
  (setq company-box-show-single-candidate t)
  :config)

(use-package
  company-prescient
  :ensure t
  :after company
  :hook (company-mode . company-prescient-mode))

(use-package
  undo-tree                             ;撤销重做可视化
  :ensure t
  :config (global-undo-tree-mode))

(use-package
  smart-comment                         ;注释插件
  :ensure t
  :defer t
  :bind ("C-/" . smart-comment)
  :init (modal-leader-set-key "cc" '(smart-comment :which-key "comment")))

(use-package
  hungry-delete                         ; 可以删除前面所有的空白字符
  :ensure t
  :defer t
  :custom (hungry-delete-join-reluctantly t)
  :hook (prog-mode . hungry-delete-mode))


(use-package
  drag-stuff
  :ensure t
  :defer t
  :after evil
  :bind (:map evil-visual-state-map
              ("K" . drag-stuff-up)
              ("J" . drag-stuff-down)
              :map evil-normal-state-map
              ("K" . drag-stuff-up)
              ("J" . drag-stuff-down))
  :config                               ;
  (drag-stuff-global-mode 1))

(use-package
  expand-region                         ;选择区域
  :ensure t
  :defer t
  :after evil
  :bind (("<S-return>" . er/expand-region)
         ("S-RET" . er/expand-region)))

(use-package
  format-all                            ;格式化代码，支持多种格式
  :ensure t
  :defer t
  :init (modal-leader-set-key "cf" '(format-all-buffer :which-key "format")))

;;; 主题外观

(use-package
  doom-modeline
  :ensure t
  :defer t
  :disabled
  :init (doom-modeline-init)
  (setq doom-modeline-height 20)
  (setq doom-modeline-bar-width 3)
  (setq doom-modeline-enable-word-count t) ;字数统计
  (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
  (setq doom-modeline-buffer-file-name-style 'auto)
  ;; (setq doom-modeline-minor-modes t)
  (setq doom-modeline-icon (display-graphic-p))
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-modal-icon t)
  (doom-modeline-mode 1))

(use-package
  mini-modeline
  :ensure t
  :hook (after-init . mini-modeline-mode)
  :custom (mini-modeline-right-padding 1)
  (mini-modeline-face-attr nil)
  (mini-modeline-enhance-visual t)
  (mini-modeline-display-gui-line nil)
  (mini-modeline-l-format '("%e"
                            (:eval (modal-indicator))))
  (mini-modeline-r-format '("%e" " %l:%C "
                            (:eval (mode-line-buffer-encoding))
                            (:eval (mode-line-buffer-major-mode))
                            (:eval (mode-line-buffer-name))))
  :init                                 ;
  (defface mode-line-buffer-name '((t
                                    (:inherit bold
                                              :background nil)))
    "")
  (defface mode-line-buffer-name-modified '((t
                                             (:inherit (error
                                                        bold)
                                                       :background nil)))
    "")
  (defface mode-line-buffer-project '((t
                                       (:inherit (font-lock-keyword-face bold)
                                                 :background nil)))
    "")
  (defface mode-line-buffer-encoding '((t
                                        (:inherit default
                                                  :background nil)))
    "")
  (defface mode-line-buffer-major-mode
    '((t
       (:inherit (font-lock-keyword-face bold)
                 :background nil)))
    "")
  (defun mode-line-buffer-name ()
    (propertize " %b " 'face (cond ((and
                                     buffer-file-name
                                     (buffer-modified-p)) 'mode-line-buffer-name-modified)
                                   (t 'mode-line-buffer-name))))
  (defun mode-line-buffer-major-mode ()
    (propertize " %m " 'face 'mode-line-buffer-major-mode))
  (defun mode-line-buffer-project ()
    (when-let ((project-root (or (when (fboundp 'projectile-project-root)
                                   (projectile-project-root))
                                 (when (fboundp 'project-current)
                                   (when-let ((project (project-current)))
                                     (car (project-roots project)))))))
      (propertize (format " %s "  (file-name-nondirectory (directory-file-name project-root))) 'face
                  'mode-line-buffer-project)))
  (defun mode-line-buffer-encoding ()
    "Displays the eol and the encoding style of the buffer the same way Atom does."
    (concat
     ;; eol type
     (let ((eol (coding-system-eol-type buffer-file-coding-system)))
       (propertize (pcase eol (0 "LF ")
                          (1 "CRLF ")
                          (2 "CR ")
                          (_ "")) 'face 'mode-line-buffer-encoding ))
     ;; coding system
     (propertize (let ((sys (coding-system-plist buffer-file-coding-system)))
                   (cond ((memq (plist-get sys
                                           :category)
                                '(coding-category-undecided coding-category-utf-8)) "UTF-8")
                         (t (upcase (symbol-name (plist-get sys
                                                            :name)))))) 'face
                                                            'mode-line-buffer-encoding )))
  (defun mode-line-buffer-name-with-project()
    (let ((project-root (mode-line-buffer-project))
          (buffer-name (mode-line-buffer-name)))
      (if project-root (format "[%s:%s]" project-root buffer-name)
        (format "[%s] buffer"))))
  :config                               ;
  ;; (mini-modeline-mode t)
  )

(use-package
  solaire-mode
  :ensure t
  :if (display-graphic-p)
  :hook                                 ;
  ((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
  (minibuffer-setup . solaire-mode-in-minibuffer)
  :config                               ;
  (set-face-background 'solaire-mode-line-face nil)
  (set-face-background 'solaire-mode-line-inactive-face nil)
  (solaire-global-mode +1)
  (solaire-mode-swap-bg))

(use-package
  doom-themes
  :ensure t
  :init
  :custom                               ;
  (doom-themes-neotree-file-icons t)
  (doom-themes-treemacs-theme "doom-colors")
  :custom-face                          ;
  (font-lock-comment-face ((t
                            (:slant italic))))
  (neo-root-dir-face ((t
                       (:extend t))))
  :hook (server-after-make-frame . (lambda()
                                     (load-theme 'doom-one t)))
  :config                               ;
  (load-theme 'doom-one t)
  ;; (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(use-package
  dashboard
  :ensure t
  :config                               ;
  (modal-leader-set-key "b <home>" '(dashboard-refresh-buffer :which-key "dashboard"))
  (setq dashboard-startup-banner (expand-file-name "dashboard-banner.txt" user-config-directory))
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '())
  (setq dashboard-set-navigator t)
  (setq dashboard-navigator-buttons `(   ;
                                      () ;
                                      () ;
                                      () ;
                                      ((,(all-the-icons-octicon "calendar"
                                                                :height 0.9
                                                                :v-adjust 0.0)
                                        " Open agenda                         " "" (lambda
                                                                                     (&rest
                                                                                      _)
                                                                                     (call-interactively
                                                                                      'org-agenda))
                                        nil "" "")
                                       ("" "SPC n a   " "" (lambda
                                                             (&rest
                                                              _)
                                                             (call-interactively 'org-agenda))
                                        default "" ""))
                                      () ;
                                      ((,(all-the-icons-octicon "file-text"
                                                                :height 0.9
                                                                :v-adjust 0.0)
                                        " Open recently file                  " "" (lambda
                                                                                     (&rest
                                                                                      _)
                                                                                     (call-interactively
                                                                                      'counsel-recentf))
                                        nil "" "")
                                       ("" "SPC f r   " "" (lambda
                                                             (&rest
                                                              _)
                                                             (call-interactively 'counsel-recentf))
                                        default "" ""))
                                      () ;
                                      ((,(all-the-icons-octicon "briefcase"
                                                                :height 0.9
                                                                :v-adjust 0.0)
                                        " Open project                        " "" (lambda
                                                                                     (&rest
                                                                                      _)
                                                                                     (call-interactively
                                                                                      'counsel-projectile))
                                        nil "" "")
                                       ("" "SPC p p   " "" (lambda
                                                             (&rest
                                                              _)
                                                             (call-interactively
                                                              'counsel-projectile)) default "" ""))
                                      () ;
                                      ((,(all-the-icons-octicon "star"
                                                                :height 0.9
                                                                :v-adjust 0.0)
                                        " Jump to bookmark                    " "" (lambda
                                                                                     (&rest
                                                                                      _)
                                                                                     (call-interactively
                                                                                      'counsel-bookmark))
                                        nil "" "")
                                       ("" "SPC return" "" (lambda
                                                             (&rest
                                                              _)
                                                             (call-interactively 'counsel-bookmark))
                                        default "" ""))
                                      ()   ;
                                      ()   ;
                                      ())) ;
  ;;
  (setq dashboard-page-separator "")
  (setq dashboard-set-footer nil)
  (setq dashboard-items-default-length 20)
  ;; C/S mode use dashboard as default buffer
  (dashboard-setup-startup-hook))


(use-package
  all-the-icons
  :ensure t
  :init (setq all-the-icons-scale-factor 0.9))


(provide 'core/package)

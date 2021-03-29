;;; modal.el --- My modal edit -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(defgroup modal nil
  "Introduce modal editing"
  :tag "Modal"
  :prefix "modal-")

(defvar modal-mode-map (make-sparse-keymap)
  "Global keymap for Modal")

(defvar modal-insert-state-map
  (let ((keymap (make-keymap)))
    ;; (define-key keymap (kbd "<escape>") 'meow-insert-exit)
    keymap)
  "Keymap for Modal insert state.")

(defvar modal-normal-state-map (let ((keymap (make-keymap)))
                                 (suppress-keymap keymap t) keymap)
  "Keymap for Modal normal state.")

(define-minor-mode modal-normal-mode "Modal normal state."
  nil
  " ModalNormal"
  modal-normal-state-map
  (when modal-normal-mode (modal-insert-mode -1)
        (setq-local cursor-type 'hollow)))

(define-minor-mode modal-insert-mode "Modal insert state."
  nil
  " ModalInsert"
  modal-insert-state-map
  (when modal-insert-mode (modal-normal-mode -1)
        (setq-local cursor-type '(bar . 1))))

(define-minor-mode modal-mode "Toggle `modal-mode` minor mode."
  nil
  " Modal"
  modal-mode-map
  (if modal-mode (modal-mode--enable)
    (modal-mode--disable)))
(defun modal-mode--minibuffer-setup()
  "Set modal-mode state when minibuffer avtive."
  (setq-local modal-normal-mode nil))

(define-globalized-minor-mode modal-global-mode modal-mode
  (lambda ()
    (unless (minibufferp)
      (message "enable modal")
      (modal-mode 1)))
  (if modal-mode (progn (setq-default modal-normal-mode t)
                        (setq-default modal-mode t)
                        (add-hook 'minibuffer-setup-hook #'modal-mode--minibuffer-setup))
    (progn (setq-default meow-normal-mode nil)
           (setq-default modal-mode nil)
           (remove-hook 'minibuffer-setup-hook #'modal-mode--minibuffer-setup))))

(defun modal-mode--enable ()
  "Enable Modal mode"
  (modal-normal-mode 1))

(defun modal-mode--disable ()
  "Disable Modal mode"
  (modal-normal-mode -1)
  (modal-insert-mode -1))

;;; command
(defun modal--set-mark()
  (when (not (region-active-p))
    (set-mark-command nil)))

(defun modal-mark-and-forward-char(arg)
  (interactive "p")
  (call-interactively #'forward-char))

(defun modal-mark-and-backward-char(arg)
  (interactive "p")
  (modal--set-mark)
  (call-interactively #'backward-char))

(defun modal-mark-and-forward-char(arg)
  (interactive "p")
  (modal--set-mark)
  (call-interactively #'forward-char))

(defun modal-mark-and-previous-line(arg)
  (interactive "p")
  (modal--set-mark)
  (call-interactively #'previous-line))

(defun modal-mark-and-next-line(arg)
  (interactive "p")
  (modal--set-mark)
  (call-interactively #'next-line))

(defun modal-mark-and-next-line(arg)
  (interactive "p")
  (modal--set-mark)
  (call-interactively #'next-line))

(defun modal-mark-word(arg)
  (interactive "p")
  (let ((point (bounds-of-thing-at-point 'word)))
    (goto-char (cdr point))
    (push-mark (car point) t t)))

(defun modal-mark-symbol(arg)
  (interactive "p")
  (let ((point (bounds-of-thing-at-point 'symbol)))
    (goto-char (cdr point))
    (push-mark (car point) t t)))

(defun modal-forward-word(arg)
  (interactive "p")
  (forward-thing 'word arg))

(defun modal-backward-word(arg)
  (interactive "p")
  (let ((arg (- 0 arg)))
    (forward-thing 'word arg)))

;;; bind map
(define-key modal-normal-state-map (kbd "j") #'next-line)
(define-key modal-normal-state-map (kbd "k") #'previous-line)
(define-key modal-normal-state-map (kbd "h") #'backward-char)
(define-key modal-normal-state-map (kbd "l") #'forward-char)
(define-key modal-normal-state-map (kbd "L") #'modal-mark-and-forward-char)
(define-key modal-normal-state-map (kbd "K") #'modal-mark-and-previous-line)
(define-key modal-normal-state-map (kbd "J") #'modal-mark-and-next-line)
(define-key modal-normal-state-map (kbd "H") #'modal-mark-and-backward-char)


(define-key modal-normal-state-map (kbd "w") #'modal-mark-word)
(define-key modal-normal-state-map (kbd "W") #'backward-word)
(define-key modal-normal-state-map (kbd "s") #'modal-mark-symbol)
(define-key modal-normal-state-map (kbd "S") #'backward-symbol)

(define-key modal-normal-state-map (kbd "i") #'modal-insert-mode)
(define-key modal-insert-state-map (kbd "<escape>") #'modal-normal-mode)
(defun forward-symbol-shift-aware (arg)
  "`forward-symbol', with shift-select-mode support.
Shift + this command's key extends/activates the region
around the text moved over."
  (interactive "^p")
  (forward-symbol arg))

(local-set-key (kbd "C-<right>") 'forward-symbol-shift-aware)
(local-set-key (kbd "C-<left>")
               (lambda ()
                 (interactive "^")
                 (forward-symbol-shift-aware -1)))
(modal-global-mode 1)
(cua-mode 1)
(setq this-command-keys-shift-translated t)
(provide 'core/modal)
;;; modal.el ends here
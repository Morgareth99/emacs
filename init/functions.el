;;; functions.el --- List of my own functions

;; Copyright (C) 2014  Dominic Charlesworth <dgc336@gmail.com>

;; Author: Dominic Charlesworth <dgc336@gmail.com>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;; common functions used in Emacs

;;; Code:

;; --------------------------------------------
;; Functions used in compiling latex & xelatex
;; --------------------------------------------
(defun latex-make ()
  (interactive)
  (setq buffer-save-without-query t)
  (if (buffer-modified-p) (save-buffer))
  (let ((f1 (current-frame-configuration))
        (retcode (shell-command (concat "rubber --pdf " (buffer-file-name)))))
    (message "Return code ❯ %s" retcode)
    (if (= retcode 0) (find-file (concat (file-name-sans-extension (buffer-file-name)) ".pdf")))))

(defun xelatex-make ()
  (interactive)
  (if (string-equal major-mode "latex-mode")
      (progn
        (setq buffer-save-without-query t)
        (if (buffer-modified-p) (save-buffer))
        (let ((f1 (current-frame-configuration))
              (retcode (shell-command (concat "xelatex " (buffer-file-name)))))
          (message "Return code ❯ %s" retcode)
          (if (= retcode 0)
              (progn
                (if (get-buffer (concat (file-name-sans-extension (buffer-name)) ".pdf"))
                    (kill-buffer (concat (file-name-sans-extension (buffer-name)) ".pdf")))
                (find-file (concat (file-name-sans-extension (buffer-file-name)) ".pdf"))
                (delete-other-windows)))))
    nil))

(defun get-last-spy ()
  (interactive)
  (save-excursion
    (let ((start (+ (search-backward-regexp "spyOn(" 6)))
          (end (- (search-forward-regexp ")") 1)))
      (if (string-match "spyOn\(\\\(.*\\\),\\s-*['\"]\\\(.*?\\\)['\"]" (buffer-substring start end))
          (format "%s.%s" (match-string 1 (buffer-substring start end)) (match-string 2 (buffer-substring start end)))))))

(defun jump-to-class ()
  "Find and go to the class at point"
  (interactive)
  (let ((class-name (thing-at-point 'symbol)))
    (ring-insert find-tag-marker-ring (point-marker))
    (save-excursion
      (beginning-of-buffer)
      (let ((start (search-forward-regexp "function\\s-*(" (point-max) t))
            (end (- (search-forward ")") 1)))
        (goto-char start)
        (if (search-forward class-name end t)
            (mapcar #'(lambda (lib-alist)
                        (let* ((id (car lib-alist))
                               (file-alist (cdr lib-alist))
                               (record (assoc (concat (downcase class-name) ".js") file-alist)))
                          (if (and record (= (length record) 2))
                            (let ((found-file (cadr record)))
                              (message "Found %s" found-file)
                              (find-file found-file))
                            nil)))
                    jpop-project-alist)
          nil)))))

(defun jump-to-require ()
  "Tries to load the require path assoscaited with a variable for node includes"
  (interactive)
  (save-excursion
    (ring-insert find-tag-marker-ring (point-marker))
    (goto-char (line-beginning-position))
    (let ((require-pos (search-forward "require" (line-end-position) t)))
      (when require-pos
        (if (search-forward-regexp "(['\"]\\(.*?\\)['\"])" (line-end-position) t)
            (mapcar #'(lambda (lib-alist)
                        (let* ((id (car lib-alist))
                               (file-alist (cdr lib-alist))
                               (file (file-name-base (match-string 1)))
                               (record (assoc (concat file ".js") file-alist)))
                          (if (and record (= (length record) 2))
                              (let ((found-file (cadr record)))
                                (message "Found %s" found-file)
                                (find-file found-file))
                            nil)))
                    jpop-project-alist)
          nil)))))

(defun jump-to-find-function ()
  "Go to the function definition for elisp"
  (interactive)
  (ring-insert find-tag-marker-ring (point-marker))
  (find-function (intern (thing-at-point 'symbol))))

(defun jump-to-thing-at-point ()
  "Go to the thing at point assuming if it's not a class or function it's a variable."
  (interactive)
  (let ((thing (thing-at-point 'symbol))
        (p (point)))
    (if thing
        (when (and (eq nil (jump-to-require))
                   (or (eq nil (jump-to-class))
                       (equal '(nil) (jump-to-class))))
          (ignore-errors (js2-jump-to-definition))
          (when (and (eq p (point))
                     (not (eq nil (etags-select-find-tag-at-point))))
            (helm-swoop)))
      (etags-select-find-tag))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Opening Files in other applications ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun open-in (ed &optional file)
  "Opens the current file in ED or specified FILE."
  (shell-command (format "%s %s" ed (or file buffer-file-name))))

(defun panic ()
  "Alias to run `open-current-file`."
  (interactive)
  (open-current-file))


(defun open-urls-in-file ()
  (interactive)
  (let (result)
    (save-excursion
      (with-current-buffer (buffer-name)
        (goto-char (point-min))
        (while (search-forward-regexp goto-address-url-regexp nil t)
          (setq result (append (list (match-string 0)) result)))))
    (browse-url
     (completing-read "Open URL: "
                      (-uniq (--map (s-chop-suffix "\)" it) result))))))

(defun open-current-file ()
  "Open the current file in different things."
  (interactive)
  (let ((type (completing-read
               "Open current file in editor ❯ " '("Sublime Text" "Atom" "Chrome" "Finder" "Multiple URLs" "URL") nil nil)))
    (cond ((string-equal type "Sublime Text") (open-in "subl"))
          ((string-equal type "Atom") (open-in "atom"))
          ((string-equal type "Chrome") (browse-url (buffer-file-name)))
          ((string-equal type "Multiple URLs")
           (call-interactively 'link-hint-open-multiple-links))
          ((string-equal type "URL")
           (if (browse-url-url-at-point) (browse-url-at-point) (link-hint-open-link)))
          ((string-equal type "Finder") (open-in "open" (file-name-directory (buffer-file-name)))))))

(defun isearch-yank-from-start ()
  "Move to beginning of word before yanking word in `isearch-mode`."
  (interactive)
  ;; Making this work after a search string is entered by user
  ;; is too hard to do, so work only when search string is empty.
  (if (= 0 (length isearch-string))
      (beginning-of-thing 'word))
  (isearch-yank-word-or-char)
  ;; Revert to 'isearch-yank-word-or-char for subsequent calls
  (substitute-key-definition 'isearch-yank-from-start
                             'isearch-yank-word-or-char
                             isearch-mode-map))

(add-hook 'isearch-mode-hook (lambda ()
  "Activate my customized Isearch word yank command."
  (substitute-key-definition 'isearch-yank-word-or-char
                             'isearch-yank-from-start
                             isearch-mode-map)))

(defun my-vc-dir ()
  "Call `vc-dir` on the appropriate project."
  (interactive)
  (let ((repo-root (repository-root)))
    (if (repository-root-match repository-root-matcher/git repo-root repo-root)
        (magit-status)
        (vc-dir repo-root))))

(defun quick-term (name)
  (interactive "sEnter terminal name ❯ ")
  (ansi-term "/bin/bash" name))


;; ============================================================================
(defun dgc-comment ()
  "comment or uncomment highlighted region or line"
  (interactive)
  (if mark-active
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

(defun kill-all-buffers ()
  "Kill all open buffers."
  (interactive)
  (mapc 'kill-buffer (buffer-list)))

(defun kill-buffer-regexps (r)
  "Kill all buffers matching regexp R."
  (interactive "sEnter Regexp ❯ ")
  (let ((killable-buffers (-filter '(lambda (b) (string-match r (buffer-name b))) (buffer-list))))
    (when (yes-or-no-p (format "Kill %d buffers matching \"%s\"? " (length killable-buffers) r))
      (mapc #'kill-buffer killable-buffers))))

;; ============================================================================

(defvar my-ediff-bwin-config nil "Window configuration before ediff.")
(defcustom my-ediff-bwin-reg ?b
  "*Register to be set up to hold `my-ediff-bwin-config'
    configuration.")

(defvar my-ediff-awin-config nil "Window configuration after ediff.")
(defcustom my-ediff-awin-reg ?e
  "*Register to be used to hold `my-ediff-awin-config' window
    configuration.")

(defun my-ediff-bsh ()
  "Function to be called before any buffers or window setup for
    ediff."
  (setq my-ediff-bwin-config (current-window-configuration))
  (when (characterp my-ediff-bwin-reg)
    (set-register my-ediff-bwin-reg
                  (list my-ediff-bwin-config (point-marker)))))

(defun my-ediff-ash ()
  "Function to be called after buffers and window setup for ediff."
  (setq my-ediff-awin-config (current-window-configuration))
  (when (characterp my-ediff-awin-reg)
    (set-register my-ediff-awin-reg
                  (list my-ediff-awin-config (point-marker)))))

(defun my-ediff-qh ()
  "Function to be called when ediff quits."
  (if (get-buffer "*vc-dir*")
      (progn (switch-to-buffer "*vc-dir*")
             (delete-other-windows))
    (when my-ediff-bwin-config (set-window-configuration my-ediff-bwin-config))))

(defun kill-all-dired-buffers ()
  "Kill all dired buffers."
  (interactive)
  (save-excursion
    (let ((count 0))
      (dolist (buffer (buffer-list))
        (set-buffer buffer)
        (when (equal major-mode 'dired-mode)
          (setq count (1+ count))
          (kill-buffer buffer)))
      (message "Killed %i dired buffer(s)." count))))


;; ============================================================================
(defun random-hex ()
  "Return a string in the form of #FFFFFF. Choose the number for
   #xffffff randomly using Emacs Lisp's builtin function (random)."
  ;; seed our random number generator: current datetime plus Emacs's
  ;; process ID
  (interactive)
  (random t)
  (message "%s" (format "#%06x" (random #xffffff))))

(defun ahahah ()
  "You know what it displays..."
  (interactive)
  (random)
  (setq clr (nth (random (length (defined-colors))) (defined-colors)))
  (message "%s" (propertize "Ah ah ah, you didn't say the magic word!"
                            'face `(:foreground ,clr))))

(defun rotate-windows ()
  "Rotate your windows"
  (interactive)
  (cond
   ((not (> (count-windows) 1))
    (message "You can't rotate a single window!"))
   (t
    (setq i 1)
    (setq numWindows (count-windows))
    (while  (< i numWindows)
      (let* (
             (w1 (elt (window-list) i))
             (w2 (elt (window-list) (+ (% i numWindows) 1)))
             (b1 (window-buffer w1))
             (b2 (window-buffer w2))
             (s1 (window-start w1))
             (s2 (window-start w2)))
        (set-window-buffer w1  b2)
        (set-window-buffer w2 b1)
        (set-window-start w1 s2)
        (set-window-start w2 s1)
        (setq i (1+ i)))))))

(defun semi-colon-end ()
  "Function to insert a semi colon at the end of the line from anywhere."
  (interactive)
  (save-excursion
    (delete-trailing-whitespace)
    (end-of-line)
    (insert ";")))

(defun kill-whitespace ()
  "Kill the whitespace between two non-whitespace characters."
  (interactive)
  (save-excursion
    (progn
      (re-search-forward "[ \t\r\n]+" nil t)
      (replace-match "" nil nil))))

(defun json-format ()
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)))

(defun upcase-case-next-letter ()
  "Upcase the next letter, then move forward one character."
  (interactive)
  (upcase-region (point) (+ 1 (point)))
  (forward-char))

(defun downcase-case-next-letter ()
  "Downcase the next letter, then move forward one character."
  (interactive)
  (downcase-region (point) (+ 1 (point)))
  (forward-char))

(defun disable-all-themes ()
  "disable all active themes."
  (dolist (i custom-enabled-themes)
    (disable-theme i)))

(defun duplicate-line ()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank))

(defun duplicate-line-and-replace-regexp ()
  (interactive)
  (duplicate-line)
  (move-beginning-of-line 1)
  (set-mark-command nil)
  (move-end-of-line 1)
  (call-interactively 'vr/query-replace))

(defun leet-mode ()
  "Turn off auto complete and major mode."
  (interactive)
  (auto-complete-mode 0)
  (smartparens-mode 0)
  (key-combo-mode 0)
  (flycheck-mode 0)
  (font-lock-mode 0))

(defun font-scale (op &optional amount)
  "Apply function operator OP (+/-) to scale face attribute height by AMOUNT."
  (let* ((height (face-attribute 'default :height))
         (mode-line-height (face-attribute 'mode-line :height)))
    (set-face-attribute 'default nil :height (funcall op height (or amount 10)))
    (set-face-attribute 'mode-line nil :height powerline/default-height)
    (set-face-attribute 'mode-line-inactive nil :height powerline/default-height)))

(defun elisp-debug (var)
  (interactive "sDebug variable ❯ ")
  (insert (concat "(message \"" (capitalize var) ": %s\" " var ")")))

(defun smart-delete-pair (&rest args)
  "Smartly delete character or pair based on the next character."
  (interactive)
  (save-excursion
    (let ((next-char (buffer-substring (point) (+ (point) 1)))
          (prev-char (buffer-substring (point) (- (point) 1))))
     (cond ((string-match "[\{\(\[\"']" next-char) (delete-pair))
           ((string-match "[\{\(\[\"']" prev-char) (backward-char 1) (delete-pair))
           ((string-match "[\]\}\)]" next-char) (smart-backward) (delete-pair))
           ((string-match "[\]\}\)]" prev-char) (smart-backward) (delete-pair))))))

(defun magit-open-file-other-window ()
  (interactive)
  (let ((current-section (magit-current-section)))
    (when (eq 'file (magit-section-type current-section))
      (let* ((file-name (expand-file-name (magit-section-value current-section)))
             (file-buffer (or (find-buffer-visiting file-name) (create-file-buffer file-name))))
        (when (not (file-directory-p file-name))
          (display-buffer file-buffer))))))

(defun magit-whitespace-cleanup ()
  (interactive)
  (let ((current-section (magit-current-section)))
    (when (eq 'file (magit-section-type current-section))
      (let* ((magit-file (magit-section-value current-section))
             (file-name (expand-file-name magit-file))
             (file-buffer (or (get-file-buffer file-name) (create-file-buffer file-name))))
        (with-current-buffer file-buffer
          (goto-char (point-min))
          (whitespace-cleanup)
          (save-buffer file-buffer))
        (when (-contains? (magit-staged-files) magit-file)
          (magit-stage-file magit-file))
        (magit-refresh)))))

(defun magit-vc-ediff ()
  (interactive)
  (let ((current-section (magit-current-section)))
    (when (eq 'file (magit-section-type current-section))
      (let* ((file-name (expand-file-name (magit-section-value current-section)))
             (file-buffer (find-file file-name)))
        (with-current-buffer file-buffer (call-interactively 'vc-ediff))))))

(defun you-can-never-leave (&optional full)
  (interactive)
  (let ((playing
         (string-equal "playing\n"
          (shell-command-to-string "osascript -e \"if app \\\"iTunes\\\" is running then tell app \\\"iTunes\\\" to get player state\""))))
    (when (not playing)
      (if full
          (shell-command "osascript -e \"tell application \\\"Terminal\\\" to do script \\\"mplayer ~/.emacs.d/elisp/music/hotel-california.m4a -ss 04:14.3 && exit 0\\\"\"")
        (shell-command "osascript -e \"tell application \\\"Terminal\\\" to do script \\\"mplayer ~/.emacs.d/elisp/music/youcanneverleave.wav && exit 0\\\"\""))))
  (restart-emacs))

(defun gallery-music ()
  (interactive)
  (shell-command "osascript -e \"tell application \\\"Terminal\\\" to do script \\\"mplayer ~/.emacs.d/elisp/music/gallery.m4a && exit 0\\\"\""))

(defun dired-mark-duplicate-dirs ()
  "Mark all directories which have a common part."
  (interactive)
  (when (not (eq 'dired-mode (with-current-buffer (buffer-name) major-mode)))
    (error "Not in dired-mode"))
  (let* ((cwd (dired-current-directory))
         (cmd (format "ls %s | grep -Eo [a-z0-9\-]+[a-z] | sort | uniq -d | xargs echo -n" cwd))
         (dirs (split-string (shell-command-to-string cmd) " ")))
    (mapc (lambda (dir) (dired-mark-files-regexp dir)) dirs)))

(defun ac-lambda (&rest sources)
  "Sets up autocomplete mode and local SOURCES"
  (interactive)
  (auto-complete-mode)
  (setq-local ac-sources sources))

(defun format-for-frame-title (joke)
  (with-temp-buffer
    (insert (format "%s" joke))
    (while (and (search-backward "she" (point-min) t) (looking-at "she"))
      (replace-match "it"))
    (goto-char (point-max))
    (while (search-backward-regexp "her[\.]\\{0,1\\}\\s-*$" (point-min) t)
      (replace-match "it"))
    (goto-char (point-max))
    (while (and (search-backward "her" (point-min) t) (looking-at "her"))
      (replace-match "its"))
    (goto-char (point-max))
    (while (and (search-backward "fat" (point-min) t) (looking-at "fat"))
      (replace-match "big (%I)"))
    (goto-char (point-max))
    (while (search-backward-regexp "[Yy]o[ur]\\{0,2\\} m[oua][m]+[as]+" (point-min) t)
      (replace-match "%b"))
    (buffer-string)))

(defun -move-link (f)
  (funcall f "http[s]\\{0,1\\}://[a-z0-9#%\./_-]+"))

(defun previous-link ()
  (interactive)
  (-move-link 'search-backward-regexp))

(defun next-link ()
  (interactive)
  (-move-link 'search-forward-regexp))

(defun get-quote-char ()
  "Get the majority quote character used in a file."
  (if (> (count-matches "\"" (point-min) (point-max))
         (count-matches "'" (point-min) (point-max)))
      "\"" "'"))

(defun json-comma? ()
  "Whether or not to use a comma at the end of a json snippet"
  (with-current-buffer (buffer-name)
    (save-excursion
      (let* ((restore (point))
             (quote (and (goto-char restore) (search-forward "\"" nil t)))
             (brace (and (goto-char restore) (search-forward "}" nil t))))
        (when (and quote brace) (< quote brace))))))

;; (defun bemify-emmet-string (expr)
;;   "Pre process an emmet string to be bemified."
;; 	(let* ((split (split-string (car expr) "|"))
;; 				 (filter (cadr split))
;; 				 (emmet-s (car split)))
;; 		(when (equal filter "bem")
;; 			(let ((bemified
;; 						 (with-temp-buffer
;; 							 (insert emmet-s)
;; 							 (goto-char (point-min))
;; 							 (while (re-search-forward "\\.\\([a-zA-Z]+[a-zA-Z0-9]*\\)" (point-max) t)
;; 								 (let ((base-class (match-string 1))
;; 											 (restore-point (point)))
;; 									 (while (re-search-forward "\\.[a-z]*?\\([_-]\\{2\\}\\)" (point-max) t)
;; 										 (replace-match (format ".%s%s" base-class (match-string 1))))
;; 									 (goto-char restore-point)))
;; 							 (buffer-string))))
;; 				(when (not (equal emmet-s bemified))
;; 					(with-current-buffer (current-buffer)
;; 						(goto-char (cadr expr))
;; 						(delete-region (cadr expr) (caddr expr))
;; 						(insert bemified)))))))

(defun dir-depth (dir)
  "Gives depth of directory DIR"
  (when dir (length (split-string (expand-file-name dir) "/"))))

(defun flycheck--guess-checker ()
  "Guess the JS lintrc file in the current project"
  (if (not (buffer-file-name))
      'javascript-standard
    (let* ((jshintrc-loc (locate-dominating-file (buffer-file-name) flycheck-jshintrc))
           (jshintrc-depth (dir-depth jshintrc-loc))
           (eslintrc-loc (locate-dominating-file (buffer-file-name) flycheck-eslintrc))
           (eslintrc-depth (dir-depth eslintrc-loc)))
      (cond
       ((and (not eslintrc-loc) (not jshintrc-loc)) 'javascript-standard)
       ((and jshintrc-loc (not eslintrc-loc)) 'javascript-jshint)
       ((and eslintrc-loc (not jshintrc-loc)) 'javascript-eslint)
       ((> jshintrc-depth eslintrc-depth) 'javascript-jshint)
       (t 'javascript-eslint)))))

(defun other-window-everything (thing)
  (cond
   ((get-buffer thing) (switch-to-buffer-other-window thing))
   (t (find-file-other-window thing))))

(defmacro defrepl (name executable)
  `(prog1
       (defun ,(intern (format "%s-repl" name)) ()
         ,(format "Open a `%s` repl" name)
         (interactive)
         (ansi-color-for-comint-mode-on)
         (add-to-list
          'comint-preoutput-filter-functions
          (lambda (output)
            (replace-regexp-in-string "\033\\[[0-9]+[GKJ]" "" output)))
         (pop-to-buffer (make-comint ,(format "%s-repl" name) ,executable)))))

(defrepl "ramda" "ramda-repl")
(defrepl "node" "node")
(defrepl "lodash" "n_")

(defun send-to-repl ()
  (interactive)
  (let ((buf (car (--filter (and (string-match "repl" (buffer-name it)) (get-buffer-window it))
                            (buffer-list)))))
    (when (not buf) (error "Could not find repl to send to"))
    (let ((proc (get-buffer-process buf))
          (content (if (region-active-p)
                       (buffer-substring (region-beginning) (region-end))
                     (buffer-string))))
      (comint-send-string proc (format "%s\n" content)))))

;; Docker helper functions

(defun docker-containers--remove-trailing-whitespace (proc string)
  "Remove trailing whitespace from PROC on STRING."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((inhibit-read-only t))
        (goto-char (process-mark proc))
        (insert string)
        (delete-trailing-whitespace)
        (set-marker (process-mark proc) (point))))))

(defun docker-containers-logs-follow-all ()
  "Follow all currently running docker containers"
  (interactive)
  (--map (docker-containers-logs-follow (car it))
         (docker-containers-entries)))

(defun docker-containers-logs-follow (image)
  "Create a process buffer to follow an image"
  (let* ((cmd (format "docker logs -f --tail=50 %s" image))
         (bufname (format "*docker-logs:%s*" image))
         (buf (get-buffer bufname))
         (proc (get-buffer-process buf)))

    (when (and buf proc)
      (set-process-query-on-exit-flag proc nil)
      (kill-buffer buf))

    (prog1 (setq buf (get-buffer-create bufname))
      (with-current-buffer bufname
        (compilation-mode)))

    (let ((proc (start-process-shell-command bufname buf cmd)))
      (set-process-filter proc #'docker-containers--remove-trailing-whitespace))
    (get-buffer bufname)))

(defun docker-containers-logs-follow-selection ()
  "Log the currently selected docker container"
  (interactive)
  (let ((cb (current-buffer)))
    (switch-to-buffer-other-window
     (docker-containers-logs-follow (tabulated-list-get-id)))
    (select-window (get-buffer-window cb))))

(defun org-color-tag (tag col)
    (while (re-search-forward tag nil t)
      (add-text-properties (match-beginning 0) (point-at-eol)
                           `(face (:foreground ,col)))))

(defun cfw:capture-schedule-day ()
  (let* ((date (s-chop-prefix "<" (s-chop-suffix ">" (cfw:org-capture-day))))
         (h (format-time-string "%H"))
         (M (string-to-number (format-time-string "%M")))
         (m (format "%02d" (- M (mod M 30))))
         (H (1+ (string-to-number h))))
    (message "%s" (format "<%s %s:%s-%s:%s>" date h m H m ))))

 (defun unfill-paragraph (&optional region)
      "Takes a multi-line paragraph and makes it into a single line of text."
      (interactive (progn (barf-if-buffer-read-only) '(t)))
      (let ((fill-column (point-max))
            ;; This would override `fill-column' if it's an integer.
            (emacs-lisp-docstring-fill-column t))
        (fill-paragraph nil region)))

(global-set-key (kbd "<s-f12>") 'dgc/save-or-restore-window-config)
(defvar dgc/window-config nil "A variable to store current window config")
(defun dgc/save-or-restore-window-config ()
  (interactive)
  (if dgc/window-config
      (progn (message "♺ Restoring window layout")
           (set-window-configuration dgc/window-config)
           (setq dgc/window-config nil))
    (message "✓ Saving window layout")
    (setq dgc/window-config (current-window-configuration))))

(global-set-key (kbd "M-K") 'kill-assignment)
(defun kill-assignment ()
  (interactive)
  (with-current-buffer (current-buffer)
    (let ((start (+ 3 (search-backward " = " (line-beginning-position) t))))
      (kill-region start (line-end-position))
      (goto-char start))))

(defun projectile-test-suffix (project-type)
  "Find default test files suffix based on PROJECT-TYPE."
  (cond
   ((member project-type '(rebar)) "_SUITE")
   ((member project-type '(emacs-cask)) "-test")
   ((member project-type '(rails-rspec ruby-rspec)) "_spec")
   ((member project-type '(rails-test ruby-test lein-test boot-clj go)) "_test")
   ((member project-type '(scons)) "test")
   ((member project-type '(maven symfony)) "Test")
   ((member project-type '(gradle gradlew grails)) "Spec")
   ((member project-type '(grunt generic)) "Spec")
   ((member project-type '(gulp)) "-spec")))

(global-set-key (kbd "C--") 'itunes-remote)
(defun itunes-remote (pfx)
  (interactive "P")
  (let* ((prefix (cond
                  ((equal pfx '(4)) '("-a" . "Arists "))
                  ((equal pfx '(16)) '("-A" . "Albums "))
                  (t '("" . ""))))
         (search-term (read-string (format "Search %s❯ " (cdr prefix))))
         (cmd-f (format "itunes-remote \"search \\\"%s\\\" %s\" > /dev/null" search-term (car prefix))))
    (shell-command cmd-f)))

(provide 'functions)
;;; functions.el ends here
;; Local Variables:
;; indent-tabs-mode: nil
;; eval: (flycheck-mode 0)
;; End:

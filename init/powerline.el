;;; powerline.el --- fancy statusline

;; Name: Emacs Powerline
;; Author: Nicolas Rougier and Chen Yuan
;; Version: 1.2
;; Keywords: statusline
;; Repository: https://github.com/yuanotes/powerline (not maintained)
;; Alternative: https://github.com/milkypostman/powerline by Donald Curtis

;;; Commentary:

;; This package simply provides a minor mode for fancifying the status line.

;;; Changelog:

;; v1.0 - Nicolas Rougier posted to wiki (http://www.emacswiki.org/emacs/PowerLine)
;; v1.1 - Guard clause around the powerline output, so that if
;;        powerline tries to output something unexpected, it won't
;;        just fail and flail-barf.  (JonathanArkell)
;; v1.2 - Fixed the Guard Clause to not just sit there and message like mad
;;        When a list is encountered, it is interpreted as a mode line. Fixes
;;        problems with shell mode and nXhtml mode.

;;; Code:

(defvar powerline-c1-primary "#383838")
(defvar powerline-c2-primary "#666666")
(defvar powerline-fg-primary "#bababa")
(defvar powerline-c1-secondary "#383838")
(defvar powerline-c2-secondary "#666666")
(defvar powerline-fg-secondary "#bababa")

(defun powerline-primary-window () (eq (get-buffer-window) powerline-current-window))
(defun powerline-c1 () (if (powerline-primary-window) powerline-c1-primary powerline-c1-secondary))
(defun powerline-c2 () (if (powerline-primary-window) powerline-c2-primary powerline-c2-secondary))
(defun powerline-fg () (if (powerline-primary-window) powerline-fg-primary powerline-fg-secondary))

(defvar theme-powerline-color-alist
  '((whiteboard    (:primary ("#bbbbbb" "#d7d7d7" "#2a2a2a")
                    :secondary ("#bbbbbb" "#d7d7d7" "#2a2a2a")))
    (atom-one-dark (:primary ("#3E4451" "#5C6370" "#ABB2BF")
                    :secondary ("#3E4451" "#5C6370" "#ABB2BF")))
    (darktooth     (:primary ("#222222" "#222222" "#FDF3C3")
                    :secondary ("#403935" "#403935" "#988975")))
    (niflheim      (:primary ("#222222" "#2a2a2a" "#bababa")
                    :secondary ("#222222" "#2a2a2a" "#bababa")))
    (gotham        (:primary ("#10272D" "#081E26" "#357C91")
                    :secondary ("#10272D" "#081E26" "#357C91")))
    (aurora        (:primary ("#455a64" "#2B3B40" "#CDD3D3")
                    :secondary ("#232A2F" "#232A2F" "#556D79")))
    (eink          (:primary ("#DDDDD8" "#DDDDD8" "#383838")
                    :secondary ("#DDDDD8" "#DDDDD8" "#DDDDD8")))
    (ujelly        (:primary ("#000000" "#000000" "#ffffff")
                    :secondary ("#000000" "#000000" "#ffffff")))
    (moe-light     (:primary ("#CCCCB7" "#EDEDD3" "#3F3F38")
                    :secondary ("#CCCCB7" "#EDEDD3" "#3F3F38")))
    (misterioso    (:promary ("#455a64" "#2B3B40" "#CDD3D3")
                    :secondary ("#455a64" "#2B3B40" "#CDD3D3")))
    (jazz          (:primary ("#151515" "#101010" "#7F6A4F")
                    :secondary ("#151515" "#101010" "#7F6A4F")))
    (spacemacs-dark (:primary ("#6c3163" "#292B2E" "#b2b2b2")
                              :secondary ("#292B2E" "#292B2E" "#292B2E")))
    (gruvbox       (:primary ("#3c3836" "#282828" "#f4e8ba")
                    :secondary ("#504945" "#282828" "#a89984")))))

(defun update-powerline (&rest args)
  "Update the extra powerline colours based on a mapping to theme."
  (let* ((theme (car custom-enabled-themes))
         (primary-alist (plist-get (cadr (assoc theme theme-powerline-color-alist)) :primary))
         (secondary-alist (plist-get (cadr (assoc theme theme-powerline-color-alist)) :secondary)))
    (if (and primary-alist secondary-alist)
        (setq powerline-c1-primary (car primary-alist)
              powerline-c2-primary (cadr primary-alist)
              powerline-fg-primary (caddr primary-alist)
              powerline-c1-secondary (car secondary-alist)
              powerline-c2-secondary (cadr secondary-alist)
              powerline-fg-secondary (caddr secondary-alist))
      (setq powerline-fg-primary "white"
            powerline-fg-secondary "white"))))

(defun arrow-left-xpm
  (color1 color2)
  "Return an XPM left arrow string representing."
  (create-image
   (format "/* XPM */
static char * arrow_left[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\".           \",
\"..          \",
\"...         \",
\"....        \",
\".....       \",
\"......      \",
\".......     \",
\"........    \",
\".........   \",
\"..........  \",
\"........... \",
\"........... \",
\"..........  \",
\".........   \",
\"........    \",
\".......     \",
\"......      \",
\".....       \",
\"....        \",
\"...         \",
\"..          \",
\".           \"};"
           (if color1 color1 "None")
           (if color2 color2 "None"))
   'xpm t :ascent 'center))

(defun arrow-right-xpm
  (color1 color2)
  "Return an XPM right arrow string representing."
  (create-image
   (format "/* XPM */
static char * arrow_right[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\"           .\",
\"          ..\",
\"         ...\",
\"        ....\",
\"       .....\",
\"      ......\",
\"     .......\",
\"    ........\",
\"   .........\",
\"  ..........\",
\" ...........\",
\" ...........\",
\"  ..........\",
\"   .........\",
\"    ........\",
\"     .......\",
\"      ......\",
\"       .....\",
\"        ....\",
\"         ...\",
\"          ..\",
\"           .\"};"
           (if color2 color2 "None")
           (if color1 color1 "None"))
   'xpm t :ascent 'center))

(defun curve-right-xpm
  (color1 color2)
  "Return an XPM right curve string representing."
  (create-image
   (format "/* XPM */
static char * curve_right[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\"           .\",
\"         ...\",
\"         ...\",
\"       .....\",
\"       .....\",
\"       .....\",
\"      ......\",
\"      ......\",
\"      ......\",
\"     .......\",
\"     .......\",
\"     .......\",
\"     .......\",
\"      ......\",
\"      ......\",
\"      ......\",
\"       .....\",
\"       .....\",
\"       .....\",
\"         ...\",
\"         ...\",
\"           .\"};"
           (if color2 color2 "None")
           (if color1 color1 "None"))
   'xpm t :ascent 'center))

(defun curve-left-xpm
  (color1 color2)
  "Return an XPM left curve string representing."
  (create-image
   (format "/* XPM */
static char * curve_left[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\".           \",
\"...         \",
\"...         \",
\".....       \",
\".....       \",
\".....       \",
\"......      \",
\"......      \",
\"......      \",
\".......     \",
\".......     \",
\".......     \",
\".......     \",
\"......      \",
\"......      \",
\"......      \",
\".....       \",
\".....       \",
\".....       \",
\"...         \",
\"...         \",
\".           \"};"
           (if color1 color1 "None")
           (if color2 color2 "None"))
   'xpm t :ascent 'center))

(defun gradient-color-blend (c1 c2 &optional alpha)
  "Blend the two colors C1 and C2 with ALPHA.
C1 and C2 are in the format of `color-values'.
ALPHA is a number between 0.0 and 1.0 which corresponds to the
influence of C1 on the result."
  (setq alpha (or alpha 0.5))
  (apply #'gradient-color-join
         (cl-mapcar
          (lambda (x y)
            (round (+ (* x alpha) (* y (- 1 alpha)))))
          c1 c2)))

(defun gradient-color-join (r g b)
  "Build a color from R G B.
Inverse of `color-values'."
  (format "#%02x%02x%02x"
          (ash r -8)
          (ash g -8)
          (ash b -8)))

(defun gradient-xpm
  (c1 c2)
  "Return an XPM gradient string representing."
  (let* ((backup-color
          (if (eq (get-buffer-window) powerline-current-window)
            (face-attribute 'mode-line :background)
            (face-attribute 'mode-line-inactive :background)))
        (c1 (or c1 backup-color))
        (c2 (or c2 backup-color)))
    (create-image
    (format "/* XPM */
static char * gradient_left[] = {
/* columns rows colours chars-per-pixel */
\"12 22 12 1\",
\"a c %s\",
\"b c %s\",
\"c c %s\",
\"d c %s\",
\"e c %s\",
\"f c %s\",
\"g c %s\",
\"h c %s\",
\"i c %s\",
\"j c %s\",
\"k c %s\",
\"l c %s\",
/* pixels */
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\",
\"abcdefghijkl\"};"
            c1
            (gradient-color-blend (color-values c2) (color-values c1) 0.1)
            (gradient-color-blend (color-values c2) (color-values c1) 0.2)
            (gradient-color-blend (color-values c2) (color-values c1) 0.3)
            (gradient-color-blend (color-values c2) (color-values c1) 0.4)
            (gradient-color-blend (color-values c2) (color-values c1) 0.5)
            (gradient-color-blend (color-values c2) (color-values c1) 0.6)
            (gradient-color-blend (color-values c2) (color-values c1) 0.7)
            (gradient-color-blend (color-values c2) (color-values c1) 0.8)
            (gradient-color-blend (color-values c2) (color-values c1) 0.9)
            (gradient-color-blend (color-values c2) (color-values c1) 1.0)
            c2)
    'xpm t :ascent 'center)))

(defun slash-left-xpm
  (color1 color2)
  "Return an XPM left curve string representing."
  (create-image
   (format "/* XPM */
static char * curve_left[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\"........... \",
\"........... \",
\"..........  \",
\"..........  \",
\".........   \",
\".........   \",
\"........    \",
\"........    \",
\".......     \",
\".......     \",
\"......      \",
\"......      \",
\".....       \",
\".....       \",
\"....        \",
\"....        \",
\"...         \",
\"...         \",
\"..          \",
\"..          \",
\".           \",
\".           \"};"
           (if color1 color1 "None")
           (if color2 color2 "None"))
   'xpm t :ascent 'center))

(defun slash-right-xpm
  (color1 color2)
  "Return an XPM left curve string representing."
  (create-image
   (format "/* XPM */
static char * curve_left[] = {
\"12 22 2 1\",
\". c %s\",
\"  c %s\",
\".           \",
\".           \",
\"..          \",
\"..          \",
\"...         \",
\"...         \",
\"....        \",
\"....        \",
\".....       \",
\".....       \",
\"......      \",
\"......      \",
\".......     \",
\".......     \",
\"........    \",
\"........    \",
\".........   \",
\".........   \",
\"..........  \",
\"..........  \",
\"........... \",
\"........... \"};"
           (if color1 color1 "None")
           (if color2 color2 "None"))
   'xpm t :ascent 'center))

(defun make-xpm
  (name color1 color2 data)
  "Return an XPM image for lol data"
  (create-image
   (concat
    (format "/* XPM */
static char * %s[] = {
\"%i %i 2 1\",
\". c %s\",
\"  c %s\",
"
            (downcase (replace-regexp-in-string " " "_" name))
            (length (car data))
            (length data)
            (if color1 color1 "None")
            (if color2 color2 "None"))
    (let ((len  (length data))
          (idx  0))
      (apply 'concat
             (mapcar #'(lambda (dl)
                        (setq idx (+ idx 1))
                        (concat
                         "\""
                         (concat
                          (mapcar #'(lambda (d)
                                     (if (eq d 0)
                                         (string-to-char " ")
                                       (string-to-char ".")))
                                  dl))
                         (if (eq idx len)
                             "\"};"
                           "\",\n")))
                     data))))
   'xpm t :ascent 'center))

(defun half-xpm
  (color1 color2)
  (make-xpm "half" color1 color2
            (make-list 18
                       (append (make-list 6 0)
                               (make-list 6 1)))))

(defun percent-xpm
  (pmax pmin we ws width color1 color2)
  (let* ((fs   (if (eq pmin ws)
                   0
                 (round (* 17 (/ (float ws) (float pmax))))))
         (fe   (if (eq pmax we)
                   17
                 (round (* 17 (/ (float we) (float pmax))))))
         (o    nil)
         (i    0))
    (while (< i 18)
      (setq o (cons
               (if (and (<= fs i)
                        (<= i fe))
                   (append (list 0) (make-list width 1) (list 0))
                 (append (list 0) (make-list width 0) (list 0)))
               o))
      (setq i (+ i 1)))
    (make-xpm "percent" color1 color2 (reverse o))))


;; from memoize.el @ http://nullprogram.com/blog/2010/07/26/
(defun memoize (func)
  "Memoize the given function. If argument is a symbol then
install the memoized function over the original function."
  (typecase func
    (symbol (fset func (memoize-wrap (symbol-function func))) func)
    (function (memoize-wrap func))))

(defun memoize-wrap (func)
  "Return the memoized version of the given function."
  (let ((table-sym (gensym))
  (val-sym (gensym))
  (args-sym (gensym)))
    (set table-sym (make-hash-table :test 'equal))
    `(lambda (&rest ,args-sym)
       ,(concat (documentation func) "\n(memoized function)")
       (let ((,val-sym (gethash ,args-sym ,table-sym)))
   (if ,val-sym
       ,val-sym
     (puthash ,args-sym (apply ,func ,args-sym) ,table-sym))))))

(memoize 'arrow-left-xpm)
(memoize 'arrow-right-xpm)
(memoize 'curve-left-xpm)
(memoize 'curve-right-xpm)
(memoize 'slash-left-xpm)
(memoize 'slash-right-xpm)
(memoize 'gradient-xpm)

(defun powerline-set-style ()
  "Set the style of the powerline separator"
  (interactive)
  (let* ((styles
          '(("arrow" arrow-left-xpm arrow-right-xpm)
            ("curve" curve-left-xpm curve-right-xpm)
            ("slash-/\\" slash-left-xpm slash-right-xpm)
            ("slash-//" slash-left-xpm slash-left-xpm)
            ("slash-\\/" slash-right-xpm slash-left-xpm)
            ("slash-\\\\" slash-right-xpm slash-right-xpm)
            ("gradient" gradient-xpm gradient-xpm)))
         (result (assoc (completing-read "Style: " styles) styles)))
    (defalias 'right-xpm (caddr result))
    (defalias 'left-xpm (cadr result))))

(defalias 'right-xpm 'slash-right-xpm)
(defalias 'left-xpm  'slash-left-xpm)

(defvar powerline-minor-modes nil)
(defvar powerline-arrow-shape 'arrow)
(defun powerline-make-face
  (bg &optional fg)
  (if bg
      (let ((cface (intern (concat "powerline-"
                                   bg
                                   "-"
                                   (if fg
                                       (format "%s" fg)
                                     "white")))))
        (make-face cface)2
        (if fg
            (if (eq fg 0)
                (set-face-attribute cface nil
                                    :background bg
                                    :box nil)
              (set-face-attribute cface nil
                                  :foreground fg
                                  :background bg
                                  :box nil))
          (set-face-attribute cface nil
                            :foreground (powerline-fg)
                            :background bg
                            :box nil))
        cface)
    nil))

(defun powerline-make-left
  (string color1 &optional color2 localmap)
  (let ((plface (powerline-make-face color1))
        (arrow  (and color2 (not (string= color1 color2)))))
    (concat
     (if (or (not string) (string= string ""))
         ""
       (propertize " " 'face plface))
     (if string
         (if localmap
             (propertize string 'face plface 'mouse-face plface 'local-map localmap)
           (propertize string 'face plface))
       "")
     (if arrow
         (propertize " " 'face plface)
       "")
     (if arrow
         (propertize " " 'display
                     (left-xpm color1 color2)
                     'local-map (make-mode-line-mouse-map
                                 'mouse-1 (lambda () (interactive)
                                            (setq powerline-arrow-shape 'arrow)
                                            (force-mode-line-update)))) ""))))



(defun powerline-make-right
  (string color2 &optional color1 localmap)
  (let ((plface (powerline-make-face color2))
        (arrow  (and color1 (not (string= color1 color2)))))
    (concat
     (if arrow
         (propertize " " 'display
                     (right-xpm color1 color2)
                   'local-map (make-mode-line-mouse-map
                               'mouse-1 (lambda () (interactive)
                                          (setq powerline-arrow-shape 'arrow)
                                          (force-mode-line-update))))
       "")
     (if arrow
         (propertize " " 'face plface)
       "")
     (if string
         (if localmap
             (propertize string 'face plface 'mouse-face plface 'local-map localmap)
           (propertize string 'face plface))
       "")
     (if (or (not string) (string= string ""))
         ""
       (propertize " " 'face plface)))))

(defun powerline-make-fill (color)
  ;; justify right by filling with spaces to right fringe, 20 should be calculated
  (let ((plface (powerline-make-face color))
        (amount (- (window-total-width)
                   (+ 34
                      (if (eq (get-buffer-window) powerline-current-window)
                          (length (-powerline-get-weather " %(weather) "))
                        0)
                      (if (and (fboundp 'boop-format-results)
                               (eq (get-buffer-window) powerline-current-window))
                          (+ 1 (length  (boop-format-results))) 0)
                      (length (-powerline-get-temp))))))
    (propertize " " 'display `((space :align-to ,amount)) 'face plface)))

(defun powerline-make-text
  (string color &optional fg localmap)
  (let ((plface (powerline-make-face color)))
    (if string
        (if localmap
            (propertize string 'face plface 'mouse-face plface 'local-map localmap)
          (propertize string 'face plface))
      "")))

(defun powerline-make (side string color1 &optional color2 localmap)
  (cond ((and (eq side 'right) color2) (powerline-make-right  string color1 color2 localmap))
        ((and (eq side 'left) color2)  (powerline-make-left   string color1 color2 localmap))
        ((eq side 'left)               (powerline-make-left   string color1 color1 localmap))
        ((eq side 'right)              (powerline-make-right  string color1 color1 localmap))
        ((eq side 'donttouch)          (powerline-make-right  string color1 color1 localmap))
        (t                             (powerline-make-text   string color1 localmap))))

(defmacro defpowerline (name string)
  "Macro to create a powerline chunk."
  `(defun ,(intern (concat "powerline-" (symbol-name name)))
       (side color1 &optional color2)
     (powerline-make side
                     (let ((result ,string))
                       (cond ((listp result)
                              (format-mode-line result))
                             ((not (or (stringp result)
                                       (null result)))
                              (progn
                                " ERR"))
                             (t
                              result)))
                     color1 color2)))



(defun powerline-mouse (click-group click-type string)
  (cond ((eq click-group 'minor)
         (cond ((eq click-type 'menu)
                `(lambda (event)
                   (interactive "@e")
                   (minor-mode-menu-from-indicator ,string)))
               ((eq click-type 'help)
                `(lambda (event)
                   (interactive "@e")
                   (describe-minor-mode-from-indicator ,string)))
               (t
                `(lambda (event)
                   (interactive "@e")
                    nil))))
        (t
         `(lambda (event)
            (interactive "@e")
            nil))))

(defpowerline arrow       "")

(defvar powerline-buffer-size-suffix t)
(defpowerline buffer-size (propertize
                            (if powerline-buffer-size-suffix
                                "%I"
                              "%i")
                            'local-map (make-mode-line-mouse-map
                                        'mouse-1 (lambda () (interactive)
                                                   (setq powerline-buffer-size-suffix
                                                         (not powerline-buffer-size-suffix))
                                                   (redraw-modeline)))))
(defpowerline rmw         "%*")
(defpowerline major-mode  (propertize (if (stringp mode-name) mode-name (format "%s" (buffer-mode (current-buffer))))
                                      'help-echo "Major mode\n\ mouse-1: Display major mode menu\n\ mouse-2: Show help for major mode\n\ mouse-3: Toggle minor modes"
                                      'local-map (let ((map (make-sparse-keymap)))
                                                   (define-key map [mode-line down-mouse-1]
                                                     `(menu-item ,(purecopy "Menu Bar") ignore
                                                                 :filter (lambda (_) (mouse-menu-major-mode-map))))
                                                   (define-key map [mode-line mouse-2] 'describe-mode)
                                                   (define-key map [mode-line down-mouse-3] mode-line-mode-menu)
                                                   map)))
(defpowerline process      mode-line-process)
(defpowerline minor-modes (let ((mms (split-string (format-mode-line minor-mode-alist))))
                            (apply 'concat
                                   (mapcar #'(lambda (mm)
                                              (propertize (if (string= (car mms)
                                                                       mm)
                                                              mm
                                                            (concat " " mm))
                                                          'help-echo "Minor mode\n mouse-1: Display minor mode menu\n mouse-2: Show help for minor mode\n mouse-3: Toggle minor modes"
                                                          'local-map (let ((map (make-sparse-keymap)))
                                                                       (define-key map [mode-line down-mouse-1]   (powerline-mouse 'minor 'menu mm))
                                                                       (define-key map [mode-line mouse-2]        (powerline-mouse 'minor 'help mm))
                                                                       (define-key map [mode-line down-mouse-3]   (powerline-mouse 'minor 'menu mm))
                                                                       (define-key map [header-line down-mouse-3] (powerline-mouse 'minor 'menu mm))
                                                                       map)))
                                           mms))))
(defpowerline row         "%4l")
(defpowerline column      "%3c")
(defpowerline percent     "%6p")
(defpowerline narrow      (let (real-point-min real-point-max)
                            (save-excursion
                              (save-restriction
                                (widen)
                                (setq real-point-min (point-min) real-point-max (point-max))))
                            (when (or (/= real-point-min (point-min))
                                      (/= real-point-max (point-max)))
                              (propertize "Narrow"
                                          'help-echo "mouse-1: Remove narrowing from the current buffer"
                                          'local-map (make-mode-line-mouse-map
                                                      'mouse-1 'mode-line-widen)))))
(defpowerline status      "%s")
(defpowerline global      global-mode-string)
(defpowerline emacsclient mode-line-client)
(defpowerline project-id (if (and (boundp 'jpop-id)
                                  (not (eql nil jpop-id)))
                             (propertize (format "%s" (concat (upcase jpop-id) " ∘"))
                                         'display '(height 0.8))
                           (format "×")))

(defpowerline vc vc-mode)
(defpowerline time (format-time-string "%H:%M"))

(defpowerline flycheck-status (propertize (format "%s" (cadr (flycheck-status-emoji-mode-line-text)))
                                          'display '(height 0.8)))

(defun -powerline-get-temp ()
  (let ((temp (-powerline-get-weather "%(temperature)")))
    (unless (string= "" temp) (format "%s°C" (round (string-to-number temp))))))

(defun -powerline-get-weather (format)
  (if (boundp 'yahoo-weather-info)
      (downcase (yahoo-weather-info-format yahoo-weather-info format))
    ""))

(defpowerline weather (-powerline-get-weather " %(weather) "))
(defpowerline temperature (-powerline-get-temp))

(defpowerline eb-indicator (eyebrowse-mode-line-indicator))

(defpowerline buffer-id (propertize (car (propertized-buffer-identification "%12b"))
                                      'face (powerline-make-face color1)))

(defpowerline window-number (format "%c" (+ 10121 (window-numbering-get-number))))

(defpowerline percent-xpm (propertize "  "
                                      'display
                                      (let (pmax
                                            pmin
                                            (ws (window-start))
                                            (we (window-end)))
                                        (save-restriction
                                          (widen)
                                          (setq pmax (point-max))
                                          (setq pmin (point-min)))
                                        (percent-xpm pmax pmin we ws 15 color1 color2))))

(defvar powerline-current-window nil)
(defun update-current-window (windows)
  (when (not (minibuffer-window-active-p (frame-selected-window)))
    (setq powerline-current-window (selected-window))))
(add-function :before pre-redisplay-function 'update-current-window)

(defun powerline-boop ()
  (when (fboundp 'boop-format-results)
    (let ((s (boop-format-results)))
      (add-face-text-property 0 (length s) `(:background ,(powerline-c2)) nil s) s)))

(defun -count-notifications (pattern notification-char)
  (when (boundp 'slack-ims)
    (let ((result
          (-reduce '+ (-map 'string-to-number (-non-nil
                                               (-map (lambda (it)
                                                       (with-temp-buffer
                                                         (insert (format "%s" it))
                                                         (goto-char (point-min))
                                                         (when (search-forward-regexp pattern (point-max) t)
                                                           (match-string 1)))) slack-ims))))))
     (when (> result 0) notification-char))))

(defpowerline new-im-notifications (-count-notifications "[0-9]+ \\([0-9]+\\) (.*?)" "✩"))
(defpowerline new-channel-notifications (-count-notifications "(.*?) \\([0-9]+\\) [0-9]+ nil" "✧"))

(defun powerline-mode-xpm ()
  (propertize " " 'display (mode-icon-ruby-xpm (powerline-fg) (powerline-c1))
              'face `(:background ,(powerline-c1))))

(defun powerline-mode-icon-xpm ()
  (let ((mode-s (cadr (assoc major-mode mode-icons))))
    (if mode-s
        (propertize " " 'display
                    (funcall (intern (format "mode-icon-%s-xpm" mode-s)) (powerline-fg) (powerline-c1))
                    'face `(:background ,(powerline-c1))
                    'help-echo "Major mode\n\ mouse-1: Display major mode menu\n\ mouse-2: Show help for major mode\n\ mouse-3: Toggle minor modes"
                    'local-map (let ((map (make-sparse-keymap)))
                                 (define-key map [mode-line down-mouse-1]
                                   `(menu-item ,(purecopy "Menu Bar") ignore
                                               :filter (lambda (_) (mouse-menu-major-mode-map))))
                                 (define-key map [mode-line mouse-2] 'describe-mode)
                                 (define-key map [mode-line down-mouse-3] mode-line-mode-menu)
                                 map))
      (powerline-major-mode 'left (powerline-c1)))))

(setq-default mode-line-format
              (list "%e"
                    '(:eval (concat
                             (powerline-rmw    'left  nil  )
                             (powerline-project-id     'left  nil  )
                             (powerline-window-number  'left  nil  )

                             ;; (powerline-new-im-notifications  'left  nil  )

                             (powerline-buffer-id      'left  nil   (powerline-c1)  )

                             (powerline-make-text " " (powerline-c1))

                             (powerline-mode-icon-xpm)
                             (powerline-process          'text        (powerline-c1)  )
                             (powerline-flycheck-status  'left        (powerline-c1)  )
                             (powerline-narrow           'left        (powerline-c1)  (powerline-c2) )


                             (if (eq (get-buffer-window) powerline-current-window)
                                 (concat
                                  (powerline-vc       'center      (powerline-c2)  )
                                  (powerline-make-fill             (powerline-c2)  )
                                  (powerline-weather  'text        (powerline-c2)  )
                                  (powerline-boop))
                               (powerline-make-fill                (powerline-c2)  ))

                             (powerline-row            'right       (powerline-c1)  (powerline-c2) )
                             (powerline-make-text      ":"          (powerline-c1)  )
                             (powerline-column         'right       (powerline-c1)  )
                             (powerline-time           'right  nil  (powerline-c1)  )
                             (powerline-temperature    'right  nil  )
                             (powerline-make-text      "-"   nil  )
                             (powerline-buffer-size    'left   nil  )))))

(provide 'powerline)
;; Local Variables:
;; indent-tabs-mode: nil
;; eval: (flycheck-mode 0)
;; End:
;;; powerline.el ends here
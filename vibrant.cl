(proclaim '(optimize (speed 0) (safety 3) (debug 3)))

(ql:quickload '(alexandria iterate anaphora cl-colors) :silent t)

(defpackage vibrant
  (:export vibrant)
  (:use cl iterate anaphora alexandria cl-colors)
  (:shadow variance))

(in-package vibrant)

(defun bytes-to-str (bytes)
   (map 'string #'code-char bytes))

(defun str-to-bytes (str)
   (map 'list #'char-code str))

(defun write-str-to-file (path str)
   (let ((stream (open path :direction :output :if-exists :supersede)))
         (write-string str stream)
         (close stream)))

(defun cat (list)
   (format nil "~{~a~}" list))

(defmacro cat* (&rest rest)
   `(cat (list ,@rest)))

(defvar comment-styles
 '((c  "Comment")
   (cm "Comment.Multiline")
   (cp "Comment.Preproc")
   (c1 "Comment.Single")
   (cs "Comment.Special")))

(defvar number-styles
 '((m  "Literal.Number")
   (mf "Literal.Number.Float")
   (mh "Literal.Number.Hex")
   (mi "Literal.Number.Integer")
   (il "Literal.Number.Integer.Long")
   (mo "Literal.Number.Oct")
   (ld "Literal.Date")
   (l  "literal")))

(defvar string-styles
 '((s  "Literal.String")
   (sc "Literal.String.Char")
   (sd "Literal.String.Doc")
   (s2 "Literal.String.Double")
   (se "Literal.String.Escape")
   (sh "Literal.String.Heredoc")
   (si "Literal.String.Interpol")
   (sx "Literal.String.Other")
   (sr "Literal.String.Regex")
   (s1 "Literal.String.Single")
   (ss "Literal.String.Symbol")))

(defvar keyword-styles
 '((k  "Keyword")
   (kc "Keyword.Constant")
   (kd "Keyword.Decleration")
   (kn "Keyword.Namespace")
   (kp "Keyword.Pseudo")
   (kr "Keyword.Reserved")
   (kt "Keyword.Type")))

(defvar foreground-styles
 '((p  "Punctuation")
   (nv "Name.Variable")))

(defvar operator-styles
 '((o  "Operator")
   (ow "Operator.Word")))

(defvar misc-styles
 '((n  "Name")
   (na "Name.Attribute")
   (nb "Name.Builtin")
   (nc "Name.Class")
   (no "Name.Constant")
   (nd "Name.Decorator")
   (ni "Name.Entity")
   (ne "Name.Exception")
   (nf "Name.Function")
   (nl "Name.Label")
   (nn "Name.Namespace")
   (nx "Name.Other")
   (py "Name.Proprty")
   (nt "Name.Tag")))

(defvar prefix ".highlight")
(defvar variance 0.8)
(defvar blending 0)

(defun average-colors (c1 c2)
   (rgb-combination c1 c2 0.5))

(defun randomize (n v) (clamp (+ n (* v (gaussian-random -1 1))) 0 1))

(defun apply-variance (color amt)
   (average-colors color 
      (let ((r (rgb-red color))
            (g (rgb-green color))
            (b (rgb-blue color)))
            (rgb (randomize r amt) (randomize g amt) (randomize b amt)))))

(defun blend (color avg)
   (rgb-combination color avg blending))

(defun generate-secondary-random-color (colors)
   (blend (apply-variance (random-elt colors) (/ variance (length colors)))
          (reduce #'average-colors colors)))

(defun color-style-transform (style fun)
   (iter (for (x y) in style)
         (for r = (print-hex-rgb (if (functionp fun) (funcall fun) fun)))
         (collect (list x r y))))

(defvar used-colors nil)

(defmacro handle-style (name)
  (with-gensyms (x)
   `(if (eql (length used-colors) (length colors))
        (color-style-transform ,name (generate-secondary-random-color colors))
        (iter (for ,x = (random-elt colors))
              (unless (find ,x used-colors :test #'equalp)
                      (push ,x used-colors)
                      (leave (color-style-transform ,name 
                                (blend (random-elt colors) 
                                       (reduce #'average-colors colors)))))))))

;; curving affect on the values that brings them closer to normal saturation and value
(defun generate-color-scheme (colors)
   (setf used-colors nil)
   (append (handle-style foreground-styles)
           (handle-style comment-styles)
           (handle-style keyword-styles)
           (handle-style operator-styles)
           (handle-style number-styles)
           (handle-style string-styles)
           (color-style-transform misc-styles 
              (lambda () (generate-secondary-random-color colors)))))

(defun render (colors variance blending list)
   (cat* (format nil " /* ~a~%    ~a ~{~a ~}~%    ~a ~a~%    ~a ~a */~%~%"
            "generated by vibrant" "colors:" colors 
            "variance:" variance "blending:" blending)
         (cat (iter (for (x y z) in list)
                    (collect (format nil "~a .~2a { color: ~a } /* ~a */~%" prefix x y z))))))

(defun vibrant (file strings &key (variance 0.4) (blending 0) (prefix ".highlight"))
   (write-str-to-file file
     (render strings variance blending
       (generate-color-scheme
        (iter (for s in strings)
              (collect (parse-hex-rgb s)))))))

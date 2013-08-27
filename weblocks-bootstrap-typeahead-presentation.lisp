;;;; weblocks-bootstrap-typeahead-presentation.lisp

(in-package #:weblocks-bootstrap-typeahead-presentation)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (yaclml::def-empty-html-tag <:input :core :event :i18n
                              accept
                              accesskey
                              alt
                              checked
                              disabled
                              maxlength
                              name
                              onblur
                              onchange
                              onfocus
                              onselect
                              readonly
                              size
                              src
                              tabindex
                              type
                              usemap
                              value
                              width
                              height 
                              placeholder 
                              data-provide))

(defclass bootstrap-typeahead-presentation (input-presentation choices-presentation-mixin)
  ((display-create-message :initform t :initarg :display-create-message)))

(defmethod obtain-presentation-choices ((choices bootstrap-typeahead-presentation) obj)
  (let ((choices (presentation-choices choices)))
    (if (or (functionp choices)
            (and (symbolp choices)
                 (fboundp choices)))
      (funcall choices obj)
      choices)))

(defun render-bootstrap-typeahead (&key list-of-choices input-id input-name input-size input-value input-maxlength display-create-message (input-placeholder (translate "Type or choose ... ▼")))
  (send-script
    (ps:ps 
      (j-query 
        (lambda ()
          (let* ((source (eval (ps:LISP (format nil "(~A)" (json:encode-json-to-string list-of-choices)))))
                 (input (j-query (ps:LISP (format nil "#~A" input-id))))
                 (input-append (ps:chain input (parents ".maybe-input-append"))))

            (flet ((hide-or-show-clear-button-and-create-hint ()
                     (if (and 
                           (ps:chain input (val))
                           (= -1 (ps:chain source 
                                           (index-of 
                                             (ps:chain input (val))))))
                       (ps:chain input-append (siblings ".help-inline") (show))
                       (ps:chain input-append (siblings ".help-inline") (hide)))
                     (if (ps:chain input (val))
                       (progn 
                         (ps:chain input (siblings "button") (show))
                         (ps:chain input-append (add-class "input-append")))
                       (progn 
                         (ps:chain input (siblings "button") (hide))
                         (ps:chain input-append (remove-class "input-append")))))
                   (maybe-show-list ()
                     (hide-or-show-clear-button-and-create-hint)
                     (if (ps:chain (j-query this) (val))
                       (ps:chain (ps:chain 
                                   (j-query this) (data "typeahead") 
                                   (show)))
                       (ps:chain (j-query this) (data "typeahead") 
                                 (lookup)
                                 (render source)
                                 (show)))))

              (ps:chain 
                input
                (typeahead (ps:create 
                             :source source))
                (click maybe-show-list)
                (keyup maybe-show-list)
                (change (lambda ()
                          (hide-or-show-clear-button-and-create-hint)))
                (siblings "button")
                (click (lambda ()
                         (ps:chain input (val "") (focus) (click)))))

              (hide-or-show-clear-button-and-create-hint)))))))
  (with-yaclml 
    (<:div :class "input-append maybe-input-append" :style "display:inline-block"
           (<:input :name input-name :type "text" :class "typeahead-input" :placeholder input-placeholder :data-provide "typeahead"
                    :value  input-value
                    :maxlength  input-maxlength
                    :size input-size
                    :id input-id)
           (<:button :type "button" :class "btn" (<:i :class "icon-remove"))) 
    (when  display-create-message
      (<:span :class "help-inline" :style "color:#468847" "New item will be created"))))

(defmethod render-view-field-value (value (presentation bootstrap-typeahead-presentation)
                                          field view widget obj
                                          &rest args &key intermediate-values field-info &allow-other-keys)
  (declare (special *presentation-dom-id*))
  (let ((attributized-slot-name (if field-info
                                  (attributize-view-field-name field-info)
                                  (attributize-name (view-field-slot-name field)))))
    (multiple-value-bind (intermediate-value intermediate-value-p)
      (form-field-intermediate-value field intermediate-values)

      (render-bootstrap-typeahead 
        :list-of-choices (obtain-presentation-choices presentation obj)
        :input-id *presentation-dom-id* 
        :input-size (weblocks::input-presentation-size presentation)
        :input-value (if intermediate-value-p
                       intermediate-value
                       (apply #'print-view-field-value value presentation field view widget obj args))
        :input-maxlength (input-presentation-max-length presentation)
        :display-create-message (slot-value presentation 'display-create-message)
        :input-name attributized-slot-name))))


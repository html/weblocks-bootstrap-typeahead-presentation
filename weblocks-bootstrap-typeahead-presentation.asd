;;;; weblocks-bootstrap-typeahead-presentation.asd

(asdf:defsystem #:weblocks-bootstrap-typeahead-presentation
  :version "0.0.3"
  :description "Weblocks form view presentation for Twitter Bootstrap typeahead"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :license "LLGPL"
  :depends-on (#:weblocks
               #:yaclml
               #:parenscript)
  :components ((:file "package")
               (:file "weblocks-bootstrap-typeahead-presentation" :depends-on ("package"))))


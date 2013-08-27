# Weblocks Bootstrap Typeahead Presentation

## About

This is Weblocks form view presentation which allows you to use Twitter Bootstrap Typeahead javascript component http://getbootstrap.com/2.3.2/javascript.html#typeahead

## Requirements

It works only with Weblocks Twitter Bootstrap Application https://github.com/html/weblocks-twitter-bootstrap-application

## Usage 

It is used in `defview` code

```lisp
(defview nil (:type form 
              :caption "Editing something"
              :inherit-from '(:scaffold content-item))
 (catalog-element 
  :label "Some catalog"
  :present-as 
  (bootstrap-typeahead 
   :display-create-message nil
   :choices 
   (lambda (item)
    (mapcar #'cdr (catalog-item-text-tree nil))) ; List of strings which will be displayed as typeahead values 
  )
  :reader 

  ; We displaying here object text value which can be turned into object on submit
  (lambda (item)
   (let ((elem (content-item-catalog-element item)))
    (and 
     elem
     (tree-path-pretty-print elem))))
  :writer 

  ; We transforming here object text presentation into object and connecting this object with form data object
  (lambda (value item)
   (setf 
    (content-item-catalog-element item)
    (parse-catalog-item-from-text value)))))
```

;;; -*- Mode: common-lisp; package: shop2; -*-
;;;
;;; Version: MPL 1.1/GPL 2.0/LGPL 2.1
;;; 
;;; The contents of this file are subject to the Mozilla Public License
;;; Version 1.1 (the "License"); you may not use this file except in
;;; compliance with the License. You may obtain a copy of the License at
;;; http://www.mozilla.org/MPL/
;;; 
;;; Software distributed under the License is distributed on an "AS IS"
;;; basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
;;; License for the specific language governing rights and limitations under
;;; the License.
;;; 
;;; The Original Code is SHOP2.  
;;; 
;;; The Initial Developer of the Original Code is the University of
;;; Maryland. Portions created by the Initial Developer are Copyright (C)
;;; 2002,2003 the Initial Developer. All Rights Reserved.
;;;
;;; Additional developments made by Robert P. Goldman, and Ugur Kuter.
;;; Portions created by Drs. Goldman and Kuter are Copyright (C)
;;; 2017 SIFT, LLC.  These additions and modifications are also
;;; available under the MPL/GPL/LGPL licensing terms.
;;; 
;;; 
;;; Alternatively, the contents of this file may be used under the terms of
;;; either of the GNU General Public License Version 2 or later (the "GPL"),
;;; or the GNU Lesser General Public License Version 2.1 or later (the
;;; "LGPL"), in which case the provisions of the GPL or the LGPL are
;;; applicable instead of those above. If you wish to allow use of your
;;; version of this file only under the terms of either the GPL or the LGPL,
;;; and not to allow others to use your version of this file under the terms
;;; of the MPL, indicate your decision by deleting the provisions above and
;;; replace them with the notice and other provisions required by the GPL or
;;; the LGPL. If you do not delete the provisions above, a recipient may use
;;; your version of this file under the terms of any one of the MPL, the GPL
;;; or the LGPL.
;;; ----------------------------------------------------------------------
;;; ----------------------------------------------------------------------
;;; Copyright(c) 2017  Smart Information Flow Technologies
;;; Air Force Research Lab Contract # FA8750-16-C-0182
;;; Unlimited Government Rights
;;; ----------------------------------------------------------------------

(defpackage shop-theorem-prover-tests
  (:shadowing-import-from #:shop3.theorem-prover #:fail)
  (:use common-lisp shop3.theorem-prover fiveam))

(in-package #:shop-theorem-prover-tests)

(def-suite* theorem-prover-tests)

(def-fixture tp-domain ()
  (let ((*domain* (make-instance 'thpr-domain)))
    (&body)))

(def-fixture pddl-tp-domain ()
  (let ((*domain* (make-instance 'shop3:adl-domain)))
    (&body)))

(defun sorted-bindings (variable binding-lists)
  (sort (mapcar #'(lambda (x) (binding-list-value variable x))
                               binding-lists)
                       'string-lessp))

;;; does OR properly bind variables?
(test check-disjunction-bindings
  (with-fixture tp-domain ()
    (let ((bindings
            (query '(or (foo ?x) (bar ?x))
                   (shop3.common:make-initial-state *domain* (default-state-type *domain*)
                                                    '((foo a) (bar b))))))
      (is (equal '(a b) (sorted-bindings '?x bindings))))))

;;; what about IMPLY?
(test check-implication-bindings
  (with-fixture tp-domain ()
    (let ((bindings
            (query '(and (foo ?x) (imply (bar ?x) (baz ?x)))
                   (shop3.common:make-initial-state *domain* (default-state-type *domain*)
                                                    '((foo a) (foo b) (bar b) (baz b)
                                                      (foo c)
                                                      (foo d) (bar d))))))
      (is (equal '(a b c) (sorted-bindings '?x bindings))))
    ;; in this context, (NOT (BAR ?X)) has no sensible semantics.  Raise error.
    (signals non-ground-error
     (query '(and (imply (bar ?x) (baz ?x)))
            (shop3.common:make-initial-state *domain* (default-state-type *domain*)
                                             '((foo a) (foo b) (bar b) (baz b))))))
  (with-fixture pddl-tp-domain ()
    (let ((bindings
            (query '(and (foo ?x) (imply (bar ?x) (baz ?x)))
                   (shop3.common:make-initial-state *domain* (default-state-type *domain*)
                                                    '((foo a) (foo b) (bar b) (baz b)
                                                      (foo c)
                                                      (foo d) (bar d))))))
      (is (equal '(a b c) (sorted-bindings '?x bindings))))))



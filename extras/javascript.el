;; Specific versions of node packages installed on a per-project
;; basis are the norm in JS development. So, for example, if you're
;; using `eslint' to stylecheck your code, this will make project
;; buffers find `node_modules/.bin/eslint' before any other
;; executable in their `exec-path'
(use-package add-node-modules-path
  :ensure t
  :hook (prog-mode . add-node-modules-path))

;; (defun @cowboyd/find-nearest-dominating-file (files dir)
;;   "Find which file is the nearest to the current"
;;   (if (string= dir "/") nil
;;     (let* ((contents (directory-files dir))
;; 	  (file (seq-find (lambda (file) (seq-contains-p contents file)) files)))
;;       (or
;;        (when file (concat (file-name-as-directory dir) file))
;;        (@cowboyd/find-nearest-dominating-file files (directory-file-name (file-name-directory dir)))))))

;; (defun @cowboyd/deno-project (&optional startdir)
;;   "Is the current file inside a deno (and not a node)project"
;;   (let* ((dir (directory-file-name (or startdir (file-name-directory (buffer-file-name)))))
;; 	(project-file (@cowboyd/find-nearest-dominating-file
;; 		       (list "deno.json" "package.json")
;; 		       dir)))
;;     (when (string= "deno" (file-name-base project-file)) project-file)))

(add-to-list 'auto-mode-alist '("\\.ts\\'"    . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"    . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'"    . js-ts-mode))

(defun @cowboyd/find-js-marker ()
  (catch 'done
    (locate-dominating-file
     default-directory
     (lambda (d)
       (dolist (f '("package.json" "deno.json"))
         (let ((marker (expand-file-name f d)))
           (when (file-exists-p marker) (throw 'done marker))))))))

(defun @cowboyd/deno-lsp-or-typescript-language-server ()
  (lambda (&optional _interactive)
    (let* ((m (@cowboyd/find-js-marker)))
      (cdr
       (assoc
        (file-name-nondirectory m)
        '(("package.json" "typescript-language-server" "--stdio")
          ("deno.json" "deno" "lsp" :initializationOptions '(:enable t :lint t))))))))

;; (defun my/project-find-function (dir)
;;   (when-let ((f (and (boundp eglot-lsp-context) eglot-lsp-context (@cowboyd/find-js-marker))))
;;     `(transient . ,(file-name-directory f))))

;; (add-hook 'project-find-functions 'my/project-find-function)
(add-to-list 'eglot-server-programs
             `((js-mode (typescript-ts-base-mode :language-id "typescript")) .
               ,(@cowboyd/deno-lsp-or-typescript-language-server)))


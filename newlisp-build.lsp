(module "getopts.lsp")

(define (load-file source-file)
  (or (file? source-file) (throw))
  (define loaded-new-file false)
  (letn (file (open source-file "read")
        out-filename (first (exec "mktemp -t newlisp"))
        out-file (open out-filename "write") 
        load-func (fn (f) (and (file? f) (write out-file (read-file f))) (setq loaded-new-file true)))
  (while (read-line file)
   (or
    (find-all {^\(load "(.*)"\)} (current-line) (load-func $1) 0)
    (write-line out-file)))
  (if loaded-new-file 
   (load-file out-filename)
   out-filename)))

(define (link source-file target)
 (let (file (load-file source-file))
  (! (string "newlisp -x " file " " target))
  (! (string "chmod +x " target))))

(shortopt "s" (setq source-file getopts:arg) "file" "")
(shortopt "o" (setq output-file getopts:arg) "file" "")

(getopts (main-args))

(and (nil? source-file) (exit))
(and (nil? output-file) (exit))

(catch (link source-file output-file)) 

(exit)

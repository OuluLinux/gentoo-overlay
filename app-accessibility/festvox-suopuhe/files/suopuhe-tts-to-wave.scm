(load (path-append libdir "init.scm"))
(load "/usr/share/festvox-suopuhe/festival.scm")
(load "/usr/share/festival/voices/finnish/suopuhe.common/hy_fi_mv_diphone.scm")

(define totalnumsamples 0)
(define fp #f)
(define an_utt #f)
(define volume "1.0")
(define frequency #f)
(define output_type 'riff)

(define (save-record-wave utt)
  (let ((samples (get_param 'num_samples (wave.info (utt.wave utt)) 0)))
    (if (eq? totalnumsamples 0)
        (wave.save.header fp (utt.wave utt) output_type nil
                          (list (list "numsamples" 0))))
    (set! totalnumsamples (+ totalnumsamples samples))
    (if (not (equal? volume "1.0"))
        (utt.wave.rescale utt (parse-number volume)))
    (format t "Saving samples ~a, total ~a~%" samples totalnumsamples)
    (wave.save.data.fp (utt.wave utt) fp output_type nil)
    (set! an_utt utt)))

(set! tts_hooks (list utt.synth save-record-wave))

(define (process-file infile output)
  (let ((mode (tts_find_text_mode infile auto-text-mode-alist)))
    (set! fp (fopen output "wb"))
    (set! totalnumsamples 0)
    (set! an_utt #f)
    (tts_file infile mode)
    (fseek fp 0 0)
    (wave.save.header fp (utt.wave an_utt) output_type nil
                      (list (list "numsamples" totalnumsamples)))
    (fclose fp)))

(let ((infile (getenv "SUOPUHE_TEXT_FILE"))
      (outfile (getenv "SUOPUHE_WAVE_FILE")))
  (if (or (null? infile) (null? outfile))
      (begin
        (format stderr "SUOPUHE_TEXT_FILE and SUOPUHE_WAVE_FILE must be set\n")
        (quit 1)))
  (process-file infile outfile))

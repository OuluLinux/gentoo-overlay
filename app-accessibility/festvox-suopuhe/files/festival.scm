 ;; Any site-wide Festival initialization can be added to this file.
 ;; It is marked as a configuration file, so your changes will be saved
 ;; across upgrades of the Festival package.
 ;; siteinit.scm alkaa...
 ;; VOLUME KAAKKOON, FESTIVAL PUHUU SANGEN HILJAA LINUXISSA
 (set! default_after_synth_hooks
            (list
              (lambda (utt)
                (utt.wave.rescale utt 1.0 t))))
 
 ;; 
  (if (probe_file "/usr/share/festival/voices/finnish/suopuhe.common/hy_fi_mv_diphone.scm")
      (begin 
       (load "/usr/share/festival/voices/finnish/suopuhe.common/hy_fi_mv_diphone.scm")
       (set! voice_default 'hy_fi_mv_diphone)))
 ;;; ... siteinit.scm päättyy


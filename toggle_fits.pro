function toggle_fits,fileL,usescale=usescale,lineP=lineP,zoombox=zoombox
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  i = 0l
  nFile = n_elements(fileL)
  while (!mouse.button NE 4) do begin
     fits_display,fileL[i],usescale=usescale,lineP=lineP,zoombox=zoombox
     slot = i

     cursor,xcur,ycur,/normal,/down
     if xcur LT 0.5 then begin
        i = wrap_mod((i - 1l),nfile)
     endif else begin
        i = wrap_mod((i + 1l),nfile)
     endelse

  endwhile
  !MOUSE.button=1
  ;; make sure slot is defined, otherwise it produces an IDl error
  if n_elements(slot) EQ 0 then slot=0 
return,slot

end
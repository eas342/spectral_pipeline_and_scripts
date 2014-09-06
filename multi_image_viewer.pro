pro multi_image_viewer
;; Displays multiple fits files and lets you go between them

actions = ['(q)uit','(r)ead new file',$
           '(o)pen new file w/ browser','set (s)cale',$
           '(t)oggle image mode','(d)raw a line',$
           '(p)lot a line or box','(pm) to plot median',$
           '(ps) to plot and stop',$
          '(b)ox draw mode','(c)lear previous settings',$
          '(l)oad another parameter file.',$
          '(z)oom in']
naction = n_elements(actions)

;; Load in previous preferences, if it finds the right file
cd,current=currentD
FindPref = file_search(currentD+'/ev_local_display_params.sav')
if findPref NE '' then begin
   restore,currentD+'/ev_local_display_params.sav'
   if n_elements(filel) NE 0 then status='nothing' else status = 'r'
endif else status = 'r'

while status NE 'q' and status NE 'Q' do begin
   nfile = n_elements(fileL)
   skipaction = 0
   if n_elements(slot) EQ 0 then slot = nfile-1l
   case 1 of
      status EQ 'r' OR status EQ 'R' OR $
         status EQ 'o' OR status EQ 'O': begin
         if status EQ 'r' OR status EQ 'R' then begin
            print,'Choose a FITS file'
            filen = choose_file(filetype='fits')
         endif else begin
            filen = dialog_pickfile(/read,filter='*.fits')
         endelse
         fits_display,filen,usescale=currentS,lineP=lineP,zoombox=zoombox
         if n_elements(fileL) EQ 0 then begin
            fileL = filen
         endif else fileL = [fileL,filen]
         slot = n_elements(fileL)-1l
      end
      status EQ 's' OR status EQ 'S': begin
         fits_display,filel[slot],/findscale,outscale=CurrentS,lineP=lineP,zoombox=zoombox
      end
      status EQ 't' OR status EQ 'T': begin
         slot = toggle_fits(fileL,usescale=currentS,lineP=lineP,zoombox=zoombox)
      end
      status EQ 'c' OR status EQ 'C': begin
         confirm=''
         print,'Are you sure you want to delete all settings?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,currentS
            undefine,slot
            undefine,lineP
            status = 'r'
            skipaction=1
         endif
      end
      status EQ 'p' OR status EQ 'P': begin
         fits_line_plot,fileL,lineP=lineP,current=slot
      end
      status EQ 'pm' OR status EQ 'PM': begin
         fits_line_plot,fileL,lineP=lineP,current=slot,/median
      end
      status EQ 'ps' OR status EQ 'PS': begin
         fits_line_plot,fileL,lineP=lineP,current=slot,/makestop
      end
      status EQ 'd' OR status EQ 'D': begin
         lineP = fits_line_draw(fileL[slot],useScale=currentS,zoombox=zoombox)
      end
      status EQ 'b' OR status EQ 'B': begin
         lineP = find_click_box(filel[slot],usescale=currentS,$
                               /get_direction,zoombox=zoombox)
      end
      status EQ 'bp' OR status EQ 'Bp': begin
         fits_line_plot,fileL,boxP=boxC,current=slot
      end
      status EQ 'l' OR status EQ 'L': begin
         print,'Choose a parameter file'
         paramfile = choose_file(filetype='sav')
         restore,paramfile
      end
      status EQ 'z' OR status EQ 'Z': begin
         zoomBox = find_click_box(filel[slot],usescale=currentS)
      end
      status EQ 'nothing': begin
      end
      else: print,'Unrecognized Action'
   endcase
   
   print,'Choose an action'
   for i=0l,naction-1l do begin
      print,actions[i]+' ',format='(A,$)'
   endfor
   print,''
   if not skipaction then read,'Action: ',status
;   status = get_kbrd()

endwhile
save,currentS,fileL,slot,lineP,zoomBox,$
     filename='ev_local_display_params.sav'


end
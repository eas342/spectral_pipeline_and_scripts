function fits_line_plot,fileL,lineP=lineP,current=current,$
                        median=median,makestop=makestop,$
                        overplot=overplot,normalize=normalize,$
                        plotp=plotp,peakNorm=peaknorm
;; This plots a line or box depending on input
;; lineP - a structure of line coordinates
;; boxC - a structure of box coordinates
;; median - do a median instead of an average
;; overplot - makes an over-plot
;; normalize - normalize the plot by the median
;; peaknorm - normalize the plot by the peak

nfile = n_elements(filel)
type = size(filel[0],/type)
if n_elements(current) EQ 0 then i=0l else i = current

if n_elements(lineP) EQ 0 then begin
   print,'No line drawn to plot'
   return,i
endif

firsttime = 1
counter=0
maxCounter = 100
while counter LT maxCounter do begin
   slot = i ;; current image slot number
   a = mod_rdfits(fileL[i],0,header,plotp=plotp)

   ;; Get the plot abscissa axis
   if LineP.direction EQ 'x' then begin
      xplot = min(Linep.xcoor) + lindgen(abs(LineP.xcoor[1] - LineP.xcoor[0]))
   endif else begin
      xplot = min(Linep.ycoor) + lindgen(abs(LineP.ycoor[1] - Linep.ycoor[0]))
   endelse
   ;; Get the ordinate axis
;   case 1 of 
;      LineP.type EQ 'line': begin
   if keyword_set(median) then begin
      if LineP.direction EQ 'x' then begin
         yplot = median(a[xplot,LineP.ycoor[0]:LineP.ycoor[1]],dimension=2)
      endif else begin
         yplot = median(a[LineP.xcoor[0]:LineP.xcoor[1],xplot],dimension=1)
      endelse
   endif else begin
      if LineP.direction EQ 'x' then begin
         if LineP.type EQ 'box' then begin
            yplot = total(a[xplot,LineP.ycoor[0]:LineP.ycoor[1]],2)
            yplot = yplot / float(LineP.ycoor[1] - LineP.ycoor[0] + 1l) ;; renormalize for avg
         endif else yplot = a[xplot,LineP.ycoor[0]]
      endif else begin
         yplot = total(a[LineP.xcoor[0]:LineP.xcoor[1],xplot],1)
         yplot = yplot / float(LineP.xcoor[1] - LineP.xcoor[0] + 1l) ;; renormalize for avg
      endelse
   endelse
   if keyword_set(normalize) then begin
      yplot = yplot/median(yplot)
   endif
   if keyword_set(peaknorm) then begin
      yplot = yplot/max(yplot)
   endif

   if counter GT 0 and keyword_set(overplot) then begin
      plottedInd = [plottedInd,i]
      ev_oplot,data,xplot,yplot,gparam=gparam
      newslabel = [gparam.slabel,clobber_dir(filel[i],/exten)]
      ev_undefine_tag,gparam,'slabel'
      gparam = create_struct(gparam,'slabel',newslabel)
      genplot,data,gparam=gparam
   endif else begin
      gparam = create_struct('TITLES',[lineP.direction+ 'coordinate',$
                                       'Counts',''],$
                            'FILENAME',clobber_dir(filel[i],/exten),$
                            'SLABEL',clobber_dir(filel[i],/exten))
      data = struct_arrays(create_struct('X',xplot,'Y',yplot))
      genplot,data,gparam=gparam
;      plot,xplot,yplot,ystyle=16,$
;           title=Ftitle,$
;           xtitle=lineP.direction+' coordinate',psym=10
      plottedInd = i
   endelse
   if keyword_set(makestop) then stop
   if quit_caught() then return,slot

;   cursor,xcur,ycur,/normal;,/down
;   if xcur LT 0.5 then begin
;      i = wrap_mod((i - 1l),nfile)
;   endif else begin
      i = wrap_mod((i + 1l),nfile)
;   endelse
   counter = counter + 1

endwhile
;!Mouse.button=1

return,slot

end

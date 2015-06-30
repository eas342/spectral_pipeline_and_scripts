pro apfind,filen,apsize,plotp=plotp,linep=linep,peak=peak,one=one
;; Finds the aperture(s)
;; peak - finds the peak
;; one - only show the positive aperture spectrum (otherwise it
;;          addes the two)

;; Get the order info
restore,reduction_dir()+'/data/ts4_order_coeff.sav'

;; Take the input box and find a median profile
   a = mod_rdfits(filen,0,header,plotp=plotp)

   ;; Make sure the coordintes are in range
   sz = size(a)
   xcoor = checkrange(LineP.xcoor,0,sz[1]-1l)
   ycoor = checkrange(LineP.ycoor,0,sz[2]-1l)

   ;; Array for the y coordinate
   ArrYcoor = min(ycoor) + lindgen(abs(ycoor[1] - ycoor[0]))
   ;;Get the order of the zoombox
   xcen = mean(xcoor)
   ycen = mean(ycoor)
   profOrd = order_pic(xcen,ycen,ind=profind)
   Ordcen = poly(xcen,oArr.mc[profInd,*]) ;; center of order
   SpatCoor = ArrYCoor - OrdCen

   prof = median(a[xcoor[0]:xcoor[1],ArrYcoor],dimension=1)
   datSt = create_struct('Spat_Coor',SpatCoor,'prof',prof)
   datA = struct_arrays(datSt)

   PosPeak = max(prof,maxInd)
   NegPeak = min(prof,minInd)
   
   ApPos = [SpatCoor[maxInd],SpatCoor[minInd]]
   edat = create_struct('VERTLINES',ApPos)

;   genplot,datA,edat
;   quick_specsum,filen,ap,ApPos[0],plotp=plotp
   ypos = spec_sum(filen,apsize,ApPos[0],plotp=plotp,/showap)
   rough_wavecal,ypos,oArr
   ydat = ypos
   yneg = spec_sum(filen,apsize,ApPos[1],plotp=plotp,/showap)
   rough_wavecal,yneg,oArr

   gparam = create_struct('PKEYS',['WAV','SUM'])
;   shiftYNeg = shift_interp(yneg.sum,-1.7)
   shiftYNeg = yneg.sum
   ev_oplot,ydat,yneg.wav,shiftYneg * (-1E),gparam=gparam

   ev_add_tag,gparam,'SERIES','ORD'

   ycomb = ypos
   ycomb.sum = ypos.sum - shiftYneg

;   genplot,ydat,gparam=gparam
   if keyword_set(peak) then begin
      gparam.pkeys=['WAV','PEAK']
      genplot,ypos,gparam=gparam
   endif else genplot,ycomb,gparam=gparam

end

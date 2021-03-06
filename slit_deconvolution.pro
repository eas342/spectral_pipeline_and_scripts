function slit_deconvolution,arcNar,arcWide,filter=filter,psplot=psplot,$
                       useplainArgon=useplainArgon,showplots=showplots,$
                            deconvstep=deconvstep,outArr=outArr,$
                            NarrSKern=NarrSKern
;; Deconvolves a arc spectra to find the slit function
;; filter - does a low pass filter in Fourier domain
;; psplot - saves a postscript plot
;; useplainArgon - just use the 0.3x60 argon spectrum (don't
;;                 deconvolve it)
;; deconvstep - Terry wanted to see this intermediate step
;; outArr - an optional keyword for the array of the de-convolved
;;          0.3x60 slit image
;; NarrSKern - the kernel used in max likelihood de-convolution of the
;;             0.3x60 arcsecond image

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   plotprenm='fft_deconv_argon_test'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=30, ysize=40,decomposed=1,/color
endif
if keyword_set(showplots) then begin
   !p.multi = [0,0,8]
endif

Np = 2048l
midP = 512
;; Convolved one
;restore,'slit3_arcspec.sav'
convolSD = fltarr(np)
nY = n_elements(arcWide)
convolSD[midP:(midP+nY-1)] = arcWide
sz = size(convolSD)

if keyword_set(showplots) then begin
   plot,convolSD,title='Convolution (3x60)',charsize=2
endif

;; Delta functions
;restore,'nar_slit_arcspec.sav'
;restore,'narrower_slit_arcspec_deconvol.sav'
narArc = fltarr(np)
narArc[midP:(midP+nY-1l)] = arcNar
if keyword_set(showplots) then begin
   plot,narArc,title='Function (0.3x60)',charsize=2
endif


if keyword_set(useplainArgon) then begin
   fulldeltas = narArc
endif else begin
   if n_elements(NarrSkern) EQ 0 then restore,'narrSKern.sav'
   normKern = narrSKern / total(NarrSkern)
   for i=0l,300 do Max_Likelihood, narArc, normkern, Narrdeconv,ft_psf=psf_ft
   fulldeltas = Narrdeconv
   if keyword_set(cutoff) then begin
      thresh = threshold(fulldeltas[where(fulldeltas NE 0E)],low=0.20,high=0.8,mult=0E)
      lowp = where(fulldeltas LT thresh[1])
      if lowp NE [-1] then fulldeltas[lowp] = 0E
   endif

   if keyword_set(showplots) then begin
      plot,fulldeltas,title='De-convolved Argon (0.3x60)',charsize=2
   endif
endelse
;fulldeltas[midP:(midP+nY-1l)] = yplot


;; Shifted Convolved

shiftConvolSD = shift(convolSD,-sz[1]/2)

if keyword_set(showplots) then begin
   plot,shiftConvolSD,title='Shifted Convolution (3x60)',charsize=2
endif


fftconvolSD = fft(shiftConvolSD)/float(sz[1])
if keyword_set(filter) then begin
   filterAmt = 750l
   fftconvolSD[1024-filterAmt:1023+filterAmt] = complex(0E,0E)
endif
if keyword_set(showplots) then begin
   plot,fftconvolSD,title='FFT Shifted Convolution (3x60)',charsize=2
   oplot,imaginary(fftconvolSD),color=mycol('yellow')
endif


fftdeltas = fft(fulldeltas)
if keyword_set(filter) then begin
   fftdeltas[1024-filterAmt:1023+filterAmt] = complex(0E,0E)
endif
if keyword_set(showplots) then begin
   plot,fftdeltas,title='FFT Function (0.3x60)',charsize=2
   oplot,imaginary(fftdeltas),color=mycol('yellow')
endif


nonZ = where(fftDeltas NE 0E)
fftDeconvol = complexarr(sz[1])
if nonz NE [-1] then fftDeconvol[nonz] = fftconvolSD[nonz]/fftDeltas[nonz]

if keyword_set(showplots) then begin
   plot,fftDeconvol,title='FFT Convolution (3x60) / FFT Kernel (0.3x60)',charsize=2
   oplot,imaginary(fftDeconvol),color=mycol('yellow')
endif


deconvol = fft(fftDeconvol,/inverse) * float(sz[1])
if keyword_set(showplots) then begin
   plot,deconvol,title='De-convolution (to get Kernel)',charsize=2
endif


xColumn = fltarr(Np)
xColShort = findgen(n_elements(arcWide)) + 1E
xColumn[midP:(midP+nY-1l)] = xColShort
save,xColumn,convolSD,narArc,fulldeltas,filename='data/deconv_step_data.sav'
;; Save all deconvolution steps
if keyword_set(deconvstep) then begin
   forprint,xColumn,convolSD,narArc,fulldeltas,real_part(deconvol),$
            textout='deconv_steps.txt',$
            comment='Column number in 1 based counting from [65:749,33:617] trim;'+$
            ' Wide Arc Image 3x60; Narrow Arc Image 0.3x60; De-convolved Arc 0.3x60 Image;'+$
            ' Slit Image from De-convolved Wide Arc Image'
   outArr=real_part(fulldeltas)
endif

;save,deconvol,filename='slit_func_estimate.sav'


;plot,fulldeltas,/nodata,yrange=[-.5,1.5],title='Function',charsize=2
;oplot,fulldeltas,color=mycol('red')
;
;;; Test the convolution with FFT
;
;fftconvolSD = fftSquare * fftDeltas
;plot,fftConvolSD,title='FFT Convolution',charsize=2
;oplot,imaginary(fftconvolsd),color=mycol('yellow')
;convolSDshift = fft(fftconvolSD,/inverse) * float(n_elements(square))
;plot,convolSDshift,title='Convolution (shifted by FFT)',charsize=2
;
;
;;oplot,square
if keyword_set(showplots) then begin
   !p.multi = 0
endif

if keyword_set(psplot) then begin
   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
   !p.thick=1
   !x.thick=1
   !y.thick=1
   
endif else begin
   if keyword_set(showplots) then stop
endelse

startp = np/2 - ny/2
return, deconvol[startp:(startp+nY-1l)]

end

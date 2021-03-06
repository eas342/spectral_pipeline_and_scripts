pro miv
;; Displays multiple fits files and lets you go between them
;; data/miv_help.txt has help on the commands

;; Load in previous preferences, if it finds the right file
cd,current=currentD
FindPref = file_search(currentD+'/ev_local_display_params.sav')

;; Make sure there are two windows open - one for plotting and one for
;;                                        images
adjust_pwindow,type='Plot Window'
adjust_pwindow,type='FITS Window'
es_cmd_focus

if findPref NE '' then begin
   restore,currentD+'/ev_local_display_params.sav'
   if n_elements(filel) NE 0 then status='nothing' else status = 'r'
endif else status = 'o'

while status NE 'q' and status NE 'Q' and status NE 'nsq' do begin
   nfile = n_elements(fileL)
   skipaction = 0
   if n_elements(slot) EQ 0 then slot = nfile-1l
   splitStatus = strsplit(status,' ',/extract)
   case 1 of
      status EQ 'r' OR status EQ 'R' OR $
         status EQ 'o' OR status EQ 'O' OR $
         status EQ 'rf' OR status EQ 'RF': begin
         case 1 of
            status EQ 'r' OR status EQ 'R': begin
               print,'Choose a FITS file'
               filen = choose_file(filetype='fits')
            end
            status EQ 'rf' OR status EQ 'RF': begin
               print,'Choose file filter'
               filter=''
               read,filter
               filen = choose_file(filetype=filter)
            end
            else: filen = dialog_pickfile(/read,filter='*.fits',/multiple)
         endcase
         if n_elements(fileL) EQ 0 then begin
            fileL = filen
         endif else fileL = [fileL,filen]
         slot = n_elements(fileL)-1l
         fits_display,fileL[slot],plotp=plotp,lineP=lineP
      end
      status EQ 'rfa' OR status EQ 'RFA': begin
         prevFileL = fileL
         print,'Choose file filter'
         filter=''
         read,filter
         fileL = choose_file(filter=filter,/all)
         if fileL EQ [''] then fileL = prevFileL else begin
            slot = n_elements(fileL)-1l
            fits_display,filel[slot],plotp=plotp,lineP=lineP
         endelse
      end
      splitstatus[0] EQ 'pared': $
         fileL = pare_down(splitstatus,nfile,fileL,slot=slot)
      splitstatus[0] EQ 'ignore': begin
         if n_elements(splitstatus) GE 2 then begin
            ev_add_tag,plotp,'IGNORE_STR',splitstatus[1]
         endif else message,'No string specified',/cont
      end
      splitstatus[0] EQ 'ref': begin
         if n_elements(splitstatus) GT 2 then begin
            pref =splitstatus[2]
         endif else pref=''
         if n_elements(splitstatus) LE 1 then begin
            splitstatus=['ref','1']
         endif
         refresh_fits,long(splitstatus[1]),filel,plotp,linep,slot,/display,$
                      pref=pref
      end
      status EQ 's' OR status EQ 'S': begin
         fits_display,filel[slot],/findscale,plotp=plotp,lineP=lineP
      end
      status EQ 'fedit' OR status EQ 'FEDIT': begin
         fedit,filel,plotp=plotp
      end
      status EQ 'aedit' OR status EQ 'AEDIT': begin
         fedit,filel,plotp=plotp,/action
      end
      status EQ 'fread' OR status EQ 'FREAD': begin
         readcol,'ev_local_display_filelist.txt',filel,format='(A)'
         if slot GT n_elements(filel) -1l then slot=0
      end
      status EQ 't' OR status EQ 'T': begin
         toggle_fits,fileL,plotp=plotp,lineP=lineP,slot=slot
      end
      splitstatus[0] EQ 'cindex' OR splitstatus[0] EQ 'CINDEX': begin
         if n_elements(splitstatus) LE 1 then cindex = 0 else begin
            if valid_num(splitstatus[1]) then begin
               cindex = long(checkrange(splitstatus[1],0,n_elements(filel)-1))
            endif else begin
               cindex=0
            endelse
         endelse
         slot = checkrange(cindex,0,nfile)
      end
      status EQ 'save' OR status EQ 'SAVE': begin
         save_image,fileL,plotp=plotp,lineP=lineP,startslot=slot
      end
      status EQ 'asave' OR status EQ 'ASAVE': begin
         for i=0l,n_elements(fileL)-1l do begin
            save_image,fileL,plotp=plotp,lineP=lineP,$
                       startslot=i
         endfor
      end
      status EQ 'ashift' OR status EQ 'ASHIFT': begin
         arrow_shift,filel,plotp=plotp,linep=linep,slot=slot
      end
      status EQ 'nodsub' Or status EQ 'NODSUB': $
         nodsub,filel,plotp,lineP,slot
      status EQ 'maskedit' OR status EQ 'MASKEDIT': $
         maskedit,filel[slot],lineP,plotp
      status EQ 'imcombine' OR status EQ 'IMCOMBINE': $
         imcombine,'action_list.txt',/median,plotp=plotp,linep=linep
      status EQ 'nimcombine' OR status EQ 'NIMCOMBINE': $
         imcombine,'action_list.txt',/median,plotp=plotp,/normalize,linep=linep
      status EQ 'sparam' OR status EQ 'SPARAM': check_idlsave,fileL,slot,lineP,plotp,$
         varnames=['fileL','slot','lineP','plotp']
      status EQ 'c' OR status EQ 'C': begin
         confirm=''
         print,'Are you sure you want to delete all settings?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,slot
            undefine,lineP
            undefine,plotp
            status = 'o'
            skipaction=1
         endif
      end
      status EQ 'cf' OR status EQ 'CF': begin
         confirm=''
         print,'Are you sure you want to clear all file lists?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,slot
            status = 'o'
            skipaction=1
         endif
      end
      status EQ 'cfolder' OR status EQ 'CFOLDER': begin
         spawn,'open .'
      end
      status EQ 'p' OR status EQ 'P': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,plotp=plotp)
      end
      status EQ 'op' OR status EQ 'OP': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,plotp=plotp)
      end
      status EQ 'opd' OR status EQ 'OPD': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,$
                               /normalize,plotp=plotp)
      end
      status EQ 'opp' OR status EQ 'OPP': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,$
                               /peaknorm,plotp=plotp)
      end
      status EQ 'pm' OR status EQ 'PM': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/median,plotp=plotp)
      end
      status EQ 'ps' OR status EQ 'PS': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/makestop,plotp=plotp)
      end
      status EQ 'd' OR status EQ 'D': begin
         lineP = fits_line_draw(fileL[slot],plotp=plotp)
      end
      status EQ 'b' OR status EQ 'B': begin
         lineP = find_click_box(filel[slot],plotp=plotp,$
                               /get_direction)
      end
      status EQ 'eLine': begin
         choose_linep,lineP
      end
      status EQ 'bp' OR status EQ 'Bp': begin
         slot = fits_line_plot(fileL,boxP=boxC,current=slot)
      end
      status EQ 'l' OR status EQ 'L': begin
         print,'Choose a parameter file'
         paramfile = choose_file(filetype='sav')
         restore,paramfile
      end
      status EQ 'z' OR status EQ 'Z': begin
         get_zoom,filel[slot],plotp=plotp,/restart
      end
      status EQ 'st' OR status EQ 'ST': begin
         ev_add_tag,plotp,'STRETCH',1
      end
      status EQ 'unst' OR status EQ 'UNST': begin
         ev_add_tag,plotp,'STRETCH',0
      end
      status EQ 'zz' OR status EQ 'ZZ': begin
         get_zoom,filel[slot],plotp=plotp
      end
      status EQ 'rzoom' OR status EQ 'RZOOM': begin
         get_zoom,filel[slot],plotp=plotp,/rzoom
      end
      status EQ 'jwsub' OR status EQ 'JWSUB': begin
         ev_add_tag,plotp,'JWSUB',1
      end
      status EQ 'lris' OR status EQ 'LRIS': begin
         ev_add_tag,plotp,'LRIS',1
      end
      status EQ 'qjwsub' OR status EQ 'qJWSUB': begin
         ev_add_tag,plotp,'JWSUB',0
      end
      status EQ 'rot' OR status EQ 'ROT': begin
         get_rotation,filel[slot],plotp=plotp,linep=linep
      end
      status EQ 'fullscale' OR status EQ 'FULLSCALE':begin
         ev_add_tag,plotp,'FULLSCALE',1
         fits_display,filel[slot],linep=linep,plotp=plotp
      end
      status EQ 'nothing': begin
      end
      status EQ 'h' OR status EQ 'H': begin
         miv_help
      end
      status EQ 'head' OR status EQ 'HEAD': begin
         if ev_tag_exist(plotp,'CHOOSEEXTEN') then begin
            showhead,fileL[slot],ext=plotp.chooseexten
         endif else showhead,fileL[slot]
      end
      status EQ 'ckey' OR status EQ 'CKEY': $
         choose_key,fileL[slot],plotp
      status EQ 'keyedit' OR status EQ 'KEYEDIT': $
         if ev_tag_exist(plotp,'KEYDISP') then $
            fedit,plotp.keydisp,custnm='keyword_list.txt'
      status EQ 'keyread' OR status EQ 'KEYREAD': begin
         readcol,'keyword_list.txt',quickkey,format='(A)'
         ev_add_tag,plotp,'KEYDISP',quickkey
      end
      status EQ 'dispkey' OR status EQ 'DISPKEY': $
         choose_key,fileL[slot],plotp,insertkey='PLOTFKEY'
      status EQ 'qdispkey' OR status EQ 'QDISPKEY': $
         ev_undefine_tag,plotp,'PLOTFKEY'
      status EQ 'titlekey' OR status EQ 'TITLEKEY': $
         choose_key,fileL[slot],plotp,insertkey='IMGTITLEKEY'
      status EQ 'qtitlekey' OR status EQ 'QTITLEKEY': $
         ev_undefine_tag,plotp,'IMGTITLEKEY'
      status EQ 'bsize' OR status EQ 'BSIZE': begin
         choose_bsize,plotp
      end
      status EQ 'fitpsf' OR status EQ 'FITPSF': begin
         fit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'mfit' OR status EQ 'MFIT': begin
         multi_fit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'sphot' OR status EQ 'SPHOT': begin
         save_phot
      end
      status EQ 'stser' OR status EQ 'STSER': begin 
          save_phot,/tser
      end
      status EQ 'tser' OR status EQ 'TSER': begin
         make_tser,/norm
         photfile = 'ev_phot_data_tser.sav'
         if file_exists(photfile) then restore,photfile
         adjust_pwindow,type='Plot Window'
         genplot,otdat,plotp=plotp
         adjust_pwindow,type='FITS Window'
      end
      status[0] EQ 'addphotkey' or status[0] EQ 'ADDPHOTKEY': begin
         add_to_tser
      end
      status[0] EQ 'silentphot' OR status[0] EQ 'SILENTPHOT': begin
         ev_add_tag,plotp,'SILENTPHOT',1
      end
      status[0] EQ 'listphot' OR status[0] EQ 'LISTPHOT': begin
         ev_add_tag,plotp,'SILENTPHOT',0
      end
      status EQ 'tserprev' OR status EQ 'TSERPREV': begin
         photfile = 'ev_phot_data_tser.sav'
         if file_exists(photfile) then restore,photfile
         plotparamfile = 'ev_local_pparams.sav'
         if file_exists(plotparamfile) then restore,plotparamfile
         adjust_pwindow,type='Plot Window'
         genplot,otdat,plotp=plotp,gparam=gparam
         adjust_pwindow,type='FITS Window'
      end
      status EQ 'qfoc' OR status EQ 'QFOC': begin
         quick_foc,filel,plotp,linep,slot
      end
      status EQ 'ts4foc' OR status EQ 'TS4FOC': begin
         quick_foc,filel,plotp,linep,slot,/nopwidg
      end
      status EQ 'refit' OR status EQ 'REFIT': begin
         refit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'redophot' OR status EQ 'REDOPHOT': begin
         refit_psf,fileL,lineP,plotp=plotp,/redo
      end
      status EQ 'allfit' OR status EQ 'ALLFIT': begin
         refit_psf,fileL,LineP,plotp=plotp
      end
      status EQ 'cphot' OR status EQ 'CPHOT': clear_phot
      status EQ 'showphot': ev_add_tag,plotp,'SHOWPHOT',1
      status EQ 'qshowphot': ev_add_tag,plotp,'SHOWPHOT',0
      status EQ 'boxstat' OR status EQ 'BOXSTAT': begin
         box_stats,fileL[slot],lineP=lineP,plotp=plotp
      end
      status EQ 'allbox' OR status EQ 'ALLBOX': begin
         allbox,fileL,lineP=lineP,plotp=plotp
      end
      status EQ 'boxtser' OR status EQ 'BOXTSER': begin
         box_tser,plotp=plotp
      end
      status[0] EQ 'clearbox' OR status EQ 'CLEARBOX': begin
           file_move,'es_box_stats.sav','es_box_stats_backup.sav',/overwrite
      end
      status EQ 'bsub' OR status EQ 'BSUB': begin
         fileL[slot] = fits_backsub(fileL[slot],lineP=lineP,plotp=plotp)
      end
      splitstatus[0] EQ 'qspec' OR splitstatus[0] EQ 'QSPEC': begin
         if n_elements(splitstatus) GE 3 then begin
            if valid_num(splitstatus[1]) and $
               valid_num(splitstatus[2]) then begin
               quick_specsum,filel[slot],float(splitstatus[1]),$
                             float(splitstatus[2]),plotp=plotp
            endif else begin
               message,'Invalid qspec parameters specified',/cont
            endelse
         endif else begin
            message,'Not enough qspec parameters specified',/cont
         endelse
      end
      splitstatus[0] EQ 'dospec' OR splitstatus[0] EQ 'DOSPEC': begin
         if n_elements(splitstatus) LT 2 then doap=7.0 else doap=float(splitstatus[1])
         spec_from_ap,filel[slot],doap,$
                      plotp=plotp,linep=linep
      end
      splitstatus[0] EQ 'calspec' OR splitstatus[0] EQ 'CALSPEC': begin
         if n_elements(splitstatus) LT 2 then doap=7.0 else doap=float(splitstatus[1])
         spec_from_ap,filel[slot],doap,$
                      plotp=plotp,linep=linep,/savecal
      end
      splitstatus[0] EQ 'pspec' OR splitstatus[0] EQ 'PSPEC': begin
         if n_elements(splitstatus) LT 2 then doap=7.0 else doap=float(splitstatus[1])
         spec_from_ap,filel[slot],doap,$
                      plotp=plotp,linep=linep,/peak
      end
      status EQ 'cflat' OR status EQ 'CFLAT': begin
         choose_flat,plotp
      end
      status EQ 'qflat' OR status EQ 'QFLAT': begin
         ev_undefine_tag,plotp,'FLATFILE'
      end
      status EQ 'cbias' OR status EQ 'CFLAT': begin
         choose_bias,plotp
      end
      status EQ 'qbias' OR status EQ 'QFLAT': begin
         ev_undefine_tag,plotp,'BIASFILE'
      end
      status EQ 'DCSsub' OR status EQ 'dcssub': begin
         ev_add_tag,plotp,'DCSSUB',1
      end
      status EQ 'qDCS' OR status EQ 'qdcs': begin
         ev_add_tag,plotp,'DCSSUB',0
      end
      status[0] EQ 'savedcs' OR status EQ 'SAVEDCS': begin
         save_dcs,filel,plotp=plotp,linep=linep,slot=slot
      end
      status[0] EQ 'asavedcs' OR status EQ 'ASAVEDCS': begin
         for i=0l,n_elements(fileL)-1l do begin
            save_dcs,fileL,plotp=plotp,lineP=lineP,slot=i
         endfor
      end
      splitstatus[0] EQ 'cplane' OR status EQ 'CPLANE': begin
         if n_elements(splitstatus) GE 2 then begin
            if valid_num(splitstatus[1]) then begin
               ev_add_tag,plotp,'ChoosePlane',long(splitstatus[1])
            endif else begin
               message,'Invalid plane specified.',/cont
            endelse
         endif else message,'No plane specified',/cont
      end
      splitstatus[0] EQ 'cexten' OR status EQ 'CEXTEN': begin
         if n_elements(splitstatus) GE 2 then begin
            if valid_num(splitstatus[1]) then begin
               ev_add_tag,plotp,'ChooseExten',long(splitstatus[1])
            endif else begin
               message,'Invalid extension specified.',/cont
            endelse
         endif else message,'No extension specified',/cont
      end
      splitstatus[0] EQ 'qexten': begin
         ev_undefine_tag,plotp,'ChooseExten'
      end
      splitstatus[0] EQ 'qplane': begin
         ev_undefine_tag,plotp,'ChoosePlane'
      end
      else: print,'Unrecognized Action'
   endcase
   
   print,'Choose an action or press (h) for help on actions'
   if not skipaction then read,'Action: ',status
;   status = get_kbrd()

endwhile

if status EQ 'q' or status EQ 'Q' then begin
   save,fileL,slot,lineP,plotp,$
        filename='ev_local_display_params.sav'
   
   if n_elements(plotp) GT 0 then ev_add_tag,allParams,'plotp',plotp
   if n_elements(lineP) GT 0 then ev_add_tag,allParams,'lineP',lineP
   if n_elements(slot) GT 0 then ev_add_tag,allParams,'slot',slot
   if n_elements(fileL) GT 0 then ev_add_tag,allParams,'filel',fileL
   openw,1,'ev_local_display_params.json'
   if float(!Version.Release) GE 8.5 then begin
      printf,1,allParams,/implied_print
   endif else begin
      printf,1,allParams
   endelse
   close,1
endif

end

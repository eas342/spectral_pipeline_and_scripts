pro choose_key,filen,plotp
  keypar = ''
  temphead = headfits(filen)
  nkeys = n_elements(temphead)
  for i=0l,nkeys-1l do begin
     print,nkeys-1l - i,temphead[nkeys-1l - i],format='(I03," ",A70)'
  endfor
  print,'Choose a FITS keyword to print'
  read,keypar
  newKey = strtrim(gettok(temphead[keypar],'='),1)
  if ev_tag_exist(plotp,'KEYDISP') then begin
     if total(strmatch(plotp.keyDisp,newKey)) EQ 0 then begin
        fullkey = [plotp.keyDisp,newKey]
     endif else begin
        print,'Tag already chosen!'
        fullkey = plotp.keydisp
     endelse
  endif else fullkey=newkey

  ev_add_tag,plotp,'KEYDISP',fullKey
end


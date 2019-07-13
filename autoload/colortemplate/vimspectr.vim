" Generate Vimspectr palettes
" See: https://github.com/nightsense/vimspectr
" See: https://gist.github.com/nightsense/2dd5403cb53891e9ec1c337b0989ff9b

fun! s:vimspectr_getlumi(hue, sat, val)
  let [l:r, l:g, l:b] = map(colortemplate#colorspace#hsv2rgb(a:hue, a:sat, a:val, 1),
        \                   { _,v -> pow(((v + 0.055) / 1.055), 2.4) })
  return 0.2126 * l:r + 0.7152 * l:g + 0.0722 * l:b
endf

fun! s:vimspectr_find_val1(hue, sat, base, ratio_threshold)
  let l:valint = 100
  while 1
    let l:valint -= 1
    let l:val = l:valint / 100.0
    let l:lumi = s:vimspectr_getlumi(a:hue, a:sat, l:val)
    if (a:base + 0.05) / (l:lumi + 0.05) > a:ratio_threshold
      let l:hexi = colortemplate#colorspace#hsv2hex(a:hue, a:sat, l:val)
      return [l:hexi, l:lumi]
    endif
  endwhile
endf

fun! s:vimspectr_find_val2(hue, sat, base, ratio_threshold)
  let l:valint = 0
  while 1
    let l:valint += 1
    let l:val = l:valint / 100.0
    let l:lumi = s:vimspectr_getlumi(a:hue, a:sat, l:val)
    if (l:lumi + 0.05) / (a:base + 0.05) > a:ratio_threshold
      let l:hexi = colortemplate#colorspace#hsv2hex(a:hue, a:sat, l:val)
      return [l:hexi, l:lumi]
    endif
  endwhile
endf

" satline: 'gray', 'flat', 'wflat', 'curve', 'wcurve'
" hue: integer in [0,359]
fun! colortemplate#vimspectr#palette(satline, hue)
  let l:hue = float2nr(a:hue) / 360.0

  if a:satline ==# 'grey'
    let l:sat = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    let l:b7 = colortemplate#colorspace#hsv2hex(l:hue, l:sat[7], 1.0)
    let l:b7_lum = s:vimspectr_getlumi(l:hue, l:sat[7], 1.0)
    let [l:b0, l:b0_lum] = s:vimspectr_find_val1(l:hue, l:sat[0], l:b7_lum, 17.5)
  elseif a:satline ==# 'flat'
    let l:sat = [0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833]
    let l:b7_lum = s:vimspectr_getlumi(l:hue, l:sat[7], 1.0)
    let l:b7 = colortemplate#colorspace#hsv2hex(l:hue, l:sat[7], 1.0)
    let [l:b0, l:b0_lum] = s:vimspectr_find_val1(l:hue, l:sat[0], l:b7_lum, 16.0)
  elseif a:satline ==# 'wflat'
    let l:sat = [0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0417, 0.0]
    let l:b7_lum = s:vimspectr_getlumi(l:hue, l:sat[7], 1.0)
    let l:b7 = colortemplate#colorspace#hsv2hex(l:hue, l:sat[7], 1.0)
    let [l:b0, l:b0_lum] = s:vimspectr_find_val1(l:hue, l:sat[0], l:b7_lum, 17.5)
  elseif a:satline ==# 'curve'
    let l:sat = [0.4167, 0.3333, 0.25, 0.2083, 0.125, 0.0833, 0.0833, 0.0833]
    let l:b7_lum = s:vimspectr_getlumi(l:hue, l:sat[7], 1.0)
    let l:b7 = colortemplate#colorspace#hsv2hex(l:hue, l:sat[7], 1.0)
    let [l:b0, l:b0_lum] = s:vimspectr_find_val1(l:hue, l:sat[0], l:b7_lum, 16.0)
  elseif a:satline ==# 'wcurve'
    let l:sat = [0.4167, 0.3333, 0.25, 0.2083, 0.125, 0.0833, 0.0417, 0.0]
    let l:b7_lum = s:vimspectr_getlumi(l:hue, l:sat[7], 1.0)
    let l:b7 = colortemplate#colorspace#hsv2hex(l:hue, l:sat[7], 1.0)
    let [l:b0, l:b0_lum] = s:vimspectr_find_val1(l:hue, l:sat[0], l:b7_lum, 17.5)
  else
    throw '[Colortemplate] Invalid value: ' . string(a:satline)
  endif

  let [l:b6, l:b6_lum] = s:vimspectr_find_val1(l:hue, l:sat[6], l:b7_lum, 1.17)
  let [l:b4, l:b4_lum] = s:vimspectr_find_val1(l:hue, l:sat[4], l:b7_lum, 3.25)
  let [l:b2, l:b2_lum] = s:vimspectr_find_val1(l:hue, l:sat[2], l:b7_lum, 5.5)
  let [l:b1, l:b1_lum] = s:vimspectr_find_val2(l:hue, l:sat[1], l:b0_lum, 1.17)
  let [l:b3, l:b3_lum] = s:vimspectr_find_val2(l:hue, l:sat[3], l:b0_lum, 3.25)
  let [l:b5, l:b5_lum] = s:vimspectr_find_val2(l:hue, l:sat[5], l:b0_lum, 5.5)

  return {'g0': l:b0, 'g1': l:b1, 'g2': l:b2, 'g3': l:b3, 'g4': l:b4, 'g5': l:b5, 'g6': l:b6, 'g7': l:b7}
endf

" vim: foldmethod=marker nowrap et ts=2 sw=2

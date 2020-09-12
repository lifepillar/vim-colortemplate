" Courtesy of Pathogen
function! s:slash() abort
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction

fun! s:hex2rgb(col)
  return a:col =~# '^#'
        \ ? [str2nr(a:col[1:2],16), str2nr(a:col[3:4],16), str2nr(a:col[5:6],16)]
        \ : [str2nr(a:col[0:1],16), str2nr(a:col[2:3],16), str2nr(a:col[4:5],16)]
endf

fun! s:rgb2hex(r, g, b)
  return printf('#%02x%02x%02x', a:r, a:g, a:b)
endf

" Convert a hexadecimal color string into a three-elements list of RGB values.
"
" Example: call colortemplate#colorspace#hex2rgb('#ffffff') -> [255,255,255]
"
" Note: the leading '#' may be omitted.
fun! colortemplate#colorspace#hex2rgb(col)
  return s:hex2rgb(a:col)
endf

" Convert an RGB color into the equivalent hexadecimal string.
"
" Example: call colortemplate#colorspace#rgb2hex(255,255,255) -> '#ffffff'
fun! colortemplate#colorspace#rgb2hex(r, g, b)
  return s:rgb2hex(a:r, a:g, a:b)
endf

" Convert an RGB color (in 0-255) into a gray shade (0-1)
" See: https://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
fun! colortemplate#colorspace#color2gray(r, g, b)
  let l:y = colortemplate#colorspace#relative_luminance(a:r, a:g, a:b)
  return l:y <= 0.0031308 ? 12.92 * l:y : 1.055 * pow(l:y, 0.4167) - 0.055
endf

" Convert a hex color into a gray shade in 0-255.
" See: https://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
fun! colortemplate#colorspace#hex2gray(col)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(a:col)
  return float2nr(round(255 * colortemplate#colorspace#color2gray(l:r, l:g, l:b)))
endf

" Convert an HSV color into RGB space.
" Input values must be in the interval [0,1]
" See: http://www.easyrgb.com/en/math.php
" Last optional parameter may be 1 or 256 (default is 256)
fun! colortemplate#colorspace#hsv2rgb(h, s, v, ...)
  " Force values to be interpreted as floats
  let l:h = a:h / 1.0
  let l:s = a:s / 1.0
  let l:v = a:v / 1.0
  if l:s == 0.0
    return a:0 > 0 && a:1 == 1
          \ ? [l:v, l:v, l:v]
          \ : map([l:v, l:v, l:v], { _,v -> float2nr(round(255 * v)) })
  endif
  let l:var_h = l:h * 6.0
  if l:var_h >= 6.0
    let l:var_h = 0.0
  endif
  let l:var_i = floor(l:var_h)
  let l:var_1 = l:v * (1.0 - l:s)
  let l:var_2 = l:v * (1.0 - l:s * (l:var_h - l:var_i))
  let l:var_3 = l:v * (1.0 - l:s * (1.0 - (l:var_h - l:var_i)))
  if l:var_i == 0.0
    let l:var_r = l:v
    let l:var_g = l:var_3
    let l:var_b = l:var_1
  elseif l:var_i == 1.0
    let l:var_r = l:var_2
    let l:var_g = l:v
    let l:var_b = l:var_1
  elseif l:var_i == 2.0
    let l:var_r = l:var_1
    let l:var_g = l:v
    let l:var_b = l:var_3
  elseif l:var_i == 3.0
    let l:var_r = l:var_1
    let l:var_g = l:var_2
    let l:var_b = l:v
  elseif l:var_i == 4.0
    let l:var_r = l:var_3
    let l:var_g = l:var_1
    let l:var_b = l:v
  else
    let l:var_r = l:v
    let l:var_g = l:var_1
    let l:var_b = l:var_2
  endif
  return a:0 > 0 && a:1 == 1
        \ ? [l:var_r, l:var_g, l:var_b]
        \ : map([l:var_r, l:var_g, l:var_b], { _,v -> float2nr(round(255 * v)) })
endf

fun! colortemplate#colorspace#hsv2hex(h, s, v)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hsv2rgb(a:h, a:s, a:v, 256)
  return colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
endf

" Without arguments, returns a Dictionary of the color names from $VIMRUNTIME/rgb.txt
" (converted to all lowercase), with the associated hex values.
" If an argument is given, returns the hex value of the specified color name.
fun! colortemplate#colorspace#rgbname2hex(...) abort
  if !exists('s:rgb_colors')
    let s:rgb_colors = {}
    " Add some color names not in rgb.txt (see syntax.c for the values)
    let s:rgb_colors['darkyellow']   = '#af5f00' " 130
    let s:rgb_colors['lightmagenta'] = '#ffd7ff' " 225
    let s:rgb_colors['lightred']     = '#ffd7d7' " 224
    let l:rgb = readfile($VIMRUNTIME . s:slash() . 'rgb.txt')
    for l:line in l:rgb
      let l:match = matchlist(l:line, '^\s*\(\d\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)$')
      if len(l:match) > 4
        let [l:name, l:r, l:g, l:b] = [l:match[4], str2nr(l:match[1]), str2nr(l:match[2]), str2nr(l:match[3])]
        let s:rgb_colors[tolower(l:name)] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
      endif
    endfor
  endif
  if a:0 > 0
    if has_key(s:rgb_colors, tolower(a:1))
      return s:rgb_colors[tolower(a:1)]
    else
      throw 'Unknown RGB color name: ' . a:1
    endif
  endif
  return s:rgb_colors
endf

" See:
" https://en.wikipedia.org/wiki/Relative_luminance
" https://www.w3.org/TR/WCAG20-TECHS/G18.html
fun! colortemplate#colorspace#relative_luminance(sR, sG, sB)
  let var_R = (a:sR / 255.0)
  let var_G = (a:sG / 255.0)
  let var_B = (a:sB / 255.0)

  if var_R > 0.04045
    let var_R = pow((var_R + 0.055) / 1.055, 2.4)
  else
    let var_R = var_R / 12.92
  endif
  if var_G > 0.04045
    let var_G = pow((var_G + 0.055) / 1.055, 2.4)
  else
    let var_G = var_G / 12.92
  endif
  if var_B > 0.04045
    let var_B = pow((var_B + 0.055) / 1.055, 2.4)
  else
    let var_B = var_B / 12.92
  endif

  return 0.2126 * var_R + 0.7152 * var_G + 0.0722 * var_B
endf

" Arguments must be hex colors (strings) or RGB values as 3-element lists.
fun! colortemplate#colorspace#contrast_ratio(col1, col2)
  let [l:sR1, l:sG1, l:sB1] = type(a:col1) == v:t_string ? s:hex2rgb(a:col1) : a:col1
  let [l:sR2, l:sG2, l:sB2] = type(a:col2) == v:t_string ? s:hex2rgb(a:col2) : a:col2
  let L1 = colortemplate#colorspace#relative_luminance(l:sR1, l:sG1, l:sB1)
  let L2 = colortemplate#colorspace#relative_luminance(l:sR2, l:sG2, l:sB2)
  return L1 > L2 ? (L1 + 0.05) / (L2 + 0.05) : (L2 + 0.05) / (L1 + 0.05)
endf

" Returns a matrix of contrast ratio values, comparing all colors among
" themselves.
"
" colors: a List of colors

" Colors may be hex colors (strings) or RGB values as 3-element lists.
fun! colortemplate#colorspace#contrast_matrix(colors)
  let l:M = []
  let l:range = range(len(a:colors))
  for l:i in l:range
    call add(l:M, [])
    for l:j in l:range
      call add(l:M[l:i], colortemplate#colorspace#contrast_ratio(a:colors[l:i], a:colors[l:j]))
    endfor
  endfor
  return l:M
endf

" Arguments must be hex colors (strings) or RGB values as 3-element lists.
" See also: https://www.w3.org/TR/AERT/#color-contrast
fun! colortemplate#colorspace#color_difference(col1, col2)
  let [l:sR1, l:sG1, l:sB1] = type(a:col1) == v:t_string ? s:hex2rgb(a:col1) : a:col1
  let [l:sR2, l:sG2, l:sB2] = type(a:col2) == v:t_string ? s:hex2rgb(a:col2) : a:col2
  return abs(l:sR1 - l:sR2) + abs(l:sG1 - l:sG2) + abs(l:sB1 - l:sB2)
endf

" Colors may be hex colors (strings) or RGB values as 3-element lists.
fun! colortemplate#colorspace#coldiff_matrix(colors)
  let l:M = []
  let l:range = range(len(a:colors))
  for l:i in l:range
    call add(l:M, [])
    for l:j in l:range
      call add(l:M[l:i], colortemplate#colorspace#color_difference(a:colors[l:i], a:colors[l:j]))
    endfor
  endfor
  return l:M
endf

" Arguments must be hex colors (strings) or RGB values as 3-element lists.
fun! colortemplate#colorspace#brightness_diff(col1, col2)
  let [l:sR1, l:sG1, l:sB1] = type(a:col1) == v:t_string ? s:hex2rgb(a:col1) : a:col1
  let [l:sR2, l:sG2, l:sB2] = type(a:col2) == v:t_string ? s:hex2rgb(a:col2) : a:col2
  " return ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
  return abs(((l:sR1 * 299.0 + l:sG1 * 587.0 + l:sB1 * 114.0) / 1000.0) - ((l:sR2 * 299.0 + l:sG2 * 587.0 + l:sB2 * 114.0) / 1000.0))
endf

" Colors may be hex colors (strings) or RGB values as 3-element lists.
fun! colortemplate#colorspace#brightness_diff_matrix(colors)
  let l:M = []
  let l:range = range(len(a:colors))
  for l:i in l:range
    call add(l:M, [])
    for l:j in l:range
      call add(l:M[l:i], colortemplate#colorspace#brightness_diff(a:colors[l:i], a:colors[l:j]))
    endfor
  endfor
  return l:M
endf

" XYZ (Tristimulus) Reference values of a perfect reflecting diffuser
" (Values from http://www.easyrgb.com/en/math.php)
" See also: https://en.wikipedia.org/wiki/Standard_illuminant
"
"   Observer     2° (CIE 1931)      |    10° (CIE 1964)      Note
" Illuminant X2      Y2      Z2      X10     Y10     Z10
" A          109.850 100.000 35.585  111.144 100.000 35.200  Incandescent/tungsten
" B          99.0927 100.000 85.313  99.178; 100.000 84.3493 Old direct sunlight at noon
" C          98.074  100.000 118.232 97.285  100.000 116.145 Old daylight
" D50        96.422  100.000 82.521  96.720  100.000 81.427  ICC profile PCS
" D55        95.682  100.000 92.149  95.799  100.000 90.926  Mid-morning daylight
" D65        95.047  100.000 108.883 94.811  100.000 107.304 Daylight, sRGB, Adobe-RGB
" D75        94.972  100.000 122.638 94.416  100.000 120.641 North sky daylight
" E          100.000 100.000 100.000 100.000 100.000 100.000 Equal energy
" F1         92.834  100.000 103.665 94.791  100.000 103.191 Daylight Fluorescent
" F2         99.187  100.000 67.395  103.280 100.000 69.026  Cool fluorescent
" F3         103.754 100.000 49.861  108.968 100.000 51.965  White Fluorescent
" F4         109.147 100.000 38.813  114.961 100.000 40.963  Warm White Fluorescent
" F5         90.872  100.000 98.723  93.369  100.000 98.636  Daylight Fluorescent
" F6         97.309  100.000 60.191  102.148 100.000 62.074  Lite White Fluorescent
" F7         95.044  100.000 108.755 95.792  100.000 107.687 Daylight fluorescent, D65 simulator
" F8         96.413  100.000 82.333  97.115  100.000 81.135  Sylvania F40, D50 simulator
" F9         100.365 100.000 67.868  102.116 100.000 67.826  Cool White Fluorescent
" F10        96.174  100.000 81.712  99.001  100.000 83.134  Ultralume 50, Philips TL85
" F11        100.966 100.000 64.370  103.866 100.000 65.627  Ultralume 40, Philips TL84
" F12        108.046 100.000 39.228  111.428 100.000 40.353  Ultralume 30, Philips TL83

" See: http://www.easyrgb.com/en/math.php
" sR, sG and sB (Standard RGB) input range = 0 ÷ 255
" X, Y and Z output refer to a D65/2° standard illuminant.
fun! colortemplate#colorspace#srgb2xyz(sR, sG, sB)
  let var_R = (a:sR / 255.0)
  let var_G = (a:sG / 255.0)
  let var_B = (a:sB / 255.0)

  if var_R > 0.04045
    let var_R = pow((var_R + 0.055) / 1.055, 2.4)
  else
    let var_R = var_R / 12.92
  endif
  if var_G > 0.04045
    let var_G = pow((var_G + 0.055) / 1.055, 2.4)
  else
    let var_G = var_G / 12.92
  endif
  if var_B > 0.04045
    let var_B = pow((var_B + 0.055) / 1.055, 2.4)
  else
    let var_B = var_B / 12.92
  endif

  let var_R = var_R * 100.0
  let var_G = var_G * 100.0
  let var_B = var_B * 100.0
  let X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
  let Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
  let Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505
  return [X, Y, Z]
endf

fun! colortemplate#colorspace#xyz_to_cielab(X,Y,Z)
  " ref_X, ref_Y and ref_Z refer to specific illuminants and observers:
  " Observer=2°, Illuminant=D65
  let ref_X = 95.047
  let ref_Y = 100.0
  let ref_Z = 108.883
  let var_X = a:X / ref_X
  let var_Y = a:Y / ref_Y
  let var_Z = a:Z / ref_Z

  if var_X > 0.008856
    let var_X = pow(var_X, 1.0 / 3.0)
  else
    let var_X = (7.787 * var_X) + (16.0 / 116.0)
  endif
  if var_Y > 0.008856
    let var_Y = pow(var_Y, 1.0 / 3.0)
  else
    let var_Y = (7.787 * var_Y) + (16.0 / 116.0)
  endif
  if var_Z > 0.008856
    let var_Z = pow(var_Z, 1.0 / 3.0)
  else
    let var_Z = (7.787 * var_Z) + (16.0 / 116.0)
  endif
  let L =  (116.0 * var_Y) - 16.0
  let a = 500.0 * (var_X - var_Y)
  let b = 200.0 * (var_Y - var_Z)
  return [L, a, b]
endf

fun! colortemplate#colorspace#hex2cielab(hexvalue)
  let [r, g, b] = colortemplate#colorspace#hex2rgb(a:hexvalue)
  let [x, y, z] = colortemplate#colorspace#srgb2xyz(r, g, b)
  return colortemplate#colorspace#xyz_to_cielab(x, y, z)
endf

fun! colortemplate#colorspace#rgb2cielab(r, g, b)
  let [x, y, z] = colortemplate#colorspace#srgb2xyz(a:r, a:g, a:b)
  return colortemplate#colorspace#xyz_to_cielab(x, y, z)
endf

fun! s:DegToRad(degrees)
  return a:degrees * 3.14159265359 / 180.0
endf

" See: https://en.wikipedia.org/wiki/Color_difference
" See also: http://colormine.org/delta-e-calculator/cie2000
fun! colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
  let PI = 3.14159265359
  let k_L = 1.0
  let k_C = 1.0
  let k_H = 1.0

  let delta_L_prime = a:L2 - a:L1
  let L_bar = (a:L1 + a:L2) / 2.0

  let C_star_1 = sqrt(a:a1 * a:a1 + a:b1 * a:b1)
  let C_star_2 = sqrt(a:a2 * a:a2 + a:b2 * a:b2)
  let C_bar = (C_star_1 + C_star_2) / 2.0
  let C_bar_pow_7 = pow(C_bar, 7)

  let G = 0.5 * (1 - sqrt(C_bar_pow_7 / (C_bar_pow_7 + 6103515625))) " 6103515625 = 25^7
  let a_prime_1 = (1 + G) * a:a1
  let a_prime_2 = (1 + G) * a:a2

  let C_prime_1 = sqrt(a_prime_1 * a_prime_1 + a:b1 * a:b1)
  let C_prime_2 = sqrt(a_prime_2 * a_prime_2 + a:b2 * a:b2)
  let C_bar_prime = (C_prime_1 + C_prime_2) / 2.0
  let delta_C_prime = C_prime_2 - C_prime_1

  " Angles in degrees
  " The inverse tangent is indeterminate if both a' and b are zero.
  " In that case, the hue angle must be set to zero (atan2(0,0) is 0.0).
  let h_prime_1 = atan2(a:b1, a_prime_1) * 180.0 / PI
  if h_prime_1 < 0.0
    let h_prime_1 += 360.0
  endif
  let h_prime_2 = atan2(a:b2, a_prime_2) * 180.0 / PI
  if h_prime_2 < 0.0
    let h_prime_1 += 360.0
  endif
  let h_prime_abs_delta = abs(h_prime_1 - h_prime_2)

  if C_prime_1 * C_prime_2 == 0.0
    let delta_h_prime = 0.0
  else
    if (h_prime_abs_delta <= 180.0)
      let delta_h_prime = h_prime_2 - h_prime_1
    elseif h_prime_2 <= h_prime_1
      let delta_h_prime = h_prime_2 - h_prime_1 + 360.0
    else
      let delta_h_prime = h_prime_2 - h_prime_1 - 360.0
    endif
  endif
  let delta_H_prime = 2.0 * sqrt(C_prime_1 * C_prime_2) * sin(delta_h_prime * PI / 360.0)

  if C_prime_1 * C_prime_2 == 0.0
    let H_bar_prime = h_prime_1 + h_prime_2
  else
    if (h_prime_abs_delta <= 180.0)
      let H_bar_prime = (h_prime_1 + h_prime_2) / 2.0
    elseif h_prime_1 + h_prime_2 < 360.0
      let H_bar_prime = (h_prime_1 + h_prime_2 + 360.0) / 2.0
    else
      let H_bar_prime = (h_prime_1 + h_prime_2 - 360.0) / 2.0
    endif
  endif

  let T = 1.0
        \ - 0.17 * cos(s:DegToRad(H_bar_prime - 30.0))
        \ + 0.24 * cos(s:DegToRad(H_bar_prime * 2.0))
        \ + 0.32 * cos(s:DegToRad(H_bar_prime * 3.0 + 6.0))
        \ - 0.20 * cos(s:DegToRad(H_bar_prime * 4.0 - 63.0))

  let L_bar_minus_50_square = (L_bar - 50.0) * (L_bar - 50.0)
  let S_L = 1.0 + ((0.015 * L_bar_minus_50_square) / sqrt(20.0 + L_bar_minus_50_square))
  let S_C = 1.0 + 0.045 * C_bar_prime
  let S_H = 1.0 + 0.015 * T * C_bar_prime

  let H_bar_prime_minus_275_div_25_square = (H_bar_prime - 275.0) / 25.0
  let H_bar_prime_minus_275_div_25_square = H_bar_prime_minus_275_div_25_square * H_bar_prime_minus_275_div_25_square
  let delta_theta = 60.0 * exp(-H_bar_prime_minus_275_div_25_square)
  let C_bar_prime_pow_7 = pow(C_bar_prime, 7)
  let R_C = 2.0 * sqrt(C_bar_prime_pow_7 / (C_bar_prime_pow_7 + 6103515625)) " 25^7
  let R_T = -R_C * sin(s:DegToRad(delta_theta))

  let delta_L_prime_div_k_L_S_L = delta_L_prime / (S_L * k_L)
  let delta_C_prime_div_k_C_S_C = delta_C_prime / (S_C * k_C)
  let delta_H_prime_div_k_H_S_H = delta_H_prime / (S_H * k_H)
  let CIEDE2000 = sqrt(
        \   delta_L_prime_div_k_L_S_L * delta_L_prime_div_k_L_S_L
        \ + delta_C_prime_div_k_C_S_C * delta_C_prime_div_k_C_S_C
        \ + delta_H_prime_div_k_H_S_H * delta_H_prime_div_k_H_S_H
        \ + R_T * delta_C_prime_div_k_C_S_C * delta_H_prime_div_k_H_S_H
        \ )

  return CIEDE2000
endf

fun! colortemplate#colorspace#hex_delta_e(hexcol1, hexcol2)
    let [L1, a1, b1] = colortemplate#colorspace#hex2cielab(a:hexcol1)
    let [L2, a2, b2] = colortemplate#colorspace#hex2cielab(a:hexcol2)
    return colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
endf

fun! colortemplate#colorspace#rgb_delta_e(r1, g1, b1, r2, g2, b2)
    let [L1, a1, b1] = colortemplate#colorspace#rgb2cielab(a:r1, a:g1, a:b1)
    let [L2, a2, b2] = colortemplate#colorspace#rgb2cielab(a:r2, a:g2, a:b2)
    return colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
endf

" See :help cterm-colors
let g:colortemplate#colorspace#ansi_colors = [
      \ 'black',
      \ 'darkblue',
      \ 'darkgreen',
      \ 'darkcyan',
      \ 'darkred',
      \ 'darkmagenta',
      \ 'brown',
      \ 'darkyellow',
      \ 'lightgray',
      \ 'lightgrey',
      \ 'gray',
      \ 'grey',
      \ 'darkgray',
      \ 'darkgrey',
      \ 'blue',
      \ 'lightblue',
      \ 'green',
      \ 'lightgreen',
      \ 'cyan',
      \ 'lightcyan',
      \ 'red',
      \ 'lightred',
      \ 'magenta',
      \ 'lightmagenta',
      \ 'yellow',
      \ 'lightyellow',
      \ 'white',
      \ ]

let s:ctermcolors_nr8 = {
      \ 'black':        0,
      \ 'darkblue':     4,
      \ 'darkgreen':    2,
      \ 'darkcyan':     6,
      \ 'darkred':      1,
      \ 'darkmagenta':  5,
      \ 'brown':        3,
      \ 'darkyellow':   3,
      \ 'lightgray':    7,
      \ 'lightgrey':    7,
      \ 'gray':         7,
      \ 'grey':         7,
      \ 'darkgray':     0,
      \ 'darkgrey':     0,
      \ 'blue':         4,
      \ 'lightblue':    4,
      \ 'green':        2,
      \ 'lightgreen':   2,
      \ 'cyan':         6,
      \ 'lightcyan':    6,
      \ 'red':          1,
      \ 'lightred':     1,
      \ 'magenta':      5,
      \ 'lightmagenta': 5,
      \ 'yellow':       3,
      \ 'lightyellow':  3,
      \ 'white':        7,
      \ }

let s:ctermcolors_nr16 = {
      \ 'black':        0,
      \ 'darkblue':     1,
      \ 'darkgreen':    2,
      \ 'darkcyan':     3,
      \ 'darkred':      4,
      \ 'darkmagenta':  5,
      \ 'brown':        6,
      \ 'darkyellow':   6,
      \ 'lightgray':    7,
      \ 'lightgrey':    7,
      \ 'gray':         7,
      \ 'grey':         7,
      \ 'darkgray':     8,
      \ 'darkgrey':     8,
      \ 'blue':         9,
      \ 'lightblue':    9,
      \ 'green':        10,
      \ 'lightgreen':   10,
      \ 'cyan':         11,
      \ 'lightcyan':    11,
      \ 'red':          12,
      \ 'lightred':     12,
      \ 'magenta':      13,
      \ 'lightmagenta': 13,
      \ 'yellow':       14,
      \ 'lightyellow':  14,
      \ 'white':        15,
      \ }

" Returns the number corresponding to the given color name.
" t_Co must be 8 or 16. See :help cterm-colors
fun! g:colortemplate#colorspace#ctermcolor(name, t_Co)
  return t_Co == 16
        \ ? s:ctermcolors_nr16[a:name]
        \ : s:ctermcolors_nr8[a:name] + (g:colortemplate#ansi_style ? 8 : 0)
endf

let g:colortemplate#colorspace#xterm256 = [
      \ "#000000", "#00005f", "#000087", "#0000af", "#0000d7", "#0000ff", "#005f00", "#005f5f", "#005f87", "#005faf",
      \ "#005fd7", "#005fff", "#008700", "#00875f", "#008787", "#0087af", "#0087d7", "#0087ff", "#00af00", "#00af5f",
      \ "#00af87", "#00afaf", "#00afd7", "#00afff", "#00d700", "#00d75f", "#00d787", "#00d7af", "#00d7d7", "#00d7ff",
      \ "#00ff00", "#00ff5f", "#00ff87", "#00ffaf", "#00ffd7", "#00ffff", "#5f0000", "#5f005f", "#5f0087", "#5f00af",
      \ "#5f00d7", "#5f00ff", "#5f5f00", "#5f5f5f", "#5f5f87", "#5f5faf", "#5f5fd7", "#5f5fff", "#5f8700", "#5f875f",
      \ "#5f8787", "#5f87af", "#5f87d7", "#5f87ff", "#5faf00", "#5faf5f", "#5faf87", "#5fafaf", "#5fafd7", "#5fafff",
      \ "#5fd700", "#5fd75f", "#5fd787", "#5fd7af", "#5fd7d7", "#5fd7ff", "#5fff00", "#5fff5f", "#5fff87", "#5fffaf",
      \ "#5fffd7", "#5fffff", "#870000", "#87005f", "#870087", "#8700af", "#8700d7", "#8700ff", "#875f00", "#875f5f",
      \ "#875f87", "#875faf", "#875fd7", "#875fff", "#878700", "#87875f", "#878787", "#8787af", "#8787d7", "#8787ff",
      \ "#87af00", "#87af5f", "#87af87", "#87afaf", "#87afd7", "#87afff", "#87d700", "#87d75f", "#87d787", "#87d7af",
      \ "#87d7d7", "#87d7ff", "#87ff00", "#87ff5f", "#87ff87", "#87ffaf", "#87ffd7", "#87ffff", "#af0000", "#af005f",
      \ "#af0087", "#af00af", "#af00d7", "#af00ff", "#af5f00", "#af5f5f", "#af5f87", "#af5faf", "#af5fd7", "#af5fff",
      \ "#af8700", "#af875f", "#af8787", "#af87af", "#af87d7", "#af87ff", "#afaf00", "#afaf5f", "#afaf87", "#afafaf",
      \ "#afafd7", "#afafff", "#afd700", "#afd75f", "#afd787", "#afd7af", "#afd7d7", "#afd7ff", "#afff00", "#afff5f",
      \ "#afff87", "#afffaf", "#afffd7", "#afffff", "#d70000", "#d7005f", "#d70087", "#d700af", "#d700d7", "#d700ff",
      \ "#d75f00", "#d75f5f", "#d75f87", "#d75faf", "#d75fd7", "#d75fff", "#d78700", "#d7875f", "#d78787", "#d787af",
      \ "#d787d7", "#d787ff", "#d7af00", "#d7af5f", "#d7af87", "#d7afaf", "#d7afd7", "#d7afff", "#d7d700", "#d7d75f",
      \ "#d7d787", "#d7d7af", "#d7d7d7", "#d7d7ff", "#d7ff00", "#d7ff5f", "#d7ff87", "#d7ffaf", "#d7ffd7", "#d7ffff",
      \ "#ff0000", "#ff005f", "#ff0087", "#ff00af", "#ff00d7", "#ff00ff", "#ff5f00", "#ff5f5f", "#ff5f87", "#ff5faf",
      \ "#ff5fd7", "#ff5fff", "#ff8700", "#ff875f", "#ff8787", "#ff87af", "#ff87d7", "#ff87ff", "#ffaf00", "#ffaf5f",
      \ "#ffaf87", "#ffafaf", "#ffafd7", "#ffafff", "#ffd700", "#ffd75f", "#ffd787", "#ffd7af", "#ffd7d7", "#ffd7ff",
      \ "#ffff00", "#ffff5f", "#ffff87", "#ffffaf", "#ffffd7", "#ffffff", "#080808", "#121212", "#1c1c1c", "#262626",
      \ "#303030", "#3a3a3a", "#444444", "#4e4e4e", "#585858", "#626262", "#6c6c6c", "#767676", "#808080", "#8a8a8a",
      \ "#949494", "#9e9e9e", "#a8a8a8", "#b2b2b2", "#bcbcbc", "#c6c6c6", "#d0d0d0", "#dadada", "#e4e4e4", "#eeeeee"]

let s:xterm_cielab = [
      \ [0.0,0.0,0.0],
      \ [7.46321,38.396151,-52.346075],
      \ [14.112276,49.371926,-67.243209],
      \ [20.420984,59.71565,-81.331077],
      \ [26.466121,69.627224,-94.830369],
      \ [32.302587,79.196662,-107.863681],
      \ [34.364043,-41.842403,40.384226],
      \ [36.004775,-23.342522,-6.864022],
      \ [37.723152,-8.27353,-28.842577],
      \ [40.047393,8.059567,-49.083099],
      \ [42.899613,24.243175,-67.671516],
      \ [46.183203,39.624098,-84.841619],
      \ [48.670619,-53.728293,51.855902],
      \ [49.682567,-41.466004,12.868358],
      \ [50.777422,-29.973275,-8.813839],
      \ [52.312233,-16.079967,-29.673772],
      \ [54.274663,-0.974296,-49.352781],
      \ [56.632285,14.448952,-67.832544],
      \ [62.219513,-64.984703,62.720034],
      \ [62.915914,-56.273736,30.550463],
      \ [63.679663,-47.530405,9.985831],
      \ [64.767705,-36.252862,-10.660392],
      \ [66.187161,-23.171347,-30.665455],
      \ [67.932038,-9.010726,-49.799349],
      \ [75.202349,-75.770832,73.130274],
      \ [75.716267,-69.237895,46.414074],
      \ [76.28368,-62.435013,27.35547],
      \ [77.098718,-53.313388,7.409882],
      \ [78.173489,-42.270094,-12.429799],
      \ [79.511766,-29.794352,-31.750969],
      \ [87.737033,-86.184636,83.181165],
      \ [88.134974,-81.079727,60.783185],
      \ [88.57598,-75.64877,43.366413],
      \ [89.212414,-68.189217,24.404354],
      \ [90.0569,-58.898434,5.049116],
      \ [91.116521,-48.079618,-14.138128],
      \ [17.612373,38.892849,27.207102],
      \ [21.053117,47.702152,-29.539101],
      \ [24.264756,55.119724,-50.118663],
      \ [28.189093,63.508354,-68.197717],
      \ [32.566941,72.290135,-84.503035],
      \ [37.212116,81.17002,-99.546909],
      \ [38.928307,-10.465334,45.870986],
      \ [40.31768,0.002554,-0.005053],
      \ [41.792911,9.722218,-22.191255],
      \ [43.817709,21.366608,-42.836857],
      \ [46.343173,33.921024,-61.923023],
      \ [49.29819,46.663327,-79.617489],
      \ [51.56573,-31.108962,55.364201],
      \ [52.494569,-22.365153,17.182632],
      \ [53.503319,-13.752261,-4.46511],
      \ [54.923689,-2.854057,-25.419623],
      \ [56.749651,9.53177,-45.271392],
      \ [58.95659,22.681111,-63.970136],
      \ [64.236012,-48.205648,65.172036],
      \ [64.898278,-41.171114,33.484674],
      \ [65.625553,-33.961256,13.008382],
      \ [66.66331,-24.459882,-7.6324],
      \ [68.019979,-13.181903,-27.687293],
      \ [69.691772,-0.698145,-46.908189],
      \ [76.699463,-62.883196,74.953848],
      \ [77.197047,-57.22221,48.535418],
      \ [77.746731,-51.269804,29.567106],
      \ [78.536846,-43.202778,9.659007],
      \ [79.579699,-33.315414,-10.182153],
      \ [80.879676,-22.001608,-29.532597],
      \ [88.900217,-75.971011,84.599354],
      \ [89.289429,-71.355907,62.391339],
      \ [89.720877,-66.421839,45.05252],
      \ [90.343722,-59.60629,26.135735],
      \ [91.170543,-51.059361,6.798265],
      \ [92.208573,-41.031744,-12.392021],
      \ [27.160414,49.940879,40.139981],
      \ [29.354667,55.736656,-15.913384],
      \ [31.578547,61.252582,-37.930075],
      \ [34.490132,68.056586,-57.623147],
      \ [37.944883,75.666752,-75.443952],
      \ [41.799629,83.721293,-91.802405],
      \ [43.264198,9.135533,50.93374],
      \ [44.463711,16.314612,6.506585],
      \ [45.749831,23.378789,-15.774739],
      \ [47.534248,32.309181,-36.71209],
      \ [49.787854,42.454989,-56.194212],
      \ [52.459339,53.236528,-74.330678],
      \ [54.531422,-13.438151,58.901249],
      \ [55.385187,-6.767046,21.57648],
      \ [56.315465,0.003279,-0.006489],
      \ [57.630453,8.831582,-21.029271],
      \ [59.329134,19.188051,-41.031141],
      \ [61.393502,30.51918,-59.930316],
      \ [66.375139,-33.33801,67.748322],
      \ [67.003845,-27.527522,36.579796],
      \ [67.695147,-21.480799,16.207293],
      \ [68.68311,-13.380642,-4.417532],
      \ [69.977287,-3.587375,-24.515352],
      \ [71.575898,7.4572,-43.819054],
      \ [78.316771,-50.588122,76.911559],
      \ [78.797566,-45.652609,50.816515],
      \ [79.329,-40.421283,31.949585],
      \ [80.093416,-33.267162,12.08616],
      \ [81.103283,-24.404697,-7.752441],
      \ [82.363566,-14.147239,-27.13044],
      \ [90.169923,-65.773256,86.140744],
      \ [90.549932,-61.60075,64.140414],
      \ [90.971292,-57.120187,46.888243],
      \ [91.579785,-50.899197,28.022766],
      \ [92.387927,-43.048597,8.706633],
      \ [93.403093,-33.772988,-10.485047],
      \ [36.202788,60.403802,50.584335],
      \ [37.73486,64.508797,-2.449278],
      \ [39.349153,68.664559,-25.141655],
      \ [41.546547,74.085376,-45.87666],
      \ [44.261968,80.474184,-64.862368],
      \ [47.40962,87.536747,-82.370081],
      \ [48.633814,27.334063,57.034969],
      \ [49.646888,32.351526,14.529353],
      \ [50.742905,37.490517,-7.752836],
      \ [52.27925,44.258891,-28.941823],
      \ [54.243497,52.291618,-48.817765],
      \ [56.603112,61.191462,-67.424062],
      \ [58.45415,5.073643,63.499246],
      \ [59.221693,10.072221,27.343009],
      \ [60.061062,15.271388,5.887256],
      \ [61.252706,22.232048,-15.185299],
      \ [62.800481,30.642188,-35.347178],
      \ [64.693315,40.12222,-54.476347],
      \ [69.308191,-16.253527,71.241424],
      \ [69.894849,-11.59925,40.793473],
      \ [70.540919,-6.685396,20.579036],
      \ [71.466002,0.003967,-0.007848],
      \ [72.680819,8.244924,-20.148835],
      \ [74.18587,17.725274,-39.550995],
      \ [80.579988,-35.516599,79.630469],
      \ [81.038674,-31.34819,53.990118],
      \ [81.546035,-26.892578,35.271395],
      \ [82.276485,-20.739844,15.477472],
      \ [83.242638,-13.027903,-4.350576],
      \ [84.450147,-3.986155,-23.760304],
      \ [91.968562,-52.704506,88.312599],
      \ [92.33608,-49.038702,66.606796],
      \ [92.743739,-45.082525,49.480013],
      \ [93.332717,-39.557054,30.69048],
      \ [94.115428,-32.532731,11.407948],
      \ [95.099414,-24.163821,-7.782358],
      \ [44.86738,70.429595,59.097778],
      \ [46.006266,73.503738,10.518261],
      \ [47.231037,76.722243,-12.362377],
      \ [48.936094,81.068179,-33.697112],
      \ [51.098094,86.38203,-53.491245],
      \ [53.671967,92.464536,-71.895056],
      \ [54.690715,43.555852,63.735017],
      \ [55.540706,47.203522,23.487573],
      \ [56.467021,51.03861,1.335351],
      \ [57.77666,56.23638,-20.012701],
      \ [59.468839,62.609796,-40.218202],
      \ [61.525873,69.911695,-59.255655],
      \ [63.156502,22.862689,68.903276],
      \ [63.836724,26.638462,34.180342],
      \ [64.583201,30.638538,12.932756],
      \ [65.647455,36.105644,-8.144764],
      \ [67.03725,42.873761,-28.445959],
      \ [68.747657,50.70293,-47.801931],
      \ [72.962305,1.429997,75.533818],
      \ [73.502195,5.120799,45.99291],
      \ [74.09775,9.064861,25.998816],
      \ [74.95226,14.50941,5.483401],
      \ [76.077432,21.330839,-14.687667],
      \ [77.47597,29.324857,-34.189598],
      \ [83.467602,-18.951279,83.066041],
      \ [83.900215,-15.493196,58.007841],
      \ [84.379135,-11.767994,39.4882],
      \ [85.069355,-6.576565,19.794184],
      \ [85.983565,0.004625,-0.009151],
      \ [87.128116,7.820039,-19.448325],
      \ [94.29827,-37.67118,91.106043],
      \ [94.650501,-34.514207,69.781761],
      \ [95.041374,-31.090146,52.8217],
      \ [95.606415,-26.279216,34.135987],
      \ [96.357879,-20.116942,14.902652],
      \ [97.303471,-12.710733,-4.280234],
      \ [53.232882,80.10931,67.220068],
      \ [54.11837,82.509552,22.901121],
      \ [55.081885,85.072482,0.154061],
      \ [56.441633,88.609511,-21.467026],
      \ [58.194562,93.044307,-41.783546],
      \ [60.319934,98.254219,-60.842984],
      \ [61.171862,58.017159,70.735875],
      \ [61.88704,60.779975,32.933036],
      \ [62.670799,63.734698,11.047977],
      \ [63.786344,67.818209,-10.346824],
      \ [65.24,72.943679,-30.788392],
      \ [67.024497,78.966325,-50.181397],
      \ [68.451728,39.352671,74.866389],
      \ [69.050221,42.263129,41.773186],
      \ [69.709039,45.387526,20.823498],
      \ [70.651875,49.724068,-0.196395],
      \ [71.889146,55.19455,-20.593406],
      \ [73.42074,61.656317,-40.146864],
      \ [77.232943,18.717646,80.473854],
      \ [77.724894,21.655071,51.997564],
      \ [78.268458,24.824181,32.290523],
      \ [79.049958,29.248646,11.889841],
      \ [80.081763,34.870457,-8.285727],
      \ [81.368458,41.564581,-27.874514],
      \ [86.928585,-1.924215,87.137158],
      \ [87.332764,0.926246,62.776858],
      \ [87.7806,4.017404,44.509231],
      \ [88.426737,8.359763,24.950493],
      \ [89.283823,13.920426,5.19243],
      \ [90.358827,20.601511,-14.266662],
      \ [97.138247,-21.555908,94.482485],
      \ [97.473094,-18.868079,73.622355],
      \ [97.844859,-15.939487,56.871548],
      \ [98.38261,-11.801804,38.320269],
      \ [99.098378,-6.464022,19.155187],
      \ [100.0,0.00526,-0.010408],
      \ [2.193388,2.984079e-4,-5.904407e-4],
      \ [5.463862,7.433522e-4,-0.001471],
      \ [10.268184,0.001191,-0.002357],
      \ [15.15972,0.001413,-0.002796],
      \ [19.865534,0.001626,-0.003218],
      \ [24.42132,0.001833,-0.003627],
      \ [28.851902,0.002034,-0.004024],
      \ [33.175472,0.00223,-0.004412],
      \ [37.40589,0.002422,-0.004792],
      \ [41.554043,0.00261,-0.005164],
      \ [45.628689,0.002795,-0.00553],
      \ [49.637014,0.002977,-0.005889],
      \ [53.585013,0.003156,-0.006244],
      \ [57.477756,0.003332,-0.006593],
      \ [61.319583,0.003506,-0.006938],
      \ [65.114245,0.003678,-0.007278],
      \ [68.865018,0.003849,-0.007615],
      \ [72.574783,0.004017,-0.007947],
      \ [76.246091,0.004183,-0.008277],
      \ [79.881216,0.004348,-0.008603],
      \ [83.4822,0.004511,-0.008926],
      \ [87.050879,0.004673,-0.009246],
      \ [90.58892,0.004834,-0.009564],
      \ [94.097834,0.004993,-0.009879],
      \ ]

fun! colortemplate#colorspace#xterm256_hexvalue(number)
  if a:number < 16 || a:number > 255
    throw "Color index out of range"
  endif
  return g:colortemplate#colorspace#xterm256[a:number - 16]
endf

fun! colortemplate#colorspace#xterm256_rgbvalue(number)
  return colortemplate#colorspace#hex2rgb(colortemplate#xterm256#color(a:number))
endf

" Converts a hex or RGB color into CIELAB colorspace.
" Returns a list [L,a,b].
fun! colortemplate#colorspace#to_cielab(color)
  if type(a:color) == v:t_string " Assume hex value
    let [L1, a1, b1] = colortemplate#colorspace#hex2cielab(a:color)
  elseif type(a:color) == v:t_list " Assume RGB
    let [L1, a1, b1] = colortemplate#colorspace#rgb2cielab(a:color[0], a:color[1], a:color[2])
  else
    throw 'Invalid color type'
  endif
  return [L1, a1, b1]
endf

let s:cache = {}

" Returns a dictionary with four keys:
" color: the color passed as argument
" index: the base-256 color number that best approximates the given color
" approx: the hex value of the approximate color
" delta: the CIEDE2000 difference between the two colors
fun! colortemplate#colorspace#approx(color)
  if has_key(s:cache, a:color)
    return s:cache[a:color]
  endif
  let [L1, a1, b1] = colortemplate#colorspace#to_cielab(a:color)
  let l:delta = 1.0 / 0.0
  let l:color_index = -1
  for l:i in range(240)
    let [L2, a2, b2] = s:xterm_cielab[l:i]
    let l:new_delta = colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
    if l:new_delta < l:delta
      let l:delta = l:new_delta
      let l:color_index = l:i
    endif
  endfor
  let s:cache[a:color] = { 'color': a:color, 'index': l:color_index + 16, 'approx': g:colortemplate#colorspace#xterm256[l:color_index], 'delta': l:delta }
  return s:cache[a:color]
endf

fun! colortemplate#colorspace#makecielab()
  new
  setl ft=vim
  call append('$', 'let s:xterm_cielab = [')
  for l:i in range(240)
    let l:xterm_color = g:colortemplate#colorspace#xterm256[l:i]
    let [L2, a2, b2] = colortemplate#colorspace#hex2cielab(l:xterm_color)
    call append('$', '\ ['.string(L2).','.string(a2).','.string(b2).']')
  endfor
  call append('$', '\ ]')
endf

" Returns a list of colors at distance less than the specified threshold from
" the given color.
" threshold: a float number.
" color: a hexdecimal (e.g., '#ffffff') or RGB color (e.g., [255, 255, 255])
" ...: an optional list of hex or RGB colors
fun! colortemplate#colorspace#colors_within(threshold, color, ...)
  let [L1, a1, b1] = colortemplate#colorspace#to_cielab(a:color)
  let l:color_list = a:0 > 0 ? a:1 : g:colortemplate#colorspace#xterm256
  let l:result = []
  let l:N = len(l:color_list)
  for l:i in range(l:N)
    let l:xterm_color = l:color_list[l:i]
    let [L2, a2, b2] = colortemplate#colorspace#to_cielab(l:xterm_color)
    let l:delta = colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
    if l:delta <= a:threshold
      call add(l:result, l:i + 16)
    endif
  endfor
  return l:result
endf

" Returns the list of the k colors nearest to the given color.
" k: a number between 1 and 240 (or between 1 and the number of colors in the
" list passed as the third argument).
" color: a hex or RGB color.
"
" Return value: a list of dictionaries with two keys:
" index: a color index
" delta: the distance from the given color
" ...: an optional list of hex or RGB colors
"
" NOTE: this is a highly inefficient implementation!
fun! colortemplate#colorspace#k_neighbours(color, k, ...)
  let [L1, a1, b1] = colortemplate#colorspace#to_cielab(a:color)
  let l:color_list = a:0 > 0 ? a:1 : g:colortemplate#colorspace#xterm256
  let l:result = []
  let l:j = 0
  let l:N = len(l:color_list)
  if a:k < 1 || a:k > l:N
    throw 'Number out of range'
  endif
  for l:j in range(a:k)
    let l:delta = 1.0 / 0.0
    let l:color_index = -1
    for l:i in range(l:N)
      if match(l:result, l:i + 16) > -1
        continue
      endif
      let l:xterm_color = l:color_list[l:i]
      let [L2, a2, b2] = colortemplate#colorspace#to_cielab(l:xterm_color)
      let l:new_delta = colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
      if l:new_delta < l:delta
        let l:delta = l:new_delta
        let l:color_index = l:i
      endif
    endfor
    call add(l:result, { 'index': l:color_index + 16, 'delta': l:delta })
    let l:j += 1
  endfor
  return sort(l:result, { i1,i2 -> i1['delta'] < i2['delta'] ? -1 : i1['delta'] > i2['delta'] ? 1 : 0 })
endf

fun! colortemplate#colorspace#k_neighbors(color, k)
  return colortemplate#colorspace#k_neighbours(a:color, a:k)
endf

" vim: foldmethod=marker nowrap et ts=2 sw=2

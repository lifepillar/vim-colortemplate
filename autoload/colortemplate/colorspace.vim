" Convert a hexadecimal color string into a three-elements list of RGB values.
"
" Example: call colortemplate#colorspace#hex2rgb('#ffffff') -> [255,255,255]
fun! colortemplate#colorspace#hex2rgb(col)
  return map(matchlist(a:col, '^#\?\(..\)\(..\)\(..\)$')[1:3], 'str2nr(v:val,16)')
endf

" Convert an RGB color into the equivalent hexadecimal string.
"
" Example: call colortemplate#colorspace#rgb2hex(255,255,255) -> '#ffffff'
fun! colortemplate#colorspace#rgb2hex(r, g, b)
  return '#' . printf('%02x', a:r) . printf('%02x', a:g) . printf('%02x', a:b)
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

let g:colortemplate#colorspace#xterm256 = ["#000000", "#00005f", "#000087", "#0000af", "#0000d7", "#0000ff", "#005f00", "#005f5f", "#005f87", "#005faf",
      \                  "#005fd7", "#005fff", "#008700", "#00875f", "#008787", "#0087af", "#0087d7", "#0087ff", "#00af00", "#00af5f",
      \                  "#00af87", "#00afaf", "#00afd7", "#00afff", "#00d700", "#00d75f", "#00d787", "#00d7af", "#00d7d7", "#00d7ff",
      \                  "#00ff00", "#00ff5f", "#00ff87", "#00ffaf", "#00ffd7", "#00ffff", "#5f0000", "#5f005f", "#5f0087", "#5f00af",
      \                  "#5f00d7", "#5f00ff", "#5f5f00", "#5f5f5f", "#5f5f87", "#5f5faf", "#5f5fd7", "#5f5fff", "#5f8700", "#5f875f",
      \                  "#5f8787", "#5f87af", "#5f87d7", "#5f87ff", "#5faf00", "#5faf5f", "#5faf87", "#5fafaf", "#5fafd7", "#5fafff",
      \                  "#5fd700", "#5fd75f", "#5fd787", "#5fd7af", "#5fd7d7", "#5fd7ff", "#5fff00", "#5fff5f", "#5fff87", "#5fffaf",
      \                  "#5fffd7", "#5fffff", "#870000", "#87005f", "#870087", "#8700af", "#8700d7", "#8700ff", "#875f00", "#875f5f",
      \                  "#875f87", "#875faf", "#875fd7", "#875fff", "#878700", "#87875f", "#878787", "#8787af", "#8787d7", "#8787ff",
      \                  "#87af00", "#87af5f", "#87af87", "#87afaf", "#87afd7", "#87afff", "#87d700", "#87d75f", "#87d787", "#87d7af",
      \                  "#87d7d7", "#87d7ff", "#87ff00", "#87ff5f", "#87ff87", "#87ffaf", "#87ffd7", "#87ffff", "#af0000", "#af005f",
      \                  "#af0087", "#af00af", "#af00d7", "#af00ff", "#af5f00", "#af5f5f", "#af5f87", "#af5faf", "#af5fd7", "#af5fff",
      \                  "#af8700", "#af875f", "#af8787", "#af87af", "#af87d7", "#af87ff", "#afaf00", "#afaf5f", "#afaf87", "#afafaf",
      \                  "#afafd7", "#afafff", "#afd700", "#afd75f", "#afd787", "#afd7af", "#afd7d7", "#afd7ff", "#afff00", "#afff5f",
      \                  "#afff87", "#afffaf", "#afffd7", "#afffff", "#d70000", "#d7005f", "#d70087", "#d700af", "#d700d7", "#d700ff",
      \                  "#d75f00", "#d75f5f", "#d75f87", "#d75faf", "#d75fd7", "#d75fff", "#d78700", "#d7875f", "#d78787", "#d787af",
      \                  "#d787d7", "#d787ff", "#d7af00", "#d7af5f", "#d7af87", "#d7afaf", "#d7afd7", "#d7afff", "#d7d700", "#d7d75f",
      \                  "#d7d787", "#d7d7af", "#d7d7d7", "#d7d7ff", "#d7ff00", "#d7ff5f", "#d7ff87", "#d7ffaf", "#d7ffd7", "#d7ffff",
      \                  "#ff0000", "#ff005f", "#ff0087", "#ff00af", "#ff00d7", "#ff00ff", "#ff5f00", "#ff5f5f", "#ff5f87", "#ff5faf",
      \                  "#ff5fd7", "#ff5fff", "#ff8700", "#ff875f", "#ff8787", "#ff87af", "#ff87d7", "#ff87ff", "#ffaf00", "#ffaf5f",
      \                  "#ffaf87", "#ffafaf", "#ffafd7", "#ffafff", "#ffd700", "#ffd75f", "#ffd787", "#ffd7af", "#ffd7d7", "#ffd7ff",
      \                  "#ffff00", "#ffff5f", "#ffff87", "#ffffaf", "#ffffd7", "#ffffff", "#080808", "#121212", "#1c1c1c", "#262626",
      \                  "#303030", "#3a3a3a", "#444444", "#4e4e4e", "#585858", "#626262", "#6c6c6c", "#767676", "#808080", "#8a8a8a",
      \                  "#949494", "#9e9e9e", "#a8a8a8", "#b2b2b2", "#bcbcbc", "#c6c6c6", "#d0d0d0", "#dadada", "#e4e4e4", "#eeeeee"]

fun! colortemplate#colorspace#xterm256_hexvalue(number)
  if a:number < 16 || a:number > 255
    throw "Color index out of range"
  endif
  return g:colortemplate#colorspace#xterm256[a:number - 16]
endf

fun! colortemplate#colorspace#xterm256_rgbvalue(number)
  return colortemplate#colorspace#hex2rgb(colortemplate#xterm256#color(a:number))
endf

" Returns a dictionary  with four keys:
" color: the color passed as argument
" index: the base-256 color number that best approximates the given color
" approx: the hex value of the approximate color
" delta: the CIEDE2000 difference between the two colors
fun! colortemplate#colorspace#approx(color)
  if type(a:color) == v:t_string " Assume hex value
    let [L1, a1, b1] = colortemplate#colorspace#hex2cielab(a:color)
  elseif type(a:color) == v:t_list " Assume RGB
    let [L1, a1, b1] = colortemplate#colorspace#rgb2cielab(a:color[0], a:color[1], a:color[2])
  else
    throw 'Invalid color type'
  endif
  let l:delta = 1.0 / 0.0
  let l:color_index = -1
  for l:i in range(240)
    let l:xterm_color = g:colortemplate#colorspace#xterm256[l:i]
    let [L2, a2, b2] = colortemplate#colorspace#hex2cielab(l:xterm_color)
    let l:new_delta = colortemplate#colorspace#delta_e(L1, a1, b1, L2, a2, b2)
    if l:new_delta < l:delta
      let l:delta = l:new_delta
      let l:color_index = l:i + 16
    endif
  endfor
  return { 'color': a:color, 'index': l:color_index, 'approx': g:colortemplate#colorspace#xterm256[l:color_index - 16], 'delta': l:delta }
endf

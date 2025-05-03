if v:version < 901
  finish
endif

vim9script

export var version = '0.0.1-alpha'

# Constants {{{
export const PI = 3.1415926535897932384626

# The 24 bit RGB values used for the 16 ANSI colors differ greatly for each
# terminal implementation. Below is a system that is both consistent and 12
# bit compatible. See https://mudhalla.net/tintin/info/ansicolor/.

# These are arbitrary hex values for terminal colors in the range 0-15. These
# are defined for situations in which a hex value must be returned under any
# circumstances, even if it is an approximate value.
export const ANSI_HEX = [
  '#000000',
  '#aa0000',
  '#00aa00',
  '#aaaa00',
  '#0000aa',
  '#aa00aa',
  '#00aaaa',
  '#aaaaaa',
  '#555555',
  '#ff5555',
  '#55ff55',
  '#ffff55',
  '#5555ff',
  '#ff55ff',
  '#55ffff',
  '#ffffff',
]

# See :help cterm-colors
export const ANSI_COLORS = [
  'black',
  'darkblue',
  'darkgreen',
  'darkcyan',
  'darkred',
  'darkmagenta',
  'brown',
  'darkyellow',
  'lightgray',
  'lightgrey',
  'gray',
  'grey',
  'darkgray',
  'darkgrey',
  'blue',
  'lightblue',
  'green',
  'lightgreen',
  'cyan',
  'lightcyan',
  'red',
  'lightred',
  'magenta',
  'lightmagenta',
  'yellow',
  'lightyellow',
  'white',
]

const XTERM256_COLORS = [
  "#000000", "#00005f", "#000087", "#0000af", "#0000d7", "#0000ff", "#005f00", "#005f5f", "#005f87", "#005faf",
  "#005fd7", "#005fff", "#008700", "#00875f", "#008787", "#0087af", "#0087d7", "#0087ff", "#00af00", "#00af5f",
  "#00af87", "#00afaf", "#00afd7", "#00afff", "#00d700", "#00d75f", "#00d787", "#00d7af", "#00d7d7", "#00d7ff",
  "#00ff00", "#00ff5f", "#00ff87", "#00ffaf", "#00ffd7", "#00ffff", "#5f0000", "#5f005f", "#5f0087", "#5f00af",
  "#5f00d7", "#5f00ff", "#5f5f00", "#5f5f5f", "#5f5f87", "#5f5faf", "#5f5fd7", "#5f5fff", "#5f8700", "#5f875f",
  "#5f8787", "#5f87af", "#5f87d7", "#5f87ff", "#5faf00", "#5faf5f", "#5faf87", "#5fafaf", "#5fafd7", "#5fafff",
  "#5fd700", "#5fd75f", "#5fd787", "#5fd7af", "#5fd7d7", "#5fd7ff", "#5fff00", "#5fff5f", "#5fff87", "#5fffaf",
  "#5fffd7", "#5fffff", "#870000", "#87005f", "#870087", "#8700af", "#8700d7", "#8700ff", "#875f00", "#875f5f",
  "#875f87", "#875faf", "#875fd7", "#875fff", "#878700", "#87875f", "#878787", "#8787af", "#8787d7", "#8787ff",
  "#87af00", "#87af5f", "#87af87", "#87afaf", "#87afd7", "#87afff", "#87d700", "#87d75f", "#87d787", "#87d7af",
  "#87d7d7", "#87d7ff", "#87ff00", "#87ff5f", "#87ff87", "#87ffaf", "#87ffd7", "#87ffff", "#af0000", "#af005f",
  "#af0087", "#af00af", "#af00d7", "#af00ff", "#af5f00", "#af5f5f", "#af5f87", "#af5faf", "#af5fd7", "#af5fff",
  "#af8700", "#af875f", "#af8787", "#af87af", "#af87d7", "#af87ff", "#afaf00", "#afaf5f", "#afaf87", "#afafaf",
  "#afafd7", "#afafff", "#afd700", "#afd75f", "#afd787", "#afd7af", "#afd7d7", "#afd7ff", "#afff00", "#afff5f",
  "#afff87", "#afffaf", "#afffd7", "#afffff", "#d70000", "#d7005f", "#d70087", "#d700af", "#d700d7", "#d700ff",
  "#d75f00", "#d75f5f", "#d75f87", "#d75faf", "#d75fd7", "#d75fff", "#d78700", "#d7875f", "#d78787", "#d787af",
  "#d787d7", "#d787ff", "#d7af00", "#d7af5f", "#d7af87", "#d7afaf", "#d7afd7", "#d7afff", "#d7d700", "#d7d75f",
  "#d7d787", "#d7d7af", "#d7d7d7", "#d7d7ff", "#d7ff00", "#d7ff5f", "#d7ff87", "#d7ffaf", "#d7ffd7", "#d7ffff",
  "#ff0000", "#ff005f", "#ff0087", "#ff00af", "#ff00d7", "#ff00ff", "#ff5f00", "#ff5f5f", "#ff5f87", "#ff5faf",
  "#ff5fd7", "#ff5fff", "#ff8700", "#ff875f", "#ff8787", "#ff87af", "#ff87d7", "#ff87ff", "#ffaf00", "#ffaf5f",
  "#ffaf87", "#ffafaf", "#ffafd7", "#ffafff", "#ffd700", "#ffd75f", "#ffd787", "#ffd7af", "#ffd7d7", "#ffd7ff",
  "#ffff00", "#ffff5f", "#ffff87", "#ffffaf", "#ffffd7", "#ffffff", "#080808", "#121212", "#1c1c1c", "#262626",
  "#303030", "#3a3a3a", "#444444", "#4e4e4e", "#585858", "#626262", "#6c6c6c", "#767676", "#808080", "#8a8a8a",
  "#949494", "#9e9e9e", "#a8a8a8", "#b2b2b2", "#bcbcbc", "#c6c6c6", "#d0d0d0", "#dadada", "#e4e4e4", "#eeeeee",
]

const XTERM_CIELAB = [
  [0.0,        0.0,         0.0],
  [7.46321,    38.396151,   -52.346075],
  [14.112276,  49.371926,   -67.243209],
  [20.420984,  59.71565,    -81.331077],
  [26.466121,  69.627224,   -94.830369],
  [32.302587,  79.196662,   -107.863681],
  [34.364043, -41.842403,  40.384226],
  [36.004775, -23.342522,  -6.864022],
  [37.723152, -8.27353,    -28.842577],
  [40.047393, 8.059567,    -49.083099],
  [42.899613, 24.243175,   -67.671516],
  [46.183203, 39.624098,   -84.841619],
  [48.670619, -53.728293,  51.855902],
  [49.682567, -41.466004,  12.868358],
  [50.777422, -29.973275,  -8.813839],
  [52.312233, -16.079967,  -29.673772],
  [54.274663, -0.974296,   -49.352781],
  [56.632285, 14.448952,   -67.832544],
  [62.219513, -64.984703,  62.720034],
  [62.915914, -56.273736,  30.550463],
  [63.679663, -47.530405,  9.985831],
  [64.767705, -36.252862,  -10.660392],
  [66.187161, -23.171347,  -30.665455],
  [67.932038, -9.010726,   -49.799349],
  [75.202349, -75.770832,  73.130274],
  [75.716267, -69.237895,  46.414074],
  [76.28368,  -62.435013,  27.35547],
  [77.098718, -53.313388,  7.409882],
  [78.173489, -42.270094,  -12.429799],
  [79.511766, -29.794352,  -31.750969],
  [87.737033, -86.184636,  83.181165],
  [88.134974, -81.079727,  60.783185],
  [88.57598,  -75.64877,   43.366413],
  [89.212414, -68.189217,  24.404354],
  [90.0569,   -58.898434,  5.049116],
  [91.116521, -48.079618,  -14.138128],
  [17.612373, 38.892849,   27.207102],
  [21.053117, 47.702152,   -29.539101],
  [24.264756, 55.119724,   -50.118663],
  [28.189093, 63.508354,   -68.197717],
  [32.566941, 72.290135,   -84.503035],
  [37.212116, 81.17002,    -99.546909],
  [38.928307, -10.465334,  45.870986],
  [40.31768,  0.002554,    -0.005053],
  [41.792911, 9.722218,    -22.191255],
  [43.817709, 21.366608,   -42.836857],
  [46.343173, 33.921024,   -61.923023],
  [49.29819,  46.663327,   -79.617489],
  [51.56573,  -31.108962,  55.364201],
  [52.494569, -22.365153,  17.182632],
  [53.503319, -13.752261,  -4.46511],
  [54.923689, -2.854057,   -25.419623],
  [56.749651, 9.53177,     -45.271392],
  [58.95659,  22.681111,   -63.970136],
  [64.236012, -48.205648,  65.172036],
  [64.898278, -41.171114,  33.484674],
  [65.625553, -33.961256,  13.008382],
  [66.66331,  -24.459882,  -7.6324],
  [68.019979, -13.181903,  -27.687293],
  [69.691772, -0.698145,   -46.908189],
  [76.699463, -62.883196,  74.953848],
  [77.197047, -57.22221,   48.535418],
  [77.746731, -51.269804,  29.567106],
  [78.536846, -43.202778,  9.659007],
  [79.579699, -33.315414,  -10.182153],
  [80.879676, -22.001608,  -29.532597],
  [88.900217, -75.971011,  84.599354],
  [89.289429, -71.355907,  62.391339],
  [89.720877, -66.421839,  45.05252],
  [90.343722, -59.60629,   26.135735],
  [91.170543, -51.059361,  6.798265],
  [92.208573, -41.031744,  -12.392021],
  [27.160414, 49.940879,   40.139981],
  [29.354667, 55.736656,   -15.913384],
  [31.578547, 61.252582,   -37.930075],
  [34.490132, 68.056586,   -57.623147],
  [37.944883, 75.666752,   -75.443952],
  [41.799629, 83.721293,   -91.802405],
  [43.264198, 9.135533,    50.93374],
  [44.463711, 16.314612,   6.506585],
  [45.749831, 23.378789,   -15.774739],
  [47.534248, 32.309181,   -36.71209],
  [49.787854, 42.454989,   -56.194212],
  [52.459339, 53.236528,   -74.330678],
  [54.531422, -13.438151,  58.901249],
  [55.385187, -6.767046,   21.57648],
  [56.315465, 0.003279,    -0.006489],
  [57.630453, 8.831582,    -21.029271],
  [59.329134, 19.188051,   -41.031141],
  [61.393502, 30.51918,    -59.930316],
  [66.375139, -33.33801,   67.748322],
  [67.003845, -27.527522,  36.579796],
  [67.695147, -21.480799,  16.207293],
  [68.68311,  -13.380642,  -4.417532],
  [69.977287, -3.587375,   -24.515352],
  [71.575898, 7.4572,      -43.819054],
  [78.316771, -50.588122,  76.911559],
  [78.797566, -45.652609,  50.816515],
  [79.329,    -40.421283,  31.949585],
  [80.093416, -33.267162,  12.08616],
  [81.103283, -24.404697,  -7.752441],
  [82.363566, -14.147239,  -27.13044],
  [90.169923, -65.773256,  86.140744],
  [90.549932, -61.60075,   64.140414],
  [90.971292, -57.120187,  46.888243],
  [91.579785, -50.899197,  28.022766],
  [92.387927, -43.048597,  8.706633],
  [93.403093, -33.772988,  -10.485047],
  [36.202788, 60.403802,   50.584335],
  [37.73486,  64.508797,   -2.449278],
  [39.349153, 68.664559,   -25.141655],
  [41.546547, 74.085376,   -45.87666],
  [44.261968, 80.474184,   -64.862368],
  [47.40962,  87.536747,   -82.370081],
  [48.633814, 27.334063,   57.034969],
  [49.646888, 32.351526,   14.529353],
  [50.742905, 37.490517,   -7.752836],
  [52.27925,  44.258891,   -28.941823],
  [54.243497, 52.291618,   -48.817765],
  [56.603112, 61.191462,   -67.424062],
  [58.45415,  5.073643,    63.499246],
  [59.221693, 10.072221,   27.343009],
  [60.061062, 15.271388,   5.887256],
  [61.252706, 22.232048,   -15.185299],
  [62.800481, 30.642188,   -35.347178],
  [64.693315, 40.12222,    -54.476347],
  [69.308191, -16.253527,  71.241424],
  [69.894849, -11.59925,   40.793473],
  [70.540919, -6.685396,   20.579036],
  [71.466002, 0.003967,    -0.007848],
  [72.680819, 8.244924,    -20.148835],
  [74.18587,  17.725274,   -39.550995],
  [80.579988, -35.516599,  79.630469],
  [81.038674, -31.34819,   53.990118],
  [81.546035, -26.892578,  35.271395],
  [82.276485, -20.739844,  15.477472],
  [83.242638, -13.027903,  -4.350576],
  [84.450147, -3.986155,   -23.760304],
  [91.968562, -52.704506,  88.312599],
  [92.33608,  -49.038702,  66.606796],
  [92.743739, -45.082525,  49.480013],
  [93.332717, -39.557054,  30.69048],
  [94.115428, -32.532731,  11.407948],
  [95.099414, -24.163821,  -7.782358],
  [44.86738,  70.429595,   59.097778],
  [46.006266, 73.503738,   10.518261],
  [47.231037, 76.722243,   -12.362377],
  [48.936094, 81.068179,   -33.697112],
  [51.098094, 86.38203,    -53.491245],
  [53.671967, 92.464536,   -71.895056],
  [54.690715, 43.555852,   63.735017],
  [55.540706, 47.203522,   23.487573],
  [56.467021, 51.03861,    1.335351],
  [57.77666,  56.23638,    -20.012701],
  [59.468839, 62.609796,   -40.218202],
  [61.525873, 69.911695,   -59.255655],
  [63.156502, 22.862689,   68.903276],
  [63.836724, 26.638462,   34.180342],
  [64.583201, 30.638538,   12.932756],
  [65.647455, 36.105644,   -8.144764],
  [67.03725,  42.873761,   -28.445959],
  [68.747657, 50.70293,    -47.801931],
  [72.962305, 1.429997,    75.533818],
  [73.502195, 5.120799,    45.99291],
  [74.09775,  9.064861,    25.998816],
  [74.95226,  14.50941,    5.483401],
  [76.077432, 21.330839,   -14.687667],
  [77.47597,  29.324857,   -34.189598],
  [83.467602, -18.951279,  83.066041],
  [83.900215, -15.493196,  58.007841],
  [84.379135, -11.767994,  39.4882],
  [85.069355, -6.576565,   19.794184],
  [85.983565, 0.004625,    -0.009151],
  [87.128116, 7.820039,    -19.448325],
  [94.29827,  -37.67118,   91.106043],
  [94.650501, -34.514207,  69.781761],
  [95.041374, -31.090146,  52.8217],
  [95.606415, -26.279216,  34.135987],
  [96.357879, -20.116942,  14.902652],
  [97.303471, -12.710733,  -4.280234],
  [53.232882, 80.10931,    67.220068],
  [54.11837,  82.509552,   22.901121],
  [55.081885, 85.072482,   0.154061],
  [56.441633, 88.609511,   -21.467026],
  [58.194562, 93.044307,   -41.783546],
  [60.319934, 98.254219,   -60.842984],
  [61.171862, 58.017159,   70.735875],
  [61.88704,  60.779975,   32.933036],
  [62.670799, 63.734698,   11.047977],
  [63.786344, 67.818209,   -10.346824],
  [65.24,     72.943679,   -30.788392],
  [67.024497, 78.966325,   -50.181397],
  [68.451728, 39.352671,   74.866389],
  [69.050221, 42.263129,   41.773186],
  [69.709039, 45.387526,   20.823498],
  [70.651875, 49.724068,   -0.196395],
  [71.889146, 55.19455,    -20.593406],
  [73.42074,  61.656317,   -40.146864],
  [77.232943, 18.717646,   80.473854],
  [77.724894, 21.655071,   51.997564],
  [78.268458, 24.824181,   32.290523],
  [79.049958, 29.248646,   11.889841],
  [80.081763, 34.870457,   -8.285727],
  [81.368458, 41.564581,   -27.874514],
  [86.928585, -1.924215,   87.137158],
  [87.332764, 0.926246,    62.776858],
  [87.7806,   4.017404,    44.509231],
  [88.426737, 8.359763,    24.950493],
  [89.283823, 13.920426,   5.19243],
  [90.358827, 20.601511,   -14.266662],
  [97.138247, -21.555908,  94.482485],
  [97.473094, -18.868079,  73.622355],
  [97.844859, -15.939487,  56.871548],
  [98.38261,  -11.801804,  38.320269],
  [99.098378, -6.464022,   19.155187],
  [100.0,     0.00526,     -0.010408],
  [2.193388,  2.984079e-4, -5.904407e-4],
  [5.463862,  7.433522e-4, -0.001471],
  [10.268184, 0.001191,    -0.002357],
  [15.15972,  0.001413,    -0.002796],
  [19.865534, 0.001626,    -0.003218],
  [24.42132,  0.001833,    -0.003627],
  [28.851902, 0.002034,    -0.004024],
  [33.175472, 0.00223,     -0.004412],
  [37.40589,  0.002422,    -0.004792],
  [41.554043, 0.00261,     -0.005164],
  [45.628689, 0.002795,    -0.00553],
  [49.637014, 0.002977,    -0.005889],
  [53.585013, 0.003156,    -0.006244],
  [57.477756, 0.003332,    -0.006593],
  [61.319583, 0.003506,    -0.006938],
  [65.114245, 0.003678,    -0.007278],
  [68.865018, 0.003849,    -0.007615],
  [72.574783, 0.004017,    -0.007947],
  [76.246091, 0.004183,    -0.008277],
  [79.881216, 0.004348,    -0.008603],
  [83.4822,   0.004511,    -0.008926],
  [87.050879, 0.004673,    -0.009246],
  [90.58892,  0.004834,    -0.009564],
  [94.097834, 0.004993,    -0.009879],
]

export const CTERM_COLOR_MAP = {
  8: {
    'black':        0,
    'darkblue':     4,
    'darkgreen':    2,
    'darkcyan':     6,
    'darkred':      1,
    'darkmagenta':  5,
    'brown':        3,
    'darkyellow':   3,
    'lightgray':    7,
    'lightgrey':    7,
    'gray':         7,
    'grey':         7,
    'darkgray':     0,
    'darkgrey':     0,
    'blue':         4,
    'lightblue':    4,
    'green':        2,
    'lightgreen':   2,
    'cyan':         6,
    'lightcyan':    6,
    'red':          1,
    'lightred':     1,
    'magenta':      5,
    'lightmagenta': 5,
    'yellow':       3,
    'lightyellow':  3,
    'white':        7,
  },
  16: {
    'black':        0,
    'darkblue':     1,
    'darkgreen':    2,
    'darkcyan':     3,
    'darkred':      4,
    'darkmagenta':  5,
    'brown':        6,
    'darkyellow':   6,
    'lightgray':    7,
    'lightgrey':    7,
    'gray':         7,
    'grey':         7,
    'darkgray':     8,
    'darkgrey':     8,
    'blue':         9,
    'lightblue':    9,
    'green':        10,
    'lightgreen':   10,
    'cyan':         11,
    'lightcyan':    11,
    'red':          12,
    'lightred':     12,
    'magenta':      13,
    'lightmagenta': 13,
    'yellow':       14,
    'lightyellow':  14,
    'white':        15,
  }
}
# }}}

# Functions {{{
export def ColorNumber2Hex(num: number): string
  if num < 16
    return Cterm2Hex(num)
  endif
  return Xterm2Hex(num)
enddef

# Returns the number corresponding to the given color name.
# See :help cterm-colors
export def CtermColorNumber(name: string, t_Co: number): number
  if t_Co != 16 && t_Co != 8
    throw $'CtermColorNumber: t_Co must be 8 or 16. Got: {t_Co}'
  endif

  const num = get(CTERM_COLOR_MAP[t_Co], tolower(name), -1)

  if t_Co == 16 || num < 0
    return num
  endif

  return num + (g:colortemplate#ansi_style ? 8 : 0)
enddef

export def Cterm2Hex(num: number): string
  if num < 0 || num > 15
    throw $'Cterm color index out of range: {num} (must be between 0 and 15)'
  endif
  return ANSI_HEX[num]
enddef

# Return a conventional hex value for the given cterm color name
export def CtermName2Hex(name: string): string
  const num = CtermColorNumber(name, 16)
  return Cterm2Hex(num)
enddef

export def Xterm2Hex(num: number): string
  if num < 16 || num > 255
    throw $'Xterm color index out of range: {num} (must be between 16 and 255)'
  endif
  return XTERM256_COLORS[num - 16]
enddef

export def Xterm2Rgb(num: number): list<number>
  return Hex2Rgb(Xterm2Hex(num))
enddef

# Rescale a float in [0.0–1.0] to an integer scale
export def Scale(v: float, max = 255): number
  return float2nr(round(v * max))
enddef

export def DegToRad(degrees: float): float
  return degrees * PI / 180.0
enddef

# See:
# https://en.wikipedia.org/wiki/Relative_luminance
# https://www.w3.org/TR/WCAG20-TECHS/G18.html
export def RelativeLuminance(sR: number, sG: number, sB: number): float
  var var_R = sR / 255.0
  var var_G = sG / 255.0
  var var_B = sB / 255.0

  if var_R > 0.04045
    var_R = pow((var_R + 0.055) / 1.055, 2.4)
  else
    var_R = var_R / 12.92
  endif

  if var_G > 0.04045
    var_G = pow((var_G + 0.055) / 1.055, 2.4)
  else
    var_G = var_G / 12.92
  endif

  if var_B > 0.04045
    var_B = pow((var_B + 0.055) / 1.055, 2.4)
  else
    var_B = var_B / 12.92
  endif

  return 0.2126 * var_R + 0.7152 * var_G + 0.0722 * var_B
enddef

export def Hex2Rgb(color: string): list<number>
  if color =~# '^#'
    return [
      str2nr(color[1 : 2], 16),
      str2nr(color[3 : 4], 16),
      str2nr(color[5 : 6], 16),
    ]
  endif

  return [
    str2nr(color[0 : 1], 16),
    str2nr(color[2 : 3], 16),
    str2nr(color[4 : 5], 16),
  ]
enddef

export def Rgb2Hex(r: number, g: number, b: number): string
  return printf('#%02x%02x%02x', r, g, b)
enddef

# See https://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
export def Rgb2Gray(r: number, g: number, b: number): number
  const y = RelativeLuminance(r, g, b)

  if y <= 0.0031308
    return Scale(12.92 * y)
  endif

  return Scale(1.055 * pow(y, 0.4167) - 0.055)
enddef

export def Gray2Rgb(g: number): list<number>
  return [g, g, g]
enddef

export def Hex2Gray(color: string): number
  const [r, g, b] = Hex2Rgb(color)
  return Rgb2Gray(r, g, b)
enddef

export def Gray2Hex(g: number): string
  return Rgb2Hex(g, g, g)
enddef

# Convert an HSV color into RGB space.
# Input values are in [0-359, 0-100, 0-100]; output in in 0-255
# See: https://www.easyrgb.com/en/math.php
export def Hsv2Rgb(hh: number, ss: number, vv: number): list<number>
  # Scale to 0.0-1.0
  const h = hh / 360.0
  const s = ss / 100.0
  const v = vv / 100.0

  if s == 0.0
    const sv = Scale(v)
    return [sv, sv, sv]
  endif

  var var_h = h * 6.0

  if var_h >= 6.0
    var_h = 0.0
  endif

  const var_i = floor(var_h)
  const var_1 = v * (1.0 - s)
  const var_2 = v * (1.0 - s * (var_h - var_i))
  const var_3 = v * (1.0 - s * (1.0 - (var_h - var_i)))
  var   var_r = v
  var   var_g = var_1
  var   var_b = var_2

  if var_i == 0.0
    var_r = v
    var_g = var_3
    var_b = var_1
  elseif var_i == 1.0
    var_r = var_2
    var_g = v
    var_b = var_1
  elseif var_i == 2.0
    var_r = var_1
    var_g = v
    var_b = var_3
  elseif var_i == 3.0
    var_r = var_1
    var_g = var_2
    var_b = v
  elseif var_i == 4.0
    var_r = var_3
    var_g = var_1
    var_b = v
  endif

  return [Scale(var_r), Scale(var_g), Scale(var_b)]
enddef

# See above
# Input values must be in 0-255; output is in 0-359° for h, and 0-100% for s,v.
export def Rgb2Hsv(r: number, g: number, b: number): list<number>
  const var_r = r / 255.0
  const var_g = g / 255.0
  const var_b = b / 255.0
  const var_min = (var_r < var_g
    ? (var_r < var_b ? var_r : var_b)
    : (var_g < var_b ? var_g : var_b))
  const var_max = (var_r > var_g
    ? (var_r > var_b ? var_r : var_b)
    : (var_g > var_b ? var_g : var_b))
  const del_max = var_max - var_min
  const v = var_max
  var   h = 0.0
  var   s = 0.0

  if del_max != 0.0 # Chromatic data
    s = del_max / var_max
    const del_r = (((var_max - var_r) / 6.0) + (del_max / 2.0)) / del_max
    const del_g = (((var_max - var_g) / 6.0) + (del_max / 2.0)) / del_max
    const del_b = (((var_max - var_b) / 6.0) + (del_max / 2.0)) / del_max

    if var_r == var_max
      h = del_b - del_g
    elseif var_g == var_max
      h = (1.0 / 3.0) + del_r - del_b
    elseif var_b == var_max
      h = (2.0 / 3.0) + del_g - del_r
    endif

    if (h < 0.0)
      h += 1.0
    elseif (h > 1.0)
      h -= 1.0
    endif
  endif

  return [Scale(h, 360) % 360, Scale(s, 100), Scale(v, 100)]
enddef

export def Hsv2Hex(h: number, s: number, v: number): string
  const [r, g, b] = Hsv2Rgb(h, s, v)
  return Rgb2Hex(r, g, b)
enddef

export def Hex2Hsv(color: string): list<number>
  const [r, g, b] = Hex2Rgb(color)
  return Rgb2Hsv(r, g, b)
enddef

# See: https://www.easyrgb.com/en/math.php
# sR, sG and sB (Standard RGB) input range = 0 ÷ 255
# X, Y and Z output refer to a D65/2° standard illuminant.
export def Rgb2Xyz(sR: number, sG: number, sB: number): list<float>
  var var_R = sR / 255.0
  var var_G = sG / 255.0
  var var_B = sB / 255.0

  if var_R > 0.04045
    var_R = pow((var_R + 0.055) / 1.055, 2.4)
  else
    var_R = var_R / 12.92
  endif
  if var_G > 0.04045
    var_G = pow((var_G + 0.055) / 1.055, 2.4)
  else
    var_G = var_G / 12.92
  endif
  if var_B > 0.04045
    var_B = pow((var_B + 0.055) / 1.055, 2.4)
  else
    var_B = var_B / 12.92
  endif

  var_R = var_R * 100.0
  var_G = var_G * 100.0
  var_B = var_B * 100.0
  const X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
  const Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
  const Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505

  return [X, Y, Z]
enddef

export def Xyz2Cielab(X: float, Y: float, Z: float): list<float>
  # ref_X, ref_Y and ref_Z refer to specific illuminants and observers:
  # Observer=2°, Illuminant=D65
  const ref_X = 95.047
  const ref_Y = 100.0
  const ref_Z = 108.883
  var   var_X = X / ref_X
  var   var_Y = Y / ref_Y
  var   var_Z = Z / ref_Z

  if var_X > 0.008856
    var_X = pow(var_X, 1.0 / 3.0)
  else
    var_X = (7.787 * var_X) + (16.0 / 116.0)
  endif
  if var_Y > 0.008856
    var_Y = pow(var_Y, 1.0 / 3.0)
  else
    var_Y = (7.787 * var_Y) + (16.0 / 116.0)
  endif
  if var_Z > 0.008856
    var_Z = pow(var_Z, 1.0 / 3.0)
  else
    var_Z = (7.787 * var_Z) + (16.0 / 116.0)
  endif

  const L =  (116.0 * var_Y) - 16.0
  const a = 500.0 * (var_X - var_Y)
  const b = 200.0 * (var_Y - var_Z)

  return [L, a, b]
enddef

export def Rgb2Cielab(r: number, g: number, b: number): list<float>
  const [x, y, z] = Rgb2Xyz(r, g, b)
  return Xyz2Cielab(x, y, z)
enddef

export def Hex2Cielab(hexColor: string): list<float>
  const [r, g, b] = Hex2Rgb(hexColor)
  return Rgb2Cielab(r, g, b)
enddef

# Delta CIEDE2000 {{{
# See: https://en.wikipedia.org/wiki/Color_difference
# See: https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/
export def DeltaE2000(
    L1: float, a1: float, b1: float,
    L2: float, a2: float, b2: float,
    k_L = 1.0, k_C = 1.0, k_H = 1.0
    ): float
  const C_star_1 = sqrt(a1 * a1 + b1 * b1)     # Eq (2)
  const C_star_2 = sqrt(a2 * a2 + b2 * b2)     # Eq (2)
  const C_bar    = 0.5 * (C_star_1 + C_star_2) # Eq (3)

  # Eq (4)
  const C_bar_pow_7 = pow(C_bar, 7)
  const G = 0.5 * (1.0 - sqrt(C_bar_pow_7 / (C_bar_pow_7 + 6103515625)))

  # Eq (5)
  const a_prime_1 = (1.0 + G) * a1
  const a_prime_2 = (1.0 + G) * a2

  # Eq (6)
  const C_prime_1 = sqrt(a_prime_1 * a_prime_1 + b1 * b1)
  const C_prime_2 = sqrt(a_prime_2 * a_prime_2 + b2 * b2)

  # Eq (7) - See note 1 on page 23 of G Sharma et al., 2005
  var h_prime_1 = atan2(b1, a_prime_1) * 180.0 / PI # atan2(0.0, 0.0) == 0.0 by definition
  var h_prime_2 = atan2(b2, a_prime_2) * 180.0 / PI

  if h_prime_1 < 0.0
    h_prime_1 += 360.0
  endif

  if h_prime_2 < 0.0
    h_prime_2 += 360.0
  endif

  # Eq (8)
  const delta_L_prime = L2 - L1

  # Eq (9)
  const delta_C_prime = C_prime_2 - C_prime_1

  # Eq (10)
  var delta_h_prime: float = 0.0
  const h_prime_abs_delta = abs(h_prime_1 - h_prime_2)

  if C_prime_1 * C_prime_2 != 0.0
    if h_prime_abs_delta <= 180.0
      delta_h_prime = h_prime_2 - h_prime_1
    elseif h_prime_2 - h_prime_1 > 180
      delta_h_prime = h_prime_2 - h_prime_1 - 360.0
    else
      delta_h_prime = h_prime_2 - h_prime_1 + 360.0
    endif
  endif

  # Eq (11)
  const delta_H_prime = 2.0 * sqrt(C_prime_1 * C_prime_2) * sin(delta_h_prime * PI / 360.0)

  # Eq (12)
  const L_bar_prime = 0.5 * (L1 + L2)

  # Eq (13)
  const C_bar_prime = 0.5 * (C_prime_1 + C_prime_2)

  # Eq (14)
  var h_bar_prime: float

  if C_prime_1 * C_prime_2 == 0.0
    h_bar_prime = h_prime_1 + h_prime_2
  else
    if (h_prime_abs_delta <= 180.0)
      h_bar_prime = 0.5 * (h_prime_1 + h_prime_2)
    elseif h_prime_1 + h_prime_2 < 360.0
      h_bar_prime = 0.5 * (h_prime_1 + h_prime_2 + 360.0)
    else
      h_bar_prime = 0.5 * (h_prime_1 + h_prime_2 - 360.0)
    endif
  endif

  # Eq (15)
  const T = 1.0
    - 0.17 * cos(DegToRad(h_bar_prime - 30.0))
    + 0.24 * cos(DegToRad(h_bar_prime * 2.0))
    + 0.32 * cos(DegToRad(h_bar_prime * 3.0 + 6.0))
    - 0.20 * cos(DegToRad(h_bar_prime * 4.0 - 63.0))

  # Eq (16)
  var h_bar_prime_minus_275_div_25_square = (h_bar_prime - 275.0) / 25.0
  h_bar_prime_minus_275_div_25_square = h_bar_prime_minus_275_div_25_square * h_bar_prime_minus_275_div_25_square
  const delta_theta = 60.0 * exp(-h_bar_prime_minus_275_div_25_square)

  # Eq (17)
  const C_bar_prime_pow_7 = pow(C_bar_prime, 7)
  const R_C = 2.0 * sqrt(C_bar_prime_pow_7 / (C_bar_prime_pow_7 + 6103515625))

  # Eq (18)
  var L_bar_prime_minus_50_squared = L_bar_prime - 50.0
  L_bar_prime_minus_50_squared = L_bar_prime_minus_50_squared * L_bar_prime_minus_50_squared
  const S_L = 1.0 + ((0.015 * L_bar_prime_minus_50_squared) / sqrt(20.0 + L_bar_prime_minus_50_squared))

  # Eq (19)
  const S_C = 1.0 + 0.045 * C_bar_prime

  # Eq (20)
  const S_H = 1.0 + 0.015 * T * C_bar_prime

  # Eq (21)
  const R_T = -R_C * sin(DegToRad(delta_theta))

  # Eq (22)
  const delta_L_prime_div_k_L_S_L = delta_L_prime / (S_L * k_L)
  const delta_C_prime_div_k_C_S_C = delta_C_prime / (S_C * k_C)
  const delta_H_prime_div_k_H_S_H = delta_H_prime / (S_H * k_H)
  const deltaE = sqrt(
    delta_L_prime_div_k_L_S_L * delta_L_prime_div_k_L_S_L
    + delta_C_prime_div_k_C_S_C * delta_C_prime_div_k_C_S_C
    + delta_H_prime_div_k_H_S_H * delta_H_prime_div_k_H_S_H
    + R_T * delta_C_prime_div_k_C_S_C * delta_H_prime_div_k_H_S_H
  )

  return deltaE
enddef
# }}}

var cache: dict<any> = {}

# Return a dictionary with the following keys:
# xterm [number] the base-256 color number that best approximates the given color
# hex   [string] the hex value of the approximate xterm color
# delta [float]  the CIEDE2000 difference between the input color and its approximation
export def Approximate(hexColor: string): dict<any>
  if has_key(cache, hexColor)
    return cache[hexColor]
  endif

  const [L1, a1, b1] = Hex2Cielab(hexColor)
  var   delta: float = 1.0 / 0.0
  var   colorIndex   = -1
  const N            = len(XTERM256_COLORS)
  var   i            = 0

  while i < N
    const [L2, a2, b2] = XTERM_CIELAB[i]
    const new_delta = DeltaE2000(L1, a1, b1, L2, a2, b2)

    if new_delta < delta
      delta = new_delta
      colorIndex = i
    endif

    ++i
  endwhile

  cache[hexColor] = {
    xterm: colorIndex + 16,
    hex:   XTERM256_COLORS[colorIndex],
    delta: delta,
  }

  return cache[hexColor]
enddef

# Return a list of colors at distance less than the specified threshold from
# the given color.
# hexColor: a hexdecimal color
# colorsList: an optional list of candidate hex colors
export def ColorsWithin(
    hexColor: string, threshold: float, colorsList: list<string> = []
    ): list<number>
  const [L1, a1, b1]             = Hex2Cielab(hexColor)
  const candidates               = empty(colorsList) ? XTERM256_COLORS : colorsList
  const N                        = len(candidates)
  var   neighbours: list<number> = []
  var   i                        = 0


  while i < N
    const color = candidates[i]
    const [L2, a2, b2] = Hex2Cielab(color)
    const delta = DeltaE2000(L1, a1, b1, L2, a2, b2)

    if delta <= threshold
      neighbours->add(i + 16)
    endif

    ++i
  endwhile

  return neighbours
enddef

# Return the list of the k colors nearest to the given color.
# hexColor:   a hex color.
# k:          a number between 1 and 240 (or between 1 and the number of
#             colors in the list passed as the third argument).
# colorsList: an optional list of hex colors.
#
# Return value: a list of dictionaries with the following keys:
# xterm: a color index
# hex:   the hex value of the approximate xterm color
# delta: the CIEDE2000 distance from the given color
#
# NOTE: this is a highly inefficient implementation!
export def Neighbours(
    hexColor: string, k: number, colorsList: list<string> = []
    ): list<dict<any>>
  const [L1, a1, b1] = Hex2Cielab(hexColor)
  const candidates   = empty(colorsList) ? XTERM256_COLORS : colorsList
  const N            = len(candidates)

  if k < 1
    return []
  endif

  if k > N
    throw $'Requested too many neighbours: k={k}, but there are only {N} candidates'
  endif

  var neighbours: list<dict<any>> = []
  var j = 0

  while j < k
    var delta = 1.0 / 0.0
    var colorIndex = -1
    var i = 0

    while i < N
      if match(neighbours, string(i + 16)) > -1
        ++i
        continue
      endif

      const xtermColor   = candidates[i]
      const [L2, a2, b2] = Hex2Cielab(xtermColor)
      const new_delta    = DeltaE2000(L1, a1, b1, L2, a2, b2)

      if new_delta < delta
        delta = new_delta
        colorIndex = i
      endif

      ++i
    endwhile

    neighbours->add({
      xterm: colorIndex + 16,
      hex: XTERM256_COLORS[colorIndex],
      delta: delta,
    })

    ++j
  endwhile

  return sort(neighbours, (i1, i2) => i1.delta < i2.delta ? -1 : i1.delta > i2.delta ? 1 : 0)
enddef

# def colortemplate#colorspace#k_neighbors(color, k)
#   return colortemplate#colorspace#k_neighbours(a:color, a:k)
# enddef
#
# Return the color (black or white) which contrasts most with the given color
# See: https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color/3943023#3943023
export def ContrastColor(color: string): string
  const [r, g, b] = Hex2Rgb(color)

  if r * 0.299 + g * 0.587 + b * 0.114 > 186
    return '#000000'
  else
    return '#ffffff'
  endif
enddef

# Return the hex value of the specified color name.
export def RgbName2Hex(colorName: string, default = ''): string
  const name = tolower(colorName)
  return get(v:colornames, name, default)
enddef
# }}}

# Classes {{{
export class Rgb
  var r: number # 0–255
  var g: number # 0–255
  var b: number # 0–255

  def newHex(hexColor: string)
    [this.r, this.g, this.b] = Hex2Rgb(hexColor)
  enddef

  def RelativeLuminance(): float
    return RelativeLuminance(this.r, this.g, this.b)
  enddef

  def Hex(): string
    return Rgb2Hex(this.r, this.g, this.b)
  enddef

  def ToGray(): number
    return Rgb2Gray(this.r, this.g, this.b)
  enddef

  def ToHsv(): any
    const [h, s, v] = Rgb2Hsv(this.r, this.g, this.b)
    return Hsv.new(h, s, v)
  enddef
endclass

export class Hsv
  var h: number # 0–360°
  var s: number # 0–100%
  var v: number # 0–100%

  def newHex(hexColor: string)
    [this.r, this.g, this.b] = Hex2Rgb(hexColor)
  enddef

  def RelativeLuminance(): float
    # TODO: better way
    const [r, g, b] = Hsv2Rgb(this.h, this.s, this.v)
    return RelativeLuminance(r, g, b)
  enddef

  def Hex(): string
    return Hsv2Hex(this.h, this.s, this.v)
  enddef

  def ToGray(): number
    const [r, g, b] = Hsv2Rgb(this.h, this.s, this.v)
    return Rgb2Gray(r, g, b)
  enddef

  def ToRgb(): Rgb
    const [r, g, b] = Hsv2Rgb(this.h, this.s, this.v)
    return Rgb.new(r, g, b)
  enddef
endclass

# }}}

def ToRgb(col: any): Rgb
  if type(col) == v:t_string
    return Rgb.newHex(col)
  endif

  return col
enddef

export def ContrastRatio(col1: any, col2: any): float
  const rgb1 = ToRgb(col1)
  const rgb2 = ToRgb(col2)
  const L1 = rgb1.RelativeLuminance()
  const L2 = rgb2.RelativeLuminance()
  return L1 > L2 ? (L1 + 0.05) / (L2 + 0.05) : (L2 + 0.05) / (L1 + 0.05)
enddef

export def BrightnessDifference(col1: any, col2: any): float
  const rgb1 = ToRgb(col1)
  const rgb2 = ToRgb(col2)
  const [sR1, sG1, sB1] = [rgb1.r, rgb1.g, rgb1.b]
  const [sR2, sG2, sB2] = [rgb2.r, rgb2.g, rgb2.b]

  # return ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
  return abs(
    ((sR1 * 299.0 + sG1 * 587.0 + sB1 * 114.0) / 1000.0)
    - ((sR2 * 299.0 + sG2 * 587.0 + sB2 * 114.0) / 1000.0)
  )
enddef

export def ColorDifference(col1: any, col2: any): float
  const [sR1, sG1, sB1] = type(col1) == v:t_string ? Hex2Rgb(col1) : [col1.r, col1.g, col1.b]
  const [sR2, sG2, sB2] = type(col2) == v:t_string ? Hex2Rgb(col2) : [col2.r, col2.g, col2.b]
  return 1.0 * (abs(sR1 - sR2) + abs(sG1 - sG2) + abs(sB1 - sB2))
enddef

export def PerceptualDifference(col1: any, col2: any): float
  const [L1, a1, b1] = type(col1) == v:t_string ? Hex2Cielab(col1) : Rgb2Cielab(col1.r, col1.g, col1.b)
  const [L2, a2, b2] = type(col2) == v:t_string ? Hex2Cielab(col2) : Rgb2Cielab(col2.r, col2.g, col2.b)

  return DeltaE2000(L1, a1, b1, L2, a2, b2)
enddef

# vim: foldmethod=marker nowrap et ts=2 sw=2

-- text_metric_data.lua - MACHINE-EMITTED by addons/tools/emit_text_metric.py.
-- ⚠⚠ DO NOT EDIT. Re-run the tool; a hand edit is a number with no source.
--
-- Per-character advances in EMS, straight out of the client's own font files in
-- locale-enUS.MPQ, plus a per-font-object linear correction (k, c) fitted on the
-- sheet's CALIBRATION strings alone and scored on the SPECIMEN strings it never saw.
--
--     width_in_quanta = round(sum(adv[ch]) * k) + c        (check_sheet's model)
--
-- ⚠ `heldWorst` is the error in QUANTA on strings the fit never touched. It is the
-- honest number; `fitWorst` only says the fitter converged.
local M = {}

-- ★★★ THE WIDTH QUANTUM, COMPUTED:  q = 3 * (screenW/screenH) / (10 * uiScale)
-- Tested against 11 measured configuration(s); worst relative error 1.01e-07.
-- ⚠ The VERTICAL grid (UL-10) is the same formula on the NOMINAL 16:9 rather than
-- the screen's own aspect, which is the whole 0.0123% between them:
--     q_v = 3 * (16/9) / (10 * uiScale) = 8 / (15 * uiScale)   ->  1/q_v = uiScale * 1.875
M.qAspectK = 0.3          -- the 3/10
M.qNominalAspect = 1.777777778
M.qWorstRelative = 1.007e-07
M.qN = 11

M.adv = {
  ["ARIALN.ttf"] = { [32]=0.228027, [33]=0.228027, [34]=0.291016, [35]=0.456055, [36]=0.456055, [37]=0.729004, [38]=0.546875, [39]=0.157227, [40]=0.272949, [41]=0.272949, [42]=0.318848, [43]=0.479004, [44]=0.228027, [45]=0.272949, [46]=0.228027, [47]=0.228027, [48]=0.456055, [49]=0.456055, [50]=0.456055, [51]=0.456055, [52]=0.456055, [53]=0.456055, [54]=0.456055, [55]=0.456055, [56]=0.456055, [57]=0.456055, [58]=0.228027, [59]=0.228027, [60]=0.479004, [61]=0.479004, [62]=0.479004, [63]=0.456055, [64]=0.832031, [65]=0.546875, [66]=0.546875, [67]=0.591797, [68]=0.591797, [69]=0.546875, [70]=0.500977, [71]=0.638184, [72]=0.591797, [73]=0.228027, [74]=0.410156, [75]=0.546875, [76]=0.456055, [77]=0.683105, [78]=0.591797, [79]=0.638184, [80]=0.546875, [81]=0.638184, [82]=0.591797, [83]=0.546875, [84]=0.500977, [85]=0.591797, [86]=0.546875, [87]=0.773926, [88]=0.546875, [89]=0.546875, [90]=0.500977, [91]=0.228027, [92]=0.228027, [93]=0.228027, [94]=0.384766, [95]=0.456055, [96]=0.272949, [97]=0.456055, [98]=0.456055, [99]=0.410156, [100]=0.456055, [101]=0.456055, [102]=0.228027, [103]=0.456055, [104]=0.456055, [105]=0.182129, [106]=0.182129, [107]=0.410156, [108]=0.182129, [109]=0.683105, [110]=0.456055, [111]=0.456055, [112]=0.456055, [113]=0.456055, [114]=0.272949, [115]=0.410156, [116]=0.228027, [117]=0.456055, [118]=0.410156, [119]=0.591797, [120]=0.410156, [121]=0.410156, [122]=0.410156, [123]=0.273926, [124]=0.212891, [125]=0.273926, [126]=0.479004 },
  ["ARIALN.ttf#mean"] = 0.432124,
  ["FRIZQT__.TTF"] = { [32]=0.261000, [33]=0.426000, [34]=0.640000, [35]=0.640000, [36]=0.556000, [37]=0.738000, [38]=0.852000, [39]=0.426000, [40]=0.322000, [41]=0.325000, [42]=0.640000, [43]=0.640000, [44]=0.257000, [45]=0.393000, [46]=0.257000, [47]=0.430000, [48]=0.640000, [49]=0.640000, [50]=0.640000, [51]=0.640000, [52]=0.640000, [53]=0.640000, [54]=0.640000, [55]=0.640000, [56]=0.640000, [57]=0.640000, [58]=0.257000, [59]=0.257000, [60]=0.521000, [61]=0.640000, [62]=0.521000, [63]=0.532000, [64]=0.889000, [65]=0.767000, [66]=0.633000, [67]=0.670000, [68]=0.743000, [69]=0.550000, [70]=0.469000, [71]=0.793000, [72]=0.791000, [73]=0.304000, [74]=0.290000, [75]=0.657000, [76]=0.552000, [77]=1.003000, [78]=0.788000, [79]=0.856000, [80]=0.577000, [81]=0.855000, [82]=0.633000, [83]=0.580000, [84]=0.538000, [85]=0.752000, [86]=0.655000, [87]=1.002000, [88]=0.722000, [89]=0.638000, [90]=0.654000, [91]=0.333000, [92]=0.374000, [93]=0.328000, [94]=0.521000, [95]=0.521000, [96]=0.521000, [97]=0.545000, [98]=0.588000, [99]=0.521000, [100]=0.624000, [101]=0.582000, [102]=0.333000, [103]=0.619000, [104]=0.589000, [105]=0.256000, [106]=0.254000, [107]=0.528000, [108]=0.252000, [109]=0.926000, [110]=0.593000, [111]=0.631000, [112]=0.627000, [113]=0.625000, [114]=0.349000, [115]=0.467000, [116]=0.347000, [117]=0.589000, [118]=0.568000, [119]=0.833000, [120]=0.552000, [121]=0.561000, [122]=0.517000, [123]=0.333000, [124]=0.521000, [125]=0.333000, [126]=0.695000 },
  ["FRIZQT__.TTF#mean"] = 0.564716,
}

M.fonts = {
  ["ChatFontNormal"] = { file="ARIALN.ttf", size=14.0000, byScale = {
    ["0.6400"] = { k=16.449066667, c=8, fitWorst=5, heldWorst=5, heldN=19 },
    ["0.6500"] = { k=16.449066667, c=10, fitWorst=5, heldWorst=6, heldN=19 },
    ["0.8200"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=5, heldN=19 },
    ["0.8500"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=5, heldN=19 },
    ["0.8600"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=4, heldN=19 },
    ["1.0000"] = { k=26.193066667, c=5, fitWorst=2, heldWorst=2, heldN=19 },
  } },
  ["ChatFontSmall"] = { file="ARIALN.ttf", size=12.0000, byScale = {
    ["0.6400"] = { k=15.350400000, c=4, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.6500"] = { k=15.849600000, c=5, fitWorst=1, heldWorst=3, heldN=19 },
    ["0.8200"] = { k=19.737600000, c=4, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8500"] = { k=19.737600000, c=5, fitWorst=1, heldWorst=3, heldN=19 },
    ["0.8600"] = { k=19.737600000, c=5, fitWorst=1, heldWorst=3, heldN=19 },
    ["1.0000"] = { k=24.121600000, c=8, fitWorst=5, heldWorst=4, heldN=19 },
  } },
  ["GameFontDisable"] = { file="FRIZQT__.TTF", size=12.0000, byScale = {
    ["0.6400"] = { k=14.608000000, c=4, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.6500"] = { k=15.852800000, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8200"] = { k=19.024000000, c=4, fitWorst=0, heldWorst=1, heldN=19 },
    ["0.8500"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.8600"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["1.0000"] = { k=24.358400000, c=6, fitWorst=3, heldWorst=4, heldN=19 },
  } },
  ["GameFontDisableSmall"] = { file="FRIZQT__.TTF", size=10.0000, byScale = {
    ["0.6400"] = { k=12.970666667, c=8, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.6500"] = { k=12.970666667, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8200"] = { k=15.850666667, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8500"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8600"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["1.0000"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
  } },
  ["GameFontHighlight"] = { file="FRIZQT__.TTF", size=12.0000, byScale = {
    ["0.6400"] = { k=14.608000000, c=4, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.6500"] = { k=15.852800000, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8200"] = { k=19.024000000, c=4, fitWorst=0, heldWorst=1, heldN=19 },
    ["0.8500"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.8600"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["1.0000"] = { k=24.358400000, c=6, fitWorst=3, heldWorst=4, heldN=19 },
  } },
  ["GameFontHighlightSmall"] = { file="FRIZQT__.TTF", size=10.0000, byScale = {
    ["0.6400"] = { k=12.970666667, c=8, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.6500"] = { k=12.970666667, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8200"] = { k=15.850666667, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8500"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8600"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["1.0000"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
  } },
  ["GameFontNormal"] = { file="FRIZQT__.TTF", size=12.0000, byScale = {
    ["0.6400"] = { k=14.608000000, c=4, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.6500"] = { k=15.852800000, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8200"] = { k=19.024000000, c=4, fitWorst=0, heldWorst=1, heldN=19 },
    ["0.8500"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.8600"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["1.0000"] = { k=24.358400000, c=6, fitWorst=3, heldWorst=4, heldN=19 },
  } },
  ["GameFontNormalLarge"] = { file="FRIZQT__.TTF", size=16.0000, byScale = {
    ["0.6400"] = { k=19.763200000, c=4, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.6500"] = { k=21.060266667, c=9, fitWorst=5, heldWorst=10, heldN=19 },
    ["0.8200"] = { k=25.915733333, c=3, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8500"] = { k=27.221333333, c=3, fitWorst=1, heldWorst=4, heldN=19 },
    ["0.8600"] = { k=27.221333333, c=3, fitWorst=1, heldWorst=4, heldN=19 },
    ["1.0000"] = { k=30.779733333, c=3, fitWorst=2, heldWorst=3, heldN=19 },
  } },
  ["GameFontNormalSmall"] = { file="FRIZQT__.TTF", size=10.0000, byScale = {
    ["0.6400"] = { k=12.970666667, c=8, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.6500"] = { k=12.970666667, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8200"] = { k=15.850666667, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8500"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["0.8600"] = { k=16.829333333, c=9, fitWorst=5, heldWorst=9, heldN=19 },
    ["1.0000"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
  } },
  ["GameFontRed"] = { file="FRIZQT__.TTF", size=12.0000, byScale = {
    ["0.6400"] = { k=14.608000000, c=4, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.6500"] = { k=15.852800000, c=5, fitWorst=1, heldWorst=2, heldN=19 },
    ["0.8200"] = { k=19.024000000, c=4, fitWorst=0, heldWorst=1, heldN=19 },
    ["0.8500"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["0.8600"] = { k=19.760000000, c=5, fitWorst=1, heldWorst=1, heldN=19 },
    ["1.0000"] = { k=24.358400000, c=6, fitWorst=3, heldWorst=4, heldN=19 },
  } },
  ["NumberFontNormal"] = { file="ARIALN.ttf", size=14.0000, byScale = {
    ["0.6400"] = { k=16.449066667, c=10, fitWorst=5, heldWorst=6, heldN=19 },
    ["0.6500"] = { k=16.449066667, c=10, fitWorst=5, heldWorst=6, heldN=19 },
    ["0.8200"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=5, heldN=19 },
    ["0.8500"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=5, heldN=19 },
    ["0.8600"] = { k=24.121066667, c=8, fitWorst=5, heldWorst=4, heldN=19 },
    ["1.0000"] = { k=26.193066667, c=5, fitWorst=2, heldWorst=2, heldN=19 },
  } },
}

return M

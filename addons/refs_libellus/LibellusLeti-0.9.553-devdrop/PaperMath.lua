-- Paper DPS math from client DBC combat ratings + live unit combat sheets.
-- Owner→pet inheritance (creature dump / calibrated) applies to Raised minions generally.
-- Ghoul Command uses Spell.dbc 504021 coeffs; Necromancy inherit rates remain calibrated.
Mancer.PaperMathModule = {}
local PaperMath = Mancer.PaperMathModule

-- Rating → % by exact level from `dbc files/gt_combat_ratings.tsv`
-- (exported from client `gtCombatRatings.dbc`).
PaperMath.RATING = {
    [1] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.608462, meleeCrit = 0.608462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.608462, haste = 0.384615 },
    [2] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.628462, meleeCrit = 0.628462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.628462, haste = 0.384615 },
    [3] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.648462, meleeCrit = 0.648462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.648462, haste = 0.384615 },
    [4] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.668462, meleeCrit = 0.668462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.668462, haste = 0.384615 },
    [5] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.688462, meleeCrit = 0.688462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.688462, haste = 0.384615 },
    [6] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.708462, meleeCrit = 0.708462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.708462, haste = 0.384615 },
    [7] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.728462, meleeCrit = 0.728462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.728462, haste = 0.384615 },
    [8] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.748462, meleeCrit = 0.748462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.748462, haste = 0.384615 },
    [9] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.768462, meleeCrit = 0.768462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.768462, haste = 0.384615 },
    [10] = { spellHit = 0.307692, meleeHit = 0.384615, spellCrit = 0.788462, meleeCrit = 0.788462, spellHaste = 0.384615, meleeHaste = 0.384615, resilience = 0.17, crit = 0.788462, haste = 0.384615 },
    [11] = { spellHit = 0.461538, meleeHit = 0.576923, spellCrit = 0.807692, meleeCrit = 0.807692, spellHaste = 0.576923, meleeHaste = 0.576923, resilience = 0.24, crit = 0.807692, haste = 0.576923 },
    [12] = { spellHit = 0.615385, meleeHit = 0.769231, spellCrit = 1.07692, meleeCrit = 1.07692, spellHaste = 0.769231, meleeHaste = 0.769231, resilience = 0.32, crit = 1.07692, haste = 0.769231 },
    [13] = { spellHit = 0.769231, meleeHit = 0.961538, spellCrit = 1.34615, meleeCrit = 1.34615, spellHaste = 0.961538, meleeHaste = 0.961538, resilience = 0.4, crit = 1.34615, haste = 0.961538 },
    [14] = { spellHit = 0.923077, meleeHit = 1.15385, spellCrit = 1.61539, meleeCrit = 1.61539, spellHaste = 1.15385, meleeHaste = 1.15385, resilience = 0.49, crit = 1.61539, haste = 1.15385 },
    [15] = { spellHit = 1.07692, meleeHit = 1.34615, spellCrit = 1.88461, meleeCrit = 1.88461, spellHaste = 1.34615, meleeHaste = 1.34615, resilience = 0.56, crit = 1.88461, haste = 1.34615 },
    [16] = { spellHit = 1.23077, meleeHit = 1.53846, spellCrit = 2.15385, meleeCrit = 2.15385, spellHaste = 1.53846, meleeHaste = 1.53846, resilience = 0.65, crit = 2.15385, haste = 1.53846 },
    [17] = { spellHit = 1.38461, meleeHit = 1.73077, spellCrit = 2.42308, meleeCrit = 2.42308, spellHaste = 1.73077, meleeHaste = 1.73077, resilience = 0.73, crit = 2.42308, haste = 1.73077 },
    [18] = { spellHit = 1.53846, meleeHit = 1.92308, spellCrit = 2.69231, meleeCrit = 2.69231, spellHaste = 1.92308, meleeHaste = 1.92308, resilience = 0.81, crit = 2.69231, haste = 1.92308 },
    [19] = { spellHit = 1.69231, meleeHit = 2.11539, spellCrit = 2.96154, meleeCrit = 2.96154, spellHaste = 2.11539, meleeHaste = 2.11539, resilience = 0.88, crit = 2.96154, haste = 2.11539 },
    [20] = { spellHit = 1.84615, meleeHit = 2.30769, spellCrit = 3.23077, meleeCrit = 3.23077, spellHaste = 2.30769, meleeHaste = 2.30769, resilience = 0.97, crit = 3.23077, haste = 2.30769 },
    [21] = { spellHit = 2, meleeHit = 2.5, spellCrit = 3.5, meleeCrit = 3.5, spellHaste = 2.5, meleeHaste = 2.5, resilience = 1.05, crit = 3.5, haste = 2.5 },
    [22] = { spellHit = 2.15385, meleeHit = 2.69231, spellCrit = 3.76923, meleeCrit = 3.76923, spellHaste = 2.69231, meleeHaste = 2.69231, resilience = 1.13, crit = 3.76923, haste = 2.69231 },
    [23] = { spellHit = 2.30769, meleeHit = 2.88461, spellCrit = 4.03846, meleeCrit = 4.03846, spellHaste = 2.88461, meleeHaste = 2.88461, resilience = 1.22, crit = 4.03846, haste = 2.88461 },
    [24] = { spellHit = 2.46154, meleeHit = 3.07692, spellCrit = 4.30769, meleeCrit = 4.30769, spellHaste = 3.07692, meleeHaste = 3.07692, resilience = 1.29, crit = 4.30769, haste = 3.07692 },
    [25] = { spellHit = 2.61539, meleeHit = 3.26923, spellCrit = 4.57692, meleeCrit = 4.57692, spellHaste = 3.26923, meleeHaste = 3.26923, resilience = 1.37, crit = 4.57692, haste = 3.26923 },
    [26] = { spellHit = 2.76923, meleeHit = 3.46154, spellCrit = 4.84615, meleeCrit = 4.84615, spellHaste = 3.46154, meleeHaste = 3.46154, resilience = 1.45, crit = 4.84615, haste = 3.46154 },
    [27] = { spellHit = 2.92308, meleeHit = 3.65385, spellCrit = 5.11539, meleeCrit = 5.11539, spellHaste = 3.65385, meleeHaste = 3.65385, resilience = 1.54, crit = 5.11539, haste = 3.65385 },
    [28] = { spellHit = 3.07692, meleeHit = 3.84615, spellCrit = 5.38461, meleeCrit = 5.38461, spellHaste = 3.84615, meleeHaste = 3.84615, resilience = 1.61, crit = 5.38461, haste = 3.84615 },
    [29] = { spellHit = 3.23077, meleeHit = 4.03846, spellCrit = 5.65385, meleeCrit = 5.65385, spellHaste = 4.03846, meleeHaste = 4.03846, resilience = 1.7, crit = 5.65385, haste = 4.03846 },
    [30] = { spellHit = 3.38461, meleeHit = 4.23077, spellCrit = 5.92308, meleeCrit = 5.92308, spellHaste = 4.23077, meleeHaste = 4.23077, resilience = 1.78, crit = 5.92308, haste = 4.23077 },
    [31] = { spellHit = 3.53846, meleeHit = 4.42308, spellCrit = 6.19231, meleeCrit = 6.19231, spellHaste = 4.42308, meleeHaste = 4.42308, resilience = 1.86, crit = 6.19231, haste = 4.42308 },
    [32] = { spellHit = 3.69231, meleeHit = 4.61539, spellCrit = 6.46154, meleeCrit = 6.46154, spellHaste = 4.61539, meleeHaste = 4.61539, resilience = 1.95, crit = 6.46154, haste = 4.61539 },
    [33] = { spellHit = 3.84615, meleeHit = 4.80769, spellCrit = 6.73077, meleeCrit = 6.73077, spellHaste = 4.80769, meleeHaste = 4.80769, resilience = 2.02, crit = 6.73077, haste = 4.80769 },
    [34] = { spellHit = 4, meleeHit = 5, spellCrit = 7, meleeCrit = 7, spellHaste = 5, meleeHaste = 5, resilience = 2.1, crit = 7, haste = 5 },
    [35] = { spellHit = 4.15385, meleeHit = 5.19231, spellCrit = 7.26923, meleeCrit = 7.26923, spellHaste = 5.19231, meleeHaste = 5.19231, resilience = 2.18, crit = 7.26923, haste = 5.19231 },
    [36] = { spellHit = 4.30769, meleeHit = 5.38461, spellCrit = 7.53846, meleeCrit = 7.53846, spellHaste = 5.38461, meleeHaste = 5.38461, resilience = 2.27, crit = 7.53846, haste = 5.38461 },
    [37] = { spellHit = 4.46154, meleeHit = 5.57692, spellCrit = 7.80769, meleeCrit = 7.80769, spellHaste = 5.57692, meleeHaste = 5.57692, resilience = 2.34, crit = 7.80769, haste = 5.57692 },
    [38] = { spellHit = 4.61539, meleeHit = 5.76923, spellCrit = 8.07692, meleeCrit = 8.07692, spellHaste = 5.76923, meleeHaste = 5.76923, resilience = 2.42, crit = 8.07692, haste = 5.76923 },
    [39] = { spellHit = 4.76923, meleeHit = 5.96154, spellCrit = 8.34615, meleeCrit = 8.34615, spellHaste = 5.96154, meleeHaste = 5.96154, resilience = 2.5, crit = 8.34615, haste = 5.96154 },
    [40] = { spellHit = 4.92308, meleeHit = 6.15385, spellCrit = 8.61538, meleeCrit = 8.61538, spellHaste = 6.15385, meleeHaste = 6.15385, resilience = 2.59, crit = 8.61538, haste = 6.15385 },
    [41] = { spellHit = 5.07692, meleeHit = 6.34615, spellCrit = 8.88461, meleeCrit = 8.88461, spellHaste = 6.34615, meleeHaste = 6.34615, resilience = 2.66, crit = 8.88461, haste = 6.34615 },
    [42] = { spellHit = 5.23077, meleeHit = 6.53846, spellCrit = 9.15385, meleeCrit = 9.15385, spellHaste = 6.53846, meleeHaste = 6.53846, resilience = 2.75, crit = 9.15385, haste = 6.53846 },
    [43] = { spellHit = 5.38461, meleeHit = 6.73077, spellCrit = 9.42308, meleeCrit = 9.42308, spellHaste = 6.73077, meleeHaste = 6.73077, resilience = 2.83, crit = 9.42308, haste = 6.73077 },
    [44] = { spellHit = 5.53846, meleeHit = 6.92308, spellCrit = 9.69231, meleeCrit = 9.69231, spellHaste = 6.92308, meleeHaste = 6.92308, resilience = 2.91, crit = 9.69231, haste = 6.92308 },
    [45] = { spellHit = 5.69231, meleeHit = 7.11539, spellCrit = 9.96154, meleeCrit = 9.96154, spellHaste = 7.11539, meleeHaste = 7.11539, resilience = 3, crit = 9.96154, haste = 7.11539 },
    [46] = { spellHit = 5.84615, meleeHit = 7.30769, spellCrit = 10.2308, meleeCrit = 10.2308, spellHaste = 7.30769, meleeHaste = 7.30769, resilience = 3.07, crit = 10.2308, haste = 7.30769 },
    [47] = { spellHit = 6, meleeHit = 7.5, spellCrit = 10.5, meleeCrit = 10.5, spellHaste = 7.5, meleeHaste = 7.5, resilience = 3.15, crit = 10.5, haste = 7.5 },
    [48] = { spellHit = 6.15385, meleeHit = 7.69231, spellCrit = 10.7692, meleeCrit = 10.7692, spellHaste = 7.69231, meleeHaste = 7.69231, resilience = 3.23, crit = 10.7692, haste = 7.69231 },
    [49] = { spellHit = 6.30769, meleeHit = 7.88461, spellCrit = 11.0385, meleeCrit = 11.0385, spellHaste = 7.88461, meleeHaste = 7.88461, resilience = 3.32, crit = 11.0385, haste = 7.88461 },
    [50] = { spellHit = 6.46154, meleeHit = 8.07692, spellCrit = 11.3077, meleeCrit = 11.3077, spellHaste = 8.07692, meleeHaste = 8.07692, resilience = 3.39, crit = 11.3077, haste = 8.07692 },
    [51] = { spellHit = 6.61539, meleeHit = 8.26923, spellCrit = 11.5769, meleeCrit = 11.5769, spellHaste = 8.26923, meleeHaste = 8.26923, resilience = 3.48, crit = 11.5769, haste = 8.26923 },
    [52] = { spellHit = 6.76923, meleeHit = 8.46154, spellCrit = 11.8462, meleeCrit = 11.8462, spellHaste = 8.46154, meleeHaste = 8.46154, resilience = 3.55, crit = 11.8462, haste = 8.46154 },
    [53] = { spellHit = 6.92308, meleeHit = 8.65385, spellCrit = 12.1154, meleeCrit = 12.1154, spellHaste = 8.65385, meleeHaste = 8.65385, resilience = 3.64, crit = 12.1154, haste = 8.65385 },
    [54] = { spellHit = 7.07692, meleeHit = 8.84615, spellCrit = 12.3846, meleeCrit = 12.3846, spellHaste = 8.84615, meleeHaste = 8.84615, resilience = 3.72, crit = 12.3846, haste = 8.84615 },
    [55] = { spellHit = 7.23077, meleeHit = 9.03846, spellCrit = 12.6538, meleeCrit = 12.6538, spellHaste = 9.03846, meleeHaste = 9.03846, resilience = 3.8, crit = 12.6538, haste = 9.03846 },
    [56] = { spellHit = 7.38461, meleeHit = 9.23077, spellCrit = 12.9231, meleeCrit = 12.9231, spellHaste = 9.23077, meleeHaste = 9.23077, resilience = 3.88, crit = 12.9231, haste = 9.23077 },
    [57] = { spellHit = 7.53846, meleeHit = 9.42308, spellCrit = 13.1923, meleeCrit = 13.1923, spellHaste = 9.42308, meleeHaste = 9.42308, resilience = 3.96, crit = 13.1923, haste = 9.42308 },
    [58] = { spellHit = 7.69231, meleeHit = 9.61539, spellCrit = 13.4615, meleeCrit = 13.4615, spellHaste = 9.61539, meleeHaste = 9.61539, resilience = 4.05, crit = 13.4615, haste = 9.61539 },
    [59] = { spellHit = 8, meleeHit = 9.80769, spellCrit = 13.7308, meleeCrit = 13.7308, spellHaste = 9.80769, meleeHaste = 9.80769, resilience = 4.12, crit = 13.7308, haste = 9.80769 },
    [60] = { spellHit = 8, meleeHit = 10, spellCrit = 14, meleeCrit = 14, spellHaste = 10, meleeHaste = 10, resilience = 4.2, crit = 14, haste = 10 },
    [61] = { spellHit = 8.3038, meleeHit = 10.3798, spellCrit = 14.5316, meleeCrit = 14.5316, spellHaste = 10.3798, meleeHaste = 10.3798, resilience = 3.65, crit = 14.5316, haste = 10.3798 },
    [62] = { spellHit = 8.63158, meleeHit = 10.7895, spellCrit = 15.1053, meleeCrit = 15.1053, spellHaste = 10.7895, meleeHaste = 10.7895, resilience = 3.8, crit = 15.1053, haste = 10.7895 },
    [63] = { spellHit = 8.9863, meleeHit = 11.2329, spellCrit = 15.726, meleeCrit = 15.726, spellHaste = 11.2329, meleeHaste = 11.2329, resilience = 3.95, crit = 15.726, haste = 11.2329 },
    [64] = { spellHit = 9.37143, meleeHit = 11.7143, spellCrit = 16.4, meleeCrit = 16.4, spellHaste = 11.7143, meleeHaste = 11.7143, resilience = 4.12, crit = 16.4, haste = 11.7143 },
    [65] = { spellHit = 9.79105, meleeHit = 12.2388, spellCrit = 17.1343, meleeCrit = 17.1343, spellHaste = 12.2388, meleeHaste = 12.2388, resilience = 4.31, crit = 17.1343, haste = 12.2388 },
    [66] = { spellHit = 10.25, meleeHit = 12.8125, spellCrit = 17.9375, meleeCrit = 17.9375, spellHaste = 12.8125, meleeHaste = 12.8125, resilience = 4.51, crit = 17.9375, haste = 12.8125 },
    [67] = { spellHit = 10.7541, meleeHit = 13.4426, spellCrit = 18.8197, meleeCrit = 18.8197, spellHaste = 13.4426, meleeHaste = 13.4426, resilience = 4.74, crit = 18.8197, haste = 13.4426 },
    [68] = { spellHit = 11.3104, meleeHit = 14.1379, spellCrit = 19.7931, meleeCrit = 19.7931, spellHaste = 14.1379, meleeHaste = 14.1379, resilience = 4.98, crit = 19.7931, haste = 14.1379 },
    [69] = { spellHit = 12.6154, meleeHit = 14.9091, spellCrit = 20.8727, meleeCrit = 20.8727, spellHaste = 14.9091, meleeHaste = 14.9091, resilience = 5.25, crit = 20.8727, haste = 14.9091 },
    [70] = { spellHit = 12.6154, meleeHit = 15.7692, spellCrit = 22.0769, meleeCrit = 22.0769, spellHaste = 15.7692, meleeHaste = 15.7692, resilience = 5.55, crit = 22.0769, haste = 15.7692 },
    [71] = { spellHit = 13.5736, meleeHit = 16.9669, spellCrit = 23.7537, meleeCrit = 23.7537, spellHaste = 16.9669, meleeHaste = 16.9669, resilience = 5.98, crit = 23.7537, haste = 16.9669 },
    [72] = { spellHit = 14.6045, meleeHit = 18.2556, spellCrit = 25.5579, meleeCrit = 25.5579, spellHaste = 18.2556, meleeHaste = 18.2556, resilience = 6.43, crit = 25.5579, haste = 18.2556 },
    [73] = { spellHit = 15.7137, meleeHit = 19.6422, spellCrit = 27.4991, meleeCrit = 27.4991, spellHaste = 19.6422, meleeHaste = 19.6422, resilience = 6.92, crit = 27.4991, haste = 19.6422 },
    [74] = { spellHit = 16.9072, meleeHit = 21.1341, spellCrit = 29.5877, meleeCrit = 29.5877, spellHaste = 21.1341, meleeHaste = 21.1341, resilience = 7.44, crit = 29.5877, haste = 21.1341 },
    [75] = { spellHit = 18.1914, meleeHit = 22.7392, spellCrit = 31.8349, meleeCrit = 31.8349, spellHaste = 22.7392, meleeHaste = 22.7392, resilience = 8.01, crit = 31.8349, haste = 22.7392 },
    [76] = { spellHit = 19.5731, meleeHit = 24.4663, spellCrit = 34.2529, meleeCrit = 34.2529, spellHaste = 24.4663, meleeHaste = 24.4663, resilience = 8.62, crit = 34.2529, haste = 24.4663 },
    [77] = { spellHit = 21.0597, meleeHit = 26.3246, spellCrit = 36.8545, meleeCrit = 36.8545, spellHaste = 26.3246, meleeHaste = 26.3246, resilience = 9.27, crit = 36.8545, haste = 26.3246 },
    [78] = { spellHit = 22.6592, meleeHit = 28.324, spellCrit = 39.6536, meleeCrit = 39.6536, spellHaste = 28.324, meleeHaste = 28.324, resilience = 9.98, crit = 39.6536, haste = 28.324 },
    [79] = { spellHit = 26.232, meleeHit = 30.4753, spellCrit = 42.6654, meleeCrit = 42.6654, spellHaste = 30.4753, meleeHaste = 30.4753, resilience = 10.73, crit = 42.6654, haste = 30.4753 },
    [80] = { spellHit = 26.232, meleeHit = 32.79, spellCrit = 45.906, meleeCrit = 45.906, spellHaste = 32.79, meleeHaste = 32.79, resilience = 11.55, crit = 45.906, haste = 32.79 },
}

-- Intellect → spell crit is class-table shaped in client DBCs and is still left
-- on the historical live-checked divisor until Necromancer rows are verified in-game.
PaperMath.LEGACY_INT_PER_SPELL_CRIT = {
    [60] = 61,
    [70] = 80,
}

PaperMath.BONE_WARD = {
    spellId = 681529,
    staminaPct = 0.10,
    armorPct = 0.50,
}

PaperMath.GLACIAL_WARD = {
    spellId = 681460,
    intellectPct = 0.10,
}

-- Sepulchral Might 2/2 — Spell.dbc 572638: +10% player Stamina (E2 bp=9),
-- spell damage += 30% of Raised minions' total Stamina (E1 bp=29).
-- Live: 1 ghoul @ 742 HP → +16 spell damage ⇒ Stam ≈ 16/0.30 ≈ 53 (HP ≈ 14×Stam).
-- Do NOT multiply live UnitStat Stam by 1.10 again — sheet already includes the +10%.
PaperMath.SEPULCHRAL_STAM_MULT = 1.10 -- documents +10% talent stam (already in UnitStat when talented)
PaperMath.SEPULCHRAL_SPELL_FROM_STAM = 0.30 -- DBC 572638 $s1% of Raised Stam total
-- Empirical HP→Stam when UnitStat fails on Ascension guardians (1 ghoul 742 HP / ~53 Stam).
PaperMath.SEPULCHRAL_HP_PER_STAM = 14

-- WotLK white-swing model: 1 AP ≈ 1 DPS / 14.
PaperMath.AP_PER_DPS = 14

-- Creature base main-hand swing (seconds). Live UnitAttackSpeed preferred when > 0.
-- Crypt Fiend base measured in-game at 1.64s (user).
PaperMath.MINION_BASE_SWING = {
    crypt_fiend = 1.64,
}

-- Undead *melee* haste sources (not Mindless Fury — that buffs your casts).
-- Values from Spell.dbc — see PaperMath.TALENT_BUFF for spell ids.
PaperMath.MINION_MELEE_HASTE = {
    depravity = 0.05, -- 638403 E1 bp=4 → +5% minion melee haste
    unholyFrenzy = 0.30, -- 805029 E2 bp=29 → +30% minion haste
    armyOfTheDead = 0.10, -- 525388 E1 bp=9 → +10% ghoul haste (ghoul-only)
}

-- DBC-confirmed talent / buff percentages used by paper math.
PaperMath.TALENT_BUFF = {
    depravity = {
        spellId = 638403,
        minionMeleeHastePct = 0.05,
        boneClubPctOfDamage = 0.40, -- E2 bp=39
        confidence = "100%",
    },
    unholyFrenzy = {
        spellId = 805029,
        minionHastePct = 0.30,
        minionMoveSpeedPct = 0.50,
        confidence = "100%",
    },
    armyOfTheDead = {
        spellId = 525600,
        auraSpellId = 525388,
        ghoulHastePct = 0.10,
        ghoulCritPct = 0.10,
        confidence = "100%",
    },
    sepulchralMight = {
        spellId = 572638,
        spellFromRaisedStamPct = 0.30,
        playerStaminaPct = 0.10,
        confidence = "100%",
    },
}

-- Player / minion ability coefficients confirmed in Spell.dbc description or effect rows.
-- Keys marked confidence ~= "100%" still have a calibrated or inherit component elsewhere.
PaperMath.SPELL_COEFF = {
    lichfrost = {
        spellId = 801722,
        base = 20, -- E1 bp=14, dieSides=6
        spCoeff = 0.59419,
        slowPct = 35, -- E3 bp=-36
        school = "Frost",
        confidence = "100%",
    },
    blight = {
        spellId = 850012,
        directBase = 10, -- E2 bp=9
        directSpCoeff = 0.30,
        dotSpCoeff = 0.18, -- description token; E3 empty in DBC
        dotTickMs = 5999, -- E2 aura amp
        confidence = "100%",
    },
    commandGhouls = {
        castSpellId = 504021,
        effectSpellId = 801514,
        damageM1 = 30, -- 801514 E1 bp=29
        damageSpCoeff = 0.375,
        damageIntCoeff = 0.50,
        healM3 = 15, -- 801514 E3 bp=14
        healPpl3 = 0.5,
        healSpCoeff = 0.22,
        healIntCoeff = 0.50,
        confidence = "100%",
    },
    ghoulAutoHeal = {
        spellId = 707000,
        raiseSpellId = 500971,
        m1 = 5, -- E1 bp=4
        ppl1 = 0.35,
        intSpCoeff = 0.504, -- Raise: Ghoul description token
        scale = 0.07,
        confidence = "100%",
    },
    diseaseCloud = {
        spellId = 802353,
        base = 11, -- E1 bp=8, dieSides=3
        spCoeff = 0.25, -- Raise: Abomination 500335 description token
        confidence = "100%",
    },
    bonestorm = {
        hitSpellId = 801411,
        auraSpellId = 801412,
        m1 = 30,
        tipSpCoeff = 0.40, -- Animate: Bone Wraith 805032 description
        liveSpCoeff = 0.10714, -- Mortuus dummy A/B — tip overstates
        tickMs = 500, -- 801412 E1 amp
        confidence = "partial",
    },
    boneDeconstruct = {
        spellId = 531132,
        animateSpellId = 531130,
        m1 = 1500, -- E1 bp=1499
        ppl1 = 20,
        spCoeff = 2.0,
        apCoeff = 0.5,
        confidence = "100%",
    },
}

-- Mortuus Crypt Fiend naked MH damage (0 gear) — used for theoretical white DPS.
PaperMath.CRYPT_FIEND_NAKED_DAMAGE = {
    min = 36.2,
    max = 39.7,
}

-- Raise: Ghoul auto-heal + Command: Ghouls paper maths.
-- Auto heal: Raise: Ghoul (500971) → 707000 + description tokens.
-- Command dmg/heal: parent Command: Ghouls (504021) → 801514 — NOT the nested Raise tip formula.
PaperMath.GHOUL_TOOLTIP = {
    autoHealSpellId = 707000,
    commandCastSpellId = 504021,
    commandEffectSpellId = 801514,
    raiseSpellId = 500971,
    summonCreatureId = 50073,
    autoHealM1 = 5,
    autoHealPpl1 = 0.35,
    autoHealIntSp = 0.504,
    autoHealScale = 0.07,
    commandM1 = 30,
    commandSpCoeff = 0.375,
    commandIntCoeff = 0.50,
    commandM3 = 15,
    commandPpl3 = 0.5,
    commandHealSp = 0.22,
    commandHealInt = 0.50,
}

-- Necromancy (804360): Undead gain AP/SP from owner INT+SP *based on their Life Force*.
-- Mortuus naked UnitAttackPower dumps (0 gear, INT≈78 SP≈0) — API works on targeted minions:
--   Ghoul/Rogue 1 LF: 87 | Fiend 2 LF: 153 | Abom 3 LF: 256
--   AP/14 ≈ 6.2 / 10.9 / 18.3 white DPS (ghoul matched melee floor ~6–7).
--   Fit: PetAP ≈ creatureBase + 0.882×(INT+SP)×LF  (bases ~15–20; abom base higher ~50).
--   Abom/Rogue AP ratio ≈ 2.94 ≈ LF 3. Stub (1,2,1) is NOT always true — dump "target".
-- Animates (Bone Wraith, Archer, …) occupy 0 LF — tip/DoT maths, NOT this LF×AP path.
--
-- Mortuus Crypt Fiend naked sheet (0 gear/buffs) — dump order:
--   UnitName, UnitHealthMax, UnitStat(,3), UnitDamage
--   Name Crypt Fiend | HP 1236 | Stam 31/31 | MH dmg ~36.2–39.7 (mult 1)
--   Prefer UnitStat Stam for Sepulchral (0.30×31≈+9.3); do NOT use HP/10 (would invent ~124 Stam).
--   If baseHP + ~10×Stam: base ≈ 926 + 310 = 1236.
--   Player +8: 1230→1310 (=10 HP/stam).
--   +8 owner: Ghoul +10 | Rogue/G.Skel +20 | Fiend +30 | Abom +60
--   Ghoul +37 owner: 732→782 (+50). Fits PetStam += Owner×0.271×LF @ ~5 HP/stam (predict +50).
--   Other raises ≈ same 0.271×LF @ ~10 HP/stam. Ghoul is half HP/stam, not half inherit rate.
-- CALIBRATED (not DBC): ap/sp/stam/armor rates below are creature-dump fits — keep marked until re-verified.
PaperMath.NECROMANCY_INHERIT = {
    spellId = 804360,
    confidence = "calibrated", -- ap/sp/stam/armor rates — not Spell.dbc description tokens
    -- Per Life Force (candidate rates from creature dump — unconfirmed live).
    apPerLfFromSp = 0.882,
    apPerLfFromInt = 0.882,
    spPerLfFromSp = 0.4914,
    spPerLfFromInt = 0.4914,
    -- Legacy aliases (1 LF = old flat dump).
    apFromSp = 0.882,
    apFromInt = 0.882,
    spFromSp = 0.4914,
    spFromInt = 0.4914,
    stamFromStam = 0.271384,
    -- Historical mistaken flat rate (do not feed GetOwnerPetInheritPaper).
    -- stamFromStamGhoulLive = 0.10,
    armorFromArmor = 0.45,
    lifeForceCosts = {
        ghoul = 1,
        crypt_fiend = 2,
        banshee = 2,
        abomination = 3,
        decaying_colossus = 3,
        skeletal_rogue = 1,
        skeletal_mage = 2,
        skeletal_warrior_greater = 1,
        skeletal_warrior_lesser = 1,
        bone_wraith = 0, -- Animate
        skeletal_archer = 0,
        tomb_king = 0,
    },
}

-- Bone Wraith extras on top of shared inherit.
-- Tooltip script (805032): Bonestorm ≈ m1+ppl1+owner SP×0.4 (801411) — tip overstates live.
-- Two-point dummy (Mortuus lvl 41):
--   Naked (0 gear SP, INT 78): Bonestorm normal = 34 exactly (crit 68).
--   Geared (SP 224, INT 137): Bonestorm normal = 58 exactly.
--   Δ +24 dmg / +224 SP ⇒ live coeff ≈ 0.107  (hit ≈ 34 + SP×0.107).
-- Old 0.125 fit assumed floor=m1(30) and naked SP=0; naked floor is actually 34.
PaperMath.BONE_WRAITH = {
    animateSpellId = 805032,
    bonestormSpellId = 801411,
    bonestormAuraId = 801412,
    bonestormTickMs = 500, -- 801412 aura amp — DBC confirmed
    bonestormOwnerSpCoeffTip = 0.4,
    bonestormOwnerSpCoeffLive = 0.10714, -- 24/224 from naked↔geared dummy
    bonestormHitFloorLive = 34, -- naked 0-SP normal hit
    bonestormM1 = 30, -- Spell.dbc 801411 Effect1 bp=29, dieSides=1
    bonestormPpl1 = 0,
}

local SPELL_SCHOOLS = {
    { id = 1, name = "Physical" },
    { id = 2, name = "Holy" },
    { id = 3, name = "Fire" },
    { id = 4, name = "Nature" },
    { id = 5, name = "Frost" },
    { id = 6, name = "Shadow" },
    { id = 7, name = "Arcane" },
}

local function GetAdvisor()
    return Mancer.NecromancerAdvisorModule
end

local function GetMinionDps()
    return Mancer.MinionDpsModule
end

local function ClampRatingLevel(level)
    level = tonumber(level) or 60
    if level < 1 then
        return 1
    end
    if level > 80 then
        return 80
    end
    return level
end

local function NearestLegacyIntCritLevel(level)
    level = tonumber(level) or 60
    if level >= 70 then
        return 70
    end
    return 60
end

function PaperMath:GetRatingTable(level)
    return self.RATING[ClampRatingLevel(level)] or self.RATING[60]
end

function PaperMath:GetIntPerSpellCrit(level)
    local key = NearestLegacyIntCritLevel(level)
    return self.LEGACY_INT_PER_SPELL_CRIT[key] or self.LEGACY_INT_PER_SPELL_CRIT[60]
end

function PaperMath:RatingToPercent(rating, ratingPerPercent)
    rating = tonumber(rating) or 0
    ratingPerPercent = tonumber(ratingPerPercent) or 0
    if ratingPerPercent <= 0 then
        return 0
    end
    return rating / ratingPerPercent
end

-- Inverse of RatingToPercent (ceil so gear aims are "at least this much").
function PaperMath:PercentToRating(percent, ratingPerPercent)
    percent = tonumber(percent) or 0
    ratingPerPercent = tonumber(ratingPerPercent) or 0
    if ratingPerPercent <= 0 or percent <= 0 then
        return 0
    end
    return math.ceil(percent * ratingPerPercent - 1e-6)
end

function PaperMath:GetPlayerPaperStats()
    local level = UnitLevel and UnitLevel("player") or 60
    local table = self:GetRatingTable(level)
    local int = UnitStat and select(1, UnitStat("player", 4)) or 0
    local spi = UnitStat and select(1, UnitStat("player", 5)) or 0
    local sta = UnitStat and select(1, UnitStat("player", 3)) or 0
    local str = UnitStat and select(1, UnitStat("player", 1)) or 0
    local agi = UnitStat and select(1, UnitStat("player", 2)) or 0

    local schools = {}
    local maxSpell = 0
    if GetSpellBonusDamage then
        for _, school in ipairs(SPELL_SCHOOLS) do
            local bonus = GetSpellBonusDamage(school.id) or 0
            schools[school.name] = bonus
            if bonus > maxSpell then
                maxSpell = bonus
            end
        end
    end

    local spellHitRating = (GetCombatRating and CR_HIT_SPELL and GetCombatRating(CR_HIT_SPELL)) or 0
    local critRating = (GetCombatRating and CR_CRIT_SPELL and GetCombatRating(CR_CRIT_SPELL)) or 0
    local hasteRating = (GetCombatRating and CR_HASTE_SPELL and GetCombatRating(CR_HASTE_SPELL))
        or (GetCombatRating and CR_HASTE_MELEE and GetCombatRating(CR_HASTE_MELEE))
        or 0

    local base, pos, neg = 0, 0, 0
    if UnitAttackPower then
        base, pos, neg = UnitAttackPower("player")
    end
    local playerAP = (base or 0) + (pos or 0) + (neg or 0)

    local petSpell = 0
    if GetPetSpellBonusDamage then
        petSpell = GetPetSpellBonusDamage() or 0
    end

    local armor = 0
    if UnitArmor then
        armor = select(1, UnitArmor("player")) or 0
    end

    return {
        level = level,
        ratingLevel = ClampRatingLevel(level),
        intellect = int,
        spirit = spi,
        stamina = sta,
        strength = str,
        agility = agi,
        armor = armor,
        spellBonus = schools,
        spellDamage = maxSpell,
        spellHitRating = spellHitRating,
        spellHitPct = self:RatingToPercent(spellHitRating, table.spellHit),
        critRating = critRating,
        critPctFromRating = self:RatingToPercent(critRating, table.spellCrit or table.crit),
        spellCritFromInt = self:RatingToPercent(int, self:GetIntPerSpellCrit(level)),
        hasteRating = hasteRating,
        hastePct = self:RatingToPercent(hasteRating, table.spellHaste or table.haste),
        attackPower = playerAP,
        apWhiteDps = playerAP / self.AP_PER_DPS,
        petSpellBonus = petSpell,
        -- Wiki: Intellect specialization doubles Spell Damage from Spell Power.
        -- GetSpellBonusDamage already returns the final (post-spec) value.
        wikiNote = "Combat ratings from gtCombatRatings.dbc. INT→spell crit still uses legacy live divisor.",
    }
end

function PaperMath:GetSpellSchoolBonus(schoolName, player)
    player = player or self:GetPlayerPaperStats()
    if not player or not player.spellBonus then
        return player and player.spellDamage or 0
    end
    return player.spellBonus[schoolName] or player.spellDamage or 0
end

function PaperMath:GetPlayerCastPaper()
    local player = self:GetPlayerPaperStats()
    local int = player.intellect or 0
    local shadow = self:GetSpellSchoolBonus("Shadow", player)
    local frost = self:GetSpellSchoolBonus("Frost", player)
    local cmd = self.SPELL_COEFF.commandGhouls
    local lich = self.SPELL_COEFF.lichfrost
    local blight = self.SPELL_COEFF.blight
    local cloud = self.SPELL_COEFF.diseaseCloud
    local decon = self.SPELL_COEFF.boneDeconstruct
    return {
        intellect = int,
        shadowSpellPower = shadow,
        frostSpellPower = frost,
        lichfrost = (lich.base or 0) + frost * (lich.spCoeff or 0),
        blightDirect = (blight.directBase or 0) + shadow * (blight.directSpCoeff or 0),
        blightDotPerTick = shadow * (blight.dotSpCoeff or 0),
        commandDamage = (cmd.damageM1 or 0) + shadow * (cmd.damageSpCoeff or 0) + int * (cmd.damageIntCoeff or 0),
        commandHealPerGhoul = (cmd.healM3 or 0) + shadow * (cmd.healSpCoeff or 0) + int * (cmd.healIntCoeff or 0),
        diseaseCloud = (cloud.base or 0) + shadow * (cloud.spCoeff or 0),
        boneDeconstruct = (decon.m1 or 0) + shadow * (decon.spCoeff or 0) + (player.attackPower or 0) * (decon.apCoeff or 0),
    }
end

function PaperMath:GetWardScalingReport()
    local player = self:GetPlayerPaperStats()
    local inherit = self.NECROMANCY_INHERIT or {}
    local bone = self.BONE_WARD or {}
    local glacial = self.GLACIAL_WARD or {}
    local int = tonumber(player.intellect) or 0
    local sta = tonumber(player.stamina) or 0
    local shadowSp = player.spellBonus and (player.spellBonus.Shadow or player.spellDamage) or player.spellDamage or 0
    local intDelta = int * (glacial.intellectPct or 0)
    local ownerStaDelta = sta * (bone.staminaPct or 0)
    local ghoulLf = self:GetMinionLifeForceCost("ghoul")
    local colossusLf = self:GetMinionLifeForceCost("decaying_colossus")

    local function whiteDpsDelta(lf)
        local petApDelta = (inherit.apPerLfFromInt or inherit.apFromInt or 0) * intDelta * lf
        return petApDelta, petApDelta / (self.AP_PER_DPS or 14)
    end

    local ghoulApDelta, ghoulWhiteDpsDelta = whiteDpsDelta(ghoulLf)
    local colossusApDelta, colossusWhiteDpsDelta = whiteDpsDelta(colossusLf)

    local ghoulCommandDamageDelta = intDelta * (self.GHOUL_TOOLTIP.commandIntCoeff or 0.50)
    local ghoulAutoHealDelta = intDelta * (self.GHOUL_TOOLTIP.autoHealIntSp or 0) * (self.GHOUL_TOOLTIP.autoHealScale or 0)
    local ghoulCommandHealDelta = intDelta * (self.GHOUL_TOOLTIP.commandHealInt or 0)

    local ghoulInheritedStamDelta = ownerStaDelta * (inherit.stamFromStam or 0) * ghoulLf
    local colossusInheritedStamDelta = ownerStaDelta * (inherit.stamFromStam or 0) * colossusLf
    local ghoulSepulchralLower = ghoulInheritedStamDelta * (self.SEPULCHRAL_SPELL_FROM_STAM or 0)
    local colossusSepulchralLower = colossusInheritedStamDelta * (self.SEPULCHRAL_SPELL_FROM_STAM or 0)

    return {
        playerIntellect = int,
        playerStamina = sta,
        playerShadowSpellPower = shadowSp,
        glacialIntellectDelta = intDelta,
        boneOwnerStaminaDelta = ownerStaDelta,
        ghoul = {
            lifeForce = ghoulLf,
            glacial = {
                petApDelta = ghoulApDelta,
                whiteDpsDelta = ghoulWhiteDpsDelta,
                commandDamageDelta = ghoulCommandDamageDelta,
                autoHealDelta = ghoulAutoHealDelta,
                commandHealDelta = ghoulCommandHealDelta,
            },
            bone = {
                inheritedStaminaDeltaLower = ghoulInheritedStamDelta,
                sepulchralSpellDeltaLower = ghoulSepulchralLower,
            },
        },
        decayingColossus = {
            lifeForce = colossusLf,
            glacial = {
                petApDelta = colossusApDelta,
                whiteDpsDelta = colossusWhiteDpsDelta,
                commandDamageDelta = 0,
            },
            bone = {
                inheritedStaminaDeltaLower = colossusInheritedStamDelta,
                sepulchralSpellDeltaLower = colossusSepulchralLower,
            },
        },
    }
end

function PaperMath:PrintWardScalingReport()
    local r = self:GetWardScalingReport()
    Mancer.Print("--- Bone Ward vs Glacial Ward (DBC-backed formula paths) ---")
    Mancer.Print(string.format(
        "  Bone Ward (%d): +50%% armor, +10%% stamina. Glacial Ward (%d): +10%% intellect.",
        self.BONE_WARD.spellId, self.GLACIAL_WARD.spellId
    ))
    Mancer.Print("  These are the exact ward effects; verdicts below use only addon math paths that are DBC-backed.")
    Mancer.Print("")
    Mancer.Print(string.format(
        "  Ghoul (LF %d): Glacial = +%.1f AP (≈+%.2f white DPS) +%.1f Command dmg +%.1f auto-heal +%.1f Command heal/ghoul.",
        r.ghoul.lifeForce,
        r.ghoul.glacial.petApDelta,
        r.ghoul.glacial.whiteDpsDelta,
        r.ghoul.glacial.commandDamageDelta,
        r.ghoul.glacial.autoHealDelta,
        r.ghoul.glacial.commandHealDelta
    ))
    Mancer.Print(string.format(
        "             Bone = no direct ghoul damage coeffs; only +stamina/armor. Lower-bound Sepulchral gain from owner-stam inherit: +%.2f spell dmg/ghoul.",
        r.ghoul.bone.sepulchralSpellDeltaLower
    ))
    Mancer.Print("             Verdict: Glacial Ward scales ghoul offense harder; Bone Ward is mostly survivability + Sepulchral support.")
    Mancer.Print("")
    Mancer.Print(string.format(
        "  Decaying Colossus (LF %d): Glacial = +%.1f AP (≈+%.2f white DPS), but Command: Bone Smash gets +0 direct damage from the ward.",
        r.decayingColossus.lifeForce,
        r.decayingColossus.glacial.petApDelta,
        r.decayingColossus.glacial.whiteDpsDelta
    ))
    Mancer.Print(string.format(
        "                       Bone = +50%% armor, +10%% stamina, plus lower-bound Sepulchral gain +%.2f spell dmg from owner-stam inherit.",
        r.decayingColossus.bone.sepulchralSpellDeltaLower
    ))
    Mancer.Print("                       Verdict: Bone Ward is the stronger general/colossus ward for tankiness and stamina-based side value; Glacial only buffs the LF white/AP path.")
    Mancer.Print("")
end

function PaperMath:GetUnitCombatSheet(unit)
    if not unit then
        return nil
    end
    -- Do not require UnitExists — Ascension guardians often fail Exists on nameplates
    -- until targeted, while UnitName / UnitDamage still return values.
    if UnitIsDead and UnitExists and UnitExists(unit) and UnitIsDead(unit) then
        return nil
    end

    local name = UnitName and UnitName(unit) or nil
    if not name or name == "" then
        return nil
    end
    local level = UnitLevel and UnitLevel(unit) or 0

    local stam = 0
    if UnitStat then
        stam = select(1, UnitStat(unit, 3)) or 0
    end
    -- Ascension guardians often report Stam 0; estimate from max HP (Mortuus: 742 HP ≈ 53 Stam).
    if stam <= 0 and UnitHealthMax then
        local hp = tonumber(UnitHealthMax(unit)) or 0
        if hp > 0 and self.SEPULCHRAL_HP_PER_STAM and self.SEPULCHRAL_HP_PER_STAM > 0 then
            stam = math.floor(hp / self.SEPULCHRAL_HP_PER_STAM + 0.5)
        end
    end

    local base, pos, neg = 0, 0, 0
    local apApiStub = false
    if UnitAttackPower then
        base, pos, neg = UnitAttackPower(unit)
        base = tonumber(base) or 0
        pos = tonumber(pos) or 0
        neg = tonumber(neg) or 0
        -- Ascension necro minions: UnitAttackPower often returns stub (1, 2, 1) — not real AP.
        if base == 1 and pos == 2 and (neg == 1 or neg == -1) then
            apApiStub = true
            base, pos, neg = 0, 0, 0
        end
    end
    local ap = base + pos + neg
    if apApiStub then
        ap = 0
    end

    local dmgMin, dmgMax = 0, 0
    local offMin, offMax = 0, 0
    if UnitDamage then
        dmgMin, dmgMax, offMin, offMax = UnitDamage(unit)
        dmgMin = tonumber(dmgMin) or 0
        dmgMax = tonumber(dmgMax) or 0
        offMin = tonumber(offMin) or 0
        offMax = tonumber(offMax) or 0
    end

    local speed, offSpeed = 0, 0
    if UnitAttackSpeed then
        speed, offSpeed = UnitAttackSpeed(unit)
        speed = tonumber(speed) or 0
        offSpeed = tonumber(offSpeed) or 0
    end

    local avg = (dmgMin + dmgMax) / 2
    local paperAuto = 0
    if speed > 0 and avg > 0 then
        paperAuto = avg / speed
    end
    if offSpeed and offSpeed > 0 and (offMin + offMax) > 0 then
        paperAuto = paperAuto + ((offMin + offMax) / 2) / offSpeed
    end

    local apWhite = ap / self.AP_PER_DPS

    local critChance = 0
    if UnitCritChance then
        local ok, value = pcall(UnitCritChance, unit)
        if ok and value then
            critChance = tonumber(value) or 0
        end
    end

    local paperWithCrit = paperAuto * (1 + critChance / 100)

    return {
        unit = unit,
        name = name,
        level = level,
        stamina = stam,
        attackPower = ap,
        attackPowerApiStub = apApiStub,
        damageMin = dmgMin,
        damageMax = dmgMax,
        attackSpeed = speed,
        paperAutoDps = paperAuto,
        paperAutoDpsWithCrit = paperWithCrit,
        apWhiteDps = apWhite,
        critChance = critChance,
    }
end

function PaperMath:ScanArmySheets()
    local Advisor = GetAdvisor()
    local rows = {}
    local seenGuid = {}

    if Advisor and Advisor.ClearPollCaches then
        Advisor:ClearPollCaches()
    end
    if Advisor then
        Advisor.cachedScanUnits = nil
        Advisor.cachedScanUnitsUntil = 0
    end

    local function addUnit(unit, minionId)
        if not unit then
            return
        end
        -- Ascension nameplates: UnitExists can be false while UnitName/UnitDamage still work.
        local name = UnitName and UnitName(unit)
        if not name or name == "" then
            return
        end

        local guid = UnitGUID and UnitGUID(unit)
        if guid and seenGuid[guid] then
            return
        end
        if guid then
            seenGuid[guid] = true
        end

        local sheet = self:GetUnitCombatSheet(unit)
        if not sheet then
            return
        end
        -- Sheet needs real combat values; skip empty shells.
        if (sheet.attackPower or 0) <= 0 and (sheet.paperAutoDps or 0) <= 0 and (sheet.stamina or 0) <= 0 then
            return
        end

        sheet.minionId = minionId
        if not sheet.minionId and Advisor and Advisor.ClassifyMinionName then
            sheet.minionId = Advisor:ClassifyMinionName(sheet.name)
        end
        -- Fallback: creature base swing when UnitAttackSpeed is 0/missing.
        if (not sheet.attackSpeed or sheet.attackSpeed <= 0)
            and sheet.minionId
            and self.MINION_BASE_SWING
            and self.MINION_BASE_SWING[sheet.minionId]
        then
            local base = self.MINION_BASE_SWING[sheet.minionId]
            sheet.attackSpeed = base
            local avg = ((sheet.damageMin or 0) + (sheet.damageMax or 0)) / 2
            if avg > 0 and base > 0 then
                sheet.paperAutoDps = avg / base
                sheet.paperAutoDpsWithCrit = sheet.paperAutoDps * (1 + (sheet.critChance or 0) / 100)
            end
        end
        table.insert(rows, sheet)
    end

    local function classify(unit)
        if not Advisor then
            return nil
        end
        -- Prefer ScanUnitToken (guardian ownership — works without hard target).
        if Advisor.ScanUnitToken then
            local minionId = Advisor:ScanUnitToken(unit)
            if minionId then
                return minionId
            end
        end
        local name = UnitName and UnitName(unit)
        if name and Advisor.IsOwnedGuardianUnit and Advisor:IsOwnedGuardianUnit(unit, name) then
            return Advisor:ClassifyMinionName(name)
        end
        if name and Advisor.ClassifyMinionName and Advisor.IsPlayerMinionUnit and Advisor:IsPlayerMinionUnit(unit) then
            return Advisor:ClassifyMinionName(name)
        end
        return nil
    end

    local function tryUnit(unit)
        local minionId = classify(unit)
        if minionId then
            addUnit(unit, minionId)
        end
    end

    -- Always probe these (same set Status uses for visible ghouls).
    for i = 1, 40 do
        tryUnit("nameplate" .. i)
    end

    tryUnit("pet")
    tryUnit("target")
    tryUnit("focus")
    tryUnit("mouseover")

    if Advisor and Advisor.GetLightweightTempScanUnits then
        for _, unit in ipairs(Advisor:GetLightweightTempScanUnits()) do
            tryUnit(unit)
        end
    elseif Advisor and Advisor.GetAllScanUnits then
        for _, unit in ipairs(Advisor:GetAllScanUnits()) do
            tryUnit(unit)
        end
    end

    if Advisor and Advisor.trackedUnits then
        for unit in pairs(Advisor.trackedUnits) do
            tryUnit(unit)
        end
    end

    return rows
end

function PaperMath:SummarizeArmy(rows)
    rows = rows or self:ScanArmySheets()
    local totalAuto = 0
    local totalApWhite = 0
    local totalStam = 0
    local byType = {}

    for _, sheet in ipairs(rows) do
        totalAuto = totalAuto + (sheet.paperAutoDps or 0)
        totalApWhite = totalApWhite + (sheet.apWhiteDps or 0)
        totalStam = totalStam + (sheet.stamina or 0)
        local id = sheet.minionId or "unknown"
        local bucket = byType[id]
        if not bucket then
            bucket = { count = 0, auto = 0, ap = 0, stam = 0, sheets = {} }
            byType[id] = bucket
        end
        bucket.count = bucket.count + 1
        bucket.auto = bucket.auto + (sheet.paperAutoDps or 0)
        bucket.ap = bucket.ap + (sheet.attackPower or 0)
        bucket.stam = bucket.stam + (sheet.stamina or 0)
        table.insert(bucket.sheets, sheet)
    end

    -- If Status knows more ghouls than we could sheet-read, extrapolate from sampled average.
    local Advisor = GetAdvisor()
    local extrapolated = false
    if Advisor and Advisor.CollectActiveMinions then
        local counts = Advisor:CollectActiveMinions()
        for minionId, want in pairs(counts or {}) do
            want = tonumber(want) or 0
            local bucket = byType[minionId]
            local have = bucket and bucket.count or 0
            if want > have and have > 0 then
                local avgAuto = bucket.auto / have
                local avgAp = bucket.ap / have
                local avgStam = bucket.stam / have
                local missing = want - have
                bucket.count = want
                bucket.auto = bucket.auto + avgAuto * missing
                bucket.ap = bucket.ap + avgAp * missing
                bucket.stam = bucket.stam + avgStam * missing
                totalAuto = totalAuto + avgAuto * missing
                totalApWhite = totalApWhite + (avgAp / self.AP_PER_DPS) * missing
                totalStam = totalStam + avgStam * missing
                extrapolated = true
                bucket.extrapolated = missing
            elseif want > 0 and have == 0 then
                byType[minionId] = byType[minionId] or {
                    count = want,
                    auto = 0,
                    ap = 0,
                    stam = 0,
                    sheets = {},
                    unscanned = want,
                }
                extrapolated = true
            end
        end
    end

    local sepulchral = totalStam * self.SEPULCHRAL_SPELL_FROM_STAM

    return {
        rows = rows,
        byType = byType,
        totalAutoDps = totalAuto,
        totalApWhiteDps = totalApWhite,
        totalStamina = totalStam,
        sepulchralSpellDamage = sepulchral,
        unitCount = #rows,
        extrapolated = extrapolated,
    }
end

--- Compound haste: swing = base / Π(1+h_i). Returns seconds.
function PaperMath:EstimateSwingSpeed(baseSpeed, hasteFractions)
    baseSpeed = tonumber(baseSpeed) or 0
    if baseSpeed <= 0 then
        return 0
    end
    local mult = 1
    for _, h in ipairs(hasteFractions or {}) do
        local f = tonumber(h) or 0
        if f > 0 then
            mult = mult * (1 + f)
        end
    end
    if mult <= 0 then
        return baseSpeed
    end
    return baseSpeed / mult
end

--- Crypt Fiend white-swing table (base 1.64s). Optional live dmgMin/dmgMax override naked dump.
function PaperMath:GetCryptFiendSwingTable(dmgMin, dmgMax)
    local base = (self.MINION_BASE_SWING and self.MINION_BASE_SWING.crypt_fiend) or 1.64
    local naked = self.CRYPT_FIEND_NAKED_DAMAGE or { min = 36.2, max = 39.7 }
    dmgMin = tonumber(dmgMin) or naked.min
    dmgMax = tonumber(dmgMax) or naked.max
    local avg = (dmgMin + dmgMax) / 2
    local H = self.MINION_MELEE_HASTE or {}
    local dep = H.depravity or 0.05
    local uf = H.unholyFrenzy or 0.30
    -- UF uptime ≈ 15/180 → ~2.5% average haste while talented.
    local ufAvg = uf * (15 / 180)

    local function row(label, hastes)
        local speed = self:EstimateSwingSpeed(base, hastes)
        return {
            label = label,
            speed = speed,
            avgDps = speed > 0 and (avg / speed) or 0,
            maxDps = speed > 0 and (dmgMax / speed) or 0,
            minDps = speed > 0 and (dmgMin / speed) or 0,
            swingsPerMin = speed > 0 and (60 / speed) or 0,
        }
    end

    return {
        baseSpeed = base,
        damageMin = dmgMin,
        damageMax = dmgMax,
        damageAvg = avg,
        profiles = {
            row("Base (no melee haste)", {}),
            row("Typical (Depravity)", { dep }),
            row("Average (Dep + UF uptime)", { dep, ufAvg }),
            row("Max burst (Dep + Unholy Frenzy)", { dep, uf }),
        },
        note = "AotD +10% is ghoul-tagged — not in fiend table. Mindless Fury is player cast haste, not minion swing.",
    }
end

function PaperMath:PrintCryptFiendSwingTable(army)
    local dmgMin, dmgMax
    local bucket = army and army.byType and army.byType.crypt_fiend
    if bucket and bucket.sheets and bucket.sheets[1] then
        local s = bucket.sheets[1]
        if (s.damageMin or 0) > 0 then
            dmgMin, dmgMax = s.damageMin, s.damageMax
        end
    end
    local t = self:GetCryptFiendSwingTable(dmgMin, dmgMax)
    Mancer.Print(string.format(
        "--- Crypt Fiend swing (base %.2fs | MH %.0f–%.0f) ---",
        t.baseSpeed, t.damageMin, t.damageMax
    ))
    for _, p in ipairs(t.profiles or {}) do
        Mancer.Print(string.format(
            "  %s: %.2fs  |  avg white ≈%.1f DPS  |  max hit ≈%.1f DPS  |  %.1f swings/min",
            p.label, p.speed, p.avgDps, p.maxDps, p.swingsPerMin
        ))
    end
    if t.note then
        Mancer.Print("  " .. t.note)
    end
end

function PaperMath:EstimateSpellHit(baseDamage, schoolId)
    local player = self:GetPlayerPaperStats()
    schoolId = tonumber(schoolId) or 6
    local bonus = 0
    if GetSpellBonusDamage then
        bonus = GetSpellBonusDamage(schoolId) or 0
    end
    -- Without a real coefficient, report SP contribution only if caller supplies coeff.
    return {
        base = tonumber(baseDamage) or 0,
        spellBonus = bonus,
        schoolId = schoolId,
        note = "Need spell coefficient. Paper = base + SP × coeff (see PaperMath.SPELL_COEFF).",
    }
end

function PaperMath:PaperSpellDamage(baseDamage, coefficient, schoolId)
    baseDamage = tonumber(baseDamage) or 0
    coefficient = tonumber(coefficient) or 0
    schoolId = tonumber(schoolId) or 6
    local bonus = GetSpellBonusDamage and (GetSpellBonusDamage(schoolId) or 0) or 0
    return baseDamage + bonus * coefficient
end

-- Uses Ascension Raise: Ghoul + Command: Ghouls tooltip variables ($INT / $SP).
function PaperMath:GetGhoulTooltipPaper(dbc)
    local player = self:GetPlayerPaperStats()
    local g = self.GHOUL_TOOLTIP
    local int = player.intellect or 0
    local sp = self:GetSpellSchoolBonus("Shadow", player)
    dbc = dbc or {}

    local level = player.level or 0
    local autoM1 = tonumber(dbc.autoM1) or g.autoHealM1 or 0
    local autoPpl = tonumber(dbc.autoPpl1) or g.autoHealPpl1 or 0
    local autoHeal = autoM1 + (int * g.autoHealIntSp + sp * g.autoHealIntSp) * g.autoHealScale
    local autoHealWithPpl = autoHeal + autoPpl

    local commandBase = tonumber(dbc.commandM1) or g.commandM1 or 0
    local commandDamage = commandBase + sp * (g.commandSpCoeff or 0) + int * (g.commandIntCoeff or 0)
    local commandScalingOnly = sp * (g.commandSpCoeff or 0) + int * (g.commandIntCoeff or 0)

    local commandM3 = tonumber(dbc.commandM3) or g.commandM3 or 0
    local commandPpl3 = tonumber(dbc.commandPpl3) or g.commandPpl3 or 0
    local commandHeal = commandM3 + sp * g.commandHealSp + int * g.commandHealInt

    return {
        intellect = int,
        spellPower = sp,
        level = level,
        autoHealPerHit = autoHeal,
        autoHealPerHitInclPplHint = autoHealWithPpl,
        autoHealPpl1 = autoPpl,
        autoHealScalingOnly = (int * g.autoHealIntSp + sp * g.autoHealIntSp) * g.autoHealScale,
        commandDamage = commandDamage,
        commandDamageScalingOnly = commandScalingOnly,
        commandM1 = commandBase,
        commandHealPerGhoul = commandHeal,
        commandM3 = commandM3,
        commandPpl3 = commandPpl3,
        commandCastSpellId = g.commandCastSpellId,
        commandEffectSpellId = g.commandEffectSpellId,
        autoHealSpellId = g.autoHealSpellId,
        summonCreatureId = g.summonCreatureId,
        note = "Command uses parent 504021 coeffs (SP×0.375 + INT×0.5). White autos still unit-sheet.",
    }
end

-- Necromancy (804360): AP/SP from owner INT+SP, scaled by the minion's Life Force cost.
-- lifeForceCost 0 = Animate / no LF path (do not use Raised AP formula).
function PaperMath:GetOwnerPetInheritPaper(lifeForceCost)
    local player = self:GetPlayerPaperStats()
    local inherit = self.NECROMANCY_INHERIT
    local int = player.intellect or 0
    local sp = player.spellBonus and (player.spellBonus.Shadow or player.spellDamage) or player.spellDamage or 0
    local sta = player.stamina or 0
    local armor = player.armor or 0
    local lf = tonumber(lifeForceCost)
    if lf == nil then
        lf = 1
    end

    local apPerLf = (inherit.apPerLfFromSp or inherit.apFromSp or 0) * sp
        + (inherit.apPerLfFromInt or inherit.apFromInt or 0) * int
    local spPerLf = (inherit.spPerLfFromSp or inherit.spFromSp or 0) * sp
        + (inherit.spPerLfFromInt or inherit.spFromInt or 0) * int
    local petAp = apPerLf * lf
    local petSp = spPerLf * lf
    -- Live A/B: PetStam += OwnerStam × 0.271 × LF (ghoul half HP/stam, same inherit rate).
    -- stamFromStamGhoulLive (0.10) was a bad paper shortcut — do not use for all types.
    local stamRate = inherit.stamFromStam or 0
    local petStam = (lf > 0) and (sta * stamRate * lf) or 0
    local petArmor = armor * (inherit.armorFromArmor or 0)

    return {
        intellect = int,
        spellPower = sp,
        stamina = sta,
        armor = armor,
        lifeForceCost = lf,
        apPerLifeForce = apPerLf,
        spPerLifeForce = spPerLf,
        petApFromOwner = petAp,
        petSpFromOwner = petSp,
        petStamFromOwner = petStam,
        petArmorFromOwner = petArmor,
        inheritedApWhiteDps = lf > 0 and (petAp / self.AP_PER_DPS) or 0,
        note = lf > 0
            and string.format("Necromancy AP/SP × %d LF (hypothesis). Animates are LF 0 — separate maths.", lf)
            or "LF 0 (Animate): Necromancy AP×LF path N/A — use ability tip maths.",
    }
end

function PaperMath:GetMinionLifeForceCost(minionId)
    local inherit = self.NECROMANCY_INHERIT
    if inherit.lifeForceCosts and inherit.lifeForceCosts[minionId] ~= nil then
        return inherit.lifeForceCosts[minionId]
    end
    local Advisor = GetAdvisor()
    if Advisor and Advisor.GetMinionLifeForceCost then
        return Advisor:GetMinionLifeForceCost(minionId) or 1
    end
    if Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId] then
        return Advisor.MINION_TYPES[minionId].lifeForceCost or 1
    end
    return 1
end

-- Ghoul package = LF×1 Necromancy inherit + Command tooltip (owner $INT/$SP).
function PaperMath:GetGhoulInheritPaper()
    local inherit = self:GetOwnerPetInheritPaper(self:GetMinionLifeForceCost("ghoul"))
    local tip = self:GetGhoulTooltipPaper()
    inherit.commandDamage = tip.commandDamage
    inherit.commandDamageScalingOnly = tip.commandDamageScalingOnly
    inherit.autoHealPerHit = tip.autoHealPerHit
    inherit.note = "Ghoul = 1 LF Necromancy AP/SP path (calibrated inherit). Command = DBC 504021 coeffs."
    return inherit
end

-- Bone Wraith = Animate (0 LF). Bonestorm uses owner-$SP tip math; not Raise LF×AP.
function PaperMath:GetBoneWraithPaper()
    local inherit = self:GetOwnerPetInheritPaper(0)
    local w = self.BONE_WRAITH
    local sp = inherit.spellPower or 0
    local m1 = w.bonestormM1 or 0
    local ppl = w.bonestormPpl1 or 0
    local floorLive = w.bonestormHitFloorLive or m1
    inherit.bonestormOwnerSpSliceTip = sp * (w.bonestormOwnerSpCoeffTip or 0)
    inherit.bonestormOwnerSpSliceLive = sp * (w.bonestormOwnerSpCoeffLive or 0)
    inherit.bonestormHitTip = m1 + ppl + inherit.bonestormOwnerSpSliceTip
    inherit.bonestormHitLive = floorLive + inherit.bonestormOwnerSpSliceLive
    inherit.bonestormHitFloorLive = floorLive
    inherit.bonestormM1 = m1
    inherit.animateSpellId = w.animateSpellId
    inherit.bonestormSpellId = w.bonestormSpellId
    inherit.bonestormOwnerSpSlice = inherit.bonestormOwnerSpSliceLive
    inherit.note = "Animate (0 LF): Bonestorm ≈ 34 + SP×0.107 live; tip SP×0.4 wrong. Not Necromancy LF×AP."
    return inherit
end

local function FindMeasuredSpell(spells, needle)
    needle = string.lower(needle or "")
    for _, row in ipairs(spells or {}) do
        local label = string.lower(row.label or "")
        if label == needle or label:find(needle, 1, true) then
            return row
        end
    end
    return nil
end

-- Predict-vs-live test for the "shared 0.882 AP inherit" hypothesis.
-- Best proofs: (1) measured Melee DPS A/B vs SP — UnitAttackPower on Ascension
-- minions is a stub (often returns 1, 2, 1), so sheet AP cannot validate inherit.
-- (2) sheet UnitDamage/speed when non-zero, (3) Command tip hit vs measured.
function PaperMath:PrintInheritHypothesisTest(army, measured, measuredSource)
    local inherit = self:GetOwnerPetInheritPaper()
    local tip = self:GetGhoulTooltipPaper()
    local predictedAp = inherit.petApFromOwner or 0
    local predictedWhite = inherit.inheritedApWhiteDps or 0

    Mancer.Print("--- Inherit hypothesis test (Necromancy 804360 × Life Force) ---")
    Mancer.Print("  Raised: Pet AP/SP from (INT+SP) × per-LF coeff × LF cost (ghoul1 / fiend2 / abom3).")
    Mancer.Print("  Animates: 0 LF — ability tip maths (e.g. Bonestorm), not this AP×LF path.")
    Mancer.Print(string.format(
        "  Per-LF candidate dump: AP += 0.882×(INT+SP) → ×1 LF ≈%.0f AP (≈%.1f white DPS)",
        predictedAp, predictedWhite
    ))
    local fiend = self:GetOwnerPetInheritPaper(2)
    local abom = self:GetOwnerPetInheritPaper(3)
    Mancer.Print(string.format(
        "  Same coeffs × LF: Fiend(2) ≈%.0f AP / %.1f DPS | Abom(3) ≈%.0f AP / %.1f DPS",
        fiend.petApFromOwner, fiend.inheritedApWhiteDps, abom.petApFromOwner, abom.inheritedApWhiteDps
    ))

    local ghoulBucket = army and army.byType and army.byType.ghoul
    if ghoulBucket and ghoulBucket.count and ghoulBucket.count > 0 then
        local liveAp = (ghoulBucket.ap or 0) / ghoulBucket.count
        local liveAuto = (ghoulBucket.auto or 0) / ghoulBucket.count
        Mancer.Print(string.format(
            "  Live ghoul sheet: avg AP %.0f | paper auto ≈%.1f DPS/unit ×%d",
            liveAp, liveAuto, ghoulBucket.count
        ))
        if liveAp <= 0 and liveAuto <= 0 then
            Mancer.Print("  Sheet AP/auto unusable — Ascension UnitAttackPower on minions is a stub (e.g. 1, 2, 1).")
            Mancer.Print("  Use measured Melee + implied X (cannot AP-check via API).")
        else
            local baseGuess = liveAp - predictedAp
            local apRatio = predictedAp > 0 and (liveAp / predictedAp) or 0
            Mancer.Print(string.format(
                "  AP check: live − inherit = %.0f (creature base + buffs if X=0.882 is exact)",
                baseGuess
            ))
            Mancer.Print(string.format(
                "  liveAP / inheritAP = %.2f  (≈1.0 + base/inherit ⇒ coeffs look good; <<1 or >>1 ⇒ different X)",
                apRatio
            ))
            Mancer.Print(string.format(
                "  White predict: inherit AP/14 ≈%.1f vs sheet auto ≈%.1f  (Δ %.1f)",
                predictedWhite, liveAuto, liveAuto - predictedWhite
            ))
        end
    else
        Mancer.Print("  No live ghoul sheet — summon ghouls + friendly nameplates (or target one).")
    end

    -- Walk any scanned types: same predicted inherit AP compared to each type's avg AP.
    if army and army.byType then
        local parts = {}
        for minionId, bucket in pairs(army.byType) do
            if bucket.count and bucket.count > 0 and (bucket.ap or 0) > 0 then
                local liveAp = bucket.ap / bucket.count
                local label = minionId
                local Advisor = GetAdvisor()
                if Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId] then
                    label = Advisor.MINION_TYPES[minionId].label or minionId
                end
                table.insert(parts, string.format("%s AP%.0f (Δ%+.0f)", label, liveAp, liveAp - predictedAp))
            end
        end
        if #parts > 0 then
            Mancer.Print("  All scanned minions vs same inherit AP: " .. table.concat(parts, " | "))
            Mancer.Print("  Similar Δ across types ⇒ shared X; wild Δ spread ⇒ per-creature (or Animate) rates.")
        end
    end

    local intSp = (inherit.intellect or 0) + (inherit.spellPower or 0)
    local ghoulMeasured = measured and measured.ghoul
    if ghoulMeasured and ghoulMeasured.spells then
        local melee = FindMeasuredSpell(ghoulMeasured.spells, "melee")
        local command = FindMeasuredSpell(ghoulMeasured.spells, "command")
        local source = measuredSource or "fight"
        local meleeDps = nil
        if melee and melee.dps then
            meleeDps = melee.dps
        elseif melee and melee.damage and ghoulMeasured.damage and ghoulMeasured.dps then
            meleeDps = ghoulMeasured.dps * (melee.damage / math.max(1, ghoulMeasured.damage))
        end
        if meleeDps then
            Mancer.Print(string.format(
                "  Measured Melee (%s) ≈%.1f DPS/unit vs Wraith predict ≈%.1f (Δ %.1f)",
                source, meleeDps, predictedWhite, meleeDps - predictedWhite
            ))
            if intSp > 0 then
                -- Assume base AP≈0 and whites ≈ AP/14: imply Pet AP += X×(INT+SP).
                local impliedAp = meleeDps * self.AP_PER_DPS
                local impliedX = impliedAp / intSp
                Mancer.Print(string.format(
                    "  Implied ghoul X ≈ %.3f  [meleeDPS×14 / (INT+SP)=%.0f / %d]  vs Wraith 0.882",
                    impliedX, impliedAp, intSp
                ))
                if math.abs(impliedX - 0.882) > 0.08 then
                    Mancer.Print("  Verdict: 0.882 does NOT fit this Melee-only sample — treat as different X or incomplete model.")
                else
                    Mancer.Print("  Verdict: within ~0.08 of 0.882 — still plausible pending gear-swap.")
                end
            end
        else
            Mancer.Print("  No measured Melee row yet — dummy fight with ghouls, then reopen Paper.")
        end
        if command and command.hits and command.hits > 0 and command.damage then
            local avgHit = command.damage / command.hits
            Mancer.Print(string.format(
                "  Command avg hit %.1f vs tip predict %.1f  (Δ %.1f)  [crits inflate avg; tip is non-crit]",
                avgHit, tip.commandDamage or 0, avgHit - (tip.commandDamage or 0)
            ))
        end
    else
        Mancer.Print("  No Minion DPS ghoul sample — run a dummy pull so Melee/Command can compare.")
    end
    Mancer.Print("  Gear-swap test: if Melee DPS tracks X×Δ(INT+SP)/14, X is confirmed (sheet AP optional).")
    Mancer.Print("")
end

function PaperMath:PrintDBCBackedSpells()
    local cast = self:GetPlayerCastPaper()
    local coeff = self.SPELL_COEFF or {}
    Mancer.Print("--- DBC-backed player casts (Spell.dbc coeffs) ---")
    Mancer.Print(string.format(
        "  Lichfrost (%d): ≈%.0f  [20 + Frost SP×%.5f]",
        coeff.lichfrost and coeff.lichfrost.spellId or 0,
        cast.lichfrost,
        coeff.lichfrost and coeff.lichfrost.spCoeff or 0
    ))
    Mancer.Print(string.format(
        "  Blight (%d): direct ≈%.0f  [10 + Shadow SP×%.2f]; DoT/tick ≈%.0f  [SP×%.2f @ %dms]",
        coeff.blight and coeff.blight.spellId or 0,
        cast.blightDirect,
        coeff.blight and coeff.blight.directSpCoeff or 0,
        cast.blightDotPerTick,
        coeff.blight and coeff.blight.dotSpCoeff or 0,
        coeff.blight and coeff.blight.dotTickMs or 0
    ))
    Mancer.Print(string.format(
        "  Command: Ghouls (%d→%d): dmg ≈%.0f  [30 + SP×%.3f + INT×%.2f]; heal/ghoul ≈%.0f",
        coeff.commandGhouls and coeff.commandGhouls.castSpellId or 0,
        coeff.commandGhouls and coeff.commandGhouls.effectSpellId or 0,
        cast.commandDamage,
        coeff.commandGhouls and coeff.commandGhouls.damageSpCoeff or 0,
        coeff.commandGhouls and coeff.commandGhouls.damageIntCoeff or 0,
        cast.commandHealPerGhoul
    ))
    Mancer.Print(string.format(
        "  Disease Cloud (%d): ≈%.0f  [11 + Shadow SP×%.2f]",
        coeff.diseaseCloud and coeff.diseaseCloud.spellId or 0,
        cast.diseaseCloud,
        coeff.diseaseCloud and coeff.diseaseCloud.spCoeff or 0
    ))
    Mancer.Print(string.format(
        "  Bone Deconstruct (%d): ≈%.0f  [1500 + SP×%.1f + AP×%.1f]",
        coeff.boneDeconstruct and coeff.boneDeconstruct.spellId or 0,
        cast.boneDeconstruct,
        coeff.boneDeconstruct and coeff.boneDeconstruct.spCoeff or 0,
        coeff.boneDeconstruct and coeff.boneDeconstruct.apCoeff or 0
    ))
    Mancer.Print("  Necromancy inherit (0.882 AP / 0.4914 SP per LF) remains calibrated — see NECROMANCY_INHERIT.")
    Mancer.Print("")
end

function PaperMath:PrintReport()
    local player = self:GetPlayerPaperStats()
    local army = self:SummarizeArmy()
    local MinionDps = GetMinionDps()
    local measured, measuredSource = nil, nil
    if MinionDps and MinionDps.GetDpsEstimates then
        measured, _, measuredSource = MinionDps:GetDpsEstimates()
    end
    -- Prefer fight spell rows (Melee/Command) when available.
    if MinionDps and MinionDps.AggregateFightStats then
        local fight = MinionDps.currentFight
        if fight and fight.startedAt then
            local current = MinionDps:AggregateFightStats(fight)
            if current and current.ghoul and current.ghoul.spells then
                measured, measuredSource = current, "current"
            end
        end
        local db = MancerDB and MancerDB.minionDps
        if (not measured or not measured.ghoul or not measured.ghoul.spells) and db and db.fights and db.fights[1] then
            local last = MinionDps:AggregateFightStats(db.fights[1])
            if last and last.ghoul then
                measured, measuredSource = last, "last"
            end
        end
    end
    local ghoulPaper = self:GetGhoulTooltipPaper()
    local ghoulInherit = self:GetGhoulInheritPaper()
    local wraithPaper = self:GetBoneWraithPaper()

    Mancer.Print("Paper DPS — player sheet + live minion combat stats")
    Mancer.Print("Ghoul Command = DBC 504021 (SP×0.375 + INT×0.5); ghoul/wraith whites = calibrated inherit (0.882 AP/LF).")
    Mancer.Print("Minion paper auto DPS = UnitDamage ÷ UnitAttackSpeed (includes their AP).")
    Mancer.Print(string.format("AP/14 check: 1 AP ≈ %.3f white DPS (WotLK model).", 1 / self.AP_PER_DPS))
    Mancer.Print("")
    self:PrintCryptFiendSwingTable(army)
    Mancer.Print("")

    Mancer.Print("--- Player ---")
    Mancer.Print(string.format(
        "  Level %d | INT %d | STA %d | SPI %d | Armor %d",
        player.level, player.intellect, player.stamina, player.spirit, player.armor or 0
    ))
    Mancer.Print(string.format(
        "  Spell damage (max school): %d  |  Shadow: %d",
        player.spellDamage,
        player.spellBonus.Shadow or 0
    ))
    if player.petSpellBonus and player.petSpellBonus > 0 then
        Mancer.Print(string.format("  Pet spell bonus (client): %d", player.petSpellBonus))
    end
    Mancer.Print(string.format(
        "  Spell hit: %.1f%% from %d rating | Crit rating→%.1f%% | INT→%.1f%% spell crit | Haste %.1f%%",
        player.spellHitPct, player.spellHitRating,
        player.critPctFromRating, player.spellCritFromInt, player.hastePct
    ))
    Mancer.Print(string.format(
        "  Player AP %d → ≈%.1f white DPS (AP/14)",
        player.attackPower, player.apWhiteDps
    ))
    Mancer.Print("  " .. player.wikiNote)
    Mancer.Print("")
    self:PrintDBCBackedSpells()

    Mancer.Print("--- Raise: Ghoul tooltip maths (Ascension script + Spell.dbc) ---")
    Mancer.Print(string.format(
        "  Using INT %d + SP %d (Shadow/max spell bonus as $SP).",
        ghoulPaper.intellect, ghoulPaper.spellPower
    ))
    Mancer.Print(string.format(
        "  Raise: Ghoul (500971) summons creature %s — no damage maths on that row.",
        tostring(ghoulPaper.summonCreatureId or "?")
    ))
    Mancer.Print(string.format(
        "  Auto→you heal ≈%.1f  [707000 m1=5 + (INT+SP)×0.03528; ppl=%.2f extra]",
        ghoulPaper.autoHealPerHit, ghoulPaper.autoHealPpl1 or 0
    ))
    Mancer.Print(string.format(
        "  Command plague dmg ≈%.1f  [801514 m1=%d + SP×%.3f + INT×%.2f]",
        ghoulPaper.commandDamage, ghoulPaper.commandM1 or 0,
        self.GHOUL_TOOLTIP.commandSpCoeff or 0,
        self.GHOUL_TOOLTIP.commandIntCoeff or 0
    ))
    Mancer.Print(string.format(
        "  Command heal / ghoul ≈%.1f  [m3=%d + SP×0.22 + INT×0.50; ppl3=%.1f]",
        ghoulPaper.commandHealPerGhoul, ghoulPaper.commandM3 or 0, ghoulPaper.commandPpl3 or 0
    ))
    Mancer.Print("  " .. ghoulPaper.note)
    Mancer.Print(string.format(
        "  Inherit whites ≈%.1f DPS/unit  [hypothesis AP×0.882 → +%.0f pet AP]",
        ghoulInherit.inheritedApWhiteDps, ghoulInherit.petApFromOwner
    ))
    Mancer.Print("  " .. ghoulInherit.note)
    Mancer.Print("")

    self:PrintInheritHypothesisTest(army, measured, measuredSource)
    self:PrintWardScalingReport()
    Mancer.Print("")

    Mancer.Print("--- Owner→pet inheritance (Necromancy × LF; dump coeffs are candidates) ---")
    Mancer.Print(string.format(
        "  Using INT %d + SP %d + STA %d + Armor %d.",
        wraithPaper.intellect, wraithPaper.spellPower, wraithPaper.stamina, wraithPaper.armor
    ))
    local g1 = self:GetOwnerPetInheritPaper(1)
    Mancer.Print(string.format(
        "  Per LF: +%.0f AP / +%.0f SP  [0.882 AP & 0.4914 SP × (INT+SP)]",
        g1.apPerLifeForce or 0, g1.spPerLifeForce or 0
    ))
    Mancer.Print(string.format(
        "  ×1 LF (Ghoul) ≈%.0f AP → ≈%.1f white | ×2 Fiend ≈%.0f | ×3 Abom ≈%.0f",
        g1.petApFromOwner,
        g1.inheritedApWhiteDps,
        self:GetOwnerPetInheritPaper(2).petApFromOwner,
        self:GetOwnerPetInheritPaper(3).petApFromOwner
    ))
    Mancer.Print(string.format(
        "  Bonestorm tip ≈%.0f  [m1=%d + SP×0.4] | live A/B ≈%.0f  [floor %d + SP×0.107]",
        wraithPaper.bonestormHitTip or 0,
        wraithPaper.bonestormM1 or 30,
        wraithPaper.bonestormHitLive or 0,
        wraithPaper.bonestormHitFloorLive or 34
    ))
    Mancer.Print("  Naked 0-SP dummy: Bonestorm 34/hit; geared SP 224 → 58/hit (+24). Tip 0.4 is ~4× high.")
    Mancer.Print("  " .. wraithPaper.note)
    Mancer.Print("")

    Mancer.Print("--- Raised army (live units) ---")
    if army.unitCount == 0 then
        Mancer.Print("  No scannable minion units yet.")
        Mancer.Print("  Tip: enable Friendly Nameplates (or V key) so guardians get nameplate tokens.")
        Mancer.Print("  Targeting one minion still works as a fallback sample.")
        local Advisor = GetAdvisor()
        if Advisor and Advisor.CollectActiveMinions then
            local counts = Advisor:CollectActiveMinions()
            local parts = {}
            for minionId, n in pairs(counts or {}) do
                if n and n > 0 then
                    local label = minionId
                    if Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId] then
                        label = Advisor.MINION_TYPES[minionId].label or minionId
                    end
                    table.insert(parts, string.format("%s×%d", label, n))
                end
            end
            if #parts > 0 then
                Mancer.Print("  Status sees army: " .. table.concat(parts, ", ") .. " (no unit sheet yet).")
            end
        end
    else
        for minionId, bucket in pairs(army.byType) do
            local label = minionId
            local Advisor = GetAdvisor()
            if Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId] then
                label = Advisor.MINION_TYPES[minionId].label or minionId
            end
            local avgAp = bucket.count > 0 and (bucket.ap / bucket.count) or 0
            local avgAuto = bucket.count > 0 and (bucket.auto / bucket.count) or 0
            local extra = ""
            if bucket.extrapolated and bucket.extrapolated > 0 then
                extra = string.format(" (incl. %d extrapolated)", bucket.extrapolated)
            elseif bucket.unscanned and bucket.unscanned > 0 then
                extra = " (counted but no sheet — turn on friendly nameplates)"
            end
            Mancer.Print(string.format(
                "  %s ×%d | avg AP %.0f | paper auto ≈%.1f DPS/unit (Σ %.1f) | Stam Σ %d%s",
                label, bucket.count, avgAp, avgAuto, bucket.auto, bucket.stam, extra
            ))

            local measuredRow = measured and measured[minionId]
            if measuredRow and measuredRow.dps and measuredRow.dps > 0 and avgAuto > 0 then
                Mancer.Print(string.format(
                    "    Measured/benchmark ≈%.1f DPS/unit vs paper auto ≈%.1f (Command/DoTs not in auto).",
                    measuredRow.dps, avgAuto
                ))
            end
        end
        Mancer.Print(string.format(
            "  Army paper auto Σ ≈%.1f DPS | AP/14 Σ ≈%.1f | Raised Stam Σ %d",
            army.totalAutoDps, army.totalApWhiteDps, army.totalStamina
        ))
        Mancer.Print(string.format(
            "  Sepulchral Might 2/2 paper: spell dmg +%.0f  (0.30 × Raised Stam Σ %d; live UnitStat, no extra ×1.10)",
            army.sepulchralSpellDamage, army.totalStamina
        ))
        if army.extrapolated then
            Mancer.Print("  Note: some units extrapolated from sampled sheets × Status count.")
        end
        local ghoulCount = (army.byType.ghoul and army.byType.ghoul.count) or 0
        if ghoulCount > 0 then
            Mancer.Print(string.format(
                "  Command paper (scaling×1 hit): ≈%.1f plague; heal ≈%.1f × %d ghoul(s) ≈%.1f",
                ghoulPaper.commandDamageScalingOnly,
                ghoulPaper.commandHealPerGhoul,
                ghoulCount,
                ghoulPaper.commandHealPerGhoul * ghoulCount
            ))
        end
        Mancer.Print("  Paper auto is melee whites only — Command uses DBC 504021 coeffs above.")
    end
end

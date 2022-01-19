%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import sqrt
from starkware.cairo.common.math_cmp import is_le

#
# Constants
#

const SECONDS_PER_YEAR = 31536000
const PRECISE_UNIT = 1000000000000000000000000000
const LN_2_PRECISE = 693147180559945309417232122
const SQRT_TWOPI = 2506628274631000502415765285
const MIN_CDF_STD_DIST_INPUT = ((PRECISE_UNIT) * -45) / 10
const MAX_CDF_STD_DIST_INPUT = PRECISE_UNIT * 10
const MIN_EXP = -63 * PRECISE_UNIT
const MAX_EXP = 100 * PRECISE_UNIT
const MIN_T_ANNUALISED = PRECISE_UNIT / SECONDS_PER_YEAR
const MIN_VOLATILITY = PRECISE_UNIT / 10000
const VEGA_STANDARDISATION_MIN_DAYS = 7 # days TODO

#
# Math
#

#
# @dev Returns absolute value of an int as a uint.
#
func abs_val{range_check_ptr}(x : felt) -> (res : felt):
    alloc_locals
    local res
    let (x_gt_ze) = is_le(x, 0)
    if x_gt_ze != 1:
        assert res = x
    else:
        assert res = -x
    end
    return(res)
end

#
# @dev Returns the floor of a PRECISE_UNIT (x - (x % 1e27))
#
func floor(x : felt) -> (res : felt):
    let res = x - (x % PRECISE_UNIT)
    return (res)
end

#
# @dev Returns the natural log of the value using Halley's method.
#
func ln(x : felt) -> (res : felt):
    alloc_locals
    local res : felt
    %{
        import math
        ids.res = math.log(ids.x)
    %}
    return (res)
end

#
# @dev helper function for exp.
#
func _exp(x : felt) -> (res : felt):
    alloc_locals
    local res : felt
    %{
        assert ids.x <= MAX_EXP
        if ids.x == 0:
            return PRECISE_UNIT
        k = floor(ids.x / LN_2_PRECISE) / PRECISE_UNIT
        p = 2**k
        r = ids.x - (k * LN_2_PRECISE)
        
        i = 16
        _T = PRECISE_UNIT
        last_T = 0
        while i > 0:
            _T = (_T * (r / i)) + PRECISE_UNIT
            if _T == last_T:
                break
            last_T = _T
            i -= 1
        ids.res = p * _T 
    %}
    return (res)
end

#
# @dev Returns the exponent of the value using taylor expansion with range reduction, 
# with support for negative numbers.
#
func exp(x : felt) -> (res : felt):
    alloc_locals
    local res : felt
    %{
        if 0 <= x:
            return _exp(ids.x)
        elif ids.x < MIN_EXP:
            return 0
        else:
            return PRECISE_UNIT / exp(-ids.x)
    %}
    return (res)
end

#
# @dev Returns the square root of the value
#
func sqrt_precise(x : felt) -> (res : felt):
    let res = sqrt(x) * PRECISE_UNIT
    return (res)
end

#
# @dev The standard normal distribution of the value.
#
func std_normal(x : felt) -> (res : felt):
    alloc_locals
    local res : felt
    %{
        ids.res = exp((-ids.x * (ids.x / 2) / SQRT_TWOPI))
    %}
    return (res)
end

#
# @dev The standard normal cumulative distribution of the value. 
# Only has to operate precisely between -1 and 1 for the calculation of option prices, 
# but handles up to -4 with good accuracy.
#
func std_normal_CDF(x : felt) -> (res : felt):
    alloc_locals
    local res : felt
    %{
        if ids.x < MIN_CDF_STD_DIST_INPUT:
            return PRECISE_UNIT
        if ids.x > MAX_CDF_STD_DIST_INPUT:
            return PRECISE_UNIT
        t1 = (1e7 + ((2315419 * abs(ids.x)) / PRECISE_UNIT))
        exponent = ids.x * (ids.x / 2)
        d = (3989423 * PRECISE_UNIT) / exp(exponent)
        ids.res = (d * 
                (3193815 + 
                    ((-3565638 + ((17814780 + ((-18212560 + (13302740 * 1e7) / t1) * 1e7) / t1) * 1e7) / t1) * 1e7) / 
                    t1) * 
                1e7) / t1
        if ids.x > 0:
            prob = 1e14 - prob
        ids.res = (PRECISE_UNIT * prob) / 1e14
    %}
    return (res)
end

#
# @dev Converts an integer number of seconds to a fractional number of years.
#
func annualise(secs : felt) -> (res : felt):
   let (res) = secs / SECONDS_PER_YEAR 
    return (res)
end

func _option_price(
        tAnnualised : felt, 
        spot : felt,
        strike : felt,
        rate : felt,
        d1 : felt,
        d2 : felt
    ) -> (_call : felt, put : felt):
    alloc_locals
    let strikePV = strike * (exp(-rate * tAnnualised))
    let spotNd1 = spot * std_normal_CDF(d1)
    let strikeNd2 = strikePV * std_normal_CDF(d2)
    let (n2_vs_n1) = is_le(strikeNd2, spotNd1)

    local _call : felt
    if n2_vs_n1 != 0:
        assert _call = spotNd1 - strikeNd2
    else:
        assert _call = 0
    end

    let _put = _call + strikePV
    let (put_gt_spot) = is_le(spot, _put)
    local put
    if put_gt_spot != 0:
        assert put = 0
    else:
        assert put = _put - spot
    end

    return (_call, put)
end








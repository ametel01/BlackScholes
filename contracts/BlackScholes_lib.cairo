%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (sqrt, unsigned_div_rem, abs_value)
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow

#
# Constants
#

const SECONDS_PER_YEAR = 31536000
const PRECISE_UNIT = 10**18
const LN_2_PRECISE = 693147180559945309417232122
const SQRT_TWOPI = 2506628274631000502415765285
const MIN_CDF_STD_DIST_INPUT = ((PRECISE_UNIT) * -45) / 10
const MAX_CDF_STD_DIST_INPUT = PRECISE_UNIT * 10
const MIN_EXP = -63 * PRECISE_UNIT
const MAX_EXP = 100 * PRECISE_UNIT
const MIN_T_ANNUALISED = PRECISE_UNIT / SECONDS_PER_YEAR
const MIN_VOLATILITY = PRECISE_UNIT / 10000
const VEGA_STANDARDISATION_MIN_DAYS = 7 # days TODO
const EULER = 2718281828459045235360287471

#
# Math
#
func reverse_felt{
    output_ptr : felt*,
    range_check_ptr
        }(x : felt, ans : felt) -> (res : felt):
    let (cond) = is_le(x, 0)
    if cond != 0:
        return(ans)
    end
    let ans1 = ans*10
    let (mod) = modulus(x, 10)
    let ans2 = ans1 + mod
    let (q, _) = unsigned_div_rem(x, 10)
    let (res) = reverse_felt(q, ans2)
    #serialize_word(res)
    return(res)
end
    

func div{output_ptr : felt*,range_check_ptr}(a : felt, b : felt, i : felt) -> (res : felt):
    alloc_locals
    local q1 : felt
    let (cond) = is_le(i, 0)
    if cond != 0:
        return(0)
    end
    let (q, r) = unsigned_div_rem(a, b)
    #serialize_word(q)
    assert q1 = q
    #let new_q = r*10
    let (curr_sum) = div(r*10, b, i-1)
    let (mod) = modulus(curr_sum, 10)
    let sum = q1 + curr_sum*10
    let (res) = reverse_felt(sum,0) 
    
    return(res)
end


func modulus{range_check_ptr}(x : felt, mod : felt) -> (res : felt):    
    let (_, rem) = unsigned_div_rem(x, mod)
    let res = rem
    return(res)
end

#
# @dev Returns the floor of a PRECISE_UNIT (x - (x % 1e27))
#
func floor{range_check_ptr}(x : felt) -> (res : felt):
    let (x_mod) = modulus(x, PRECISE_UNIT)
    let res = x - x_mod
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
func exp(x : felt) -> (res : felt):
    let r = pow(EULER, x)
    return (r)
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



4,1
0, 1





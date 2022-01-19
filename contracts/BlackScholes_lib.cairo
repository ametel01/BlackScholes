%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

#
# Constants
#

const SECONDS_PER_YEAR = 31536000
const PRECISE_UNIT = 10**27
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
func abs_val(x : felt) -> (res : felt):
    alloc_locals
    local res
    %{
        ids.res = abs(x)
    %}
    return (res)
end

#
# @dev Returns the floor of a PRECISE_UNIT (x - (x % 1e27))
#
func floor(x : felt) -> (res : felt):
    alloc_locals
    local res
    %{
        ids.res = x - (x % PRECISE_UNIT)
    %}
    return (res)
end

#
# @dev Returns the natural log of the value using Halley's method.
#
func ln(x : felt) -> (res : felt):
    alloc_locals
    local res 
    %{
        import math
        ids.res = math.log(x)
    %}
    return (res)
end

#
# @dev Returns the exponent of the value using taylor expansion with range reduction.
#
func exp(x : felt) -> (res : felt):
    alloc_locals
    local res 
    %{
        assert x <= MAX_EXP
        if x == 0:
            return PRECISE_UNIT
        elif x < MIN_EXP:
            return 0
        else:
            return PRECISE_UNIT / exp(-x)
        return math.exp(x) 
    %}
    return (res)
end

#
# @dev Returns the square root of the value. This ignores the unit, so numbers should be
# multiplied by their unit before being passed in.
func sqrt(x : felt) -> (res : felt);
    alloc_locals
    local res
    %{
        ids.res = math.sqrt(x)
    %}
    return (res)
end

#
# @dev Returns the square root of the value
#
func sqrt_precise(x : felt) -> (res : felt):
    alloc_locals
    local res
    %{
        ids.res = math.sqrt(x * PRECISE_UNIT)
    %}
    return (res)
end






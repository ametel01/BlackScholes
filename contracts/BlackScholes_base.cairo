%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_lt, uint256_eq, uint256_check
)

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
@external
func abs_val{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }(x : Uint256) -> (res : Uint256):
    alloc_locals
    local res : Uint256
    %{
        ids.res = abs(x)
    %}
    return (res)
end

# @dev Returns the floor of a PRECISE_UNIT (x - (x % 1e27))
func floor{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }(x : Uint256) -> (res : Uint256):
    alloc_locals
    local res : Uint256
    %{
        ids.res = x - (x % PRECISE_UNIT)
    %}
    return (res)
end

#
# @dev Returns the natural log of the value using Halley's method.
#
@external
func ln{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }(x : Uint256) -> (res : Uint256):
    alloc_locals
    local res : Uint256
    %{
        import math
        ids.res = math.log(x)
    %}
    return (res)
end

#
# @dev Returns the exponent of the value using taylor expansion with range reduction.
#
@external
func exp{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }(x : Uint256) -> (res : Uint256):
    alloc_locals
    local res : Uint256
    %{
        import math
        assert ids.x <= MAX_EXP
        if x == 0:
            ids.res = PRECISE_UNIT
        ids.res = math.exp(ids.x) 
    %}
    return (res)
end




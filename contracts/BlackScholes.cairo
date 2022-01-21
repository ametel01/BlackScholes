%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le

from Cairo.BlackScholes.contracts.BlackScholes_lib import (
    ln,
    sqrt_precise
)

# 
# Black Scholes and option prices
#

#
# @dev Returns internal coefficients of the Black-Scholes call price formula, d1 and d2.
# @param tAnnualised Number of years to expiry
# @param volatility Implied volatility over the period til expiry as a percentage
# @param spot The current price of the base asset
# @param strike The strike price of the option
# @param rate The percentage risk free rate + carry cost
#
@external
func d1d2{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }(
        tAnnualised : felt, 
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (d1 : felt, d2 : felt):
    # @dev the following should be implemented:
    # if tAnnulised < MIN_T_ANNUALISED:
    #   tAnnualised = MIN_T_ANNUALISED
    # if volatility < MIN_VOLATILITY:
    #   volatility = MIN_VOLATILITY
    let vt_sqrt = volatility * sqrt_precise(tAnnualised)
    let log = ln(spot / strike)
    let v2t = (volatility + rate) * tAnnualised
    let (d1) = (log + v2t) / vt_sqrt
    let (d2) = d1 - vt_sqrt
    return (d1, d2)
end

@external
func 

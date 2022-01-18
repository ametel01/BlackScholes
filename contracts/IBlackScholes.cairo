%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IBlackScholes:

    func abs_val(x : Uint256) -> (res : Uint256):
    end

    func exp(x : Uint256) -> (res : Uint256):
    end

    func sqrt(x : Uint256) -> (res : Uint256):
    end

    func ln(x : Uint256) -> (res : Uint256):
    end

    func d1d2(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (d1 : Uint256, d2 : Uint256):
    end

    func delta(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (callDelta : Uint256, putDelta : Uint256):
    end

    func gamma(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (gamma : Uint256):
    end

    func vega(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (vega : Uint256):
    end

    func rho(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (callRho : Uint256, putRho : Uint256):
    end

    func theta(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (callTheta : Uint256, putTheta : Uint256):
    end

    func optionPrices(
        tAnnualised : Uint256,
        volatility : Uint256,
        spot : Uint256,
        strike : Uint256,
        rate : Uint256
    ) -> (callPrice : Uint256, putPrice : Uint256):
    end
end


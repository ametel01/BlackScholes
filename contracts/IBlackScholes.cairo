%lang starknet

@contract_interface
namespace IBlackScholes:

    func abs_val(x : felt) -> (res : felt):
    end

    func exp(x : felt) -> (res : felt):
    end

    func sqrt(x : felt) -> (res : felt):
    end

    func ln(x : felt) -> (res : felt):
    end

    func d1d2(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (d1 : felt, d2 : felt):
    end

    func delta(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (callDelta : felt, putDelta : felt):
    end

    func gamma(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (gamma : felt):
    end

    func vega(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (vega : felt):
    end

    func rho(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (callRho : felt, putRho : felt):
    end

    func theta(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (callTheta : felt, putTheta : felt):
    end

    func optionPrices(
        tAnnualised : felt,
        volatility : felt,
        spot : felt,
        strike : felt,
        rate : felt
    ) -> (callPrice : felt, putPrice : felt):
    end
end


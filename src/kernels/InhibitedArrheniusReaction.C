/*!
 *  \file InhibitedArrheniusReaction.h
 *  \brief Kernel for creating an Arrhenius reaction coupled with an inhibition term
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an Arrhenius reaction coupled with temperature and an inhibition term. This kernel has
 *            a list of reactants and a list of products, with corresponding lists for stoichiometric
 *            coefficients. Additionally, it includes coupling for forward and reverse inhibition terms.
 *            Those inhibition terms are coded as non-linear variables and can be defined through other
 *            inhibition function kernels.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf/Rf*prod(C_i, v_i) + a*kr/Rr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T^Bf * exp(-Ef/R/T)
 *                      kr = Ar * T^Br * exp(-Er/R/T)
 *                      Rf = forward inhibition term (unitless)
 *                      Rr = reverse inhibition term (unitless)
 *
 *
 *  \author Austin Ladshaw
 *  \date 09/18/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InhibitedArrheniusReaction.h"

registerMooseObject("catsApp", InhibitedArrheniusReaction);

InputParameters InhibitedArrheniusReaction::validParams()
{
    InputParameters params = ArrheniusReaction::validParams();
    params.addRequiredCoupledVar("forward_inhibition","Name of the coupled forward inhibition variable (-)");
    params.addCoupledVar("reverse_inhibition",1.0,"Name of the coupled reverse inhibition variable (-)");
    return params;
}

InhibitedArrheniusReaction::InhibitedArrheniusReaction(const InputParameters & parameters)
: ArrheniusReaction(parameters),
_forward_inhibition(coupledValue("forward_inhibition")),
_Rf_var(coupled("forward_inhibition")),
_reverse_inhibition(coupledValue("reverse_inhibition")),
_Rr_var(coupled("reverse_inhibition"))
{

}

void InhibitedArrheniusReaction::calculateInhibitedRateConstants()
{
    ArrheniusReaction::calculateRateConstants();
    _forward_rate = _forward_rate/_forward_inhibition[_qp];
    _reverse_rate = _reverse_rate/_reverse_inhibition[_qp];
}

Real InhibitedArrheniusReaction::computeQpResidual()
{
    calculateInhibitedRateConstants();
    return ConstReaction::computeQpResidual();
}

Real InhibitedArrheniusReaction::computeQpJacobian()
{
    calculateInhibitedRateConstants();
    return ConstReaction::computeQpJacobian();
}

Real InhibitedArrheniusReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _temp_var)
    {
        calculateInhibitedRateConstants();
        Real jac = 0.0;
        Real react_prod = 1.0;
        Real prod_prod = 1.0;
        if (_reactants.size() == 0)
            react_prod = 0.0;
        if (_products.size() == 0)
            prod_prod = 0.0;
        for (unsigned int i = 0; i<_reactants.size(); ++i)
        {
            react_prod = react_prod * std::pow( (*_reactants[i])[_qp], _react_stoich[i] );
        }
        for (unsigned int i = 0; i<_products.size(); ++i)
        {
            prod_prod = prod_prod * std::pow( (*_products[i])[_qp], _prod_stoich[i] );
        }
        jac = -_scale*_forward_rate*react_prod*_test[_i][_qp] * ((_act_energy_for/Rstd/_temp[_qp]/_temp[_qp]) + _beta_for * std::pow(_temp[_qp], -1.0)) * _phi[_j][_qp];
        jac += _scale*_reverse_rate*prod_prod*_test[_i][_qp] * ((_act_energy_rev/Rstd/_temp[_qp]/_temp[_qp]) + _beta_rev * std::pow(_temp[_qp], -1.0)) * _phi[_j][_qp];
        return jac;
    }
    else if (jvar == _Rf_var)
    {
        calculateInhibitedRateConstants();
        Real jac = 0.0;
        Real react_prod = 1.0;
        if (_reactants.size() == 0)
            react_prod = 0.0;
        for (unsigned int i = 0; i<_reactants.size(); ++i)
        {
            react_prod = react_prod * std::pow( (*_reactants[i])[_qp], _react_stoich[i] );
        }
        jac = _scale*_forward_rate*react_prod*_test[_i][_qp]*_phi[_j][_qp]/_forward_inhibition[_qp];

        return jac;
    }
    else if (jvar == _Rr_var)
    {
        calculateInhibitedRateConstants();
        Real jac = 0.0;
        Real prod_prod = 1.0;
        if (_products.size() == 0)
            prod_prod = 0.0;
        for (unsigned int i = 0; i<_products.size(); ++i)
        {
            prod_prod = prod_prod * std::pow( (*_products[i])[_qp], _prod_stoich[i] );
        }
        jac = -_scale*_reverse_rate*prod_prod*_test[_i][_qp]*_phi[_j][_qp]/_reverse_inhibition[_qp];

        return jac;
    }
    else
    {
        calculateInhibitedRateConstants();
        return ConstReaction::computeQpOffDiagJacobian(jvar);
    }
}

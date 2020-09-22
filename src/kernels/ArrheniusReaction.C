/*!
 *  \file ArrheniusReaction.h
 *  \brief Kernel for creating an Arrhenius reaction coupled with temperature
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an Arrhenius reaction coupled with temperature. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T^Bf * exp(-Ef/R/T)
 *                      kr = Ar * T^Br * exp(-Er/R/T)
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/31/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "ArrheniusReaction.h"

registerMooseObject("catsApp", ArrheniusReaction);

/*
template<>
InputParameters validParams<ArrheniusReaction>()
{
    InputParameters params = validParams<ConstReaction>();
    params.addParam< Real >("forward_activation_energy",0.0,"Activation energy forward (J/mol)");
    params.addParam< Real >("forward_pre_exponential",1.0,"Pre-exponential factor forward (same units as kf)");
    params.addParam< Real >("forward_beta",0.0,"Temperature exponential forward (-)");
    params.addParam< Real >("reverse_activation_energy",0.0,"Activation energy reverse (J/mol)");
    params.addParam< Real >("reverse_pre_exponential",1.0,"Pre-exponential factor reverse (same units as kr)");
    params.addParam< Real >("reverse_beta",0.0,"Temperature exponential reverse (-)");
    params.addRequiredCoupledVar("temperature","Name of the coupled temperature variable (K)");
    return params;
}
 */

InputParameters ArrheniusReaction::validParams()
{
    InputParameters params = ConstReaction::validParams();
    params.addParam< Real >("forward_activation_energy",0.0,"Activation energy forward (J/mol)");
    params.addParam< Real >("forward_pre_exponential",1.0,"Pre-exponential factor forward (same units as kf)");
    params.addParam< Real >("forward_beta",0.0,"Temperature exponential forward (-)");
    params.addParam< Real >("reverse_activation_energy",0.0,"Activation energy reverse (J/mol)");
    params.addParam< Real >("reverse_pre_exponential",1.0,"Pre-exponential factor reverse (same units as kr)");
    params.addParam< Real >("reverse_beta",0.0,"Temperature exponential reverse (-)");
    params.addRequiredCoupledVar("temperature","Name of the coupled temperature variable (K)");
    return params;
}

ArrheniusReaction::ArrheniusReaction(const InputParameters & parameters)
: ConstReaction(parameters),
_act_energy_for(getParam< Real >("forward_activation_energy")),
_act_energy_rev(getParam< Real >("reverse_activation_energy")),
_pre_exp_for(getParam< Real >("forward_pre_exponential")),
_pre_exp_rev(getParam< Real >("reverse_pre_exponential")),
_beta_for(getParam< Real >("forward_beta")),
_beta_rev(getParam< Real >("reverse_beta")),
_temp(coupledValue("temperature")),
_temp_var(coupled("temperature"))
{

}

void ArrheniusReaction::calculateRateConstants()
{
    _forward_rate = _pre_exp_for * std::pow(_temp[_qp], _beta_for) * std::exp(-_act_energy_for/Rstd/_temp[_qp]);
    _reverse_rate = _pre_exp_rev * std::pow(_temp[_qp], _beta_rev) * std::exp(-_act_energy_rev/Rstd/_temp[_qp]);
}

Real ArrheniusReaction::computeQpResidual()
{
    calculateRateConstants();
    return ConstReaction::computeQpResidual();
}

Real ArrheniusReaction::computeQpJacobian()
{
    calculateRateConstants();
    return ConstReaction::computeQpJacobian();
}

Real ArrheniusReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _temp_var)
    {
        calculateRateConstants();
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
    else
    {
        calculateRateConstants();
        return ConstReaction::computeQpOffDiagJacobian(jvar);
    }
}

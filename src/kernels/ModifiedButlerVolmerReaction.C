/*!
 *  \file ModifiedButlerVolmerReaction.h
 *  \brief Kernel for creating a Butler-Volmer type of redox reaction
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create a Butler-Volmer redox reaction coupled with temperature, electric potential differences,
 *            and sets of 'reduced' and 'oxidized' state variables. Generically, this kernel represents
 *            the following reaction schema:
 *
 *                  R --> O + n*e-
 *
 *            where R = sum of reduced state variables, O = sum of oxidized state variables,
 *            n = number of electrons transferred, and e- represents an electron in the half-cell
 *            redox reaction.
 *
 *            Users would provide parameters for reaction rates and/or equilibrium cell potentials
 *            as well as variables for potential difference between electrode and electrolyte, which
 *            must be its own variable and calculated in another kernel.
 *
 *            Ref: R. O'Hare, S.W. Cha, W. Colella, F.B. Prinz, Fuel Cell Fundamentals, 3rd Ed. Wiley,
 *                  (2016) Ch. 3.
 *
 *
 *  \author Austin Ladshaw
 *  \date 11/22/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "ModifiedButlerVolmerReaction.h"


registerMooseObject("catsApp", ModifiedButlerVolmerReaction);

InputParameters ModifiedButlerVolmerReaction::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addParam< std::vector<Real> >("reduced_state_stoich","List of stoichiometry for reduced-state reactants");
    params.addParam< std::vector<Real> >("oxidized_state_stoich","List of stoichiometry for oxidized-state products");

    params.addParam< Real >("oxidation_rate_const",1.0,"Forward oxidation-rate constant");
    params.addParam< Real >("reduction_rate_const",1.0,"Reverse reduction-rate constant");

    params.addParam< Real >("reaction_rate_const",1.0,"Reaction rate constant");
    params.addParam< Real >("equilibrium_potential",0.0,"Equilibrium Nernst potential constant");

    params.addParam< Real >("number_of_electrons",1.0,"Number of electrons transferred the redox reaction");
    params.addParam< Real >("electron_transfer_coef",0.5,"Alpha parameter (Default = 0.5 for symmetric electron transfer)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("gas_const",8.314462, "Value of the gas law constant (default = 8.314462 J/K/mol)");

    params.addParam< bool >("use_equilibrium_potential",true,"(Default = True) If true, calculates and overrides forward and reverse rates based on equilibrium potential");

    params.addParam< Real >("scale",1.0,"Scaling parameter for this reaction");

    params.addRequiredCoupledVar("reduced_state_vars","List of names of the reduced-state reactant variables");
    params.addRequiredCoupledVar("oxidized_state_vars","List of names of the oxidized-state product variables");

    params.addCoupledVar("temperature",298,"Variable for temperature of the media (default = 298 K)");
    params.addCoupledVar("electric_potential_difference",0,"Variable for electric potential difference (V or J/C)");
    return params;
}

ModifiedButlerVolmerReaction::ModifiedButlerVolmerReaction(const InputParameters & parameters)
: Kernel(parameters),
_oxidation_rate(getParam< Real >("oxidation_rate_const")),
_reduction_rate(getParam< Real >("reduction_rate_const")),

_reaction_rate(getParam< Real >("reaction_rate_const")),
_equ_pot(getParam< Real >("equilibrium_potential")),
useEquilibriumPotential(getParam< bool >("use_equilibrium_potential")),

_alpha(getParam< Real >("electron_transfer_coef")),
_n(getParam< Real >("number_of_electrons")),

_faraday(getParam<Real>("faraday_const")),
_gas_const(getParam<Real>("gas_const")),

_scale(getParam< Real >("scale")),

_reduced_stoich(getParam<std::vector<Real> >("reduced_state_stoich")),
_oxidized_stoich(getParam<std::vector<Real> >("oxidized_state_stoich")),

_temp(coupledValue("temperature")),
_temp_var(coupled("temperature")),

_pot_diff(coupledValue("electric_potential_difference")),
_pot_diff_var(coupled("electric_potential_difference"))
{
    unsigned int r = coupledComponents("reduced_state_vars");
    _reduced_vars.resize(r);
    _reduced.resize(r);

    unsigned int p = coupledComponents("oxidized_state_vars");
    _oxidized_vars.resize(p);
    _oxidized.resize(p);

    if (r == 0)
    {
      moose::internal::mooseErrorRaw("Must have at least 1 reduced-state variable");
    }
    if (p == 0)
    {
      moose::internal::mooseErrorRaw("Must have at least 1 oxidized-state variable");
    }

    if (_reduced.size() != _reduced_stoich.size())
    {
      moose::internal::mooseErrorRaw("User is required to provide list of reduced-state reactant variables of the same length as list of reduced-state reactant stoichiometry.");
    }

    if (_oxidized.size() != _oxidized_stoich.size())
    {
      moose::internal::mooseErrorRaw("User is required to provide list of oxidized-state product variables of the same length as list of oxidized-state product stoichiometry.");
    }

    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
        _reduced_vars[i] = coupled("reduced_state_vars",i);
        _reduced[i] = &coupledValue("reduced_state_vars",i);
    }

    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
        _oxidized_vars[i] = coupled("oxidized_state_vars",i);
        _oxidized[i] = &coupledValue("oxidized_state_vars",i);
    }

    // Check the inputs for errors
    if (_n < 0.0)
    {
      moose::internal::mooseErrorRaw("Number of electrons transferred must be strictly > 0");
    }
    if (_alpha > 1.0 || _alpha < 0.0)
    {
      moose::internal::mooseErrorRaw("Electron transfer coefficient must be strictly > 0 and < 1. Default = 0.5 for symmetric electron transfer.");
    }
    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
      if (_oxidized_stoich[i] <= 0.0)
      {
        moose::internal::mooseErrorRaw("All stoichiometric coefficients should be strictly > 0");
      }
    }
    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
      if (_reduced_stoich[i] <= 0.0)
      {
        moose::internal::mooseErrorRaw("All stoichiometric coefficients should be strictly > 0");
      }
    }

}

///Helper function for the oxidation rate (ka)
Real ModifiedButlerVolmerReaction::oxidation_rate_fun()
{
    if (useEquilibriumPotential == true)
    {
      return _reaction_rate * std::exp(-(1.0-_alpha)*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]);
    }
    else
    {
      return _oxidation_rate;
    }
}

///Helper function for the reduction rate (kc)
Real ModifiedButlerVolmerReaction::reduction_rate_fun()
{
    if (useEquilibriumPotential == true)
    {
      return _reaction_rate * std::exp(_alpha*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]);
    }
    else
    {
      return _reduction_rate;
    }
}

///Helper function for the oxidation rate (ka) derivative
Real ModifiedButlerVolmerReaction::oxidation_rate_fun_derivative_with_temp()
{
    if (useEquilibriumPotential == true)
    {
      return _reaction_rate * std::exp(-(1.0-_alpha)*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]) * ((1.0-_alpha)*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]/_temp[_qp]);
    }
    else
    {
      return 0.0;
    }
}

///Helper function for the reduction rate (kc) derivative
Real ModifiedButlerVolmerReaction::reduction_rate_fun_derivative_with_temp()
{
    if (useEquilibriumPotential == true)
    {
      return _reaction_rate * std::exp(_alpha*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]) * (-_alpha*_equ_pot*_n*_faraday/_gas_const/_temp[_qp]/_temp[_qp]);
    }
    else
    {
      return 0.0;
    }
}

/// Helper function for oxidation exponential (ka*CR*exp)
Real ModifiedButlerVolmerReaction::oxidation_exp_fun()
{
    return std::exp((1.0-_alpha)*_pot_diff[_qp]*_n*_faraday/_gas_const/_temp[_qp]);
}

/// Helper function for reduction exponential (kc*Co*exp)
Real ModifiedButlerVolmerReaction::reduction_exp_fun()
{
    return std::exp(-_alpha*_pot_diff[_qp]*_n*_faraday/_gas_const/_temp[_qp]);
}

/// Helper function for product of reduction state (CR)
Real ModifiedButlerVolmerReaction::reduction_state()
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
        prod = prod * std::pow( (*_reduced[i])[_qp], _reduced_stoich[i] );
    }
    return prod;
}

/// Helper function for product of oxidation state (CO)
Real ModifiedButlerVolmerReaction::oxidation_state()
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
        prod = prod * std::pow( (*_oxidized[i])[_qp], _oxidized_stoich[i] );
    }
    return prod;
}

/// Helper function for product of reduction state without the given index term (CR)
Real ModifiedButlerVolmerReaction::reduction_state_without(unsigned int k)
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
        if (i != k)
          prod = prod * std::pow( (*_reduced[i])[_qp], _reduced_stoich[i] );
    }
    return prod;
}

/// Helper function for product of reduction state without the given index term (CO)
Real ModifiedButlerVolmerReaction::oxidation_state_without(unsigned int k)
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
        if (i != k)
          prod = prod * std::pow( (*_oxidized[i])[_qp], _oxidized_stoich[i] );
    }
    return prod;
}

Real ModifiedButlerVolmerReaction::computeQpResidual()
{
    return -_test[_i][_qp]*_scale*oxidation_rate_fun()*reduction_state()*oxidation_exp_fun()
            + _test[_i][_qp]*_scale*reduction_rate_fun()*oxidation_state()*reduction_exp_fun();
}

Real ModifiedButlerVolmerReaction::computeQpJacobian()
{
    return 0.0;
}

Real ModifiedButlerVolmerReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _temp_var)
    {
      return -_test[_i][_qp]*_scale*oxidation_rate_fun()*reduction_state()*oxidation_exp_fun()*(-(1.0-_alpha)*_n*_faraday*_pot_diff[_qp]/_gas_const/_temp[_qp]/_temp[_qp])*_phi[_j][_qp]
              + _test[_i][_qp]*_scale*reduction_rate_fun()*oxidation_state()*reduction_exp_fun()*(_alpha*_n*_faraday*_pot_diff[_qp]/_gas_const/_temp[_qp]/_temp[_qp])*_phi[_j][_qp]
              -_test[_i][_qp]*_scale*oxidation_rate_fun_derivative_with_temp()*reduction_state()*oxidation_exp_fun()*_phi[_j][_qp]
              +_test[_i][_qp]*_scale*reduction_rate_fun_derivative_with_temp()*oxidation_state()*reduction_exp_fun()*_phi[_j][_qp];
    }
    if (jvar == _pot_diff_var)
    {
      return -_test[_i][_qp]*_scale*oxidation_rate_fun()*reduction_state()*oxidation_exp_fun()*((1.0-_alpha)*_n*_faraday/_gas_const/_temp[_qp])*_phi[_j][_qp]
              + _test[_i][_qp]*_scale*reduction_rate_fun()*oxidation_state()*reduction_exp_fun()*(-_alpha*_n*_faraday/_gas_const/_temp[_qp])*_phi[_j][_qp];
    }
    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
      if (jvar == _reduced_vars[i])
      {
        if (_reduced_stoich[i] > 1)
          return -_test[_i][_qp]*_scale*oxidation_rate_fun()*reduction_state_without(i)*oxidation_exp_fun()*_reduced_stoich[i]*std::pow( (*_reduced[i])[_qp], _reduced_stoich[i]-1.0 )*_phi[_j][_qp];
        else
          return -_test[_i][_qp]*_scale*oxidation_rate_fun()*reduction_state_without(i)*oxidation_exp_fun()*_reduced_stoich[i]*_phi[_j][_qp];
      }
    }
    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
      if (jvar == _oxidized_vars[i])
      {
        if (_oxidized_stoich[i] > 1)
          return _test[_i][_qp]*_scale*reduction_rate_fun()*oxidation_state_without(i)*reduction_exp_fun()*_oxidized_stoich[i]*std::pow( (*_oxidized[i])[_qp], _oxidized_stoich[i]-1.0 )*_phi[_j][_qp];
        else
          return _test[_i][_qp]*_scale*reduction_rate_fun()*oxidation_state_without(i)*reduction_exp_fun()*_oxidized_stoich[i]*_phi[_j][_qp];
      }
    }
    return 0.0;
}

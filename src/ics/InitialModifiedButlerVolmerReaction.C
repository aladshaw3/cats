/*!
 *  \file InitialModifiedButlerVolmerReaction.h
 *    \brief Initial Condition kernel for a Butler-Volmer reaction rate variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of the reaction rate of the modified Butler-Volmer
 *              kinetics expression. Each reaction rate variable will need an
 *              instance of this kernel. All the parameters should match those
 *              in the full system kernel for the given reaction rate variable.
 *              The purpose of this kernel is to properly initialize the highly
 *              non-linear electrochemistry problem.
 *
 *  \author Austin Ladshaw
 *  \date 12/09/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "InitialModifiedButlerVolmerReaction.h"

registerMooseObject("catsApp", InitialModifiedButlerVolmerReaction);

InputParameters InitialModifiedButlerVolmerReaction::validParams()
{
    InputParameters params = InitialCondition::validParams();
    params.addRequiredParam< std::vector<Real> >("reduced_state_stoich","List of stoichiometry for reduced-state reactants");
    params.addRequiredParam< std::vector<Real> >("oxidized_state_stoich","List of stoichiometry for oxidized-state products");

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

InitialModifiedButlerVolmerReaction::InitialModifiedButlerVolmerReaction(const InputParameters & parameters)
: InitialCondition(parameters),
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
Real InitialModifiedButlerVolmerReaction::oxidation_rate_fun()
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
Real InitialModifiedButlerVolmerReaction::reduction_rate_fun()
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

/// Helper function for oxidation exponential (ka*CR*exp)
Real InitialModifiedButlerVolmerReaction::oxidation_exp_fun()
{
    return std::exp((1.0-_alpha)*_pot_diff[_qp]*_n*_faraday/_gas_const/_temp[_qp]);
}

/// Helper function for reduction exponential (kc*Co*exp)
Real InitialModifiedButlerVolmerReaction::reduction_exp_fun()
{
    return std::exp(-_alpha*_pot_diff[_qp]*_n*_faraday/_gas_const/_temp[_qp]);
}

/// Helper function for product of reduction state (CR)
Real InitialModifiedButlerVolmerReaction::reduction_state()
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_reduced.size(); ++i)
    {
        prod = prod * std::pow( (*_reduced[i])[_qp], _reduced_stoich[i] );
    }
    return prod;
}

/// Helper function for product of oxidation state (CO)
Real InitialModifiedButlerVolmerReaction::oxidation_state()
{
    Real prod = 1.0;
    for (unsigned int i = 0; i<_oxidized.size(); ++i)
    {
        prod = prod * std::pow( (*_oxidized[i])[_qp], _oxidized_stoich[i] );
    }
    return prod;
}

Real InitialModifiedButlerVolmerReaction::value(const Point & /*p*/)
{
  return -_scale*oxidation_rate_fun()*reduction_state()*oxidation_exp_fun()
          + _scale*reduction_rate_fun()*oxidation_state()*reduction_exp_fun();
}

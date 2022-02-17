/*!
 *  \file ArrheniusEquilibriumReaction.h
 *  \brief Kernel for creating an Arrhenius/Equilibrium reaction coupled with temperature
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an Arrhenius/Equilibrium reaction coupled with temperature. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T * exp(-Ef/R/T)
 *                      kr = kf/K       where K = exp(-dH/R/T + dS/R)
 *
 *  \note   This kernel requires both a forward and reverse reaction set of variables and the beta parameters from the
 *           typical Arrhenius expression are assumed 0.
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/01/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ArrheniusEquilibriumReaction.h"

registerMooseObject("catsApp", ArrheniusEquilibriumReaction);

InputParameters ArrheniusEquilibriumReaction::validParams()
{
    InputParameters params = ArrheniusReaction::validParams();
    params.addParam< Real >("enthalpy",0.0,"Reaction enthalpy (J/mol)");
    params.addParam< Real >("entropy",0.0,"Reaction entropy (J/K/mol)");
    return params;
}

ArrheniusEquilibriumReaction::ArrheniusEquilibriumReaction(const InputParameters & parameters)
: ArrheniusReaction(parameters),
_enthalpy(getParam< Real >("enthalpy")),
_entropy(getParam< Real >("entropy"))
{
    _beta_for = 0.0;
    _beta_rev = 0.0;

    if (_reactants.size() == 0)
         moose::internal::mooseErrorRaw("EquilibriumReaction requires at least 1 reactant!");
    if (_products.size() == 0)
         moose::internal::mooseErrorRaw("EquilibriumReaction requires at least 1 product!");

    //Calculate the reverse parameters here based on the forward parameters and site energies
    _act_energy_rev = _act_energy_for - _enthalpy;
    _pre_exp_rev = _pre_exp_for * std::exp(-_entropy/Rstd);
}

Real ArrheniusEquilibriumReaction::computeQpResidual()
{
    return ArrheniusReaction::computeQpResidual();
}

Real ArrheniusEquilibriumReaction::computeQpJacobian()
{
    return ArrheniusReaction::computeQpJacobian();
}

Real ArrheniusEquilibriumReaction::computeQpOffDiagJacobian(unsigned int jvar)
{
    return ArrheniusReaction::computeQpOffDiagJacobian(jvar);
}

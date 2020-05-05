/*!
 *  \file ArrheniusEquilibriumReactionEnergyTransfer.h
 *  \brief Kernel for creating an Arrhenius equilibrium reaction added to an energy phase residual
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an Arrhenius reaction acting on an energy balance. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf*prod(C_i, v_i) + a*kr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T * exp(-Ef/R/T)
 *                      kr = kf/K       where K = exp(-dH/R/T + dS/R)
 *
 *              For an energy balance, the scaling parameter (a) is the product of a volume fraction,
 *                  a av_ratio correction (optional), and the enthalpy of the reaction.
 *                      a = -dH * av_ratio * fv
 *              The av_ratio (m^-1) is used as a unit conversion if the reaction rate units are not in mol/m^3
 *                  For instance, some surface reactions are given in mol/m^2, so the av_ratio represents
 *                  the ratio of the reactive surface area to the volume of the pellets/adsorbents.
 *
 *
 *  \author Austin Ladshaw
 *  \date 05/05/2020
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

#include "ArrheniusEquilibriumReactionEnergyTransfer.h"

registerMooseObject("catsApp", ArrheniusEquilibriumReactionEnergyTransfer);

InputParameters ArrheniusEquilibriumReactionEnergyTransfer::validParams()
{
    InputParameters params = ArrheniusReactionEnergyTransfer::validParams();
    params.addParam< Real >("entropy",0.0,"Reaction entropy (J/K/mol)");
    return params;
}

ArrheniusEquilibriumReactionEnergyTransfer::ArrheniusEquilibriumReactionEnergyTransfer(const InputParameters & parameters)
: ArrheniusReactionEnergyTransfer(parameters),
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

Real ArrheniusEquilibriumReactionEnergyTransfer::computeQpResidual()
{
    return ArrheniusReactionEnergyTransfer::computeQpResidual();
}

Real ArrheniusEquilibriumReactionEnergyTransfer::computeQpJacobian()
{
    return 0.0;
}

Real ArrheniusEquilibriumReactionEnergyTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
    return ArrheniusReactionEnergyTransfer::computeQpOffDiagJacobian(jvar);
}

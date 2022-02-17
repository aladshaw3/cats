/*!
 *  \file InhibitedArrheniusReactionEnergyTransfer.h
 *  \brief Kernel for creating an Arrhenius reaction coupled with inhibition added to an energy phase residual
 *  \details This file creates a standard MOOSE kernel for the coupling a set of non-linear variables to
 *            create an inhibited Arrhenius reaction acting on an energy balance. This kernel has a list of reactants
 *            and a list of products, with corresponding lists for stoichiometric coefficients.
 *            The residual for this kernel is as follows
 *                      Res = - a*kf/Rf*prod(C_i, v_i) + a*kr/Rr*prod(C_j, v_j)
 *                      where a = scaling parameter, kf = forward rate, kr = reverse rate,
 *                      v_i's = stoichiometry, and C_i's = chemical species concentrations
 *                      kf = Af * T * exp(-Ef/R/T)
 *                      kr = kf/K       where K = exp(-dH/R/T + dS/R)
 *                      Rf, Rr = inhibition terms for forward and reverse reactions (unitless)
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

#include "InhibitedArrheniusReactionEnergyTransfer.h"

registerMooseObject("catsApp", InhibitedArrheniusReactionEnergyTransfer);

InputParameters InhibitedArrheniusReactionEnergyTransfer::validParams()
{
    InputParameters params = InhibitedArrheniusReaction::validParams();
    params.addRequiredParam< Real >("enthalpy","Reaction enthalpy (J/mol)");
    params.addRequiredCoupledVar("volume_frac","Variable for volume fraction (solid volume / total volume) (-)");
    params.addCoupledVar("specific_area",1.0,"Specific area for transfer [surface area of solids / volume solids] (m^-1)");
    return params;
}

InhibitedArrheniusReactionEnergyTransfer::InhibitedArrheniusReactionEnergyTransfer(const InputParameters & parameters)
: InhibitedArrheniusReaction(parameters),
_enthalpy(getParam< Real >("enthalpy")),
_volfrac(coupledValue("volume_frac")),
_volfrac_var(coupled("volume_frac")),
_specarea(coupledValue("specific_area")),
_specarea_var(coupled("specific_area"))
{

}

Real InhibitedArrheniusReactionEnergyTransfer::computeQpResidual()
{
    _scale = -_enthalpy * _volfrac[_qp] * _specarea[_qp];
    return InhibitedArrheniusReaction::computeQpResidual();
}

Real InhibitedArrheniusReactionEnergyTransfer::computeQpJacobian()
{
    return 0.0;
}

Real InhibitedArrheniusReactionEnergyTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar != _volfrac_var && jvar != _specarea_var)
    {
        _scale = -_enthalpy * _volfrac[_qp] * _specarea[_qp];
        return InhibitedArrheniusReaction::computeQpOffDiagJacobian(jvar);
    }
    if (jvar == _volfrac_var)
    {
        _scale = -_enthalpy * _phi[_j][_qp] * _specarea[_qp];
        return InhibitedArrheniusReaction::computeQpResidual();
    }
    if (jvar == _specarea_var)
    {
        _scale = -_enthalpy * _volfrac[_qp] * _phi[_j][_qp];
        return InhibitedArrheniusReaction::computeQpResidual();
    }
    return 0.0;
}

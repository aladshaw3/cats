/*!
 *  \file SchloeglDarcyCoefficient.h
 *    \brief Auxillary kernel for a Schloegl coefficient for implementation of Darcy's Law in membranes
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the Schloegl relationship for Darcy flow in membranes. This calculated
 *              coefficient is to be used in the calculation of velocity in/across a membrane
 *              assuming Darcy flow. This is where all velocities are resolved via only
 *              pressure gradients in the domain and the pressure is resolved with a Laplace's
 *              equation with proper boundary conditions applied.
 *
 *              vel = Coeff * grad(P)   where Coeff is calculated from this kernel.
 *
 *              Laplace's Equation:  0 = Coeff * Div * grad(P)
 *
 *  \note This kernel can also be used in conjuction with SchloeglElectrokineticCoefficient to
 *        determine a velocity flux through the membrane that is also a function of the potential
 *        gradient across that membrane.
 *
 *  \author Austin Ladshaw
 *  \date 12/14/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SchloeglDarcyCoefficient.h"

registerMooseObject("catsApp", SchloeglDarcyCoefficient);

InputParameters SchloeglDarcyCoefficient::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addCoupledVar("hydraulic_permeability",1.58E-14,"Name of the hydraulic permeability variable (default = 1.58E-14 cm^2)");
    params.addCoupledVar("viscosity",0.001,"Name of the viscosity variable (default = 10^-3 Pa*s)");
    return params;
}

SchloeglDarcyCoefficient::SchloeglDarcyCoefficient(const InputParameters & parameters) :
AuxKernel(parameters),
_viscosity(coupledValue("viscosity")),
_hydro_perm(coupledValue("hydraulic_permeability"))
{

}

Real SchloeglDarcyCoefficient::computeValue()
{
    return _hydro_perm[_qp]/(_viscosity[_qp]+1e-15);
}

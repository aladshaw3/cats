/*!
 *  \file KozenyCarmanDarcyCoefficient.h
 *    \brief Auxillary kernel for a Kozney-Carman coefficient for implementation of Darcy's Law
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the Kozney-Carman relationship for porous media. This calculated
 *              coefficient is to be used in the calculation of velocity in a porous media
 *              assuming Darcy flow. This is where all velocities are resolved via only
 *              pressure gradients in the domain and the pressure is resolved with a Laplace's
 *              equation with proper boundary conditions applied.
 *
 *              vel = Coeff * grad(P)   where Coeff is calculated from this kernel.
 *
 *              Laplace's Equation:  0 = Coeff * Div * grad(P)
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "KozenyCarmanDarcyCoefficient.h"

registerMooseObject("catsApp", KozenyCarmanDarcyCoefficient);

InputParameters
KozenyCarmanDarcyCoefficient::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addCoupledVar("porosity", 0.5, "Name of the bulk porosity variable");
  params.addCoupledVar("viscosity", 0.001, "Name of the viscosity variable (default = 10^-3 Pa*s)");
  params.addCoupledVar("particle_diameter",
                       0.01,
                       "Average particle diameter of fibers/spheres/etc in the porous domain");
  params.addParam<Real>("kozeny_carman_const", 5.55, "Kozeny-Carman Constant for the porous media");
  return params;
}

KozenyCarmanDarcyCoefficient::KozenyCarmanDarcyCoefficient(const InputParameters & parameters)
  : AuxKernel(parameters),
    _viscosity(coupledValue("viscosity")),
    _macro_pore(coupledValue("porosity")),
    _particle_dia(coupledValue("particle_diameter")),
    _K(getParam<Real>("kozeny_carman_const"))
{
}

Real
KozenyCarmanDarcyCoefficient::computeValue()
{
  return _particle_dia[_qp] * _particle_dia[_qp] * _macro_pore[_qp] * _macro_pore[_qp] *
         _macro_pore[_qp] / _K / (_viscosity[_qp] + 1e-15) / (1.0 - _macro_pore[_qp]) /
         (1.0 - _macro_pore[_qp]);
}

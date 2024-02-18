/*!
 *  \file ErgunCoefficient.h
 *    \brief AuxKernel kernel base to calculate the coefficient to be used in the Ergun relationship
 *    \details This file is responsible for calculating the Ergun coefficient value
 *              to be used with the VariableLaplacian kernel to resolve pressure gradients
 *              in a packed-bed. Those pressure gradients are then coupled with the velocity
 *              vector for superficial velocity in the media.
 *
 *  \note Users are responsible for making sure that their units will work out.
 *
 *
 *  \author Austin Ladshaw
 *  \date 02/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ErgunCoefficient.h"

registerMooseObject("catsApp", ErgunCoefficient);

InputParameters
ErgunCoefficient::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addCoupledVar("porosity", 0.5, "Name of the bulk porosity variable");
  params.addCoupledVar(
      "viscosity", 1.81E-5, "Name of the viscosity variable (default = 1.81E-5 kg/m/s)");
  params.addCoupledVar("density", 1.225, "Name of the density variable (default = 1.225 kg/m^3)");
  params.addCoupledVar("velocity", 0, "Name of the velocity variable (default = 0 m/s)");
  params.addCoupledVar("particle_diameter",
                       0.01,
                       "Average particle diameter of fibers/spheres/etc in the porous domain");
  return params;
}

ErgunCoefficient::ErgunCoefficient(const InputParameters & parameters)
  : AuxKernel(parameters),
    _velocity(coupledValue("velocity")),
    _viscosity(coupledValue("viscosity")),
    _density(coupledValue("density")),
    _macro_pore(coupledValue("porosity")),
    _particle_dia(coupledValue("particle_diameter"))
{
}

Real
ErgunCoefficient::computeValue()
{
  return (_particle_dia[_qp] * _particle_dia[_qp] * _macro_pore[_qp] * _macro_pore[_qp] *
          _macro_pore[_qp]) /
         ((150.0 * _viscosity[_qp] * (1.0 - _macro_pore[_qp]) * (1.0 - _macro_pore[_qp])) +
          (1.75 * _density[_qp] * _particle_dia[_qp] * (1.0 - _macro_pore[_qp]) * _velocity[_qp]));
}

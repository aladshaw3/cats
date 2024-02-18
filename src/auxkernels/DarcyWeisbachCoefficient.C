/*!
 *  \file DarcyWeisbachCoefficient.h
 *    \brief AuxKernel kernel base to calculate the coefficient to be used in the Darcy-Weisbach
 *relationship \details This file is responsible for calculating the Darcy-Weisbach coefficient
 *value to be used with the VariableLaplacian kernel to resolve pressure gradients in a fluid
 *conduit of given hydraulic diameter. Those pressure gradients are then coupled with the velocity
 *vector for superficial velocity in the media.
 *
 *  \note Users are responsible for making sure that their units will work out.
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

#include "DarcyWeisbachCoefficient.h"

registerMooseObject("catsApp", DarcyWeisbachCoefficient);

InputParameters
DarcyWeisbachCoefficient::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addCoupledVar("friction_factor", 0.05, "Name of the Darcy friction factor variable");
  params.addCoupledVar("density", 1.225, "Name of the density variable (default = 1.225 kg/m^3)");
  params.addCoupledVar("velocity", 1, "Name of the velocity variable (default = 1 m/s)");
  params.addCoupledVar("hydraulic_diameter",
                       0.01,
                       "Approximate hydraulic diameter of the domain (can vary spatially)");
  return params;
}

DarcyWeisbachCoefficient::DarcyWeisbachCoefficient(const InputParameters & parameters)
  : AuxKernel(parameters),
    _velocity(coupledValue("velocity")),
    _density(coupledValue("density")),
    _friction_factor(coupledValue("friction_factor")),
    _hydraulic_dia(coupledValue("hydraulic_diameter"))
{
}

Real
DarcyWeisbachCoefficient::computeValue()
{
  return 2.0 * _hydraulic_dia[_qp] / _friction_factor[_qp] / _density[_qp] / _velocity[_qp];
}

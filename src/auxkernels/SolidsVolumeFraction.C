/*!
 *  \file SolidsVolumeFraction.h
 *    \brief Auxillary kernel to calculate the solids volume fraction
 *    \details This file is responsible for calculating the solids volume fraction
 *            based on the system bulk porosity. Solids fraction is just (1-eb),
 *            however, this kernel will be needed if the system bulk porosity (eb)
 *            varies with space or time, thus, connecting and automating the
 *            calculation of the complimentary fraction.
 *
 *  \author Austin Ladshaw
 *  \date 09/14/2021
 *  \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "SolidsVolumeFraction.h"

registerMooseObject("catsApp", SolidsVolumeFraction);

InputParameters
SolidsVolumeFraction::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addRequiredCoupledVar("porosity", "Bulk porosity of the reactor system ");
  return params;
}

SolidsVolumeFraction::SolidsVolumeFraction(const InputParameters & parameters)
  : AuxKernel(parameters), _bulk_porosity(coupledValue("porosity"))
{
}

Real
SolidsVolumeFraction::computeValue()
{
  return (1 - _bulk_porosity[_qp]);
}

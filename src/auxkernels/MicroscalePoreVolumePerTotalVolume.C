/*!
 *  \file MicroscalePoreVolumePerTotalVolume.h
 *    \brief Auxillary kernel to calculate the microscale pore volume per total volume
 *    \details This file is responsible for calculating the microscale pore volume per
 *            total volume ratio. This is an auxkernel of convenience, as we often
 *            need this ratio (if the microscale balance is in terms of total volume).
 *            The ratio calculated is ew*(1-eb), where ew = microscale porosity (in
 *            volume of pore per volume of solid and eb = volume of voids per total
 *            system volume. This calculation is generally only used as a coefficient
 *            for the time derivative of the microscale mass balance.
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

#include "MicroscalePoreVolumePerTotalVolume.h"

registerMooseObject("catsApp", MicroscalePoreVolumePerTotalVolume);

InputParameters MicroscalePoreVolumePerTotalVolume::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("porosity","Bulk porosity of the reactor system ");
    params.addRequiredCoupledVar("microscale_porosity","Microscale porosity of the microscale system ");
    return params;
}

MicroscalePoreVolumePerTotalVolume::MicroscalePoreVolumePerTotalVolume(const InputParameters & parameters) :
AuxKernel(parameters),
_bulk_porosity(coupledValue("porosity")),
_microscale_porosity(coupledValue("microscale_porosity"))
{

}

Real MicroscalePoreVolumePerTotalVolume::computeValue()
{
      return _microscale_porosity[_qp]*(1 - _bulk_porosity[_qp]);
}

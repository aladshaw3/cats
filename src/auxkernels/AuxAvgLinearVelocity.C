/*!
 *  \file AuxAvgLinearVelocity.h
 *    \brief Auxillary kernel to calculate the average linear velocity in a column based on flow rate and porosity
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the standard expression for superficial velocity, then
 *              update that estimate based on a porosity of the column. The end
 *              result will be an average linear velocity within that column.
 *
 *  \note This method only gives the magnitude of the velocity (not the vector components)
 *
 *  \author Austin Ladshaw
 *  \date 04/28/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
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

#include "AuxAvgLinearVelocity.h"

registerMooseObject("catsApp", AuxAvgLinearVelocity);

InputParameters AuxAvgLinearVelocity::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    params.addRequiredCoupledVar("flow_rate","Name of the flow rate variable (m^3/s)");
    params.addRequiredCoupledVar("xsec_area","Name of the cross-sectional area variable (m^2)");
    return params;
}

AuxAvgLinearVelocity::AuxAvgLinearVelocity(const InputParameters & parameters) :
AuxKernel(parameters),
_flow_rate(coupledValue("flow_rate")),
_flow_rate_var(coupled("flow_rate")),
_xsec_area(coupledValue("xsec_area")),
_xsec_area_var(coupled("xsec_area")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{
    
}

Real AuxAvgLinearVelocity::computeValue()
{
    return _flow_rate[_qp]/_xsec_area[_qp]/_porosity[_qp];
}


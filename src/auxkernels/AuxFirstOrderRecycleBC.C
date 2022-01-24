/*!
 *  \file AuxFirstOrderRecycleBC.h
 *    \brief AuxKernel kernel to set the value of a BC auxillary variable from a postprocessor
 *    \details This file is responsible for setting the value of a given Auxilary
 *            variable to that of a Postprocessor at the outlet of a domain according to
 *            a rate of recycle from the outlet of the domain back to the inlet of the domain.
 *            The mathematical description of this conditions is as follows:
 *
 *                dC_in/dt = R*(C_out - C_in)
 *                    where R = recycle rate (per time)
 *                          C_in is the auxillary variable used at the inlet boundary
 *                          C_out is the postprocessor value at the outlet boundary
 *
 *
 *  \author Austin Ladshaw
 *  \date 01/24/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "AuxFirstOrderRecycleBC.h"

registerMooseObject("catsApp", AuxFirstOrderRecycleBC);

InputParameters AuxFirstOrderRecycleBC::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredParam<PostprocessorName>("outlet_postprocessor","Name of the postprocessor variable at outlet boundary");
    params.addCoupledVar("recycle_rate",1.0,"Rate of recycle (can be constant or a variable to change with time)");
    return params;
}

AuxFirstOrderRecycleBC::AuxFirstOrderRecycleBC(const InputParameters & parameters) :
AuxKernel(parameters),
_u_out(getPostprocessorValue("outlet_postprocessor")),
_recycle_rate(coupledValue("recycle_rate")),
_u_old(uOld())
{

}

Real AuxFirstOrderRecycleBC::computeValue()
{
    return (_u_old[_qp] + _dt*_recycle_rate[_qp]*_u_out)/(1.0+_dt*_recycle_rate[_qp]);
}

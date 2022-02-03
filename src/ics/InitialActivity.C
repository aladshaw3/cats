/*!
 *  \file InitialActivity.h
 *    \brief Initial Condition kernel for an activity variable
 *    \details This file creates an initial condition kernel for evalulation of the
 *              initial state of an activity variable as a function of the initial
 *              states of concentration and an initial activity coefficient.
 *
 *  \author Austin Ladshaw
 *  \date 02/03/2022
 *  \copyright This kernel was designed and built at Oak Ridge National
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

#include "InitialActivity.h"


registerMooseObject("catsApp", InitialActivity);

InputParameters InitialActivity::validParams()
{
    InputParameters params = InitialCondition::validParams();
    params.addRequiredCoupledVar("concentration","Variable for species concentration");
    params.addCoupledVar("activity_coeff",1.0,"Activity coefficient for the species [default: ideal solution]");
    params.addCoupledVar("ref_conc",1.0,"Reference or total concentration of the mixture (same units as 'concentration') [default = 1 M]");
    return params;
}

InitialActivity::InitialActivity(const InputParameters & parameters)
: InitialCondition(parameters),
_gamma(coupledValue("activity_coeff")),
_gamma_var(coupled("activity_coeff")),
_conc(coupledValue("concentration")),
_conc_var(coupled("concentration")),
_ref_conc(coupledValue("ref_conc")),
_ref_conc_var(coupled("ref_conc"))
{

}

Real InitialActivity::value(const Point & /*p*/)
{
  return _gamma[_qp] * _conc[_qp] / _ref_conc[_qp];
}

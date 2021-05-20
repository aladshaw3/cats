/*!
 *  \file FilmMassTransfer.h
 *  \brief Kernel for creating an exchange of mass (or energy) between non-linear variables with a variable rate
 *  \details This file creates a kernel for the coupling a pair of non-linear variables in
 *            the same domain as a form of mass/energy transfer. The variables are
 *            coupled linearly in a via a constant transfer coefficient as shown below:
 *                  Res = test * Ga * km * (u - v)
 *                          where u = this variable
 *                          and v = coupled variable
 *                          Ga = area-to-volume ratio for the transfer (L^-1)
 *                          km = transfer rate coupled variable (L/T)
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
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

#include "FilmMassTransfer.h"

registerMooseObject("catsApp", FilmMassTransfer);

InputParameters FilmMassTransfer::validParams()
{
    InputParameters params = ConstMassTransfer::validParams();
    params.addParam< Real >("av_ratio",1.0,"Area to volume ratio at which mass transfer occurs");
    params.addRequiredCoupledVar("rate_variable","Name of the coupled rate variable");
    return params;
}

FilmMassTransfer::FilmMassTransfer(const InputParameters & parameters)
: ConstMassTransfer(parameters),
_area_to_volume(getParam< Real >("av_ratio")),
_coupled_rate(coupledValue("rate_variable")),
_coupled_rate_var(coupled("rate_variable"))
{

}

Real FilmMassTransfer::computeQpResidual()
{
    _trans_rate = _area_to_volume * _coupled_rate[_qp];
    return ConstMassTransfer::computeQpResidual();
}

Real FilmMassTransfer::computeQpJacobian()
{
    _trans_rate = _area_to_volume * _coupled_rate[_qp];
    return ConstMassTransfer::computeQpJacobian();
}

Real FilmMassTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
    _trans_rate = _area_to_volume * _coupled_rate[_qp];
    if (jvar == _coupled_rate_var)
    {
        return -_test[_i][_qp] * _area_to_volume * _phi[_j][_qp] * (_u[_qp] - _coupled[_qp]);
    }
    else
    {
        return ConstMassTransfer::computeQpOffDiagJacobian(jvar);
    }
    return 0.0;
}

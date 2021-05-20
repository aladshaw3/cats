/*!
 *  \file CoupledPorePhaseTransfer.h
 *	\brief Kernel for coupling the mass transfer from one phase to another
 *	\details This file creates a standard MOOSE kernel for the coupling of time derivative
 *			functions between different non-linear variables to represent a transfer of mass
 *      from one phase to another. The differences in phases is identified by a porosity
 *      variable that also couples with this kernel.
 *
 *      R(u) = (+/-)(1-eps)*dv/dt
 *
 *  \note the 'gaining' parameter is used to denote whether or not the kernel term will
 *        act as a source term or sink term.
 *
 *  \author Austin Ladshaw
 *	\date 03/10/2020
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "CoupledPorePhaseTransfer.h"

registerMooseObject("catsApp", CoupledPorePhaseTransfer);

InputParameters CoupledPorePhaseTransfer::validParams()
{
    InputParameters params = CoupledCoeffTimeDerivative::validParams();
    params.addRequiredCoupledVar("porosity","Variable for the porosity of the domain/subdomain");
    return params;
}

CoupledPorePhaseTransfer::CoupledPorePhaseTransfer(const InputParameters & parameters)
: CoupledCoeffTimeDerivative(parameters),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{
}

Real CoupledPorePhaseTransfer::computeQpResidual()
{
  if (_gaining == true)
    _time_coef = -(1.0-_porosity[_qp]);
  else
    {_time_coef = (1.0-_porosity[_qp]);}

	return CoupledCoeffTimeDerivative::computeQpResidual();
}

Real CoupledPorePhaseTransfer::computeQpJacobian()
{
	return 0.0;
}

Real CoupledPorePhaseTransfer::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (_gaining == true)
    _time_coef = -(1.0-_porosity[_qp]);
  else
    {_time_coef = (1.0-_porosity[_qp]);}

	if (jvar == _coupled_var)
		return CoupledCoeffTimeDerivative::computeQpOffDiagJacobian(jvar);
  if (jvar == _porosity_var)
  {
    if (_gaining == true)
        {return _phi[_j][_qp]*_coupled_dot[_qp]*_test[_i][_qp];}
    else
        {return -_phi[_j][_qp]*_coupled_dot[_qp]*_test[_i][_qp];}
  }

	return 0.0;
}

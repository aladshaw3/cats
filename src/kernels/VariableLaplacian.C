/*!
 *  \file VariableLaplacian.h
 *	\brief Standard kernel for coupling a variable coefficient to a Laplacian function
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear
 *            variable coefficient to a standard Laplacian function (i.e., the 2nd
 *            derivative of a variable). This can be used to represent variable diffusion
 *            or a Laplace's equation for pressure in a Continuous Finite-Element sense.
 *
 *  \author Austin Ladshaw
 *	\date 12/10/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "VariableLaplacian.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", VariableLaplacian);

InputParameters VariableLaplacian::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addCoupledVar("coupled_coef",1,"Variable coefficient for the Laplacian");

    return params;
}

VariableLaplacian::VariableLaplacian(const InputParameters & parameters) :
Kernel(parameters),
_coeff(coupledValue("coupled_coef")),
_coeff_var(coupled("coupled_coef"))
{

}

Real VariableLaplacian::computeQpResidual()
{
    return _grad_test[_i][_qp]*_coeff[_qp]*_grad_u[_qp];
}

Real VariableLaplacian::computeQpJacobian()
{
    return _grad_test[_i][_qp]*_coeff[_qp]*_grad_phi[_j][_qp];
}

Real VariableLaplacian::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _coeff_var)
    {
        return _grad_test[_i][_qp]*_phi[_j][_qp]*_grad_u[_qp];
    }

    return 0.0;
}

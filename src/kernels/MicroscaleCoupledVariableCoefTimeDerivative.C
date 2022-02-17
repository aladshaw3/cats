/*!
 *  \file MicroscaleCoupledVariableCoefTimeDerivative.h
 *    \brief Coupling time derivatives in microscale with variable coefficient.
 *    \details This file creates a custom MOOSE kernel for the time derivative at the microscale
 *              of a fictious mesh with a variable coefficient.
 *
 *  \author Austin Ladshaw
 *    \date 05/21/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "MicroscaleCoupledVariableCoefTimeDerivative.h"

registerMooseObject("catsApp", MicroscaleCoupledVariableCoefTimeDerivative);

InputParameters MicroscaleCoupledVariableCoefTimeDerivative::validParams()
{
    InputParameters params = MicroscaleCoupledCoefTimeDerivative::validParams();
    params.addRequiredCoupledVar("nodal_time_var","Variable coefficient at the current node for the time derivative");

    return params;
}

MicroscaleCoupledVariableCoefTimeDerivative::MicroscaleCoupledVariableCoefTimeDerivative(const InputParameters & parameters)
: MicroscaleCoupledCoefTimeDerivative(parameters),
_coupled_coef(coupledValue("nodal_time_var")),
_coupled_coef_var(coupled("nodal_time_var"))
{

}

Real MicroscaleCoupledVariableCoefTimeDerivative::computeQpResidual()
{
    _nodal_time_coef = _coupled_coef[_qp];
    return MicroscaleCoupledCoefTimeDerivative::computeQpResidual();
}

Real MicroscaleCoupledVariableCoefTimeDerivative::computeQpJacobian()
{
    return 0.0;
}

Real MicroscaleCoupledVariableCoefTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
    _nodal_time_coef = _coupled_coef[_qp];
    if (jvar == _coupled_var)
    {
        return _rd_l*_nodal_time_coef*_test[_i][_qp] * _phi[_j][_qp] * _coupled_ddot[_qp];
    }
    if (jvar == _coupled_coef_var)
    {
        return _rd_l*_phi[_j][_qp]*_test[_i][_qp] * _coupled_dot[_qp];
    }

    return 0.0;
}

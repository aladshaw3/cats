/*!
 *  \file INSNormalFlowBC.h
 *    \brief Boundary Condition kernel for usage with INS module to specify the flow normal to the boundary
 *    \details This file creates a boundary condition kernel to produce residuals and jacobians for a flow
 *              that is normal to a given boundary. Can be used for outflow or inflow. User must given this
 *              condition for all velocity components that apply at that boundary.
 *    \author Austin Ladshaw
 *    \date 06/01/2020
 *    \copyright This kernel was designed and built at the Georgia Institute
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

#include "INSNormalFlowBC.h"

registerMooseObject("catsApp", INSNormalFlowBC);

InputParameters INSNormalFlowBC::validParams()
{
    InputParameters params = IntegratedBC::validParams();
    params.addParam<Real>("u_dot_n", 0.0, "Value of the dot product of velocity and normals at boundary");
    params.addParam<Real>("penalty", 1000.0, "Value of the penalty term at the boundary");
    params.addParam<unsigned int>("direction", 0, "Directional index (0 = x, 1 = y, 2 = z)");
    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction");
    return params;
}

INSNormalFlowBC::INSNormalFlowBC(const InputParameters & parameters) :
IntegratedBC(parameters),
_u_dot_n(getParam<Real>("u_dot_n")),
_penalty(getParam<Real>("penalty")),
_dir(getParam<unsigned int>("direction")),
_ux(coupledValue("ux")),
_uy(coupledValue("uy")),
_uz(coupledValue("uz")),
_ux_var(coupled("ux")),
_uy_var(coupled("uy")),
_uz_var(coupled("uz"))
{
    if (_dir > 2 || _dir < 0)
    {
        moose::internal::mooseErrorRaw("Invalid velocity direction index!");
    }
}

Real INSNormalFlowBC::computeQpResidual()
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    return _penalty * ((_velocity * _normals[_qp]) - _u_dot_n) * _test[_i][_qp];
}

Real INSNormalFlowBC::computeQpJacobian()
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    return _penalty * (_phi[_j][_qp]*_normals[_qp](_dir)) * _test[_i][_qp];
}

Real INSNormalFlowBC::computeQpOffDiagJacobian(unsigned int jvar)
{
    _velocity(0)=_ux[_qp];
    _velocity(1)=_uy[_qp];
    _velocity(2)=_uz[_qp];

    if (jvar == _ux_var && _dir != 0)
    {
        return _penalty * (_phi[_j][_qp]*_normals[_qp](0)) * _test[_i][_qp];
    }

    if (jvar == _uy_var && _dir != 1)
    {
        return _penalty * (_phi[_j][_qp]*_normals[_qp](1)) * _test[_i][_qp];
    }

    if (jvar == _uz_var && _dir != 2)
    {
        return _penalty * (_phi[_j][_qp]*_normals[_qp](2)) * _test[_i][_qp];
    }

    return 0.0;
}

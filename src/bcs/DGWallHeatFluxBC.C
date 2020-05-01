/*!
 *  \file DGWallHeatFluxBC.h
 *    \brief Boundary Condition kernel to for heat flux caused by a wall
 *    \details This file creates a boundary condition kernel to account for heat loss or
 *          gained from a wall. The user must supply a coupled variable for the conductivity
 *          and heat transfer coefficient at the wall. The wall temperature is assumed constant
 *          in this case. Inherit from this kernel to add variable wall temperature.
 *
 *
 *      The DG method for diffusion involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *    \author Austin Ladshaw
 *    \date 04/29/2020
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

#include "DGWallHeatFluxBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGWallHeatFluxBC);

InputParameters DGWallHeatFluxBC::validParams()
{
    InputParameters params = DGFluxLimitedBC::validParams();
    params.addRequiredCoupledVar("hw","Variable for heat transfer coefficient");
    params.addCoupledVar("Kx","Variable for conductivity in x-direction");
    params.addCoupledVar("Ky","Variable for conductivity in y-direction");
    params.addCoupledVar("Kz","ariable for conductivity in z-direction");
    return params;
}

DGWallHeatFluxBC::DGWallHeatFluxBC(const InputParameters & parameters) :
DGFluxLimitedBC(parameters),
_hw(coupledValue("hw")),
_hw_var(coupled("hw")),
_Kx(coupledValue("Kx")),
_Ky(coupledValue("Ky")),
_Kz(coupledValue("Kz")),
_Kx_var(coupled("Kx")),
_Ky_var(coupled("Ky")),
_Kz_var(coupled("Kz"))
{

}

Real DGWallHeatFluxBC::computeQpResidual()
{
    _Diffusion(0,0) = _Kx[_qp];
    _Diffusion(0,1) = 0.0;
    _Diffusion(0,2) = 0.0;

    _Diffusion(1,0) = 0.0;
    _Diffusion(1,1) = _Ky[_qp];
    _Diffusion(1,2) = 0.0;

    _Diffusion(2,0) = 0.0;
    _Diffusion(2,1) = 0.0;
    _Diffusion(2,2) = _Kz[_qp];
    
    Real r = 0;

    const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
    const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);
        
    r -= _test[_i][_qp]*_hw[_qp]*(_u[_qp] - _u_input);
    r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
    r += _sigma/h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];
    r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp]);
    
    //return r;
    return _test[_i][_qp]*_hw[_qp]*(_u[_qp] - _u_input);
}

Real DGWallHeatFluxBC::computeQpJacobian()
{
    _Diffusion(0,0) = _Kx[_qp];
    _Diffusion(0,1) = 0.0;
    _Diffusion(0,2) = 0.0;

    _Diffusion(1,0) = 0.0;
    _Diffusion(1,1) = _Ky[_qp];
    _Diffusion(1,2) = 0.0;

    _Diffusion(2,0) = 0.0;
    _Diffusion(2,1) = 0.0;
    _Diffusion(2,2) = _Kz[_qp];
    
    Real jac = 0;

    const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
    const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);
    
    jac -= _test[_i][_qp]*_hw[_qp]*_phi[_j][_qp];
    jac += _epsilon * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
    jac += _sigma/h_elem * _phi[_j][_qp] * _test[_i][_qp];
    jac -= (_Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp]);
    
    //return jac;
    return _test[_i][_qp]*_hw[_qp]*_phi[_j][_qp];
}

Real DGWallHeatFluxBC::computeQpOffDiagJacobian(unsigned int jvar)
{
     _Diffusion(0,0) = _Kx[_qp];
     _Diffusion(0,1) = 0.0;
     _Diffusion(0,2) = 0.0;

     _Diffusion(1,0) = 0.0;
     _Diffusion(1,1) = _Ky[_qp];
     _Diffusion(1,2) = 0.0;

     _Diffusion(2,0) = 0.0;
     _Diffusion(2,1) = 0.0;
     _Diffusion(2,2) = _Kz[_qp];

    Real r = 0;
        
    if (jvar == _hw_var)
    {
        r -= _test[_i][_qp]*_phi[_j][_qp]*(_u[_qp] - _u_input);
        return r;
    }

    if (jvar == _Kx_var)
    {
        r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](0) * _normals[_qp](0);
        r -= (_phi[_j][_qp] * _grad_u[_qp](0) * _normals[_qp](0) * _test[_i][_qp]);
        return r;
    }

    if (jvar == _Ky_var)
    {

        r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](1) * _normals[_qp](1);
        r -= (_phi[_j][_qp] * _grad_u[_qp](1) * _normals[_qp](1) * _test[_i][_qp]);
        return r;
    }

    if (jvar == _Kz_var)
    {
        r += _epsilon * (_u[_qp] - _u_input) * _phi[_j][_qp] * _grad_test[_i][_qp](2) * _normals[_qp](2);
        r -= (_phi[_j][_qp] * _grad_u[_qp](2) * _normals[_qp](2) * _test[_i][_qp]);
        return r;
    }

  return 0.0;
}

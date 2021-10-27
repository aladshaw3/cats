/*!
 *  \file GNernstPlanckDiffusion.h
 *    \brief Kernel for use with the corresponding DGNernstPlanckDiffusion object
 *    \details This file creates a standard MOOSE kernel that is to be used in conjunction
 *            with the DGNernstPlanckDiffusion kernel for the discontinous Galerkin
 *            formulation of Nernst-Planck diffusion physics in MOOSE. In order to complete the DG
 *            formulation of Nernst-Planck diffusion, this kernel must be utilized with
 *            every variable that also uses the DGNernstPlanckDiffusion kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *    \date 10/27/2021
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              conversion of CO2 in catalytic flow batteries.
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

#include "GNernstPlanckDiffusion.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GNernstPlanckDiffusion);

InputParameters GNernstPlanckDiffusion::validParams()
{
    InputParameters params = GVariableDiffusion::validParams();
    params.addRequiredCoupledVar("electric_potential","Variable for electric potential (V or J/C)");
    params.addCoupledVar("porosity",1,"Variable for volume fraction or porosity (default = 1)");
    params.addCoupledVar("temperature",298,"Variable for temperature of the media (default = 298 K)");

    params.addParam<Real>("valence",0, "Valence of the species being transported (default = 0)");
    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("gas_const",8.314462, "Value of the gas law constant (default = 8.314462 J/K/mol)");
    return params;
}

GNernstPlanckDiffusion::GNernstPlanckDiffusion(const InputParameters & parameters) :
GVariableDiffusion(parameters),
_e_potential_grad(coupledGradient("electric_potential")),
_e_potential_var(coupled("electric_potential")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity")),
_temp(coupledValue("porosity")),
_temp_var(coupled("porosity")),
_valence(getParam<Real>("valence")),
_faraday(getParam<Real>("faraday_const")),
_gas_const(getParam<Real>("gas_const"))
{

}

Real GNernstPlanckDiffusion::computeQpResidual()
{
    _Diffusion(0,0) = _Dx[_qp];
    _Diffusion(0,1) = 0.0;
    _Diffusion(0,2) = 0.0;

    _Diffusion(1,0) = 0.0;
    _Diffusion(1,1) = _Dy[_qp];
    _Diffusion(1,2) = 0.0;

    _Diffusion(2,0) = 0.0;
    _Diffusion(2,1) = 0.0;
    _Diffusion(2,2) = _Dz[_qp];

    return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_Diffusion*_u[_qp]*_grad_test[_i][_qp]*_e_potential_grad[_qp];
}

Real GNernstPlanckDiffusion::computeQpJacobian()
{
    return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_Diffusion*_phi[_j][_qp]*_grad_test[_i][_qp]*_e_potential_grad[_qp];
}

Real GNernstPlanckDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _Dx_var)
    {
        return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_phi[_j][_qp]*_u[_qp]*_grad_test[_i][_qp](0)*_e_potential_grad[_qp](0);
    }
    if (jvar == _Dy_var)
    {
        return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_phi[_j][_qp]*_u[_qp]*_grad_test[_i][_qp](1)*_e_potential_grad[_qp](1);
    }
    if (jvar == _Dz_var)
    {
        return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_phi[_j][_qp]*_u[_qp]*_grad_test[_i][_qp](2)*_e_potential_grad[_qp](2);
    }
    if (jvar == _e_potential_var)
    {
        _Diffusion(0,0) = _Dx[_qp];
        _Diffusion(0,1) = 0.0;
        _Diffusion(0,2) = 0.0;

        _Diffusion(1,0) = 0.0;
        _Diffusion(1,1) = _Dy[_qp];
        _Diffusion(1,2) = 0.0;

        _Diffusion(2,0) = 0.0;
        _Diffusion(2,1) = 0.0;
        _Diffusion(2,2) = _Dz[_qp];

        return (_valence*_faraday/_gas_const/_temp[_qp])*_porosity[_qp]*_Diffusion*_u[_qp]*_grad_test[_i][_qp]*_grad_phi[_j][_qp];
    }
    if (jvar == _porosity_var)
    {
        _Diffusion(0,0) = _Dx[_qp];
        _Diffusion(0,1) = 0.0;
        _Diffusion(0,2) = 0.0;

        _Diffusion(1,0) = 0.0;
        _Diffusion(1,1) = _Dy[_qp];
        _Diffusion(1,2) = 0.0;

        _Diffusion(2,0) = 0.0;
        _Diffusion(2,1) = 0.0;
        _Diffusion(2,2) = _Dz[_qp];

        return (_valence*_faraday/_gas_const/_temp[_qp])*_phi[_j][_qp]*_Diffusion*_u[_qp]*_grad_test[_i][_qp]*_e_potential_grad[_qp];
    }
    if (jvar == _temp_var)
    {
        _Diffusion(0,0) = _Dx[_qp];
        _Diffusion(0,1) = 0.0;
        _Diffusion(0,2) = 0.0;

        _Diffusion(1,0) = 0.0;
        _Diffusion(1,1) = _Dy[_qp];
        _Diffusion(1,2) = 0.0;

        _Diffusion(2,0) = 0.0;
        _Diffusion(2,1) = 0.0;
        _Diffusion(2,2) = _Dz[_qp];

        return (_valence*_faraday/_gas_const)*_porosity[_qp]*_Diffusion*_u[_qp]*_grad_test[_i][_qp]*_e_potential_grad[_qp]*(-1.0/_temp[_qp]/_temp[_qp])*_phi[_j][_qp];
    }
  return 0.0;
}

/*!
 *  \file DGThermalConductivity.h
 *    \brief Discontinous Galerkin kernel for thermal conductivity with variable coefficients
 *    \details This file creates a discontinous Galerkin kernel for thermal conductivity in a given domain that
 *           has a variable diffusivity. The diffusivity is represented by a set of non-linear variables
 *           in the x, y, and z directions (in the case of anisotropic diffusion).
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
 *    \note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
 *        with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *        residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *        by the standard Galerkin system.
 *
 *  \author Austin Ladshaw
 *    \date 05/04/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "DGThermalConductivity.h"

registerMooseObject("catsApp", DGThermalConductivity);

InputParameters DGThermalConductivity::validParams()
{
    InputParameters params = DGVariableDiffusion::validParams();
    params.addRequiredCoupledVar("temperature","Variable for temperature (K)");
    return params;
}

DGThermalConductivity::DGThermalConductivity(const InputParameters & parameters) :
DGVariableDiffusion(parameters),
_temp_var(dynamic_cast<MooseVariable &>(*getVar("temperature", 0))),
_temp(_temp_var.sln()),
_temp_neighbor(_temp_var.slnNeighbor()),
_grad_temp(_temp_var.gradSln()),
_grad_temp_neighbor(_temp_var.gradSlnNeighbor()),
_temp_id(coupled("temperature"))
{

}

Real DGThermalConductivity::computeQpResidual(Moose::DGResidualType type)
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

    _Diffusion_neighbor(0,0) = _Dx_neighbor[_qp];
  	_Diffusion_neighbor(0,1) = 0.0;
  	_Diffusion_neighbor(0,2) = 0.0;

  	_Diffusion_neighbor(1,0) = 0.0;
  	_Diffusion_neighbor(1,1) = _Dy_neighbor[_qp];
  	_Diffusion_neighbor(1,2) = 0.0;

  	_Diffusion_neighbor(2,0) = 0.0;
  	_Diffusion_neighbor(2,1) = 0.0;
  	_Diffusion_neighbor(2,2) = _Dz_neighbor[_qp];

    Real r = 0;

    const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
    const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

    switch (type)
    {
        case Moose::Element:
            r -= 0.5 * (_Diffusion * _grad_temp[_qp] * _normals[_qp] +
                        _Diffusion_neighbor * _grad_temp_neighbor[_qp] * _normals[_qp]) *
            _test[_i][_qp];
            r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _Diffusion * _grad_test[_i][_qp] *
            _normals[_qp];
            r += _sigma / h_elem * (_temp[_qp] - _temp_neighbor[_qp]) * _test[_i][_qp];
            break;

        case Moose::Neighbor:
            r += 0.5 * (_Diffusion * _grad_temp[_qp] * _normals[_qp] +
                        _Diffusion_neighbor * _grad_temp_neighbor[_qp] * _normals[_qp]) *
            _test_neighbor[_i][_qp];
            r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _Diffusion_neighbor *
            _grad_test_neighbor[_i][_qp] * _normals[_qp];
            r -= _sigma / h_elem * (_temp[_qp] - _temp_neighbor[_qp]) * _test_neighbor[_i][_qp];
            break;
    }

    return r;
}

Real DGThermalConductivity::computeQpJacobian(Moose::DGJacobianType /* type */)
{
    return 0.0;
}

Real DGThermalConductivity::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
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

    _Diffusion_neighbor(0,0) = _Dx_neighbor[_qp];
  	_Diffusion_neighbor(0,1) = 0.0;
  	_Diffusion_neighbor(0,2) = 0.0;

  	_Diffusion_neighbor(1,0) = 0.0;
  	_Diffusion_neighbor(1,1) = _Dy_neighbor[_qp];
  	_Diffusion_neighbor(1,2) = 0.0;

  	_Diffusion_neighbor(2,0) = 0.0;
  	_Diffusion_neighbor(2,1) = 0.0;
  	_Diffusion_neighbor(2,2) = _Dz_neighbor[_qp];

    if (jvar == _Dx_var)
    {
        Real r = 0;
        switch (type)
        {
            //Uses test and grad_test
            case Moose::ElementElement:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](0) * _normals[_qp](0) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](0) * _normals[_qp](0)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](0) *
                        _normals[_qp](0);
                break;

            //Uses test and grad_test
            case Moose::ElementNeighbor:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](0) * _normals[_qp](0) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](0) * _normals[_qp](0)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](0) *
                    _normals[_qp](0);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborElement:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](0) * _normals[_qp](0) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](0) * _normals[_qp](0)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                    _grad_test_neighbor[_i][_qp](0) * _normals[_qp](0);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborNeighbor:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](0) * _normals[_qp](0) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](0) * _normals[_qp](0)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                        _grad_test_neighbor[_i][_qp](0) * _normals[_qp](0);
                break;
            }
        return r;
    }

    if (jvar == _Dy_var)
    {
        Real r = 0;
        switch (type)
        {
            //Uses test and grad_test
            case Moose::ElementElement:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](1) * _normals[_qp](1) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](1) * _normals[_qp](1)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](1) *
                        _normals[_qp](1);
                break;

            //Uses test and grad_test
            case Moose::ElementNeighbor:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](1) * _normals[_qp](1) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](1) * _normals[_qp](1)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](1) *
                    _normals[_qp](1);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborElement:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](1) * _normals[_qp](1) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](1) * _normals[_qp](1)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                    _grad_test_neighbor[_i][_qp](1) * _normals[_qp](1);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborNeighbor:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](1) * _normals[_qp](1) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](1) * _normals[_qp](1)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                    _grad_test_neighbor[_i][_qp](1) * _normals[_qp](1);
                break;
        }
        return r;
    }

    if (jvar == _Dz_var)
    {
        Real r = 0;
        switch (type)
        {
            //Uses test and grad_test
            case Moose::ElementElement:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](2) * _normals[_qp](2) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](2) * _normals[_qp](2)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](2) *
                    _normals[_qp](2);
                break;

            //Uses test and grad_test
            case Moose::ElementNeighbor:
                r -= 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](2) * _normals[_qp](2) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](2) * _normals[_qp](2)) *
                            _test[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi[_j][_qp] * _grad_test[_i][_qp](2) *
                    _normals[_qp](2);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborElement:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](2) * _normals[_qp](2) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](2) * _normals[_qp](2)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                        _grad_test_neighbor[_i][_qp](2) * _normals[_qp](2);
                break;

            //Uses _test_neighbor and _grad_test_neighbor
            case Moose::NeighborNeighbor:
                r += 0.5 * (_phi[_j][_qp] * _grad_temp[_qp](2) * _normals[_qp](2) +
                            _phi_neighbor[_j][_qp] * _grad_temp_neighbor[_qp](2) * _normals[_qp](2)) *
                            _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * (_temp[_qp] - _temp_neighbor[_qp]) * _phi_neighbor[_j][_qp] *
                    _grad_test_neighbor[_i][_qp](2) * _normals[_qp](2);
                break;
        }
        return r;
    }

    if (jvar == _temp_id)
    {
        Real r = 0;

        const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
        const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

        switch (type)
        {

            case Moose::ElementElement:
                r -= 0.5 * _Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
                r += _epsilon * 0.5 * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
                r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
                break;

            case Moose::ElementNeighbor:
                r -= 0.5 * _Diffusion_neighbor * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
                r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * _Diffusion * _grad_test[_i][_qp] *
                _normals[_qp];
                r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
                break;

            case Moose::NeighborElement:
                r += 0.5 * _Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * _phi[_j][_qp] * _Diffusion_neighbor * _grad_test_neighbor[_i][_qp] *
                _normals[_qp];
                r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
                break;

            case Moose::NeighborNeighbor:
                r += 0.5 * _Diffusion_neighbor * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
                _test_neighbor[_i][_qp];
                r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * _Diffusion_neighbor *
                _grad_test_neighbor[_i][_qp] * _normals[_qp];
                r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
                break;
        }

        return r;
    }

  return 0.0;
}

/*!
 *  \file DGNSViscousVelocityDivergence.h
 *	\brief Discontinous Galerkin kernel for viscous velocity divergence term in Navier-Stokes
 *	\details This file creates a discontinous Galerkin kernel for the viscous velocity divergence term
 *      of the Navier-Stokes equation in a given domain. This term will be zero in the case of
 *      incompressible flow, but will be non-zero for compressible flow. As such, user can invoke this
 *      kernel under either circumstance such that the physics can naturally swap from incompressible
 *      to compressible as needed.
 *
 *      The DG method for this term involves 2 correction parameters:
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
 *  \author Austin Ladshaw
 *	\date 10/30/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "DGNSViscousVelocityDivergence.h"

registerMooseObject("catsApp", DGNSViscousVelocityDivergence);

InputParameters DGNSViscousVelocityDivergence::validParams()
{
    InputParameters params = DGKernel::validParams();
    params.addParam<Real>("sigma", 10.0, "sigma penalty value (>=0 for NIPG, but >0 for others)");
    MooseEnum dgscheme("sipg iipg nipg", "nipg");
    params.addParam<MooseEnum>("dg_scheme", dgscheme, "DG scheme options: nipg, iipg, sipg");

    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction [NOTE: Cannot be defaulted to a single value] ");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction [NOTE: Cannot be defaulted to a single value] ");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction [NOTE: Cannot be defaulted to a single value] ");
    params.addRequiredCoupledVar("viscosity","Variable for the viscosity of the domain/subdomain");
    params.addRequiredCoupledVar("this_variable","Name of this variable the kernel acts on");
    return params;
}

DGNSViscousVelocityDivergence::DGNSViscousVelocityDivergence(const InputParameters & parameters) :
DGKernel(parameters),
_dg_scheme(getParam<MooseEnum>("dg_scheme")),
_sigma(getParam<Real>("sigma")),

_ux_var(dynamic_cast<MooseVariable &>(*getVar("ux", 0))),
_ux(_ux_var.sln()),
_ux_neighbor(_ux_var.slnNeighbor()),
_grad_ux(_ux_var.gradSln()),
_grad_ux_neighbor(_ux_var.gradSlnNeighbor()),
_ux_id(coupled("ux")),

_uy_var(dynamic_cast<MooseVariable &>(*getVar("uy", 0))),
_uy(_uy_var.sln()),
_uy_neighbor(_uy_var.slnNeighbor()),
_grad_uy(_uy_var.gradSln()),
_grad_uy_neighbor(_uy_var.gradSlnNeighbor()),
_uy_id(coupled("uy")),

_uz_var(dynamic_cast<MooseVariable &>(*getVar("uz", 0))),
_uz(_uz_var.sln()),
_uz_neighbor(_uz_var.slnNeighbor()),
_grad_uz(_uz_var.gradSln()),
_grad_uz_neighbor(_uz_var.gradSlnNeighbor()),
_uz_id(coupled("uz")),

_viscosity(coupledValue("viscosity")),
_viscosity_var(coupled("viscosity")),

_this_var(dynamic_cast<MooseVariable &>(*getVar("this_variable", 0))),
_this(_this_var.sln()),
_this_var_id(coupled("this_variable"))
{

	if (_sigma < 0.0)
		_sigma = 0.0;

	switch (_dg_scheme)
	{
		//sipg
		case 0:
			_epsilon = -1.0;
			if (_sigma == 0.0)
				_sigma = 10.0;
			break;

		//iipg
		case 1:
			_epsilon = 0.0;
			if (_sigma == 0.0)
				_sigma = 10.0;
			break;

		//nipg
		case 2:
			_epsilon = 1.0;
			break;

		//nipg
		default:
			_epsilon = 1.0;
			break;
	}

  if (_this_var_id == _ux_id)
    _dir = 0;
  else if (_this_var_id == _uy_id)
    _dir = 1;
  else if (_this_var_id == _uz_id)
    _dir = 2;
  else
  {
    moose::internal::mooseErrorRaw("Supplied 'this_variable' argument does NOT correspond to a velocity component");
  }

  // Set up x-tensor
  _D_this_x(0,0) = 0.0;
  _D_this_x(0,1) = 0.0;
  _D_this_x(0,2) = 0.0;

  _D_this_x(1,0) = 0.0;
  _D_this_x(1,1) = 0.0;
  _D_this_x(1,2) = 0.0;

  _D_this_x(2,0) = 0.0;
  _D_this_x(2,1) = 0.0;
  _D_this_x(2,2) = 0.0;

  _D_this_x(_dir,0) = 1.0;

  // Set up y-tensor
  _D_this_y(0,0) = 0.0;
  _D_this_y(0,1) = 0.0;
  _D_this_y(0,2) = 0.0;

  _D_this_y(1,0) = 0.0;
  _D_this_y(1,1) = 0.0;
  _D_this_y(1,2) = 0.0;

  _D_this_y(2,0) = 0.0;
  _D_this_y(2,1) = 0.0;
  _D_this_y(2,2) = 0.0;

  _D_this_y(_dir,1) = 1.0;

  // Set up z-tensor
  _D_this_z(0,0) = 0.0;
  _D_this_z(0,1) = 0.0;
  _D_this_z(0,2) = 0.0;

  _D_this_z(1,0) = 0.0;
  _D_this_z(1,1) = 0.0;
  _D_this_z(1,2) = 0.0;

  _D_this_z(2,0) = 0.0;
  _D_this_z(2,1) = 0.0;
  _D_this_z(2,2) = 0.0;

  _D_this_z(_dir,2) = 1.0;
}

Real DGNSViscousVelocityDivergence::computeQpResidual(Moose::DGResidualType type)
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

	switch (type)
	{
		case Moose::Element:
      //x-dir element residuals
			r -= 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
			_test[_i][_qp];
			r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test[_i][_qp] *
			_normals[_qp];
			r += _sigma / h_elem * (_ux[_qp] - _ux_neighbor[_qp]) * _test[_i][_qp];

      //y-dir element residuals
			r -= 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
			_test[_i][_qp];
			r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test[_i][_qp] *
			_normals[_qp];
			r += _sigma / h_elem * (_uy[_qp] - _uy_neighbor[_qp]) * _test[_i][_qp];

      //z-dir element residuals
			r -= 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
			_test[_i][_qp];
			r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test[_i][_qp] *
			_normals[_qp];
			r += _sigma / h_elem * (_uz[_qp] - _uz_neighbor[_qp]) * _test[_i][_qp];
			break;

		case Moose::Neighbor:
      //x-dir neighbor residuals
			r += 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
			_test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_x *
			_grad_test_neighbor[_i][_qp] * _normals[_qp];
			r -= _sigma / h_elem * (_ux[_qp] - _ux_neighbor[_qp]) * _test_neighbor[_i][_qp];

      //y-dir neighbor residuals
			r += 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
			_test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_y *
			_grad_test_neighbor[_i][_qp] * _normals[_qp];
			r -= _sigma / h_elem * (_uy[_qp] - _uy_neighbor[_qp]) * _test_neighbor[_i][_qp];

      //z-dir neighbor residuals
			r += 0.5 * ((1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
						(1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
			_test_neighbor[_i][_qp];
			r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_viscosity[_qp]*_D_this_z *
			_grad_test_neighbor[_i][_qp] * _normals[_qp];
			r -= _sigma / h_elem * (_uz[_qp] - _uz_neighbor[_qp]) * _test_neighbor[_i][_qp];
			break;
	}

	return r;
}

Real DGNSViscousVelocityDivergence::computeQpJacobian(Moose::DGJacobianType type)
{
	Real r = 0;

	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  // Jacobian in x-dir
  if (_dir == 0)
  {
  	switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }

  // Jacobian in y-dir
  if (_dir == 1)
  {
  	switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }

  // Jacobian in z-dir
  if (_dir == 2)
  {
  	switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }
	return r;
}

Real DGNSViscousVelocityDivergence::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  Real r = 0;

  const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
  const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  if (jvar == _ux_id && jvar != _this_var_id)
  {
    switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_x * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_x *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }

  if (jvar == _uy_id && jvar != _this_var_id)
  {
    switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_y * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_y *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }

  if (jvar == _uz_id && jvar != _this_var_id)
  {
    switch (type)
  	{

      // d(R_element)/d(u)
  		case Moose::ElementElement:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test[_i][_qp] * _normals[_qp];
  			r += _sigma / h_elem * _phi[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_element)/d(u_neighbor)
  		case Moose::ElementNeighbor:
  			r -= 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test[_i][_qp] *
  			_normals[_qp];
  			r += _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test[_i][_qp];
  			break;

      // d(R_neighbor)/d(u)
  		case Moose::NeighborElement:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * _phi[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_test_neighbor[_i][_qp] *
  			_normals[_qp];
  			r -= _sigma / h_elem * _phi[_j][_qp] * _test_neighbor[_i][_qp];
  			break;

      // d(R_neighbor)/d(u_neighbor)
  		case Moose::NeighborNeighbor:
  			r += 0.5 * (1.0/3.0)*_viscosity[_qp]*_D_this_z * _grad_phi_neighbor[_j][_qp] * _normals[_qp] *
  			_test_neighbor[_i][_qp];
  			r += _epsilon * 0.5 * -_phi_neighbor[_j][_qp] * (1.0/3.0)*_viscosity[_qp]*_D_this_z *
  			_grad_test_neighbor[_i][_qp] * _normals[_qp];
  			r -= _sigma / h_elem * -_phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];
  			break;
  	}
  }

  if (jvar == _viscosity_var)
  {
    switch (type)
  	{

      // d(R_element)/d(vis)
  		case Moose::ElementElement:
        //x-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_test[_i][_qp] *
        _normals[_qp];

        //y-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_test[_i][_qp] *
        _normals[_qp];

        //z-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_test[_i][_qp] *
        _normals[_qp];
  			break;

      // d(R_element)/d(vis)
  		case Moose::ElementNeighbor:
        //x-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_test[_i][_qp] *
        _normals[_qp];

        //y-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_test[_i][_qp] *
        _normals[_qp];

        //z-dir element residuals
        r -= 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
        _test[_i][_qp];
        r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_test[_i][_qp] *
        _normals[_qp];
  			break;

      // d(R_neighbor)/d(vis)
  		case Moose::NeighborElement:
        //x-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_x *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];

        //y-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_y *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];

        //z-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_z *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];
  			break;

      // d(R_neighbor)/d(vis)
  		case Moose::NeighborNeighbor:
        //x-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_x * _grad_ux_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_ux[_qp] - _ux_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_x *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];

        //y-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_y * _grad_uy_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_uy[_qp] - _uy_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_y *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];

        //z-dir neighbor residuals
        r += 0.5 * ((1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz[_qp] * _normals[_qp] +
              (1.0/3.0)*_phi[_j][_qp]*_D_this_z * _grad_uz_neighbor[_qp] * _normals[_qp]) *
        _test_neighbor[_i][_qp];
        r += _epsilon * 0.5 * (_uz[_qp] - _uz_neighbor[_qp]) * (1.0/3.0)*_phi[_j][_qp]*_D_this_z *
        _grad_test_neighbor[_i][_qp] * _normals[_qp];
  			break;
  	}
  }

  return r;
}

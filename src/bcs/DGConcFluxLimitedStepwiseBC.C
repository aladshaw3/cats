/*!
 *  \file DGConcFluxLimitedStepwiseBC.h
 *    \brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods with stepwise inputs
 *    \details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *            condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *            so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *            if the value of a variable at the inlet boundary is equal to the finite element
 *            solution at that boundary. When the condition is not met, the residuals get penalyzed
 *            until the condition is met.
 *
 *      This kernel inherits from DGConcentrationFluxLimitedBC and uses coupled x, y, and z components
 *      of the coupled velocity to build an edge velocity vector. This also now requires the
 *      addition of OffDiagJacobian elements.
 *
 *            Stepwise inputs are determined from a list of input values and times at which those input
 *            values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
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
 *  \author Austin Ladshaw
 *    \date 03/19/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
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

#include "DGConcFluxLimitedStepwiseBC.h"

registerMooseObject("catsApp", DGConcFluxLimitedStepwiseBC);

InputParameters DGConcFluxLimitedStepwiseBC::validParams()
{
    InputParameters params = DGConcentrationFluxLimitedBC::validParams();
    params.addRequiredParam< std::vector<Real> >("input_vals","Values for u_input at corresponding times");
    params.addRequiredParam< std::vector<Real> >("input_times","Time values at which to update u_input");
    params.addParam< std::vector<Real> >("time_spans",{0},"Amount of time it takes to go from one input to the next");
    return params;
}

DGConcFluxLimitedStepwiseBC::DGConcFluxLimitedStepwiseBC(const InputParameters & parameters) :
DGConcentrationFluxLimitedBC(parameters),
_input_vals(getParam<std::vector<Real> >("input_vals")),
_input_times(getParam<std::vector<Real> >("input_times")),
_time_spans(getParam<std::vector<Real> >("time_spans"))
{
    if (_input_vals.size() != _input_times.size())
    {
        moose::internal::mooseErrorRaw("input_vals and input_times must have same size!");
    }

    if (_time_spans.size() !=_input_times.size())
    {
        _time_spans.resize(_input_times.size());
        for (int i=0; i<_time_spans.size(); i++)
        {
            _time_spans[i] = 0.0;
        }
    }

    if (_input_vals.size() == 0 && _input_times.size() == 0)
    {
        _input_vals.resize(1);
        _input_times.resize(1);
        _time_spans.resize(1);
        _input_vals[0] = _u_input;
        _input_times[0] = 0.0;
        _time_spans[0] = 0.0;
    }
    index = 0;
    _slopes.resize(_time_spans.size());
    _slopes[0] = (_input_vals[0]-_u_input)/(_time_spans[0]);
    for (int i=1; i<_slopes.size(); i++)
    {
        _slopes[i] = (_input_vals[i]-_input_vals[i-1])/(_time_spans[i]);
    }
}

Real DGConcFluxLimitedStepwiseBC::newInputValue(Real time)
{
    Real val = _u_input;
    for (int i=index; i<_input_times.size(); i++)
    {
        if (time >= _input_times[i]-(_time_spans[i]/2.0))
        {
            if (time >= _input_times[i]+(_time_spans[i]/2.0))
            {
                val = _input_vals[i];
                index++;
                break;
            }
            else
            {
                val = _input_vals[i]-_slopes[i]*(_input_times[i]+(_time_spans[i]/2.0)-time);
                break;
            }
        }
    }
    return val;
}

Real DGConcFluxLimitedStepwiseBC::computeQpResidual()
{
    _u_input = newInputValue(_t);
    _velocity(0)=_ux[_qp];
  	_velocity(1)=_uy[_qp];
  	_velocity(2)=_uz[_qp];

    Real r = 0;

  	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
  	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  	//Output (Standard Flux Out)
  	if ((_velocity)*_normals[_qp] > 0.0)
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp];
  	}
  	//Input (Dirichlet BC)
  	else
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input;
  		r -= _test[_i][_qp]*(_velocity*_normals[_qp])*(_u[_qp] - _u_input);
  		r += _epsilon * (_u[_qp] - _u_input) * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
  		r += _sigma/h_elem * (_u[_qp] - _u_input) * _test[_i][_qp];
  		r -= (_Diffusion * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp]);
  	}

  	return r;
}

Real DGConcFluxLimitedStepwiseBC::computeQpJacobian()
{
    _u_input = newInputValue(_t);
    _velocity(0)=_ux[_qp];
  	_velocity(1)=_uy[_qp];
  	_velocity(2)=_uz[_qp];

    Real r = 0;

  	const unsigned int elem_b_order = static_cast<unsigned int> (_var.order());
  	const double h_elem = _current_elem->volume()/_current_side_elem->volume() * 1./std::pow(elem_b_order, 2.);

  	//Output (Standard Flux Out)
  	if ((_velocity)*_normals[_qp] > 0.0)
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
  	}
  	//Input (Dirichlet BC)
  	else
  	{
  		r += 0.0;
  		r -= _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
  		r += _epsilon * _phi[_j][_qp] * _Diffusion * _grad_test[_i][_qp] * _normals[_qp];
  		r += _sigma/h_elem * _phi[_j][_qp] * _test[_i][_qp];
  		r -= (_Diffusion * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp]);
  	}

  	return r;
}

Real DGConcFluxLimitedStepwiseBC::computeQpOffDiagJacobian(unsigned int jvar)
{
    _u_input = newInputValue(_t);
    _velocity(0)=_ux[_qp];
  	_velocity(1)=_uy[_qp];
  	_velocity(2)=_uz[_qp];

    Real r = 0;

    if (jvar == _ux_var)
    {
      //Output
      if ((_velocity)*_normals[_qp] > 0.0)
      {
        r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](0));
      }
      //Input
      else
      {
        r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](0));
        r -= _test[_i][_qp]*(_u[_qp] - _u_input)*(_phi[_j][_qp]*_normals[_qp](0));
      }
      return r;
    }

    if (jvar == _uy_var)
    {
      //Output
      if ((_velocity)*_normals[_qp] > 0.0)
      {
        r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](1));
      }
      //Input
      else
      {
        r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](1));
        r -= _test[_i][_qp]*(_u[_qp] - _u_input)*(_phi[_j][_qp]*_normals[_qp](1));
      }
      return r;
    }

    if (jvar == _uz_var)
    {
      //Output
      if ((_velocity)*_normals[_qp] > 0.0)
      {
        r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](2));
      }
      //Input
      else
      {
        r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](2));
        r -= _test[_i][_qp]*(_u[_qp] - _u_input)*(_phi[_j][_qp]*_normals[_qp](2));
      }
      return r;
    }

    return 0.0;
}

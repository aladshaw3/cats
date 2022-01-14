/*!
 *  \file DGPoreConcFluxStepwiseBC.h
 *    \brief Boundary Condition kernel for the flux  across a boundary of the domain with stepwise inputs
 *    \details This file creates a generic boundary condition kernel for the flux of matter accross
 *            a boundary. The flux is based on a velocity vector, as well as domain porosity, and is valid
 *            in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *            conditions are essitially the same for input and ouput boundaries, this kernel will check
 *            the sign of the flux normal to the boundary and determine automattically whether it is
 *            an output or input boundary, then apply the appropriate conditions.
 *
 *           Stepwise inputs are determined from a list of input values and times at which those input
 *            values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *    \date 03/19/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
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

#include "DGPoreConcFluxStepwiseBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGPoreConcFluxStepwiseBC);

InputParameters DGPoreConcFluxStepwiseBC::validParams()
{
    InputParameters params = DGPoreConcFluxBC::validParams();
    params.addParam< std::vector<Real> >("input_vals","Values for u_input at corresponding times");
    params.addParam< std::vector<Real> >("input_times","Time values at which to update u_input");
    params.addParam< std::vector<Real> >("time_spans","Amount of time it takes to go from one input to the next");
    return params;
}

DGPoreConcFluxStepwiseBC::DGPoreConcFluxStepwiseBC(const InputParameters & parameters) :
DGPoreConcFluxBC(parameters),
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

Real DGPoreConcFluxStepwiseBC::newInputValue(Real time)
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

Real DGPoreConcFluxStepwiseBC::computeQpResidual()
{
    _u_input = newInputValue(_t);
    _velocity(0)=_ux[_qp];
  	_velocity(1)=_uy[_qp];
  	_velocity(2)=_uz[_qp];

  	Real r = 0;

  	//Output
  	if ((_velocity)*_normals[_qp] > 0.0)
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u[_qp]*_porosity[_qp];
  	}
  	//Input
  	else
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_u_input*_porosity[_qp];
  	}

  	return r;
}

Real DGPoreConcFluxStepwiseBC::computeQpJacobian()
{
    _u_input = newInputValue(_t);
    _velocity(0)=_ux[_qp];
  	_velocity(1)=_uy[_qp];
  	_velocity(2)=_uz[_qp];

  	Real r = 0;

  	//Output
  	if ((_velocity)*_normals[_qp] > 0.0)
  	{
  		r += _test[_i][_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp]*_porosity[_qp];
  	}
  	//Input
  	else
  	{
  		r += 0.0;
  	}

  	return r;
}

Real DGPoreConcFluxStepwiseBC::computeQpOffDiagJacobian(unsigned int jvar)
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
  			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](0))*_porosity[_qp];
  		}
  		//Input
  		else
  		{
  			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](0))*_porosity[_qp];
  		}
  		return r;
  	}

  	if (jvar == _uy_var)
  	{
  		//Output
  		if ((_velocity)*_normals[_qp] > 0.0)
  		{
  			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](1))*_porosity[_qp];
  		}
  		//Input
  		else
  		{
  			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](1))*_porosity[_qp];
  		}
  		return r;
  	}

  	if (jvar == _uz_var)
  	{
  		//Output
  		if ((_velocity)*_normals[_qp] > 0.0)
  		{
  			r += _test[_i][_qp]*_u[_qp]*(_phi[_j][_qp]*_normals[_qp](2))*_porosity[_qp];
  		}
  		//Input
  		else
  		{
  			r += _test[_i][_qp]*_u_input*(_phi[_j][_qp]*_normals[_qp](2))*_porosity[_qp];
  		}
  		return r;
  	}

    if (jvar == _porosity_var)
    {
      //Output
      if ((_velocity)*_normals[_qp] > 0.0)
      {
        r += _test[_i][_qp]*_u[_qp]*(_velocity*_normals[_qp])*_phi[_j][_qp];
      }
      //Input
      else
      {
        r += _test[_i][_qp]*_u_input*(_velocity*_normals[_qp])*_phi[_j][_qp];
      }
      return r;
    }

  	return 0.0;
}

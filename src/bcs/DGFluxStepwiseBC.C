/*!
 *  \file DGFluxStepwiseBC.h
 *    \brief Boundary Condition kernel for the flux across a boundary of the domain with stepwise inputs
 *    \details This file creates a generic boundary condition kernel for the flux of material accross
 *            a boundary wise stepwise inputs. The flux is based on a velocity vector and is valid
 *            in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *            conditions are essitially the same for input and ouput boundaries, this kernel will check
 *            the sign of the flux normal to the boundary and determine automattically whether it is
 *            an output or input boundary, then apply the appropriate conditions.
 *
 *            This type of boundary condition for DG kernels applies the true flux boundary condition.
 *            In true finite volumes or DG methods, there is no Dirichlet    boundary conditions,
 *            because the solutions are based on fluxes into and out of cells in a domain.
 *
 *            Stepwise inputs are determined from a list of input values and times at which those input
 *            values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/19/2020
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

#include "DGFluxStepwiseBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "catsApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGFluxStepwiseBC);

template<>
InputParameters validParams<DGFluxStepwiseBC>()
{
    InputParameters params = validParams<DGFluxBC>();
    params.addParam< std::vector<Real> >("input_vals","Values for u_input at corresponding times");
    params.addParam< std::vector<Real> >("input_times","Time values at which to update u_input");
    params.addParam< std::vector<Real> >("time_spans","Amount of time it takes to go from one input to the next");
    return params;
}

DGFluxStepwiseBC::DGFluxStepwiseBC(const InputParameters & parameters) :
DGFluxBC(parameters),
_input_vals(getParam<std::vector<Real> >("input_vals")),
_input_times(getParam<std::vector<Real> >("input_times")),
_time_spans(getParam<std::vector<Real> >("time_spans"))
{
    if (_input_vals.size() != _input_times.size())
    {
        moose::internal::mooseErrorRaw("input_vals and input_times must have same size!");
    }
    if (_time_spans.size() < _input_times.size())
    {
        for (int i=0; i<(_input_times.size()-_time_spans.size()); i++)
        {
            _time_spans.push_back(0.0);
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

Real DGFluxStepwiseBC::newInputValue(Real time)
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

Real DGFluxStepwiseBC::computeQpResidual()
{
    _u_input = newInputValue(_t);
    return DGFluxBC::computeQpResidual();
}

Real DGFluxStepwiseBC::computeQpJacobian()
{
    _u_input = newInputValue(_t);
    return DGFluxBC::computeQpJacobian();
}


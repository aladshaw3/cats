/*!
 *  \file DGVarVelDiffFluxLimitedStepwiseBC.h
 *    \brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods with coupled velocity and diffusivity
 *    \details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *            condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *            so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *            if the value of a variable at the inlet boundary is equal to the finite element
 *            solution at that boundary. When the condition is not met, the residuals get penalyzed
 *            until the condition is met.
 *
 *      This kernel inherits from DGFluxLimitedBC and uses coupled x, y, and z components
 *      of the coupled velocity to build an edge velocity vector. This also now requires the
 *      addition of OffDiagJacobian elements. In addition, we now also coupled with a variable
 *      diffusivity.
 *
 *           Stepwise inputs are determined from a list of input values and times at which those input
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

#include "DGVarVelDiffFluxLimitedStepwiseBC.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", DGVarVelDiffFluxLimitedStepwiseBC);

/*
template<>
InputParameters validParams<DGVarVelDiffFluxLimitedStepwiseBC>()
{
    InputParameters params = validParams<DGVarVelDiffFluxLimitedBC>();
    params.addParam< std::vector<Real> >("input_vals","Values for u_input at corresponding times");
    params.addParam< std::vector<Real> >("input_times","Time values at which to update u_input");
    params.addParam< std::vector<Real> >("time_spans","Amount of time it takes to go from one input to the next");
    return params;
}
 */

InputParameters DGVarVelDiffFluxLimitedStepwiseBC::validParams()
{
    InputParameters params = DGVarVelDiffFluxLimitedBC::validParams();
    params.addParam< std::vector<Real> >("input_vals","Values for u_input at corresponding times");
    params.addParam< std::vector<Real> >("input_times","Time values at which to update u_input");
    params.addParam< std::vector<Real> >("time_spans","Amount of time it takes to go from one input to the next");
    return params;
}

DGVarVelDiffFluxLimitedStepwiseBC::DGVarVelDiffFluxLimitedStepwiseBC(const InputParameters & parameters) :
DGVarVelDiffFluxLimitedBC(parameters),
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

Real DGVarVelDiffFluxLimitedStepwiseBC::newInputValue(Real time)
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

Real DGVarVelDiffFluxLimitedStepwiseBC::computeQpResidual()
{
    _u_input = newInputValue(_t);
    return DGVarVelDiffFluxLimitedBC::computeQpResidual();
}

Real DGVarVelDiffFluxLimitedStepwiseBC::computeQpJacobian()
{
    _u_input = newInputValue(_t);
    return DGVarVelDiffFluxLimitedBC::computeQpJacobian();
}

Real DGVarVelDiffFluxLimitedStepwiseBC::computeQpOffDiagJacobian(unsigned int jvar)
{
    _u_input = newInputValue(_t);
    return DGVarVelDiffFluxLimitedBC::computeQpOffDiagJacobian(jvar);
}

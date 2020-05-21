/*!
 *  \file MicroscaleVariableDiffusion.h
 *    \brief Microscale diffusion kernel with variable diffusion coefficients
 *    \details This file creates a custom MOOSE kernel for the diffusion at the microscale
 *              of a fictious mesh with variable diffusion coefficients. Each node in the mesh
 *              may have a different diffusivity and thus requires a different variable.
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

#include "MicroscaleVariableDiffusion.h"

registerMooseObject("catsApp", MicroscaleVariableDiffusion);

InputParameters MicroscaleVariableDiffusion::validParams()
{
    InputParameters params = MicroscaleDiffusion::validParams();
    params.addRequiredCoupledVar("current_diff","Variable for this diffusion coefficient");
    params.addRequiredCoupledVar("upper_diff","Variable for upper diffusion coefficient");
    params.addRequiredCoupledVar("lower_diff","Variable for lower diffusion coefficient");
    
    return params;
}

MicroscaleVariableDiffusion::MicroscaleVariableDiffusion(const InputParameters & parameters)
: MicroscaleDiffusion(parameters),

_current_diffusion(coupledValue("current_diff")),
_current_diff_var(coupled("current_diff")),

_upper_diffusion(coupledValue("upper_diff")),
_upper_diff_var(coupled("upper_diff")),

_lower_diffusion(coupledValue("lower_diff")),
_lower_diff_var(coupled("lower_diff"))
{
    
}

Real MicroscaleVariableDiffusion::computeQpResidual()
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _lower_diffusion[_qp];
    
    return MicroscaleDiffusion::computeQpResidual();
}

Real MicroscaleVariableDiffusion::computeQpJacobian()
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _lower_diffusion[_qp];
    
    return MicroscaleDiffusion::computeQpJacobian();
}

Real MicroscaleVariableDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _lower_diffusion[_qp];
    
    if (jvar == _upper_var)
    {
        return MicroscaleDiffusion::computeQpOffDiagJacobian(jvar);
    }
    if (jvar == _lower_var)
    {
        return MicroscaleDiffusion::computeQpOffDiagJacobian(jvar);
    }
    
    if (jvar == _current_diff_var)
    {
        return _test[_i][_qp]*( (_rd_lp1/_dr/_dr/2.0) )*_phi[_j][_qp]*(_u[_qp] - _upper_neighbor[_qp]) + _test[_i][_qp]*( (_rd_lm1/_dr/_dr/2.0) )*_phi[_j][_qp]*(_u[_qp] - _lower_neighbor[_qp]);
    }
    if (jvar == _upper_diff_var)
    {
        return _test[_i][_qp]*( (_rd_lp1/_dr/_dr/2.0) )*_phi[_j][_qp]*(_u[_qp] - _upper_neighbor[_qp]);
    }
    if (jvar == _lower_diff_var)
    {
        return _test[_i][_qp]*( (_rd_lm1/_dr/_dr/2.0) )*_phi[_j][_qp]*(_u[_qp] - _lower_neighbor[_qp]);
    }
    
    return 0.0;
}

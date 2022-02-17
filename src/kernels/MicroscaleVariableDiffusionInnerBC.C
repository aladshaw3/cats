/*!
 *  \file MicroscaleVariableDiffusionInnerBC.h
 *    \brief Microscale no flux diffusion BC with variable diffusion coefficients
 *    \details This file creates a custom MOOSE kernel for the inner diffusion BC at the microscale
 *              of a fictious mesh with variable diffusion coefficients. Each node may have a different
 *              diffusivity and thus must have a different variable.
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

#include "MicroscaleVariableDiffusionInnerBC.h"

registerMooseObject("catsApp", MicroscaleVariableDiffusionInnerBC);

InputParameters MicroscaleVariableDiffusionInnerBC::validParams()
{
    InputParameters params = MicroscaleDiffusionInnerBC::validParams();
    params.addRequiredCoupledVar("current_diff","Variable for this diffusion coefficient");
    params.addRequiredCoupledVar("upper_diff","Variable for upper diffusion coefficient");

    return params;
}

MicroscaleVariableDiffusionInnerBC::MicroscaleVariableDiffusionInnerBC(const InputParameters & parameters)
: MicroscaleDiffusionInnerBC(parameters),

_current_diffusion(coupledValue("current_diff")),
_current_diff_var(coupled("current_diff")),

_upper_diffusion(coupledValue("upper_diff")),
_upper_diff_var(coupled("upper_diff"))
{

}

Real MicroscaleVariableDiffusionInnerBC::computeQpResidual()
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _current_diffusion[_qp];

    return MicroscaleDiffusionInnerBC::computeQpResidual();
}

Real MicroscaleVariableDiffusionInnerBC::computeQpJacobian()
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _current_diffusion[_qp];

    return MicroscaleDiffusionInnerBC::computeQpJacobian();
}

Real MicroscaleVariableDiffusionInnerBC::computeQpOffDiagJacobian(unsigned int jvar)
{
    _current_diff = _current_diffusion[_qp];
    _upper_diff = _upper_diffusion[_qp];
    _lower_diff = _current_diffusion[_qp];

    if (jvar == _upper_var)
    {
        return MicroscaleDiffusionInnerBC::computeQpOffDiagJacobian(jvar);
    }

    if (jvar == _current_diff_var)
    {
        return _test[_i][_qp]*( (_rd_lp1/_dr/_dr/2.0) + (_rd_lm1/_dr/_dr) )*_phi[_j][_qp]*(_u[_qp] - _upper_neighbor[_qp]);
    }
    if (jvar == _upper_diff_var)
    {
        return _test[_i][_qp]*( (_rd_lp1/_dr/_dr/2.0) )*_phi[_j][_qp]*(_u[_qp] - _upper_neighbor[_qp]);
    }

    return 0.0;
}

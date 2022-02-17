/*!
 *  \file VariableCoupledCoeffTimeDerivative.h
 *    \brief Kernel for coupling the mass transfer via time derivatives with variable coefficient
 *    \details This file creates a standard MOOSE kernel for the coupling of time derivative
 *            functions between different non-linear variables to represent a transfer of mass
 *      from one phase to another. The differences in phases is identified by a bulk density
 *      variable (r) that also couples with this kernel. This is similar to the CoupledPorePhaseTransfer
 *      kernel, but is a more direct way for coupling adsorption that simultaneouly involves a
 *      unit conversion from mass/volume (in the gas phase) to mass/mass (in the solid).
 *
 *      R(u) = r*dv/dt
 *
 *  \note the 'gaining' parameter is used to denote whether or not the kernel term will
 *        act as a source term or sink term. In this kernel, it is always assumed a
 *        sink term. Primary use is for mass transfer from adsorption.
 *
 *  \author Austin Ladshaw
 *    \date 09/04/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "VariableCoupledCoeffTimeDerivative.h"

registerMooseObject("catsApp", VariableCoupledCoeffTimeDerivative);

InputParameters VariableCoupledCoeffTimeDerivative::validParams()
{
    InputParameters params = CoupledCoeffTimeDerivative::validParams();
    params.addRequiredCoupledVar("var_time_coeff","Variable for the coupled time derivative (often the bulk density for a phase change)");
    return params;
}

VariableCoupledCoeffTimeDerivative::VariableCoupledCoeffTimeDerivative(const InputParameters & parameters)
: CoupledCoeffTimeDerivative(parameters),
_coeff(coupledValue("var_time_coeff")),
_coeff_var(coupled("var_time_coeff"))
{
}

Real VariableCoupledCoeffTimeDerivative::computeQpResidual()
{
  if (_gaining == true)
    _time_coef = -_coeff[_qp];
  else
    {_time_coef = _coeff[_qp];}

  return CoupledCoeffTimeDerivative::computeQpResidual();
}

Real VariableCoupledCoeffTimeDerivative::computeQpJacobian()
{
  return 0.0;
}

Real VariableCoupledCoeffTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (_gaining == true)
    _time_coef = -_coeff[_qp];
  else
    {_time_coef = _coeff[_qp];}

  if (jvar == _coupled_var)
    return CoupledCoeffTimeDerivative::computeQpOffDiagJacobian(jvar);
  if (jvar == _coeff_var)
  {
    if (_gaining == true)
      {return -_phi[_j][_qp]*_coupled_dot[_qp]*_test[_i][_qp];}
    else
      {return _phi[_j][_qp]*_coupled_dot[_qp]*_test[_i][_qp];}
  }

  return 0.0;
}

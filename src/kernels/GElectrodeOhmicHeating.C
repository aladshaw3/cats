/*!
 *  \file GElectrodeOhmicHeating.h
 *	\brief Standard kernel for coupling electrode potentials with thermal energy density
 *	\details This file creates a standard MOOSE kernel for the coupling of electrode potentials
 *          and other parameters into an energy balance for the thermal behavior of the electrode
 *          phase during charging and discharging of the batteries.
 *
 *
 *  \author Austin Ladshaw
 *	\date 08/01/2022
 *	\copyright This kernel was designed and built at SPAN.io by Austin Ladshaw
 *            for research in battery charging/discharging behavior.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "GElectrodeOhmicHeating.h"

registerMooseObject("catsApp", GElectrodeOhmicHeating);

InputParameters
GElectrodeOhmicHeating::validParams()
{
  InputParameters params = Kernel::validParams();

  params.addCoupledVar("solid_frac", 1, "Variable for volume fraction or porosity (default = 1)");
  params.addCoupledVar("conductivity",
                       50,
                       "Variable for conductivity of the electrode in units of C/V/length/time or "
                       "similar (default = 50 C/V/m/s)");
  params.addRequiredCoupledVar("electric_potential", "Variable for electric potential (V or J/C)");

  return params;
}

GElectrodeOhmicHeating::GElectrodeOhmicHeating(const InputParameters & parameters)
  : Kernel(parameters),

    _sol_frac(coupledValue("solid_frac")),
    _sol_frac_var(coupled("solid_frac")),
    _conductivity(coupledValue("conductivity")),
    _conductivity_var(coupled("conductivity")),
    _e_potential_grad(coupledGradient("electric_potential")),
    _e_potential_var(coupled("electric_potential"))
{
}

Real
GElectrodeOhmicHeating::computeQpResidual()
{
  return -_test[_i][_qp] * _conductivity[_qp] * _sol_frac[_qp] *
         (_e_potential_grad[_qp] * _e_potential_grad[_qp]);
}

Real
GElectrodeOhmicHeating::computeQpJacobian()
{
  return 0.0;
}

Real
GElectrodeOhmicHeating::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _sol_frac_var)
  {
    return -_test[_i][_qp] * _conductivity[_qp] * _phi[_j][_qp] *
           (_e_potential_grad[_qp] * _e_potential_grad[_qp]);
  }
  if (jvar == _conductivity_var)
  {
    return -_test[_i][_qp] * _phi[_j][_qp] * _sol_frac[_qp] *
           (_e_potential_grad[_qp] * _e_potential_grad[_qp]);
  }
  if (jvar == _e_potential_var)
  {
    return -_test[_i][_qp] * _conductivity[_qp] * _sol_frac[_qp] *
           (2.0 * _grad_phi[_j][_qp] * _e_potential_grad[_qp]);
  }

  return 0.0;
}

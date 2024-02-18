/*!
 *  \file ElectrodePotentialConductivity.h
 *	\brief Standard kernel for coupling porosity and conductivity to gradients of electrode
 *potential \details This file creates a standard MOOSE kernel for the coupling of a set of
 *non-linear variables for solids fraction and conductivity to the electric potential of a porous
 *electrode. By default, the solids fraction is 1, thus, you can also use this kernel for non-porous
 *electrodes. The conductivity can be a constant given value or another non-linear variable. This
 *file assumes isotropic conductivity of the electrode, which is true in most all cases.
 *
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/15/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#include "ElectrodePotentialConductivity.h"

registerMooseObject("catsApp", ElectrodePotentialConductivity);

InputParameters
ElectrodePotentialConductivity::validParams()
{
  InputParameters params = Kernel::validParams();

  params.addCoupledVar("solid_frac", 1, "Variable for volume fraction or porosity (default = 1)");
  params.addCoupledVar("conductivity",
                       50,
                       "Variable for conductivity of the electrode in units of C/V/length/time or "
                       "similar (default = 50 C/V/m/s)");

  return params;
}

ElectrodePotentialConductivity::ElectrodePotentialConductivity(const InputParameters & parameters)
  : Kernel(parameters),

    _sol_frac(coupledValue("solid_frac")),
    _sol_frac_var(coupled("solid_frac")),
    _conductivity(coupledValue("conductivity")),
    _conductivity_var(coupled("conductivity"))
{
}

Real
ElectrodePotentialConductivity::computeQpResidual()
{
  return _grad_test[_i][_qp] * _conductivity[_qp] * _sol_frac[_qp] * _grad_u[_qp];
}

Real
ElectrodePotentialConductivity::computeQpJacobian()
{
  return _grad_test[_i][_qp] * _conductivity[_qp] * _sol_frac[_qp] * _grad_phi[_j][_qp];
}

Real
ElectrodePotentialConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _sol_frac_var)
  {
    return _grad_test[_i][_qp] * _conductivity[_qp] * _phi[_j][_qp] * _grad_u[_qp];
  }
  if (jvar == _conductivity_var)
  {
    return _grad_test[_i][_qp] * _phi[_j][_qp] * _sol_frac[_qp] * _grad_u[_qp];
  }

  return 0.0;
}

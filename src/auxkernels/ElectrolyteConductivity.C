/*!
 *  \file ElectrolyteConductivity.h
 *	\brief Auxiliary kernel to estimate electrolyte conductivity
 *	\details This file creates an auxiliary kernel to calculate the approximate electrolyte
 *            conductivity caused by the local concentration of ions in solution.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/09/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "ElectrolyteConductivity.h"

registerMooseObject("catsApp", ElectrolyteConductivity);

InputParameters ElectrolyteConductivity::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addCoupledVar("temperature",298,"Variable for temperature of the media (default = 298 K)");

    params.addParam<Real>("faraday_const",96485.3, "Value of Faraday's constant (default = 96485.3 C/mol)");
    params.addParam<Real>("gas_const",8.314462, "Value of the gas law constant (default = 8.314462 J/K/mol)");

    params.addRequiredCoupledVar("ion_conc","List of names of the ion concentration variables (mol/L^3)");
    params.addRequiredCoupledVar("diffusion","List of names of the diffusion variables (L^2/T)");
    params.addParam< std::vector<Real> >("ion_valence","List of valences for coupled ion concentrations");

    params.addParam<Real>("min_conductivity",1e-30, "Minimum/background value of conductivity of the media");
    return params;
}

ElectrolyteConductivity::ElectrolyteConductivity(const InputParameters & parameters) :
AuxKernel(parameters),
_temp(coupledValue("temperature")),

_faraday(getParam<Real>("faraday_const")),
_gas_const(getParam<Real>("gas_const")),

_valence(getParam<std::vector<Real> >("ion_valence")),
_min_conductivity(getParam<Real>("min_conductivity"))
{
  unsigned int c = coupledComponents("ion_conc");
  _ion_conc.resize(c);

  unsigned int d = coupledComponents("diffusion");
  _diffusion.resize(d);

  //Check lists to ensure they are of same size
  if (c != d)
  {
      moose::internal::mooseErrorRaw("User is required to provide list of ion concentration variables of the same length as list of diffusion coefficients.");
  }
  if (_ion_conc.size() != _valence.size())
  {
      moose::internal::mooseErrorRaw("User is required to provide list of ion concentration variables of the same length as list of ion valences.");
  }

  if (_diffusion.size() != _valence.size())
  {
      moose::internal::mooseErrorRaw("User is required to provide list of diffusion variables of the same length as list of ion valences.");
  }

  //Grab the variables
  for (unsigned int i = 0; i<_ion_conc.size(); ++i)
  {
      _ion_conc[i] = &coupledValue("ion_conc",i);
  }

  for (unsigned int i = 0; i<_diffusion.size(); ++i)
  {
      _diffusion[i] = &coupledValue("diffusion",i);
  }

  if (_min_conductivity < 1e-30)
      _min_conductivity = 1e-30;
}

Real ElectrolyteConductivity::computeValue()
{
    Real sum = 0.0;
    for (unsigned int i = 0; i<_ion_conc.size(); ++i)
    {
        sum = sum + _valence[i]*_valence[i]*(*_diffusion[i])[_qp]*(*_ion_conc[i])[_qp];
    }

    return ((_faraday*_faraday/_gas_const/_temp[_qp])*sum)+_min_conductivity;
}

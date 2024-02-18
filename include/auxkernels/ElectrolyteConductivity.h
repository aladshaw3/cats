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

#pragma once

#include "AuxKernel.h"

/// ElectrolyteConductivity class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the electrolyte conductivity as a function of ions and other variables.  */
class ElectrolyteConductivity : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  ElectrolyteConductivity(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  const VariableValue & _temp; ///< Temperature variable (K)

  Real _faraday;   ///< Value of Faraday's Constant (default = 96485.3 C/mol)
  Real _gas_const; ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

  std::vector<const VariableValue *>
      _ion_conc; ///< Pointer list to the coupled ion concentrations (mol/L^3)
  std::vector<const VariableValue *>
      _diffusion; ///< Pointer list to the coupled diffusion coeffs (L^2/T)

  std::vector<Real> _valence; ///< Valence list for corresponding ions

  Real _min_conductivity; ///< Minimum allowable value for conductivity (based on sum of ions)
};

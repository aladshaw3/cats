/*!
 *  \file ElectrolytePotentialConductivity.h
 *	\brief Standard kernel for a Poisson's equation for electrolyte conductivity
 *	\details This file creates a standard MOOSE kernel for the coupling of this kernel's variable
 *for electrolyte potential (_u and _u_grad) with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. This kernel is ONLY valid
 *            for isotropic diffusion, which should cover most all cases.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/08/2021
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

#include "Kernel.h"

/// ElectrolytePotentialConductivity class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
  All public and protected members of this class are required function overrides. */
class ElectrolytePotentialConductivity : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  ElectrolytePotentialConductivity(const InputParameters & parameters);

protected:
  /// Helper function to formulate the sum of ion terms
  Real sum_ion_terms();

  /// Helper function to formulate the full coupled coefficent
  Real effective_ionic_conductivity();

  /// Required residual function for standard kernels in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual() override;

  /// Required Jacobian function for standard kernels in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
    computed is the associated diagonal element in the overall Jacobian matrix for the
    system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian() override;

  /// Not Required, but aids in the preconditioning step
  /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _porosity;  ///< Porosity variable
  const unsigned int _porosity_var; ///< Variable identification for porosity

  const VariableValue & _temp;  ///< Temperature variable (K)
  const unsigned int _temp_var; ///< Variable identification for temperature

  Real _faraday;   ///< Value of Faraday's Constant (default = 96485.3 C/mol)
  Real _gas_const; ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

  std::vector<const VariableValue *>
      _ion_conc; ///< Pointer list to the coupled ion concentrations (mol/L^3)
  std::vector<const VariableValue *>
      _diffusion; ///< Pointer list to the coupled diffusion coeffs (L^2/T)
  std::vector<unsigned int> _ion_conc_vars;  ///< Indices for the coupled reactants
  std::vector<unsigned int> _diffusion_vars; ///< Indices for the coupled products

  std::vector<Real> _valence; ///< Valence list for corresponding ions

  Real _min_conductivity; ///< Minimum allowable value for conductivity (based on sum of ions)

  bool _tight; ///< Boolean to determine whether to use tight or loose coupling

private:
};

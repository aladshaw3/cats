/*!
 *  \file ElectrolyteCurrentFromIonGradient.h
 *	\brief Standard kernel for coupling gradients of ion concentrations to the formation of current
 *	\details This file creates a standard MOOSE kernel for the coupling of a set of non-linear variable
 *            gradients for ion concentrations with variables for diffusion, porosity, and
 *            ion valence. In the case of anisotopic diffusion, the diffusion coefficent the user
 *            provides should correspond to the direction of the electrolyte current this kernel acts on.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 11/03/2021
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

/// ElectrolyteCurrentFromIonGradient class object inherits from Kernel object
class ElectrolyteCurrentFromIonGradient : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	ElectrolyteCurrentFromIonGradient(const InputParameters & parameters);

protected:
  /// Helper function to formulate the sum of ion terms
  Real sum_ion_gradient_terms();

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

	RealVectorValue _norm_vec;	    ///< Vector for direction of gradient

  unsigned int _dir;				      ///< Direction of current this kernel acts on (0=x, 1=y, 2=z)

  const VariableValue & _porosity;			  ///< Porosity variable
  const unsigned int _porosity_var;				///< Variable identification for porosity

  Real _faraday;                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)

  std::vector<const VariableGradient *> _ion_conc_grad;   ///< Pointer list to the coupled ion concentration gradients (mol/L^3/L)
  std::vector<const VariableValue *> _diffusion;          ///< Pointer list to the coupled diffusion coeffs (L^2/T)
  std::vector<unsigned int> _ion_conc_vars;               ///< Indices for the coupled reactants
  std::vector<unsigned int> _diffusion_vars;              ///< Indices for the coupled products

  std::vector<Real> _valence;                             ///< Valence list for corresponding ions

private:

};

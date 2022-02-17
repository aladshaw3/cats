/*!
 *  \file ExtendedLangmuirModel.h
 *	\brief Standard kernel for coupling a vector non-linear variables via an extended langmuir function
 *	\details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *			together via an extended langmuir forcing function,
 *			i.e., variable = b_i * K_i * coupled_variable_i / 1 + sum(j, K_j * coupled_variable_j).
 *			In this kernel, the langmuir coefficients {K_i} are calculated as a function of temperature
 *			using the van't Hoff expression: ln(K_i) = -dH_i/(R*T) + dS_i/R
 *
 *  \note This should be used in conjunction with a TimeDerivative or Reaction kernel inside of the
 *        input file to enfore that the variable sorbs material according to Langmuir
 *
 *        Reaction kernel ==>   Res(u) = u*test
 *        Extended Langmuir ==> Res(u) = -ExtLangFunc*test
 *
 *  \author Austin Ladshaw
 *	\date 03/10/2020
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "ExtendedLangmuirFunction.h"

#ifndef Rstd
#define Rstd 8.3144621						///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

/// This macro calculates the natural log of the dimensionless isotherm parameter
#ifndef lnKo
#define lnKo(H,S,T)	-( H / ( Rstd * T ) ) + ( S / Rstd )
#endif

/// ExtendedLangmuirModel class object inherits from ExtendedLangmuirFunction object
class ExtendedLangmuirModel : public ExtendedLangmuirFunction
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	ExtendedLangmuirModel(const InputParameters & parameters);

protected:
	/// Function to compute all langmuir coefficients from temperature
	void computeAllLangmuirCoeffs();

	/// Function to compute the Jacobi for the coupled temperature
	Real computeExtLangmuirTempJacobi();

	/// Required residual function for standard kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual();

	/// Required Jacobian function for standard kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
	 computed is the associated diagonal element in the overall Jacobian matrix for the
	 system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian();

	/// Not Required, but aids in the preconditioning step
	/** This function returns the off diagonal Jacobian contribution for this object. By
	 returning a non-zero value we will hopefully improve the convergence rate for the
	 cross coupling of the variables. */
	virtual Real computeQpOffDiagJacobian(unsigned int jvar);

	std::vector<Real> _enthalpies;						///< Vector of enthalpies for all langmuir coefficients (J/mol)
	std::vector<Real> _entropies;						///< Vector of entropies for all langmuir coefficients (J/K/mol)
	const VariableValue & _coupled_temp;				///< Coupled variable for temperature
	const unsigned int _coupled_var_temp;				///< Index for the coupled temperature variable

private:

};

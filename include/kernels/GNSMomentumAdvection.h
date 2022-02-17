/*!
 *  \file GNSMomentumAdvection.h
 *	\brief Kernel for use with the corresponding DGNSMomentumAdvection object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction
 *            with DGNSMomentumAdvection for the discontinous Galerkin formulation of
 *            the momentum advection term in the Navier-Stokes equation.
 *
 *  \author Austin Ladshaw
 *	\date 10/26/2021
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

#include "GConcentrationAdvection.h"

/// GNSMomentumAdvection class object inherits from GConcentrationAdvection object
/** This class object inherits from the GConcentrationAdvection object in CATS.
	All public and protected members of this class are required function overrides.
	The kernel has a velocity vector whose components can be set piecewise in an
	input file. */
class GNSMomentumAdvection : public GConcentrationAdvection
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	GNSMomentumAdvection(const InputParameters & parameters);

protected:
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

	const VariableValue & _density;			    ///< Density variable
	const unsigned int _density_var;				///< Variable identification for density

  const VariableValue & _coupled_main;    ///< Primary velocity component variable (i.e., diagonal)
  const unsigned int _main_var;           ///< Variable identification for the primary velocity variable (i.e., diagonal)

  unsigned int _dir;                      ///< Direction that '_main_var' acts on

private:

};

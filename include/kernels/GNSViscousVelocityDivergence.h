/*!
 *  \file GNSViscousVelocityDivergence.h
 *	\brief Kernel for use with the corresponding DGNSViscousVelocityDivergence object
 *	\details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGNSViscousVelocityDivergence kernel
 *			for the discontinous Galerkin formulation of the 'extra' viscous term in compressible Navier-Stokes.
 *      This extra term is zero in the case where the divergence of velocity is zero (i.e., in the
 *       incompressible case).
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 10/30/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
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

#pragma once

#include "Kernel.h"

/// GNSViscousVelocityDivergence class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a diffusion tensor whose components can be set piecewise in an
	input file.*/
class GNSViscousVelocityDivergence : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	GNSViscousVelocityDivergence(const InputParameters & parameters);

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

	RealTensorValue _D_this_x;			///< Tensor matrix for this velocity component in x-direction
  RealTensorValue _D_this_y;			///< Tensor matrix for this velocity component in y-direction
  RealTensorValue _D_this_z;			///< Tensor matrix for this velocity component in z-direction

  const VariableGradient & _ux_grad;			///< Gradient of Velocity in the x-direction
	const VariableGradient & _uy_grad;			///< Gradient of Velocity in the y-direction
	const VariableGradient & _uz_grad;			///< Gradient of Velocity in the z-direction

	const unsigned int _ux_var;					///< Variable identification for ux
	const unsigned int _uy_var;					///< Variable identification for uy
	const unsigned int _uz_var;					///< Variable identification for uz

  const VariableValue & _viscosity;			    ///< Viscosity variable
	const unsigned int _viscosity_var;				///< Variable identification for viscosity

  const VariableGradient & _coupled_main_grad;    ///< Primary gradient of velocity component variable (i.e., diagonal)
  const unsigned int _main_var;               ///< Variable identification for the primary velocity variable (i.e., diagonal)

  unsigned int _dir;                      ///< Direction that '_main_var' acts on


private:

};

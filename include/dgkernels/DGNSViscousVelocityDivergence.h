/*!
 *  \file DGNSViscousVelocityDivergence.h
 *	\brief Discontinous Galerkin kernel for viscous velocity divergence term in Navier-Stokes
 *	\details This file creates a discontinous Galerkin kernel for the viscous velocity divergence term
 *      of the Navier-Stokes equation in a given domain. This term will be zero in the case of
 *      incompressible flow, but will be non-zero for compressible flow. As such, user can invoke this
 *      kernel under either circumstance such that the physics can naturally swap from incompressible
 *      to compressible as needed.
 *
 *      The DG method for this term involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
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

#pragma once

#include "DGKernel.h"
#include "MooseVariable.h"
#include <cmath>

/// DGNSViscousVelocityDivergence class object inherits from DGKernel object
/** This class object inherits from the DGKernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides. The object
	will provide residuals and Jacobians for the discontinous Galerkin formulation of
  the viscous velocity divergence term from Navier-Stokes.*/
class DGNSViscousVelocityDivergence : public DGKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	DGNSViscousVelocityDivergence(const InputParameters & parameters);

protected:
	/// Required residual function for DG kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual(Moose::DGResidualType type) override;
	/// Required Jacobian function for DG kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  /// Not required, but recomended function for DG kernels in MOOSE
  /** This function returns an off-diagonal jacobian contribution for this object. The jacobian
   being computed will be associated with the variables coupled to this object and not the
   main coupled variable itself. */
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;

  MooseEnum _dg_scheme;					///< Enumerator to determine what scheme to use (NIPG, IIPG, or SIPG)
	Real _epsilon;									///< Penalty term for gradient jumps between the solution and test functions
	Real _sigma;										///< Penalty term applied to element size

  RealTensorValue _D_this_x;			///< Tensor matrix for this velocity component in x-direction
  RealTensorValue _D_this_y;			///< Tensor matrix for this velocity component in y-direction
  RealTensorValue _D_this_z;			///< Tensor matrix for this velocity component in z-direction

  /// Variable set for the velocity in x
  MooseVariable & _ux_var;
  const VariableValue & _ux;
  const VariableValue & _ux_neighbor;
  const VariableGradient & _grad_ux;
  const VariableGradient & _grad_ux_neighbor;
  unsigned int _ux_id;

  /// Variable set for the velocity in y
  MooseVariable & _uy_var;
  const VariableValue & _uy;
  const VariableValue & _uy_neighbor;
  const VariableGradient & _grad_uy;
  const VariableGradient & _grad_uy_neighbor;
  unsigned int _uy_id;

  /// Variable set for the velocity in z
  MooseVariable & _uz_var;
  const VariableValue & _uz;
  const VariableValue & _uz_neighbor;
  const VariableGradient & _grad_uz;
  const VariableGradient & _grad_uz_neighbor;
  unsigned int _uz_id;

  const VariableValue & _viscosity;			    ///< Viscosity variable
	const unsigned int _viscosity_var;				///< Variable identification for viscosity

  MooseVariable & _this_var;                ///< Velocity Variable that this kernel acts on
  const VariableValue & _this;
  unsigned int _this_var_id;                ///< Variable id for this_var

  unsigned int _dir;                      ///< Direction that 'this_var' acts on

private:

};

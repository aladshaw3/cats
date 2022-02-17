/*!
 *  \file DivergenceFreeCondition.h
 *	\brief Standard kernel for creating a Divergence Free Condition in CATS
 *	\details This file creates a standard MOOSE kernel for the divergence free condition. The
 *            divergence free condition can be generically represented mathematically as follows...
 *
 *            Div * (c * v) == c*d/dx(v_x) + v_x*d/dx(c) +
 *                              c*d/dy(v_y) + v_y*d/dy(c) +
 *                              c*d/dz(v_z) + v_z*d/dz(c)   ==  0
 *
 *            where c is a scalar non-linear variable and v is a vector non-linear variable.
 *
 *            This implementation performs a 'piecewise' formulation of the divergence free
 *            condition. As such, this kernel is only valid in a Cartesian coordinate system.
 *
 *  \note If the scalar non-linear variable (c) does not vary spatially, then this formulation
 *          becomes equivalent to the divergence free condition seen in Incompressible Navier-
 *          Stokes formulations.
 *
 *  \author Austin Ladshaw
 *	\date 10/29/2021
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

#include "Kernel.h"

/// DivergenceFreeCondition class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a vector whose components can be set piecewise in an
	input file. */
class DivergenceFreeCondition : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	DivergenceFreeCondition(const InputParameters & parameters);

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

  const VariableValue & _ux;			               ///< variable for the x-direction derivatives
  const VariableGradient & _ux_grad;             ///< Coupled variable gradient for the x-direction derivatives
	const VariableValue & _uy;			               ///< variable for the y-direction derivatives
  const VariableGradient & _uy_grad;             ///< Coupled variable gradient for the y-direction derivatives
	const VariableValue & _uz;			               ///< variable for the z-direction derivatives
  const VariableGradient & _uz_grad;             ///< Coupled variable gradient for the z-direction derivatives

	const unsigned int _ux_var;					///< Variable identification for ux
	const unsigned int _uy_var;					///< Variable identification for uy
	const unsigned int _uz_var;					///< Variable identification for uz

  const VariableValue & _coupled;			               ///< Scalar variable
  const VariableGradient & _coupled_grad;            ///< Coupled variable gradient
  const unsigned int _coupled_var;                   ///< Variable identification for coupled variable

private:

};

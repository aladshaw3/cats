#pragma once

#include "Kernel.h"

/// VectorCoupledGradient class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a vector whose components can be set piecewise in an
	input file. */
class VectorCoupledGradient : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	VectorCoupledGradient(const InputParameters & parameters);

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

	RealVectorValue _vec;	///< Vector

	Real _vx;					///< x-component of vector (optional - set in input file)
	Real _vy;					///< y-component of vector (optional - set in input file)
	Real _vz;					///< z-component of vector (optional - set in input file)

  const VariableGradient & _coupled_grad;            ///< Coupled variable gradient
  const unsigned int _coupled_var;                   ///< Variable identification for coupled variable

private:

};

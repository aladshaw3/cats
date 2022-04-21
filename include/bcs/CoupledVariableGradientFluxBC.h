/*!
 *  \file CoupledVariableGradientFluxBC.h
 *	\brief Boundary Condition kernel for flux of material based on another variable gradient
 *  \details A Flux BC which couples the gradient of another variable to the flux of
 *          this variable. Additionally, a variable coefficient may be multiplied by
 *          the other variable gradient to scale the flux accordingly.
 *
 *                Res = -_test[_i][_qp]*_ceof*(_coupled_grad[_qp]*_normals[_qp]);
 *
 *
 *  \author Austin Ladshaw
 *	\date 04/21/2022
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

#include "IntegratedBC.h"
#include "libmesh/vector_value.h"

/// CoupledVariableGradientFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
	All public and protected members of this class are required function overrides.*/
class CoupledVariableGradientFluxBC : public IntegratedBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for BC objects in MOOSE
	CoupledVariableGradientFluxBC(const InputParameters & parameters);

protected:
	/// Required function override for BC objects in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;
	/// Required function override for BC objects in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;
  /// Not Required, but aids in the preconditioning step
	/** This function returns the off diagonal Jacobian contribution for this object. By
		returning a non-zero value we will hopefully improve the convergence rate for the
		cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableGradient & _coupled_grad;            ///< Coupled variable gradient
  const unsigned int _coupled_var;                   ///< Variable identification for coupled variable

  const VariableValue & _coef;			     ///< Variable for the coefficient
	const unsigned int _coef_var;					 ///< Variable identification for the coefficient

private:

};

/*!
 *  \file CoupledVariableFluxBC.h
 *	\brief Boundary Condition kernel for flux of material leaving/entering a domain
 *  \details A Flux BC which is consistent with the boundary terms arising from
 *            any flux of material into or out of a domain. The determination of
 *            whether the domain is an input or output domain is made on the fly
 *            by looking at the sign of the dot product between the flux vector
 *            and the normals of the domain.
 *
 *            [OUTPUT]
 *            if ((_flux)*_normals[_qp] > 0.0)
 *                Res = _test[_i][_qp]*(_flux*_normals[_qp]);
 *            [INPUT]
 *             else
 *                Res = _test[_i][_qp]*(_flux_in*_normals[_qp]); //Default to zero
 *
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

#include "IntegratedBC.h"
#include "libmesh/vector_value.h"

/// DGFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
	All public and protected members of this class are required function overrides.
	The flux BC uses the velocity in the system to apply a boundary
	condition based on whether or not material is leaving or entering the boundary. */
class CoupledVariableFluxBC : public IntegratedBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for BC objects in MOOSE
	CoupledVariableFluxBC(const InputParameters & parameters);

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

	/// Flux vector in the system or at the outlet boundary
	RealVectorValue _flux;

  const VariableValue & _fx;			///< Flux in the x-direction
	const VariableValue & _fy;			///< Flux in the y-direction
	const VariableValue & _fz;			///< Flux in the z-direction

	const unsigned int _fx_var;					///< Variable identification for fx
	const unsigned int _fy_var;					///< Variable identification for fy
	const unsigned int _fz_var;					///< Variable identification for fz

  /// Flux vector in the system or at the inlet boundary
	RealVectorValue _flux_in;

	Real _fx_in;
	Real _fy_in;
	Real _fz_in;

private:

};

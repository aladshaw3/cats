/*!
 *  \file DGNSMomentumOutflowBC.h
 *	\brief Boundary Condition kernel for the flux of momentum out of a domain
 *	\details This file creates a generic boundary condition kernel for the flux of momentum out of
 *			a boundary. The flux is based on a velocity vector, as well as domain density, and is valid
 *			in all directions and all boundaries of a DG method. Since the DG method's flux boundary
 *			conditions are essitially the same for input and ouput boundaries, this kernel will check
 *			the sign of the flux normal to the boundary and determine automattically whether it is
 *			an output or input boundary, then apply the appropriate conditions. If the boundary is
 *      an input boundary, then no flux will be applied.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
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

#include "DGConcentrationFluxBC.h"

/// DGNSMomentumOutflowBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
	All public and protected members of this class are required function overrides.
	The flux BC uses the velocity in the system to apply a boundary
	condition based on whether or not material is leaving or entering the boundary. */
class DGNSMomentumOutflowBC : public DGConcentrationFluxBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for BC objects in MOOSE
	DGNSMomentumOutflowBC(const InputParameters & parameters);

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

  const VariableValue & _density;			    ///< Porosity variable
  const unsigned int _density_var;				///< Variable identification for porosity

  const VariableValue & _coupled_main;    ///< Primary velocity component variable (i.e., diagonal)
  const unsigned int _main_var;           ///< Variable identification for the primary velocity variable (i.e., diagonal)

  unsigned int _dir;                      ///< Direction that '_main_var' acts on

private:

};

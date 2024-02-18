/*!
 *  \file DGFluxLimitedBC.h
 *	\brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods
 *	\details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *			condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *			so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *			if the value of a variable at the inlet boundary is equal to the finite element
 *			solution at that boundary. When the condition is not met, the residuals get penalyzed
 *			until the condition is met.
 *
 *      The DG method for diffusion involves 2 correction parameters:
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
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 *equations: Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *	\date 11/20/2015
 *	\copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *			   by Idaho National Laboratory and Oak Ridge National Laboratory
 *			   engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "IntegratedBC.h"
#include "libmesh/vector_value.h"
#include "MooseVariable.h"

/// DGFluxLimitedBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
  All public and protected members of this class are required function overrides.  */
class DGFluxLimitedBC : public IntegratedBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for BC objects in MOOSE
  DGFluxLimitedBC(const InputParameters & parameters);

protected:
  /// Required function override for BC objects in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual() override;
  /// Required function override for BC objects in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
    computed is the associated diagonal element in the overall Jacobian matrix for the
    system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian() override;

  MooseEnum _dg_scheme; ///< Enumerator to determine what scheme to use (NIPG, IIPG, or SIPG)
  /// Penalty term applied to the difference between the solution at the inlet and the value it is supposed to be
  Real _epsilon;
  /// Penalty term based on the size of the element at the boundary
  Real _sigma;

  /// Velocity vector in the system or at the boundary
  RealVectorValue _velocity;
  /// Diffusivity tensory in the system or at the boundary
  RealTensorValue _Diffusion;

  Real _vx;
  Real _vy;
  Real _vz;

  Real _Dxx, _Dxy, _Dxz;
  Real _Dyx, _Dyy, _Dyz;
  Real _Dzx, _Dzy, _Dzz;

  /// Value of the non-linear variable at the input of the boundary
  Real _u_input;

private:
};

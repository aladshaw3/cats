/*!
 *  \file INSNormalFlowBC.h
 *    \brief Boundary Condition kernel for usage with INS module to specify the flow normal to the
 * boundary \details This file creates a boundary condition kernel to produce residuals and
 * jacobians for a flow that is normal to a given boundary. Can be used for outflow or inflow. User
 * must given this condition for all velocity components that apply at that boundary. \author Austin
 * Ladshaw \date 06/01/2020 \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "IntegratedBC.h"

/// INSNormalFlowBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
    All public and protected members of this class are required function overrides.  */
class INSNormalFlowBC : public IntegratedBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for BC objects in MOOSE
  INSNormalFlowBC(const InputParameters & parameters);

protected:
  /// Required function override for BC objects in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual() override;

  /// Required function override for BC objects in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
      computed is the associated diagonal element in the overall Jacobian matrix for the
      system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian() override;

  /// Not required, but recomended function for DG kernels in MOOSE
  /** This function returns an off-diagonal jacobian contribution for this object. The jacobian
   being computed will be associated with the variables coupled to this object and not the
   main coupled variable itself. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  Real _u_dot_n;     ///< Value of the dot product of velocity and the normals at the boundary
  Real _penalty;     ///< Penalty value for the weak form of the residuals
  unsigned int _dir; ///< Direction that this velocity variable applies to (0 = x, 1 = y, 2 = z)

  const VariableValue & _ux; ///< Velocity in the x-direction
  const VariableValue & _uy; ///< Velocity in the y-direction
  const VariableValue & _uz; ///< Velocity in the z-direction

  const unsigned int _ux_var; ///< Variable identification for ux
  const unsigned int _uy_var; ///< Variable identification for uy
  const unsigned int _uz_var; ///< Variable identification for uz

  /// Velocity vector in the system or at the boundary
  RealVectorValue _velocity;

private:
};

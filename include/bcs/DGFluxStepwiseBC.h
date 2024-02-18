/*!
 *  \file DGFluxStepwiseBC.h
 *    \brief Boundary Condition kernel for the flux across a boundary of the domain with stepwise
 * inputs \details This file creates a generic boundary condition kernel for the flux of material
 * accross a boundary wise stepwise inputs. The flux is based on a velocity vector and is valid in
 * all directions and all boundaries of a DG method. Since the DG method's flux boundary conditions
 * are essitially the same for input and ouput boundaries, this kernel will check the sign of the
 * flux normal to the boundary and determine automattically whether it is an output or input
 * boundary, then apply the appropriate conditions.
 *
 *            This type of boundary condition for DG kernels applies the true flux boundary
 * condition. In true finite volumes or DG methods, there is no Dirichlet    boundary conditions,
 *            because the solutions are based on fluxes into and out of cells in a domain.
 *
 *            Stepwise inputs are determined from a list of input values and times at which those
 * input values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic
 * equations: Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *
 *  \author Austin Ladshaw
 *  \date 03/19/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
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

#include "DGFluxBC.h"

/// DGFluxStepwiseBC class object inherits from DGFluxBC object
/** This class object inherits from the DGFluxBC object.
    All public and protected members of this class are required function overrides.
    The flux BC uses the velocity in the system to apply a boundary
    condition based on whether or not material is leaving or entering the boundary.
    Stepwise inputs are directed by lists of input values and input times. */
class DGFluxStepwiseBC : public DGFluxBC
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for BC objects in MOOSE
  DGFluxStepwiseBC(const InputParameters & parameters);

protected:
  /// Function  to update the _u_input value based on given time
  Real newInputValue(Real time);
  /// Required function override for BC objects in MOOSE
  /** This function returns a residual contribution for this object.*/
  virtual Real computeQpResidual() override;
  /// Required function override for BC objects in MOOSE
  /** This function returns a Jacobian contribution for this object. The Jacobian being
      computed is the associated diagonal element in the overall Jacobian matrix for the
      system and is used in preconditioning of the linear sub-problem. */
  virtual Real computeQpJacobian() override;

  std::vector<Real> _input_vals;  ///< Values for _u_input that update at corresponding times
  std::vector<Real> _input_times; ///< Values for determining when to change _u_input
  std::vector<Real> _time_spans;  ///< Amount of time it take to change to new input value
  std::vector<Real> _slopes;      ///< Slopes between each subsequent u_input
  int index;                      ///< Index variable to keep track of location in vectors

private:
};

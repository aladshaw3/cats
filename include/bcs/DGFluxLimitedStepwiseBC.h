/*!
 *  \file DGFluxLimitedStepwiseBC.h
 *    \brief Boundary Condition kernel to mimic a Dirichlet BC for DG methods with stepwise inputs
 *    \details This file creates a boundary condition kernel to impose a dirichlet-like boundary
 *            condition in DG methods. True DG methods do not have Dirichlet boundary conditions,
 *            so this kernel seeks to impose a constraint on the inlet of a boundary that is met
 *            if the value of a variable at the inlet boundary is equal to the finite element
 *            solution at that boundary. When the condition is not met, the residuals get penalyzed
 *            until the condition is met.
 *
 *            Stepwise inputs are determined from a list of input values and times at which those input
 *            values are to occur. Optionally, users can also provide a list of "ramp up" times that are
 *            used to create a smoother transition instead of abrupt change in inputs.
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
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
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

#include "DGFluxLimitedBC.h"

/// DGFluxLimitedStepwiseBC class object forward declaration
//class DGFluxLimitedStepwiseBC;

//template<>
//InputParameters validParams<DGFluxLimitedStepwiseBC>();

/// DGFluxLimitedStepwiseBC class object inherits from DGFluxLimitedBC object
/** This class object inherits from the DGFluxLimitedBC object.
    All public and protected members of this class are required function overrides.  */
class DGFluxLimitedStepwiseBC : public DGFluxLimitedBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for BC objects in MOOSE
    DGFluxLimitedStepwiseBC(const InputParameters & parameters);

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
    
    std::vector<Real> _input_vals;         ///< Values for _u_input that update at corresponding times
    std::vector<Real> _input_times;        ///< Values for determining when to change _u_input
    std::vector<Real> _time_spans;         ///< Amount of time it take to change to new input value
    std::vector<Real> _slopes;             ///< Slopes between each subsequent u_input
    int index;                             ///< Index variable to keep track of location in vectors

private:

};

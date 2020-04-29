/*!
 *  \file DGWallHeatFluxBC.h
 *    \brief Boundary Condition kernel to for heat flux caused by a wall
 *    \details This file creates a boundary condition kernel to account for heat loss or
 *          gained from a wall. The user must supply a coupled variable for the conductivity
 *          and heat transfer coefficient at the wall. The wall temperature is assumed constant
 *          in this case. Inherit from this kernel to add variable wall temperature.
 *
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
 *    \author Austin Ladshaw
 *    \date 04/29/2020
 *    \copyright This kernel was designed and built at the Georgia Institute
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

/// DGWallHeatFluxBC class object inherits from DGFluxLimitedBC object
/** This class object inherits from the DGFluxLimitedBC object.
    All public and protected members of this class are required function overrides.  */
class DGWallHeatFluxBC : public DGFluxLimitedBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for BC objects in MOOSE
    DGWallHeatFluxBC(const InputParameters & parameters);

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
    
    const VariableValue & _hw;            ///< Variable for Heat transfer coefficient
    const unsigned int _hw_var;           ///< Variable identification for hw

    const VariableValue & _Kx;            ///< Conductivity in the x-direction
    const VariableValue & _Ky;            ///< Conductivity in the y-direction
    const VariableValue & _Kz;            ///< Conductivity in the z-direction

    const unsigned int _Kx_var;                    ///< Variable identification for Kx
    const unsigned int _Ky_var;                    ///< Variable identification for Ky
    const unsigned int _Kz_var;                    ///< Variable identification for Kz

private:

};


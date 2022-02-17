/*!
 *  \file MicroscaleCoefTimeDerivative.h
 *    \brief Custom kernel for time derivatives in a fictious microscale.
 *    \details This file creates a custom MOOSE kernel for the time derivative at the microscale
 *              of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, diffusion on the microscale, or reactions.
 *
 *  \author Austin Ladshaw
 *    \date 04/16/2020
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in catalyst
 *              performance for new vehicle technologies.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "TimeDerivative.h"

/// MicroscaleCoefTimeDerivative class object inherits from TimeDerivative object
/** This class object inherits from the TimeDerivative object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel creates an appropriate time derivative for a microscale sub-problem
    at a particular node in a fictious sub-mesh. To be used in conjunction with other
    Microscale kernels. */
class MicroscaleCoefTimeDerivative : public TimeDerivative
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    MicroscaleCoefTimeDerivative(const InputParameters & parameters);

protected:
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual();
    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian();

    Real _nodal_time_coef;                ///< Time coefficient for the coupled time derivative at given node in microscale
    Real _total_length;                   ///< Total length of the microscale [Global]
    Real _dr;                             ///< Segment length ( = _total_length / (_total_nodes - 1) )
    Real _rl;                             ///< Spatial position at current node (internally calculated)
    Real _rd_l;                           ///< Spatial position raised to power at current node (internally calculated)
    unsigned int _node;                   ///< Current node in the microscale
    unsigned int _total_nodes;            ///< Total number of nodes to discretize the microscale with [Global]
    unsigned int _coord_id;               ///< Coordinate id number ( 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical ) [Global]

private:

};

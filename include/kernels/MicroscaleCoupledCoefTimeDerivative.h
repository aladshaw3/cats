/*!
 *  \file MicroscaleCoupledCoefTimeDerivative.h
 *    \brief Custom kernel for coupling time derivatives in a fictious microscale.
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

#include "Kernel.h"

/// MicroscaleCoupledCoefTimeDerivative class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel creates an appropriate time derivative for a microscale sub-problem
    at a particular node in a fictious sub-mesh. To be used in conjunction with other
    Microscale kernels. */
class MicroscaleCoupledCoefTimeDerivative : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    MicroscaleCoupledCoefTimeDerivative(const InputParameters & parameters);

protected:
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual();
    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian();
    /// Not Required, but aids in the preconditioning step
    /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar);

    Real _nodal_time_coef;                ///< Time coefficient for the coupled time derivative at given node in microscale
    Real _total_length;                   ///< Total length of the microscale [Global]
    Real _dr;                             ///< Segment length ( = _total_length / (_total_nodes - 1) )
    Real _rl;                             ///< Spatial position at current node (internally calculated)
    Real _rd_l;                           ///< Spatial position raised to power at current node (internally calculated)
    unsigned int _node;                   ///< Current node in the microscale
    unsigned int _total_nodes;            ///< Total number of nodes to discretize the microscale with [Global]
    unsigned int _coord_id;               ///< Coordinate id number ( 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical ) [Global]

    const VariableValue & _coupled_dot;        ///< Time derivative of the coupled variable
    const VariableValue & _coupled_ddot;    ///< Cross derivative term for the coupled variables
    const unsigned int _coupled_var;        ///< Variable identification for the coupled variable

private:

};

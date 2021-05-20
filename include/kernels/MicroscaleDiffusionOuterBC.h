/*!
 *  \file MicroscaleDiffusionOuterBC.h
 *    \brief Custom kernel for a mass-transfer flux diffusion BC in a fictious microscale.
 *    \details This file creates a custom MOOSE kernel for the inner diffusion BC at the microscale
 *              of a fictious mesh. Generally this kernel is to be used in conjunction with other
 *              Microscale kernels for mass transfer, time derivatives on the microscale, or reactions.
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

/// MicroscaleDiffusionOuterBC class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel creates a diffusion transport via flux reconstruction for a microscale sub-problem
    at a particular node in a fictious sub-mesh. To be used in conjunction with other
    Microscale kernels. */
class MicroscaleDiffusionOuterBC : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    MicroscaleDiffusionOuterBC(const InputParameters & parameters);

protected:
    /// Calculation of the upper and lower fluxes
    void calculateFluxes();

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

    Real _diff_const;                     ///< Coefficient for constant diffusion in the microscale [Global]
    Real _trans_const;                    ///< Coefficient for constant mass-transfer across boundary

    Real _current_diff;                   ///< Diffusion coefficient at current node
    Real _upper_diff;                     ///< Diffusion coefficient at upper node
    Real _lower_diff;                     ///< Diffusion coefficient at lower node

    Real _flux_upper;                     ///< Calculated flux from upper neighbor diffusion
    Real _flux_lower;                     ///< Calculated flux from lower neighbor diffusion

    Real _total_length;                   ///< Total length of the microscale [Global]
    Real _dr;                             ///< Segment length ( = _total_length / (_total_nodes - 1) )

    Real _rl;                             ///< Spatial position at current node (internally calculated)
    Real _rd_l;                           ///< Spatial position raised to power at current node (internally calculated)

    Real _rlp1;                           ///< Spatial position at upper node (internally calculated)
    Real _rd_lp1;                         ///< Spatial position raised to power at upper node (internally calculated)

    Real _rlm1;                           ///< Spatial position at lower node (internally calculated)
    Real _rd_lm1;                         ///< Spatial position raised to power at lower node (internally calculated)

    unsigned int _this_node;              ///< Current node in the microscale
    unsigned int _upper_node;             ///< Upper node in the microscale (should be 1+_this_node)
    int _lower_node;                      ///< Lower node in the microscale (should be 1-_this_node)
    unsigned int _total_nodes;            ///< Total number of nodes to discretize the microscale with [Global]
    unsigned int _coord_id;               ///< Coordinate id number ( 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical ) [Global]

    const VariableValue & _macro_variable;    ///< Coupled variable for the macro-scale (i.e., true mesh)
    const unsigned int _macro_var;            ///< Variable identification for the macro-scale (i.e., true mesh)

    const VariableValue & _lower_neighbor;    ///< Coupled variable for the upper neighbor
    const unsigned int _lower_var;            ///< Variable identification for the upper neighbor

private:

};

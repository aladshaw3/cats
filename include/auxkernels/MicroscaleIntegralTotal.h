/*!
 *  \file MicroscaleIntegralTotal.h
 *    \brief Custom auxkernel for integrating a series of microscale variables over the fictious microscale space
 *    \details This file creates a custom MOOSE kernel for the diffusion at the microscale
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

#include "AuxKernel.h"

/// MicroscaleIntegralTotal class inherits from AuxKernel
class MicroscaleIntegralTotal : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    MicroscaleIntegralTotal(const InputParameters & parameters);

protected:
    /// Helper function to compute the microscale integral
    Real computeIntegral();

    /// Required MOOSE function override
    virtual Real computeValue() override;

    Real _space_factor;                   ///< Conversion factor for space (in cartesian --> face area, in cylindrical --> length, in sphere = 1)
    Real _total_length;                   ///< Total length of the microscale [Global]
    Real _dr;                             ///< Segment length ( = _total_length / (_total_nodes - 1) )
    unsigned int _total_nodes;            ///< Total number of nodes to discretize the microscale with [Global]
    unsigned int _coord_id;               ///< Coordinate id number ( 0 = cartesian, 1 = r-cylindrical, 2 = r-spherical ) [Global]
    std::vector<const VariableValue *> _vars;      ///< Pointer list to the microscale variables
    /// Node id for the first microscale variable in the above list
    /*** WARNING:  This method assumes that the variables are in nodal order from lowest node to highest node! */
    unsigned int _first_node;

private:

};

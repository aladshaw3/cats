/*!
 *  \file InterfaceMassTransfer.h
 *  \brief Interface Kernel for creating an exchange of mass (or energy) across a physical boundary
 *  \details This file creates an iterface kernel for the coupling a pair of non-linear variables in different
 *            subdomains across a boundary designated as a side-set in the mesh. The variables are
 *            coupled linearly in a via a constant transfer coefficient as shown below:
 *                  Res = test * km * (u - v)
 *                          where u = master variable in master domain
 *                          and v = neighbor variable in the adjacent subdomain
 *
 *  \note Only need 1 interface kernel for both non-linear variables that are coupled to handle transfer in both domains
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/06/2020
 *  \copyright This kernel was designed and built at Oak Ridge National
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

#include "InterfaceKernel.h"

/// InterfaceMassTransfer class object forward declarations
//class InterfaceMassTransfer;

//template <>
//InputParameters validParams<InterfaceMassTransfer>();

/// InterfaceMassTransfer class object inherits from InterfaceKernel object
/** This class object inherits from the InterfaceKernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel couples the pair of non-linear variables across a physical boundary to
    provide mass/energy transfer between domains.  */
class InterfaceMassTransfer : public InterfaceKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    InterfaceMassTransfer(const InputParameters & parameters);

protected:
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual(Moose::DGResidualType type) override;
    
    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
     computed is the associated diagonal element in the overall Jacobian matrix for the
     system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

    Real _trans_rate;             ///< Mass/energy transfer rate between domains

};

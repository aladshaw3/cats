/*!
*  \file DGConcentrationAdvection.h
*	\brief Discontinous Galerkin kernel for density advection
*	\details This file creates a discontinous Galerkin kernel for density advection in a given domain. It is a generic
*			advection kernel that is meant to be inherited from to make a more specific kernel for a given problem.
*
*	\note Any DG kernel under FENNEC will have a cooresponding G kernel (usually of same name) that must be included
*		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
*		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
*		by the standard Galerkin system. This my be due to some legacy code in MOOSE. I am not sure if it is possible to
*		lump all of these actions into a single DG kernel.
*
*  \author Austin Ladshaw
*	\date 07/12/2018
*	\copyright This kernel was designed and built at the Georgia Institute
*             of Technology by Austin Ladshaw for PhD research in the area
*             of radioactive particle transport and settling following a
*			   nuclear event. It was developed for the US DOD under DTRA
*			   project No. 14-24-FRCWMD-BAA. Portions Copyright (c) 2018, all
*             rights reserved.
*
*			   Austin Ladshaw does not claim any ownership or copyright to the
*			   MOOSE framework in which these kernels are constructed, only
*			   the kernels themselves. The MOOSE framework copyright is held
*			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "DGAdvection.h"

/// DGConcentrationAdvection class object inherits from DGKernel object
/** This class object inherits from the DGKernel object in the MOOSE framework.
All public and protected members of this class are required function overrides. The object
will provide residuals and Jacobians for the discontinous Galerkin formulation of advection
physics in the MOOSE framework. The only parameter for this kernel is a generic velocity
vector, whose components can be set piecewise in the input file or by inheriting from this
base class and manually altering the velocity vector.

\note As a reminder, any DGKernel in MOOSE was be accompanied by the equivalent GKernel in
order to provide the full residuals and Jacobians for the system. */
class DGConcentrationAdvection : public DGAdvection
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    DGConcentrationAdvection(const InputParameters & parameters);

protected:
    /// Required residual function for DG kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual(Moose::DGResidualType type) override;

    /// Required Jacobian function for DG kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
     computed is the associated diagonal element in the overall Jacobian matrix for the
     system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

    /// Not required, but recomended function for DG kernels in MOOSE
    /** This function returns an off-diagonal jacobian contribution for this object. The jacobian
     being computed will be associated with the variables coupled to this object and not the
     main coupled variable itself. */
    virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;

    const VariableValue & _ux;			///< Velocity in the x-direction
    const VariableValue & _uy;			///< Velocity in the y-direction
    const VariableValue & _uz;			///< Velocity in the z-direction

    const unsigned int _ux_var;					///< Variable identification for ux
    const unsigned int _uy_var;					///< Variable identification for uy
    const unsigned int _uz_var;					///< Variable identification for uz

private:

};

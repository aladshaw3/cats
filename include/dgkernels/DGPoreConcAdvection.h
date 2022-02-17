/*!
*  \file DGPoreConcAdvection.h
*	\brief Discontinous Galerkin kernel for density advection with variable porosity
*	\details This file creates a discontinous Galerkin kernel for density advection in a given domain that
*           has a particular porosity. The porosity is represented by another non-linear variable, though
*           you can often specify that variable to be part of the Auxillary system with a constant value.
*
*	\note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
*		with the DG kernel in the input file. This is because the DG finite element method breaks into several different
*		residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
*		by the standard Galerkin system.
*
*  \author Austin Ladshaw
*	\date 03/09/2020
*	\copyright This kernel was designed and built at Oak Ridge National
*              Laboratory by Austin Ladshaw for research in catalyst
*              performance for new vehicle technologies.
*
*			   Austin Ladshaw does not claim any ownership or copyright to the
*			   MOOSE framework in which these kernels are constructed, only
*			   the kernels themselves. The MOOSE framework copyright is held
*			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
*/

#pragma once

#include "DGConcentrationAdvection.h"

/// DGPoreConcAdvection class object inherits from DGKernel object
/** This class object inherits from the DGKernel object in the MOOSE framework.
All public and protected members of this class are required function overrides. The object
will provide residuals and Jacobians for the discontinous Galerkin formulation of advection
physics in the MOOSE framework. This kernel accepts velocity components and a porosity
variable to create a residual for pore-space advection.

\note As a reminder, any DGKernel in MOOSE was be accompanied by the equivalent GKernel in
order to provide the full residuals and Jacobians for the system. */
class DGPoreConcAdvection : public DGConcentrationAdvection
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    DGPoreConcAdvection(const InputParameters & parameters);

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

    const VariableValue & _porosity;			    ///< Porosity variable
    const unsigned int _porosity_var;					///< Variable identification for porosity

private:

};

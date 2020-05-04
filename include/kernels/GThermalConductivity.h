/*!
 *  \file GThermalConductivity.h
 *    \brief Kernel for use with the corresponding DGThermalConductivity object
 *    \details This file creates a standard MOOSE kernel that is to be used in conjunction with the DGThermalConductivity kernel
 *            for the discontinous Galerkin formulation of thermal conductivity physics in MOOSE. In order to complete the DG
 *            formulation of the conductivity physics, this kernel must be utilized with every variable that also uses
 *            the DGThermalConductivity kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *    \date 05/04/2020
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

#include "GVariableDiffusion.h"

/// GThermalConductivity class object inherits from GVariableDiffusion object
/** This class object inherits from the GVariableDiffusion object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel has a diffusion tensor whose components can be set piecewise in an
    input file.

    \note To create a specific GThermalConductivity kernel, inherit from this class and override
    the components of the diffusion tensor, then call the residual and Jacobian functions
    for this object. */
class GThermalConductivity : public GVariableDiffusion
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    GThermalConductivity(const InputParameters & parameters);

protected:
    /// Required residual function for standard kernels in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual() override;
    /// Required Jacobian function for standard kernels in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian() override;
  /// Not Required, but aids in the preconditioning step
    /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

    const VariableGradient & _temp_grad;            ///< Coupled temperature variable (K)
    const unsigned int _temp_var;                   ///< Variable identification for coupled temperature

private:

};


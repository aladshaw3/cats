/*!
 *  \file VariableCoupledCoeffTimeDerivative.h
 *    \brief Kernel for coupling the mass transfer via time derivatives with variable coefficient
 *    \details This file creates a standard MOOSE kernel for the coupling of time derivative
 *            functions between different non-linear variables to represent a transfer of mass
 *      from one phase to another. The differences in phases is identified by a bulk density
 *      variable (r) that also couples with this kernel. This is similar to the CoupledPorePhaseTransfer
 *      kernel, but is a more direct way for coupling adsorption that simultaneouly involves a
 *      unit conversion from mass/volume (in the gas phase) to mass/mass (in the solid).
 *
 *      R(u) = r*dv/dt
 *
 *  \note the 'gaining' parameter is used to denote whether or not the kernel term will
 *        act as a source term or sink term. In this kernel, it is always assumed a
 *        sink term. Primary use is for mass transfer from adsorption.
 *
 *  \author Austin Ladshaw
 *    \date 09/04/2020
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

#include "CoupledCoeffTimeDerivative.h"

/// VariableCoupledCoeffTimeDerivative class object inherits from CoupledCoeffTimeDerivative object
/** This class object inherits from the Kernel object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel interfaces the two non-linear variables to couple a time derivative
    function between given objects. */
class VariableCoupledCoeffTimeDerivative : public CoupledCoeffTimeDerivative
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();
    
    /// Required constructor for objects in MOOSE
    VariableCoupledCoeffTimeDerivative(const InputParameters & parameters);

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

    const VariableValue & _coeff;                   ///< Coupled time coefficient (usually bulk density)
    const unsigned int _coeff_var;                 ///< Variable identification for coupled time coefficient

private:

};


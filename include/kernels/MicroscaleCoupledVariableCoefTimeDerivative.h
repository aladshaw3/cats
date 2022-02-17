/*!
 *  \file MicroscaleCoupledVariableCoefTimeDerivative.h
 *    \brief Coupling time derivatives in microscale with variable coefficient.
 *    \details This file creates a custom MOOSE kernel for the time derivative at the microscale
 *              of a fictious mesh with a variable coefficient.
 *
 *  \author Austin Ladshaw
 *    \date 05/21/2020
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

#include "MicroscaleCoupledCoefTimeDerivative.h"

/// MicroscaleCoupledVariableCoefTimeDerivative class object inherits from MicroscaleCoupledCoefTimeDerivative object
/** This class object inherits from the MicroscaleCoupledCoefTimeDerivative object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel creates an appropriate time derivative for a microscale sub-problem
    at a particular node in a fictious sub-mesh. To be used in conjunction with other
    Microscale kernels. */
class MicroscaleCoupledVariableCoefTimeDerivative : public MicroscaleCoupledCoefTimeDerivative
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    MicroscaleCoupledVariableCoefTimeDerivative(const InputParameters & parameters);

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

    const VariableValue & _coupled_coef;        ///< Coupled variable for the time coefficient
    const unsigned int _coupled_coef_var;        ///< Variable identification for the coupled coefficient

private:

};

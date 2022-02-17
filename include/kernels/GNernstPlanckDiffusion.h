/*!
 *  \file GNernstPlanckDiffusion.h
 *    \brief Kernel for use with the corresponding DGNernstPlanckDiffusion object
 *    \details This file creates a standard MOOSE kernel that is to be used in conjunction
 *            with the DGNernstPlanckDiffusion kernel for the discontinous Galerkin
 *            formulation of Nernst-Planck diffusion physics in MOOSE. In order to complete the DG
 *            formulation of Nernst-Planck diffusion, this kernel must be utilized with
 *            every variable that also uses the DGNernstPlanckDiffusion kernel.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *  \author Austin Ladshaw
 *    \date 10/27/2021
 *    \copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              conversion of CO2 in catalytic flow batteries.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "GVariableDiffusion.h"

/// GNernstPlanckDiffusion class object inherits from GVariableDiffusion object
/** This class object inherits from the GVariableDiffusion object in the MOOSE framework.
    All public and protected members of this class are required function overrides.
    The kernel has a diffusion tensor whose components can be set piecewise in an
    input file.

    \note To create a specific GNernstPlanckDiffusion kernel, inherit from this class and override
    the components of the diffusion tensor, then call the residual and Jacobian functions
    for this object. */
class GNernstPlanckDiffusion : public GVariableDiffusion
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    GNernstPlanckDiffusion(const InputParameters & parameters);

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

    const VariableGradient & _e_potential_grad;            ///< Coupled eletric potential variable (V or J/C)
    const unsigned int _e_potential_var;                   ///< Variable identification for coupled eletric potential

    const VariableValue & _porosity;			  ///< Porosity variable
  	const unsigned int _porosity_var;				///< Variable identification for porosity

    const VariableValue & _temp;			  ///< Temperature variable (K)
  	const unsigned int _temp_var;				///< Variable identification for temperature

    Real _valence;                      ///< Valence or charge of the species being transported
    Real _faraday;                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)
    Real _gas_const;                    ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

private:

};

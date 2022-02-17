/*!
 *  \file DGNernstPlanckDiffusion.h
 *    \brief Discontinous Galerkin kernel for Nernst-Planck diffusion with variable coefficients
 *    \details This file creates a discontinous Galerkin kernel for Nernst-Planck diffusion in a given domain that
 *           has a variable diffusivity. The diffusivity is represented by a set of non-linear variables
 *           in the x, y, and z directions (in the case of anisotropic diffusion).
 *
 *      The DG method for diffusion involves 2 correction parameters:
 *
 *          (1) sigma - penalty term that should be >= 0 [if too large, it may cause errors]
 *          (2) epsilon - integer term with values of either -1, 0, or 1
 *
 *      Different values for epsilon result in slightly different discretizations:
 *
 *          (1) epsilon = -1   ==>   Symmetric Interior Penalty Galerkin (SIPG)
 *                                   Very efficient for symmetric problems, but may only
 *                                   converge if sigma is high.
 *          (2) epsilon = 0    ==>   Incomplete Interior Penalty Galerkin (IIPG)
 *                                   Works well for non-symmetic, well posed problems, but
 *                                   only converges under same sigma values as SIPG.
 *          (3) epsilon = 1    ==>   Non-symmetric Interior Penalty Galerking (NIPG)
 *                                   Most stable and easily convergable method that can
 *                                   work for symmetic and non-symmetric systems. Much
 *                                   less dependent on sigma values for convergence.
 *
 *      Reference: B. Riviere, Discontinous Galerkin methods for solving elliptic and parabolic equations:
 *                    Theory and Implementation, SIAM, Houston, TX, 2008.
 *
 *    \note Any DG kernel under CATS will have a cooresponding G kernel (usually of same name) that must be included
 *        with the DG kernel in the input file. This is because the DG finite element method breaks into several different
 *        residual pieces, only a handful of which are handled by the DG kernel system and the other parts must be handled
 *        by the standard Galerkin system.
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

#include "DGVariableDiffusion.h"

/// DGNernstPlanckDiffusion class object inherits from DGVariableDiffusion object
/** This class object inherits from the DGVariableDiffusion object in the MOOSE framework.
    All public and protected members of this class are required function overrides. The object
    will provide residuals and Jacobians for the discontinous Galerkin formulation of diffusion
    physics in the MOOSE framework. This kernel couples with variables for conductivity in
      x, y, and z directions.

    \note As a reminder, any DGKernel in MOOSE was be accompanied by the equivalent GKernel in
    order to provide the full residuals and Jacobians for the system. */
class DGNernstPlanckDiffusion : public DGVariableDiffusion
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    DGNernstPlanckDiffusion(const InputParameters & parameters);

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

    MooseVariable & _e_potential_var;       ///< Electric potential variable (V or J/C)
    const VariableValue & _e_potential;
    const VariableValue & _e_potential_neighbor;
    const VariableGradient & _grad_e_potential;
    const VariableGradient & _grad_e_potential_neighbor;
    unsigned int _e_potential_id;

    const VariableValue & _porosity;			    ///< Porosity variable
    const unsigned int _porosity_var;					///< Variable identification for porosity

    MooseVariable & _temp_var;                ///< Temperature variable (K)
    const VariableValue & _temp;
    const VariableValue & _temp_neighbor;
    unsigned int _temp_id;

    Real _valence;                      ///< Valence or charge of the species being transported
    Real _faraday;                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)
    Real _gas_const;                    ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

private:

};

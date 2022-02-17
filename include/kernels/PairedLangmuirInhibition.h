/*!
 *  \file PairedLangmuirInhibition.h
 *    \brief Kernel for creating an inhibition function of a Langmuir form with paired species
 *    \details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *            together via a Langmuir forcing function with paired species as follows...
 *            i.e., Res = 1 + sum(i, K_i * coupled_variable_i) + sum( (i,j) , K_ij * coupled_i * coupled_j)
 *                  where K_i and K_ij = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason it is
 *        done in this fashion is so that it will be more modular in how the inhibition variable R could
 *        be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>   Res(R) = R*test
 *        Langmuir Inhibition ==> Res(R) = -PairedLangmuirInhibition*test
 *
 *  \author Austin Ladshaw
 *    \date 09/22/2020
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

#include "LangmuirInhibition.h"

/// PairedLangmuirInhibition class object inherits from LangmuirInhibition object
class PairedLangmuirInhibition : public LangmuirInhibition
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    PairedLangmuirInhibition(const InputParameters & parameters);

protected:
    /// Function to compute all langmuir coefficients from temperature
    void computeAllLangmuirCoeffs();

    /// Function to compute the n-th pair in the Langmuir function using the n-th pairing coefficient
    Real computePairedLangmuirTerm(int n);

    /// Function to compute the off-diagonal Jacobi for the coupled concentrations
    Real computePairedLangmuirConcJacobi(int jvar);

    /// Function to compute the n-th pair in the Langmuir function's temperature Jacobi of the n-th parameter
    Real computePairedLangmuirTempJacobiTerm(int n);

    /// Function to compute the Jacobi for the coupled temperature
    Real computePairedLangmuirTempJacobi();

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

    std::vector<Real> _binary_coef;                     ///< Paired Langmuir Coefficients for the coupled variables (units are inverse concentration)
    std::vector<Real> _binary_pre_exp;                  ///< Pre-exponential factors for binary Langmuir coefficients
    std::vector<Real> _binary_beta;                     ///< Beta factors for the binary Langmuir coefficients
    std::vector<Real> _binary_act_energy;               ///< Activation energies for binary Langmuir coefficients
    std::vector<const VariableValue *> _coupled_i;        ///< Pointer list to the coupled gases (concentration units)
    std::vector<unsigned int> _coupled_i_vars;            ///< Indices for the concentration species in the system
    std::vector<const VariableValue *> _coupled_j;        ///< Pointer list to the coupled gases (concentration units)
    std::vector<unsigned int> _coupled_j_vars;            ///< Indices for the concentration species in the system

private:

};

/*!
 *  \file LangmuirInhibition.h
 *    \brief Kernel for creating an inhibition function of a Langmuir form
 *    \details This file creates a standard MOOSE kernel for the coupling of a vector non-linear variables
 *            together via a Langmuir forcing function as follows...
 *            i.e., Res = 1 + sum(i, K_i * coupled_variable_i)
 *                  where K_i = A*T^B*exp(-E/R/T)
 *
 *            T is a coupled temperature and coupled_variable_i are coupled concentrations
 *
 *  \note This should be used in conjunction with a Reaction kernel inside of the
 *        input file to enfore that the inhibition variable value equals this function. The reason it is
 *        done in this fashion is so that it will be more modular in how the inhibition variable R could
 *        be represented if multiple instances of these objects are necessary to define its behavior
 *
 *        Reaction kernel ==>   Res(R) = R*test
 *        Langmuir Inhibition ==> Res(R) = -LangmuirInhibition*test
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

#include "Kernel.h"

#ifndef Rstd
#define Rstd 8.3144621                        ///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

/// LangmuirInhibition class object inherits from Kernel object
class LangmuirInhibition : public Kernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    LangmuirInhibition(const InputParameters & parameters);

protected:
    /// Function to compute all langmuir coefficients from temperature
    void computeAllLangmuirCoeffs();

    /// Function to compute the i-th term in the Langmuir function
    Real computeLangmuirTerm(int i);

    /// Function to compute the off-diagonal Jacobi for the coupled concentrations
    Real computeLangmuirConcJacobi(int i);

    /// Function to compute the i-th term in the Langmuir function's temperature Jacobi
    Real computeLangmuirTempJacobiTerm(int i);

    /// Function to compute the Jacobi for the coupled temperature
    Real computeLangmuirTempJacobi();

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

    std::vector<Real> _langmuir_coef;                   ///< Langmuir Coefficients for the coupled variables (units are inverse concentration)
    std::vector<Real> _pre_exp;                         ///< Pre-exponential factors for Langmuir coefficients
    std::vector<Real> _beta;                            ///< Beta factors for the Langmuir coefficients
    std::vector<Real> _act_energy;                      ///< Activation energies for Langmuir coefficients
    std::vector<const VariableValue *> _coupled;        ///< Pointer list to the coupled gases (concentration units)
    std::vector<unsigned int> _coupled_vars;            ///< Indices for the concentration species in the system
    const VariableValue & _temp;                        ///< Coupled variable for temperature
    const unsigned int _temp_var;                       ///< Index for the coupled temperature variable

private:

};

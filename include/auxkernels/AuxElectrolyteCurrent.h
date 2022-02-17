/*!
 *  \file AuxElectrolyteCurrent.h
 *	\brief Auxiliary kernel for calculations of current in the electrolyte
 *	\details This file creates an auxiliary kernel for the coupling of a non-linear variable
 *            gradient for electrolyte potential with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. In the case of anisotopic
 *            diffusion, the diffusion coefficent the user provides should correspond to the
 *            direction of the electrolyte current this kernel acts on.
 *
 *            This would be done INSTEAD of using ElectrolyteCurrentFromPotentialGradient for
 *            residual based calculation of current (as it is not needed in that way)
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 02/10/2022
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"

/// AuxElectrolyteCurrent class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the current in the electrolyte in a given direction. */
class AuxElectrolyteCurrent : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    AuxElectrolyteCurrent(const InputParameters & parameters);

protected:
    /// Helper function to formulate the sum of ion terms
    Real sum_ion_terms();

    /// Helper function to formulate the full coupled coefficent
    Real effective_ionic_conductivity();

    /// Helper function to formulate the sum of ion terms
    Real sum_ion_gradient_terms();

    /// Required MOOSE function override
    virtual Real computeValue() override;

private:

    RealVectorValue _norm_vec;	    ///< Vector for direction of gradient
    unsigned int _dir;				      ///< Direction of current this kernel acts on (0=x, 1=y, 2=z)
    const VariableGradient & _e_potential_grad;            ///< Coupled eletric potential variable (V or J/C)
    const VariableValue & _porosity;			  ///< Porosity variable
    const VariableValue & _temp;			  ///< Temperature variable (K)

    Real _faraday;                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)
    Real _gas_const;                    ///< Value of the Gas law constant (default = 8.314462 J/K/mol)

    std::vector<const VariableValue *> _ion_conc;           ///< Pointer list to the coupled ion concentrations (mol/L^3)
    std::vector<const VariableGradient *> _ion_conc_grad;   ///< Pointer list to the coupled ion concentration gradients (mol/L^3/L)
    std::vector<const VariableValue *> _diffusion;          ///< Pointer list to the coupled diffusion coeffs (L^2/T)

    std::vector<Real> _valence;                             ///< Valence list for corresponding ions

    Real _min_conductivity;                                 ///< Minimum allowable value for conductivity (based on sum of ions)

};

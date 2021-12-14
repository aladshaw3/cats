/*!
 *  \file SchloeglDarcyCoefficient.h
 *    \brief Auxillary kernel for a Schloegl coefficient for implementation of Darcy's Law in membranes
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the Schloegl relationship for Darcy flow in membranes. This calculated
 *              coefficient is to be used in the calculation of velocity in/across a membrane
 *              assuming Darcy flow. This is where all velocities are resolved via only
 *              pressure gradients in the domain and the pressure is resolved with a Laplace's
 *              equation with proper boundary conditions applied.
 *
 *              vel = Coeff * grad(P)   where Coeff is calculated from this kernel.
 *
 *              Laplace's Equation:  0 = Coeff * Div * grad(P)
 *
 *  \note This kernel can also be used in conjuction with SchloeglElectrokineticCoefficient to
 *        determine a velocity flux through the membrane that is also a function of the potential
 *        gradient across that membrane.
 *
 *  \author Austin Ladshaw
 *  \date 12/14/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
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

#include "AuxKernel.h"

/// SchloeglDarcyCoefficient class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the new values for the auxvariable based on linear changes with time. */
class SchloeglDarcyCoefficient : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    SchloeglDarcyCoefficient(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:
    const VariableValue & _viscosity;                 ///< Variable for the viscosity of the fluid (typical units: Pressure * Time)
    const VariableValue & _hydro_perm;                ///< Variable for the hydrolic permeability of the membrane (units: Length^2)

};

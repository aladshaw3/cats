/*!
 *  \file SchloeglElectrokineticCoefficient.h
 *    \brief Auxillary kernel for a Schloegl Electrokinetic coefficient for implementation of Darcy's Law in membranes
 *    \details This file is responsible for calculating the value of an auxvariable
 *              according to the Schloegl Electrokinetic relationship for Darcy flow in membranes. This calculated
 *              coefficient is to be used in the calculation of velocity in/across a membrane
 *              assuming Darcy flow. This is where all velocities are resolved via only
 *              pressure gradients (and electric potential gradients) in the domain.
 *
 *              Both the electric potential and the pressure is resolved with a Laplace's
 *              equation with proper boundary conditions applied.
 *
 *              vel = DarcyCoeff * grad(P) + ElectrokineticCoeff * grad(phi)
 *                    where ElectrokineticCoeff comes from this kernel and
 *                    DarcyCoeff comes from SchloeglDarcyCoefficient.
 *
 *              Laplace's Equation for pressure:  0 = DarcyCoeff * Div * grad(P)
 *              Laplace's Equation for potential: 0 = Conductivity * Div * grad(phi)
 *
 *  \note This kernel should be used in conjuction with SchloeglDarcyCoefficient to
 *        determine a velocity flux through the membrane that is a function of the potential
 *        gradient, as well as the pressure gradient, across that membrane.
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

#pragma once

#include "AuxKernel.h"

/// SchloeglElectrokineticCoefficient class inherits from AuxKernel
class SchloeglElectrokineticCoefficient : public AuxKernel
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Standard MOOSE public constructor
    SchloeglElectrokineticCoefficient(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    virtual Real computeValue() override;

private:
    const VariableValue & _viscosity;                 ///< Variable for the viscosity of the fluid (typical units: Pressure * Time)
    const VariableValue & _eleckin_perm;              ///< Variable for the electrokinetic permeability of the membrane (units: Length^2)
    const VariableValue & _ion_conc;                  ///< Variable for the ion concentration in the membrane (units: Moles per Volume)
    Real _faraday;                      ///< Value of Faraday's Constant (default = 96485.3 C/mol)

    /// NOTE: Because this kernel uses very strange formulation, the units you get out could be non-sense
    /**
          Need the output of  (_eleckin_perm/_viscosity)*_faraday*_ion_conc * grad(phi)
          to produce the correct units for velocity (Length / Time).

            _eleckin_perm should always have units of Length^2
            _viscosity should always have units of Pressure * Time
            _faraday should have some form of Columbs/Moles
            _ion_conc should have units of Moles/Length^3
            grad(phi) will have some form of Voltz/Length or (Joules/Columbs)/Length

            Pressure Units have an equivalence with Joules and Volume
              (i.e., 1 Pa = 1 J/m^3)

            You can use any units you want and use this _conv_factor to make up the difference if needed.
                For example, what if you want velocity in cm/min, have phi in Voltz, viscosity in kPa*min,
                      ion_conc in moles/cm^3, permeability in cm^2, and your mesh dimensions in cm.
                Using this kernel as is will result in the following:

                (cm^2/(kPa*min)) * (C/mol) * (mol/cm^3) * (V/cm) == units of velocity

                1 V = 1 J/C  ==>  (cm^2/(kPa*min)) * (1/cm^3) * (J/cm) == now, units of velocity are very strange...

                Rearrage: (cm^2/(kPa*min)) * (1/cm) * (J/cm^3)  ==>  J/cm^3 is a unit of pressure

                1 kPa = 1000 J/m^3 * 1 m^3/100^3 cm^3 == 0.001 J/cm^3   ==> Thus, _conv_factor = 0.001 kPa*cm^3/J

                (cm^2/(kPa*min)) * (1/cm) * (J/cm^3) * (0.001 kPa*cm^3/J) ==> cm/min

            Thus, if you are following this basic unit convention for all variables, then the unit conversion
                term should always have units of (Pressure * Volume / Energy)
                where the Pressure should be same units as viscosity, the Volume should use same volume units
                in ion_conc, and the Energy unit should use same energy basis in the potential variable (phi).
    **/
    Real _conv_factor;                  ///< Value of a conversion factor if needed (default = 1, i.e., no conversion)

};

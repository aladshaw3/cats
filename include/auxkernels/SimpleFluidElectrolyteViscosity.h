/*!
 *  \file SimpleFluidElectrolyteViscosity.h
 *    \brief AuxKernel kernel to calculate viscosity of an electrolyte liquid (default = water + NaCl)
 *    \details This file is responsible for calculating the viscosity of an electrolyte liquid by
 *            using an emperical relationship (see SimpleFluidPropertiesBase for
 *            more details). That relationship is a function of the ionic strength
 *            of the electrolyte solution. User can specify if they want a pressure unit basis
 *            or a mass unit basis on output.
 *
 *            Pressure Basis:   [Pressure * Time]
 *            Mass Basis:       [Mass / Length / Time]
 *
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
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

#include "SimpleFluidViscosity.h"

/// SimpleFluidViscosity class object inherits from SimpleFluidViscosity object
/** This class object inherits from the SimpleFluidViscosity object in the CATS framework.
    All public and protected members of this class are required function overrides. */
class SimpleFluidElectrolyteViscosity : public SimpleFluidViscosity
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for objects in MOOSE
    SimpleFluidElectrolyteViscosity(const InputParameters & parameters);

protected:
    /// Required MOOSE function override
    /** This is the function that is called by the MOOSE framework when a calculation of the total
        system pressure is needed. You are required to override this function for any inherited
        AuxKernel. */
    virtual Real computeValue() override;

private:

};

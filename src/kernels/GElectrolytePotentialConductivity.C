/*!
 *  \file GElectrolytePotentialConductivity.h
 *	\brief Standard kernel for a Poisson's equation for electrolyte conductivity
 *	\details This file creates a standard MOOSE kernel for the coupling of this kernel's variable for
 *            electrolyte potential (_u and _u_grad) with variables for ion concentration, diffusion
 *            coefficients for ions, temperature, and ion valence. This kernel is ONLY valid
 *            for isotropic diffusion, which should cover most all cases.
 *
 *  \note This kernel is meant to be used in conjunction with DGElectrolytePotentialConductivity
 *        to fully describe the physics of current transport in a DG sense.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \author Austin Ladshaw
 *	\date 11/12/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *			   Austin Ladshaw does not claim any ownership or copyright to the
 *			   MOOSE framework in which these kernels are constructed, only
 *			   the kernels themselves. The MOOSE framework copyright is held
 *			   by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
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

#include "GElectrolytePotentialConductivity.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GElectrolytePotentialConductivity);

InputParameters GElectrolytePotentialConductivity::validParams()
{
    InputParameters params = ElectrolytePotentialConductivity::validParams();
    return params;
}

GElectrolytePotentialConductivity::GElectrolytePotentialConductivity(const InputParameters & parameters) :
ElectrolytePotentialConductivity(parameters)
{

}

Real GElectrolytePotentialConductivity::computeQpResidual()
{
    return ElectrolytePotentialConductivity::computeQpResidual();
}

Real GElectrolytePotentialConductivity::computeQpJacobian()
{
    return ElectrolytePotentialConductivity::computeQpJacobian();
}

Real GElectrolytePotentialConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
    return ElectrolytePotentialConductivity::computeQpOffDiagJacobian(jvar);
}

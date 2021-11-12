/*!
 *  \file GElectrolyteIonConductivity.h
 *	\brief Standard kernel for coupling gradients of ion concentrations to the electrolyte potential
 *	\details This file creates a standard MOOSE kernel for the coupling of a set of non-linear variable
 *            gradients for ion concentrations with variables for diffusion, porosity, and
 *            ion valence. This kernel should act on potential in the electrolyte to resolve the
 *            conservation of charge in the electrolyte phase based on diffusion of all ions in
 *            solution. This kernel is ONLY valid for isotropic diffusion, which should cover most all cases.
 *
 *  \note This kernel is meant to be used in conjunction with DGElectrolyteIonConductivity
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

#include "GElectrolyteIonConductivity.h"

/**
 * All MOOSE based object classes you create must be registered using this macro.  The first
 * argument is the name of the App with an "App" suffix (i.e., "fennecApp"). The second
 * argument is the name of the C++ class you created.
 */
registerMooseObject("catsApp", GElectrolyteIonConductivity);

InputParameters GElectrolyteIonConductivity::validParams()
{
    InputParameters params = ElectrolyteIonConductivity::validParams();
    return params;
}

GElectrolyteIonConductivity::GElectrolyteIonConductivity(const InputParameters & parameters) :
ElectrolyteIonConductivity(parameters)
{

}

Real GElectrolyteIonConductivity::computeQpResidual()
{
    return ElectrolyteIonConductivity::computeQpResidual();
}

Real GElectrolyteIonConductivity::computeQpJacobian()
{
    return ElectrolyteIonConductivity::computeQpJacobian();
}

Real GElectrolyteIonConductivity::computeQpOffDiagJacobian(unsigned int jvar)
{
    return ElectrolyteIonConductivity::computeQpOffDiagJacobian(jvar);
}

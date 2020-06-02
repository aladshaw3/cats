/*!
 *  \file INSFluid.h
 *    \brief Custom material object to interface with the incompressible Navier-Stokes module
 *    \details This file creates a custom materials object to interface with the built-in incompressible
 *              Navier-Stokes (INS) MOOSE module. The INS module was built in such a way that the fluid
 *              density and viscosity are required to be materials properties instead of variables or
 *              auxilliary variables. In CATS, all properties are done as either variables or auxillary
 *              variables to ensure that the code was flexible enough to grow and expand in capabilities
 *              without the need for major overhauls of the code base. Thus, in order to get the CATS
 *              density and viscosity to communicate with the INS module, we must have the INS module
 *              use this material, which is used only to set the material property values to those of
 *              the density and viscosity variables from CATS.
 *    \author Austin Ladshaw
 *    \date 06/02/2020
 *    \copyright This kernel was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science and was developed for use
 *               by Idaho National Laboratory and Oak Ridge National Laboratory
 *               engineers and scientists. Portions Copyright (c) 2015, all
 *             rights reserved.
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

#include "Material.h"

/// INSFluid class object inherits from Material object
/** This class object inherits from the Material object.
    All public and protected members of this class are required function overrides.  */
class INSFluid : public Material
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();
  
  /// Required constructor for BC objects in MOOSE
  INSFluid(const InputParameters & parameters);

protected:
  /// Function to compute the material properties at a quadrature point
  virtual void computeQpProperties();

  const VariableValue & _rho;                   /// CATS density variable in kg/m^3
  const VariableValue & _mu;                    /// CATS viscosity variable in kg/m/s
  
  MaterialProperty<Real> & _density;            /// INS material for density in kg/m/s
  MaterialProperty<Real> & _dynamic_viscosity;  /// INS material for viscosity in kg/m/s

private:
  
};

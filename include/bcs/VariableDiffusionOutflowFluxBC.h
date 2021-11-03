/*!
 *  \file VariableDiffusionOutflowFluxBC.h
 *	\brief Boundary Condition kernel for diffusion flux leaving a domain
 *  \details A FluxBC which is consistent with the boundary terms arising from
 *            a Diffusion process. The flux vector in this case is simply
 *            Diffusion*grad(u) and the residual contribution is:
 *
 *                Res = -eps*Diffusion*grad(u)*normals*test
 *
 *            where eps is an optional 'porosity' term and 'Diffusion' is
 *            a RealTensor to allow for anisotopic behaviors.
 *
 *            In contrast to e.g. VectorNeumannBC, the user does not provide a
 *            specified value of the flux when using this class, instead the
 *            residual contribution corresponding to the current value of grad(u)
 *            is computed and accumulated into the residual vector.
 *
 *
 *  \author Austin Ladshaw
 *	\date 11/03/2021
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

#pragma once

#include "FluxBC.h"

/// VariableDiffusionOutflowFluxBC class object inherits from FluxBC object
/** This class object inherits from the FluxBC object.
	All public and protected members of this class are required function overrides.
	Theis flux BC ONLY applies to an outlet/outflow boundary (or open boundary). */
class VariableDiffusionOutflowFluxBC : public FluxBC
{
public:
  static InputParameters validParams();

  VariableDiffusionOutflowFluxBC(const InputParameters & parameters);

protected:
  /// Override the Off-diagonal Jacobian functions for coupled variables
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  /// Override the Flux portion of the residual that FluxBC calls
  virtual RealGradient computeQpFluxResidual() override;

  /// Override the Flux portion of the jacobian that FluxBC calls
  virtual RealGradient computeQpFluxJacobian() override;

  /// Diffusivity tensory in the system or at the boundary
	RealTensorValue _Diffusion;

  const VariableValue & _Dx;			///< Diffusion in the x-direction
  const VariableValue & _Dy;			///< Diffusion in the y-direction
  const VariableValue & _Dz;			///< Diffusion in the z-direction

  const unsigned int _Dx_var;					///< Variable identification for Dx
  const unsigned int _Dy_var;					///< Variable identification for Dy
  const unsigned int _Dz_var;					///< Variable identification for Dz

  const VariableValue & _porosity;			    ///< Porosity variable
  const unsigned int _porosity_var;					///< Variable identification for porosity
};

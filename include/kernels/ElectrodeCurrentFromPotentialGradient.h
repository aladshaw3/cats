/*!
 *  \file ElectrodeCurrentFromPotentialGradient.h
 *	\brief Standard kernel for coupling a gradient of potential to the formation of current
 *	\details This file creates a standard MOOSE kernel for the coupling of a non-linear variable
 *            gradient for electrode potential to calculate current. In the case of anisotopic
 *            conductivity, the user should provide the conductivity that corresponds with the
 *            direction of current that this kernel acts on.
 *
 *            Ref:  J.R. Clausen, V.E. Brunini, H.K. Moffat, M.J. Martinez, "Numerical Modeling
 *                  of an All Vanadium Redox Flow Battery", Sandia Report, SAND2014-0190,
 *                  Sandia National Laboratories, Albuquerque, NM, January 2014.
 *
 *  \note Users MUST provide the direction of the current vector being calculated (0=>x, 1=>y, 2=>z)
 *
 *  \author Austin Ladshaw
 *	\date 11/15/2021
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

#include "Kernel.h"

/// ElectrodeCurrentFromPotentialGradient class object inherits from Kernel object
/** This class object inherits from the Kernel object in the MOOSE framework.
	All public and protected members of this class are required function overrides.
	The kernel has a vector whose components can be set piecewise in an
	input file. */
class ElectrodeCurrentFromPotentialGradient : public Kernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

	/// Required constructor for objects in MOOSE
	ElectrodeCurrentFromPotentialGradient(const InputParameters & parameters);

protected:
	/// Required residual function for standard kernels in MOOSE
	/** This function returns a residual contribution for this object.*/
	virtual Real computeQpResidual() override;

	/// Required Jacobian function for standard kernels in MOOSE
	/** This function returns a Jacobian contribution for this object. The Jacobian being
		computed is the associated diagonal element in the overall Jacobian matrix for the
		system and is used in preconditioning of the linear sub-problem. */
	virtual Real computeQpJacobian() override;

  /// Not Required, but aids in the preconditioning step
  /** This function returns the off diagonal Jacobian contribution for this object. By
        returning a non-zero value we will hopefully improve the convergence rate for the
        cross coupling of the variables. */
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

	RealVectorValue _norm_vec;	    ///< Vector for direction of gradient

  unsigned int _dir;				      ///< Direction of current this kernel acts on (0=x, 1=y, 2=z)

  const VariableGradient & _e_potential_grad;       ///< Coupled eletric potential variable (V or J/C)
  const unsigned int _e_potential_var;              ///< Variable identification for coupled eletric potential

  const VariableValue & _sol_frac;			  ///< Solids fraction variable
  const unsigned int _sol_frac_var;				///< Variable identification for solids fraction

  const VariableValue & _conductivity;			  ///< Conductivity variable (in C/C/length/time)
  const unsigned int _conductivity_var;				///< Variable identification for conductivity


private:

};

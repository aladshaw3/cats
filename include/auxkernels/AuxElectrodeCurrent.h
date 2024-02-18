/*!
 *  \file AuxElectrodeCurrent.h
 *	\brief Auxiliary kernel for calculating current in the electrode
 *	\details This file creates an auxiliary kernel for the coupling of a non-linear variable
 *            gradient for electrode potential to calculate current. In the case of anisotopic
 *            conductivity, the user should provide the conductivity that corresponds with the
 *            direction of current that this kernel acts on.
 *
 *            This would be done INSTEAD of using ElectrodeCurrentFromPotentialGradient for
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

/// AuxElectrodeCurrent class inherits from AuxKernel
/** This class object creates an AuxKernel for use in the MOOSE framework. The AuxKernel will
    calculate the current in the electrode in a given direction. */
class AuxElectrodeCurrent : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Standard MOOSE public constructor
  AuxElectrodeCurrent(const InputParameters & parameters);

protected:
  /// Required MOOSE function override
  virtual Real computeValue() override;

private:
  RealVectorValue _norm_vec; ///< Vector for direction of gradient
  unsigned int _dir;         ///< Direction of current this kernel acts on (0=x, 1=y, 2=z)
  const VariableGradient & _e_potential_grad; ///< Coupled eletric potential variable (V or J/C)
  const VariableValue & _sol_frac;            ///< Solids fraction variable
  const VariableValue & _conductivity;        ///< Conductivity variable (in C/C/length/time)
};

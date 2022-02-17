/*!
 *  \file DGWallEnergyFluxBC.h
 *    \brief Boundary Condition kernel to for energy flux caused by a wall heating/cooling
 *    \details This file creates a boundary condition kernel to account for heat loss or
 *          gained from a wall. The user must supply a coupled variable for the
 *          heat transfer coefficient at the wall. The wall temperature is given as a
 *          non-linear variable, but a constant may also be given.
 *
 *    \author Austin Ladshaw
 *    \date 05/04/2020
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

#pragma once

#include "IntegratedBC.h"

/// DGWallEnergyFluxBC class object inherits from IntegratedBC object
/** This class object inherits from the IntegratedBC object.
    All public and protected members of this class are required function overrides.  */
class DGWallEnergyFluxBC : public IntegratedBC
{
public:
    /// Required new syntax for InputParameters
    static InputParameters validParams();

    /// Required constructor for BC objects in MOOSE
    DGWallEnergyFluxBC(const InputParameters & parameters);

protected:
    /// Required function override for BC objects in MOOSE
    /** This function returns a residual contribution for this object.*/
    virtual Real computeQpResidual() override;

    /// Required function override for BC objects in MOOSE
    /** This function returns a Jacobian contribution for this object. The Jacobian being
        computed is the associated diagonal element in the overall Jacobian matrix for the
        system and is used in preconditioning of the linear sub-problem. */
    virtual Real computeQpJacobian() override;

    /// Not required, but recomended function for DG kernels in MOOSE
    /** This function returns an off-diagonal jacobian contribution for this object. The jacobian
     being computed will be associated with the variables coupled to this object and not the
     main coupled variable itself. */
    virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

    const VariableValue & _hw;            ///< Variable for Heat transfer coefficient (W/m^2/K)
    const unsigned int _hw_var;           ///< Variable identification for hw
    const VariableValue & _temp;          ///< Variable for phase temperature (K)
    const unsigned int _temp_var;         ///< Variable identification for phase temperature
    const VariableValue & _walltemp;      ///< Variable for wall temperature (K)
    const unsigned int _walltemp_var;     ///< Variable identification for wall temperature
    const VariableValue & _areafrac;      ///< Variable for area fraction (-)
    const unsigned int _areafrac_var;     ///< Variable identification for area fraction

private:

};

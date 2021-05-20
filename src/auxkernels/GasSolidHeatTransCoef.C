/*!
 *  \file GasSolidHeatTransCoef.h
 *    \brief AuxKernel kernel to compute the gas-solid heat transfer coefficient
 *    \details This file is responsible for calculating the gas-solid heat transfer in W/m^2/K
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/27/2020
 *  \copyright This kernel was designed and built at the Georgia Institute
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

#include "GasSolidHeatTransCoef.h"

registerMooseObject("catsApp", GasSolidHeatTransCoef);

InputParameters GasSolidHeatTransCoef::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< Real >("heat_cap_ratio",1.4,"Ratio of heat capacities (Cp/Cv) ==> Assumed = 1.4");
    params.addRequiredCoupledVar("solid_conductivity","Name of the solids thermal conductivity variable (W/m/K)");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    return params;
}

GasSolidHeatTransCoef::GasSolidHeatTransCoef(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_Cp_Cv_ratio(getParam< Real >("heat_cap_ratio")),
_solid_cond(coupledValue("solid_conductivity")),
_solid_cond_var(coupled("solid_conductivity")),
_porosity(coupledValue("porosity")),
_porosity_var(coupled("porosity"))
{
    // Check the bounds of the correction factor (typical values: 1.3 - 1.6)
    if (_Cp_Cv_ratio < 0.56)
    {
        _Cp_Cv_ratio = 0.56;
    }
    if (_Cp_Cv_ratio > 1.67)
    {
        _Cp_Cv_ratio = 1.67;
    }
}

Real GasSolidHeatTransCoef::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    Real Cv = _egret_dat.total_specific_heat*1000.0/_Cp_Cv_ratio;
    Real mu = _egret_dat.total_dyn_vis/1000.0*100.0;
    Real f = 0.25*(9.0*_Cp_Cv_ratio - 5.0);
    Real Kg = f*mu*Cv;

    Real Pr = (_egret_dat.total_dyn_vis/1000.0*100.0)*(_egret_dat.total_specific_heat*1000.0)/Kg;
    Real Re = ReNum(_egret_dat.velocity*_porosity[_qp],_char_len[_qp]*100.0,_egret_dat.kinematic_viscosity);

    return FilmMTCoeff(_solid_cond[_qp],_char_len[_qp],Re,Pr)/500.0;
    //Note: FilmMTCoeff is same function for heat transfer with a correction factor
}

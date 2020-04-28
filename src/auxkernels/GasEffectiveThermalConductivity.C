/*!
 *  \file GasEffectiveThermalConductivity.h
 *    \brief AuxKernel kernel to compute the effective thermal conductivity of gases in a packed column
 *    \details This file is responsible for calculating the effective gas thermal conductivity in W/m/K
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/21/2020
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

#include "GasEffectiveThermalConductivity.h"

registerMooseObject("catsApp", GasEffectiveThermalConductivity);

/*
template<>
InputParameters validParams<GasEffectiveThermalConductivity>()
{
    InputParameters params = validParams<GasPropertiesBase>();
    params.addParam< Real >("heat_cap_ratio",1.4,"Ratio of heat capacities (Cp/Cv) ==> Assumed = 1.4");
    params.addRequiredCoupledVar("macroscale_diameter","Name of the macrocale column diameter variable (m)");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    return params;
}
 */

InputParameters GasEffectiveThermalConductivity::validParams()
{
    InputParameters params = GasPropertiesBase::validParams();
    params.addParam< Real >("heat_cap_ratio",1.4,"Ratio of heat capacities (Cp/Cv) ==> Assumed = 1.4");
    params.addRequiredCoupledVar("macroscale_diameter","Name of the macrocale column diameter variable (m)");
    params.addRequiredCoupledVar("porosity","Name of the bulk porosity variable");
    return params;
}

GasEffectiveThermalConductivity::GasEffectiveThermalConductivity(const InputParameters & parameters) :
GasPropertiesBase(parameters),
_Cp_Cv_ratio(getParam< Real >("heat_cap_ratio")),
_column_dia(coupledValue("macroscale_diameter")),
_column_dia_var(coupled("macroscale_diameter")),
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

Real GasEffectiveThermalConductivity::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    Real Cv = _egret_dat.total_specific_heat*1000.0/_Cp_Cv_ratio;
    Real mu = _egret_dat.total_dyn_vis/1000.0*100.0;
    Real f = 0.25*(9.0*_Cp_Cv_ratio - 5.0);
    Real Kg = f*mu*Cv;
    Real Pr = (_egret_dat.total_dyn_vis/1000.0*100.0)*(_egret_dat.total_specific_heat*1000.0)/Kg;
    Real Re = ReNum(_egret_dat.velocity*_porosity[_qp],_column_dia[_qp]*100.0,_egret_dat.kinematic_viscosity);
    Real first = (0.73*_porosity[_qp])/Re/Pr;
    Real second = (0.5 / (1.0 + ((9.7*_porosity[_qp])/Re/Pr)) );
    Real Pe = (1.0 / (first+second) )*10.0;
    Real vel = _egret_dat.velocity/100.0;
    Real den = _egret_dat.total_density/1000.0*100.0*100.0*100.0;
    Real h = (_egret_dat.total_specific_heat*1000.0);
    
    return _column_dia[_qp]*vel*_porosity[_qp]*den*h/Pe;
}

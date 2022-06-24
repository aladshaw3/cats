/*!
 *  \file GasPropertiesBase.h
 *    \brief AuxKernel kernel to compute store information associated with calculation of gas properties
 *    \details This file is responsible for calculating storing and calculating a number of gas
 *              properties that will be used by other auxkernels that inherit from this base kernel.
 *
 *
 *  \author Austin Ladshaw
 *  \date 04/20/2020
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

#include "GasPropertiesBase.h"

registerMooseObject("catsApp", GasPropertiesBase);

InputParameters GasPropertiesBase::validParams()
{
    InputParameters params = AuxKernel::validParams();
    params.addRequiredCoupledVar("gases","List of names of the gas species variables (mol/m^3)");
    params.addRequiredCoupledVar("pressure","Pressure variable for the domain (Pa)");
    params.addRequiredCoupledVar("temperature","Temperature variable for the domain (K)");
    params.addRequiredCoupledVar("ux","Variable for velocity in x-direction (m/s)");
    params.addRequiredCoupledVar("uy","Variable for velocity in y-direction (m/s)");
    params.addRequiredCoupledVar("uz","Variable for velocity in z-direction (m/s)");
    params.addRequiredCoupledVar("hydraulic_diameter","Name of the hydraulic diameter variable (m)");

    params.addParam< std::vector<Real> >("molar_weights","List of molecular weights (g/mol)");
    params.addParam< std::vector<Real> >("sutherland_temp","List of Sutherland's reference temperatures (K)");
    params.addParam< std::vector<Real> >("sutherland_const","List of Sutherland's constants (K)");
    params.addParam< std::vector<Real> >("sutherland_vis","List of Sutherland's reference viscosities (g/cm/s)");
    params.addParam< std::vector<Real> >("spec_heat","List of specific heats (J/g/K)");

    params.addCoupledVar("carrier_gas",0,"Concentration for the carrier gas (mol/m^3)");
    params.addParam< Real >("carrier_gas_mw",0,"Molecular weight for the carrier gas (g/mol)");
    params.addParam< bool >("is_ideal_gas",true,"If true, then densities used for kinetic theory and pressure drop are calculated from given pressure assuming ideal gas law. If false, densities are calculated solely from the given gas concentrations.");
    return params;
}

GasPropertiesBase::GasPropertiesBase(const InputParameters & parameters) :
AuxKernel(parameters),
_press(coupledValue("pressure")),
_temp(coupledValue("temperature")),
_velx(coupledValue("ux")),
_vely(coupledValue("uy")),
_velz(coupledValue("uz")),
_char_len(coupledValue("hydraulic_diameter")),

_MW(getParam<std::vector<Real> >("molar_weights")),
_SuthTemp(getParam<std::vector<Real> >("sutherland_temp")),
_SuthConst(getParam<std::vector<Real> >("sutherland_const")),
_SuthVis(getParam<std::vector<Real> >("sutherland_vis")),
_SpecHeat(getParam<std::vector<Real> >("spec_heat")),

_carrier_gas(coupledValue("carrier_gas")),
_MW_cg(getParam< Real >("carrier_gas_mw")),
_is_ideal_gas(getParam< bool >("is_ideal_gas"))
{
    unsigned int n = coupledComponents("gases");
    _gases.resize(n);

    for (unsigned int i = 0; i<_gases.size(); ++i)
    {
        _gases[i] = &coupledValue("gases",i);
    }

    if (_MW.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and molecular weights!");
    }
    if (_SuthTemp.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and Sutherland's values!");
    }
    if (_SuthConst.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and Sutherland's values!");
    }
    if (_SuthVis.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and Sutherland's values!");
    }
    if (_SpecHeat.size() != _gases.size())
    {
        moose::internal::mooseErrorRaw("Must have same number of gas species and specific heats!");
    }
}

void GasPropertiesBase::prepareEgret()
{
    int success = 0;
    _total_conc = 0.0;
    // For the ideal gas, we do NOT use any carrier gas information (it is not needed)
    if (_is_ideal_gas == true)
    {
        _egret_dat.CheckMolefractions = false;
        std::vector<Real> partials;
        partials.resize(_gases.size());
        Real total = 0.0;
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                partials[i] = Pstd((*_gases[i])[_qp],_temp[_qp]);
            }
            else
            {
                partials[i] = 0.0;
            }
            total += partials[i];
        }
        if (_carrier_gas[_qp] > 0)
            total += Pstd(_carrier_gas[_qp],_temp[_qp]);

        // Do not add "carrier" gas
        if (total >= _press[_qp])
        {
            _mole_frac.resize(_gases.size());
            success = initialize_data(_gases.size(), &_egret_dat);
            if (success != 0)
            {
                moose::internal::mooseErrorRaw("Egret has encountered an error!");
            }

            Real total_moles = 0.0;
            for (unsigned int i = 0; i<_gases.size(); ++i)
            {
                if ((*_gases[i])[_qp] > 0.0)
                {
                    total_moles += (*_gases[i])[_qp];
                }
            }

            for (unsigned int i = 0; i<_gases.size(); ++i)
            {
                if ((*_gases[i])[_qp] > 0.0)
                {
                    _mole_frac[i] = (*_gases[i])[_qp]/total_moles;
                }

                _egret_dat.species_dat[i].molecular_weight = _MW[i];
                _egret_dat.species_dat[i].Sutherland_Viscosity = _SuthVis[i];
                _egret_dat.species_dat[i].Sutherland_Temp = _SuthTemp[i];
                _egret_dat.species_dat[i].Sutherland_Const = _SuthConst[i];
                _egret_dat.species_dat[i].specific_heat = _SpecHeat[i];
            }
        }
        // Add a "carrier" gas
        else
        {
            _mole_frac.resize(_gases.size()+1);
            success = initialize_data(_gases.size()+1, &_egret_dat);
            if (success != 0)
            {
                moose::internal::mooseErrorRaw("Egret has encountered an error!");
            }
            Real carrier_press = _press[_qp] - total;

            for (unsigned int i = 0; i<_gases.size(); ++i)
            {
                if ((*_gases[i])[_qp] > 0.0)
                {
                    _mole_frac[i] = Pstd((*_gases[i])[_qp],_temp[_qp])/_press[_qp];
                }
                _egret_dat.species_dat[i].molecular_weight = _MW[i];
                _egret_dat.species_dat[i].Sutherland_Viscosity = _SuthVis[i];
                _egret_dat.species_dat[i].Sutherland_Temp = _SuthTemp[i];
                _egret_dat.species_dat[i].Sutherland_Const = _SuthConst[i];
                _egret_dat.species_dat[i].specific_heat = _SpecHeat[i];
            }
            _mole_frac[_gases.size()] = carrier_press/_press[_qp];
            _egret_dat.species_dat[_gases.size()].molecular_weight = 28.85;
            _egret_dat.species_dat[_gases.size()].Sutherland_Viscosity = 0.0001827;
            _egret_dat.species_dat[_gases.size()].Sutherland_Temp = 291.17;
            _egret_dat.species_dat[_gases.size()].Sutherland_Const = 120.0;
            _egret_dat.species_dat[_gases.size()].specific_heat = 1.015;
        }
    }
    // If the gas is NOT ideal, then we never use ideal gas law to resolve densities
    //      and as a result we may require a carrier gas...
    //
    // NOTE: The carrier gas should NOT be one of the given gas species!
    //          (TO DO): Add a check to make sure it isn't...
    else
    {
        _egret_dat.CheckMolefractions = false;
        _mole_frac.resize(_gases.size()+1);
        Real total = 0.0;
        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                total+=(*_gases[i])[_qp];
            }
        }
        if (_carrier_gas[_qp] > 0)
            total+=_carrier_gas[_qp];

        _total_conc = total;

        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            if ((*_gases[i])[_qp] > 0.0)
            {
                _mole_frac[i] = (*_gases[i])[_qp]/total;
            }
            else
            {
                _mole_frac[i] = 1e-6;
            }
        }
        if (_carrier_gas[_qp] > 0)
        {
            _mole_frac[_gases.size()] = _carrier_gas[_qp]/total;
        }
        else
        {
            _mole_frac[_gases.size()] = 1e-6;
        }

        success = initialize_data(_gases.size()+1, &_egret_dat);
        if (success != 0)
        {
            moose::internal::mooseErrorRaw("Egret has encountered an error!");
        }

        for (unsigned int i = 0; i<_gases.size(); ++i)
        {
            _egret_dat.species_dat[i].molecular_weight = _MW[i];
            _egret_dat.species_dat[i].Sutherland_Viscosity = _SuthVis[i];
            _egret_dat.species_dat[i].Sutherland_Temp = _SuthTemp[i];
            _egret_dat.species_dat[i].Sutherland_Const = _SuthConst[i];
            _egret_dat.species_dat[i].specific_heat = _SpecHeat[i];
        }
        _egret_dat.species_dat[_gases.size()].molecular_weight = _MW_cg;
        _egret_dat.species_dat[_gases.size()].Sutherland_Viscosity = 0.0001827;
        _egret_dat.species_dat[_gases.size()].Sutherland_Temp = 291.17;
        _egret_dat.species_dat[_gases.size()].Sutherland_Const = 120.0;
        _egret_dat.species_dat[_gases.size()].specific_heat = 1.015;
    }
}

void GasPropertiesBase::calculateAllProperties()
{
    // Egret expects the following units on input
    //      P (kPa)
    //      T (K)
    //      vel (cm/s)
    //      dh (cm)
    //      CT (mol/L)
    Real vel_mag = sqrt(_velx[_qp]*_velx[_qp] + _vely[_qp]*_vely[_qp] + _velz[_qp]*_velz[_qp]);
    if (vel_mag <= 1.0E-8)
        vel_mag = 1.0E-8;

    int success = set_variables(_press[_qp]/1000.0, _temp[_qp], vel_mag*100.0, _char_len[_qp]*100.0, _mole_frac, &_egret_dat);
    if (success != 0)
    {
        moose::internal::mooseErrorRaw("Egret has encountered an error!");
    }
    success = calculate_properties(&_egret_dat, _is_ideal_gas, _total_conc/1000.0);
    if (success != 0)
    {
        moose::internal::mooseErrorRaw("Egret has encountered an error!");
    }
}

Real GasPropertiesBase::computeValue()
{
    prepareEgret();
    calculateAllProperties();
    // return for testing purposes only
    return _egret_dat.total_dyn_vis/1000.0*100.0;
}

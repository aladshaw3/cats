/*!
 *  \file SimpleFluidPropertiesBase.h
 *    \brief AuxKernel kernel base to aid in simple fluid properties calculations
 *    \details This file is responsible for setting up and storing information
 *              associated with the simplified calculation of system properties.
 *              Calculations here are based mostly off of emperical relationships
 *              in literature and correlations with common data associated with
 *              fluids. By default, the calculations focus on properties of water
 *              and brine or electrolyte solutions where water is the primary
 *              solvent in the system. However, the methods are generic enough
 *              to apply to other fluids as long as you have the right coefficients.
 *
 *    \note These calculations should be good between 0 to 350 oC
 *
 *              Viscosity Calculations:
 *              -----------------------
 *              [1] D.S. Viswananth, G. Natarajan. Data Book on the Viscosity of
 *                  Liquids. Hemisphere Publishing Corp. (1989)
 *              [2] D.S. Viswananth, S. Dabir, et al. Viscosity of Liquids: Theory,
 *                  Estimation, Experiment, and Data. Springer. (2007)
 *
 *              Density and Diffusivity Calculations:
 *              ------------------------------------
 *              [1] Engineering Toolbox. Water - Density, Specific Weight, and
 *                  Thermal Expansion Coefficients. (2003) https://www.engineeringtoolbox.com/
 *                  water-density-specific-weight-d_595.html [Accessed 13-12-2021]
 *              [2] A.J. Easteal, W.E. Price, L.A. Woolf. Diaphragm cell for high-temperature
 *                  diffusion measurements. J. Chem. Soc.: Faraday Trans. 85 (1989) 1091-1097.
 *
 *              Dispersion Calculations:
 *              ------------------------
 *              [1] A. Freeze and J. Cherry. Groundwater. Prentice-Hall, NJ. (1979). Ch. 9.
 *
 *
 *  \author Austin Ladshaw
 *  \date 12/13/2021
 *	\copyright This kernel was designed and built at Oak Ridge National
 *              Laboratory by Austin Ladshaw for research in electrochemical
 *              CO2 conversion.
 *
 *               Austin Ladshaw does not claim any ownership or copyright to the
 *               MOOSE framework in which these kernels are constructed, only
 *               the kernels themselves. The MOOSE framework copyright is held
 *               by the Battelle Energy Alliance, LLC (c) 2010, all rights reserved.
 */

#pragma once

#include "AuxKernel.h"

/// SimpleFluidPropertiesBase class object inherits from Kernel object
class SimpleFluidPropertiesBase : public AuxKernel
{
public:
  /// Required new syntax for InputParameters
  static InputParameters validParams();

  /// Required constructor for objects in MOOSE
  SimpleFluidPropertiesBase(const InputParameters & parameters);

protected:
  /// Helper function for errors
  void unsupported_conversion(std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real length_conversion(Real value, std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real time_conversion(Real value, std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real mass_conversion(Real value, std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real energy_conversion(Real value, std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real pressure_conversion(Real value, std::string from, std::string to);

  /// Helper function to formulate a conversion
  Real volume_conversion(Real value, std::string from, std::string to);

  // -------------------- List of Default Calculation Methods -------------------
  /// Calculation of base fluid viscosity
  Real fluid_viscosity(Real temperature);

  /// Calculation of fluid viscosity corrected for ionic strength
  Real fluid_viscosity_with_ionic_strength_correction(Real temperature, Real ionic_strength);

  /// Calculation of fluid density
  Real fluid_density(Real temperature, Real pressure);

  /// Calculation of molecular diffusion
  Real molecular_diffusion(Real temperature);

  /// Calculation of effective molecular diffusion (includes porosity adjustment)
  Real effective_molecular_diffusion(Real temperature, Real porosity);

  /// Calculation of dispersion
  Real dispersion(Real temperature);

  /// Calculation of effective dispersion (includes porosity adjustment)
  Real effective_dispersion(Real temperature, Real porosity);

  /// Calculation of the magnitude of velocity
  Real velocity_magnitude(Real ux, Real uy, Real uz);

  /// Calculation of the Reynolds numnber
  Real reynolds_number();

  /// Calculation of the Schmidt numnber
  Real schmidt_number();

  /// Required MOOSE function override
  virtual Real computeValue() override;

  /// NOTE: This aux system is under development. List of members likely to change
  const VariableValue & _pressure; ///< Variable for the pressure (kPa, Pa, mPa)
  std::string _pressure_unit;      ///< Units of the pressure variable (kPa, Pa, mPa)
  bool _use_pressure_unit; ///< Boolean that tells whether or not we use the above pressure unit
  std::string _pressure_mass_unit;    ///< Units of the mass term in pressure (kg, g, mg)
  std::string _pressure_length_unit;  ///< Units of the length term in pressure (m, cm, mm)
  std::string _pressure_time_unit;    ///< Units of the time term in pressure (hr, min, s)
  const VariableValue & _temperature; ///< Variable for the temperature (K)
  const VariableValue & _macro_pore;  ///< Variable for the macro porosity
  const VariableValue &
      _vel_x; ///< Variable for the linear velocity in x (m, cm, mm) & (hr, min, s)
  const VariableValue &
      _vel_y; ///< Variable for the linear velocity in y (m, cm, mm) & (hr, min, s)
  const VariableValue &
      _vel_z; ///< Variable for the linear velocity in z (m, cm, mm) & (hr, min, s)
  std::string _velocity_length_unit; ///< Units of the length term in velocity (m, cm, mm)
  std::string _velocity_time_unit;   ///< Units of the time term in velocity (hr, min, s)

  const VariableValue & _char_len; ///< Variable for the characteristic length
  std::string _char_len_unit;      ///< Units of characteristic length (m, cm, mm)

  Real _ref_diffusivity;         ///< Value of reference diffusivity
  std::string _diff_length_unit; ///< Units of the length term in reference diffusivity (m, cm, mm)
  std::string _diff_time_unit;   ///< Units of the time term in reference diffusivity (hr, min, s)
  Real _ref_diff_temp;           ///< Value of reference temperature for diffusivity (K)
  Real
      _eff_diff_factor; ///< Factor for porosity to calculate effective diffusivity (default=1.5) [1,2]

  Real _dispersivity;            ///< Value of dispersivity of the porous media
  std::string _disp_length_unit; ///< Units of the length term in dispersivity param (m, cm, mm)

  Real _mu_pre_exp; ///< Pre-exponential factor for viscosity calculation [Units: Pressure * Time]
  std::string
      _mu_pressure_unit; ///< Units of the pressure term in the pre-exponential viscosity term (kPa, Pa, mPa)
  std::string
      _mu_time_unit; ///< Units of the time term in the pre-exponential viscosity term (hr, min, s)
  Real _mu_B;        ///< Value of the B term in the viscosity function (K)
  Real _mu_C;        ///< Value of the C term in the viscosity function (K)

  const VariableValue &
      _ionic_strength; ///< Variable for the ionic strength of fluid [Units: moles / volume]
  std::string
      _ion_volume_unit; ///< Units of the volume in the ionic strength variable (L, m^3 (or kL), cm^3 (or mL))

  Real _mu_I_A; ///< Correction factor A for viscosity as a function of ionic strength (L/mol)^0.5
  Real _mu_I_B; ///< Correction factor B for viscosity as a function of ionic strength (L/mol)^1
  Real _mu_I_C; ///< Correction factor C for viscosity as a function of ionic strength (L/mol)^2

  Real _rho_A;                ///< Square term in the density polynomial (K)^-2
  Real _rho_B;                ///< Linear term in the density polynomial (K)^-1
  Real _rho_C;                ///< Constant term in the density polynomial (-)
  Real _rho_ref;              ///< Value of the reference fluid density (near 0 oC)
  std::string _rho_mass_unit; ///< Units of the mass in the density reference variable (kg, g, mg)
  std::string
      _rho_volume_unit; ///< Units of the volume in the density reference variable (L, m^3 (of kL), cm^3 (or mL))

private:
};

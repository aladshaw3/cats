/*!
 *  \file egret.h egret.cpp
 *	\brief Estimation of Gas-phase pRopErTies
 *	\details This file is responsible for estimating various temperature, pressure, and concentration
 *		dependent parameters to be used in other models for gas phase adsorption, mass transfer,
 *		and or mass transport. The goal of this file is to eliminate redundancies in code such
 *		that the higher level programs operate more efficiently and cleanly. Calculations made
 *		here are based on kinetic theory of gases, ideal gas law, and some emperical models that
 *		were developed to account for changes in density and viscosity with changes in temperature
 *		between standard temperatures and up to 1000 K.
 
 *  \author Austin Ladshaw
 *	\date 01/29/2015
 *	\copyright This software was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science. Copyright (c) 2015, all
 *             rights reserved.
 */

#include "macaw.h"

#ifndef EGRET_HPP_
#define EGRET_HPP_

#ifndef Rstd
#define Rstd 8.3144621						///< Gas Constant in J/K/mol (or) L*kPa/K/mol (Standard Units)
#endif

#ifndef RE3
#define RE3 8.3144621E+3					///< Gas Constant in cm^3*kPa/K/mol	(Convenient for density calculations)
#endif

#ifndef Po
#define Po 100.0							///< Standard state pressure (kPa)
#endif

#ifndef Cstd
#define Cstd(p,T) ((p)/(Rstd*T))			///< Calculation of concentration/density from partial pressure (Cstd = mol/L)
#endif										// Note: can also be used to calculate densities if p = PT * MW

#ifndef CE3
#define CE3(p,T) ((p)/(RE3*T))				///< Calculation of concentration/density from partial pressure (CE3 = mol/cm^3)
#endif										// Note: can also be used to calculate densities if p = PT * MW

#ifndef Pstd
#define Pstd(c,T) ((c)*Rstd*T)				///< Calculation of partial pressure from concentration/density (c = mol/L)
#endif

#ifndef PE3
#define PE3(c,T) ((c)*RE3*T)				///< Calculation of partial pressure from concentration/density (c = mol/cm^3)
#endif

#ifndef Nu
#define Nu(mu,rho) ((mu)/(rho))				///< Calculation of kinematic viscosity from dynamic viscosity and density (cm^2/s)
#endif

#ifndef PSI
#define PSI(T) (0.873143 + (0.000072375*T)) ///< Calculation of temperature correction factor for dynamic viscosity
#endif

#ifndef Dp_ij
#define Dp_ij(Dij,PT) ((PT*Dij)/Po)			///< Calculation of the corrected binary diffusivity (cm^2/s)
#endif

#ifndef D_ij
#define D_ij(MWi,MWj,rhoi,rhoj,mui,muj) ( (4.0 / sqrt(2.0)) * pow(((1/MWi)+(1/MWj)),0.5) ) / pow( (pow((pow((rhoi/(1.385*mui)),2.0)/MWi),0.25)+ pow((pow((rhoj/(1.385*muj)),2.0)/MWj),0.25)),2.0 ) ///< Calculation of binary diffusion based on MW, density, and viscosity info (cm^2/s)
#endif

#ifndef Mu
#define Mu(muo,To,C,T) (muo * ((To + C)/(T + C)) * pow((T/To),1.5) ) ///< Calculation of single species viscosity from Sutherland's Equ. (g/cm/s)
#endif

#ifndef D_ii
#define D_ii(rhoi,mui) (1.385*mui/rhoi)		///< Calculation of self-diffusivity (cm^2/s)
#endif

#ifndef ReNum
#define ReNum(u,L,nu) (u*L/nu)				///< Calculation of the Reynold's Number (-)
#endif

#ifndef ScNum
#define ScNum(nu,D) (nu/D)					///< Calculation of the Schmidt Number (-)
#endif

#ifndef FilmMTCoeff
#define FilmMTCoeff(D,L,Re,Sc) ((D/L)*(2.0 + (1.1*pow(Re,0.6)*pow(Sc,0.3)))) ///< Calculation of film mass transfer coefficient (cm/s)
#endif

/// Data structure holding all the parameters for each pure gas spieces
/** C-style object that holds the constants and parameters associated with each pure
	gas species in the overall mixture. This information is used in conjunction with 
	the kinetic theory of gases to produce approximations to many different gas properties
	needed in simulating gas dynamics, mobility of a gas through porous media, as well
	as some kinetic adsorption parameters such as diffusivities. */
typedef struct
{	
	//Constants
	double molecular_weight;				///< Given: molecular weights (g/mol)
	double Sutherland_Temp;					///< Given: Sutherland's Reference Temperature (K)
	double Sutherland_Const;				///< Given: Sutherland's Constant (K)
	double Sutherland_Viscosity;			///< Given: Sutherland's Reference Viscosity (g/cm/s)
	double specific_heat;					///< Given: Specific heat of the gas (J/g/K)
	
	//Parameters
	double molecular_diffusion;				///< Calculated: molecular diffusivities (cm^2/s)
	double dynamic_viscosity;				///< Calculated: dynamic viscosities (g/cm/s)
	double density;							///< Calculated: gas densities (g/cm^3) {use RE3}
	double Schmidt;							///< Calculated: Value of the Schmidt number (-)
		
}PURE_GAS;

/// Data structure holding information necessary for computing mixed gas properties
/** C-style object holding the mixed gas information necessary for performing gas dynamic
	simulations. This object works in conjunction with the calculate_variables function
	and uses the kinetic theory of gases to estimate mixed gas properties. */
typedef struct
{
	//Constants
	int N;									///< Given: Total number of gas species
	bool CheckMolefractions = true;			///< Given: True = Check Molefractions for errors
	
	//Variables
	double total_pressure;					///< Given: Total gas pressure (kPa)
	double gas_temperature;					///< Given: Gas temperature (K)
	double velocity;						///< Given: Gas phase velocity (cm/s)
	double char_length;						///< Given: Characteristic Length (cm)
	std::vector<double> molefraction;		///< Given: Gas molefractions of each species (-)
	
	//Parameters
	double total_density;					///< Calculated: Total gas density (g/cm^3) {use RE3}
	double total_dyn_vis;					///< Calculated: Total dynamic viscosity (g/cm/s)
	double kinematic_viscosity;				///< Calculated: Kinematic viscosity (cm^2/s)
	double total_molecular_weight;			///< Calculated: Total molecular weight (g/mol)
	double total_specific_heat;				///< Calculated: Total specific heat (J/g/K)
	double Reynolds;						///< Calculated: Value of the Reynold's number	(-)
	MATRIX<double> binary_diffusion;		///< Calculated: Tensor matrix of binary gas diffusivities (cm^2/s)
	
	//All Species Info
	std::vector<PURE_GAS> species_dat;		///< Vector of the pure gas info of all specie
	
}MIXED_GAS;

/// Function to initialize the MIXED_GAS structure based on number of gas species
/** This function will initialize the sizes of all vector objects in the MIXED_GAS structure
	based on the number of gas species indicated by N.*/
int initialize_data(int N, MIXED_GAS *gas_dat);

/// Function to set the values of the parameters in the gas phase
/** The gas phase properties are a function of total pressure, gas temperature, gas velocity,
	characteristic length, and the mole fractions of each species in the gas phase. Prior to
	calculating the gas phase properties, these parameters must be set and updated as they 
	change.
 
	\param PT total gas pressure in kPa
	\param T gas temperature in K
	\param us gas velocity in cm/s
	\param L characteristic length in cm (this depends on the particular system)
	\param y vector of gas mole fractions of each species in the mixture
	\param gas_dat pointer to the MIXED_GAS data structure*/
int set_variables(double PT, double T, double us, double L, std::vector<double> &y, MIXED_GAS *gas_dat);

/// Function to calculate the gas properties based on information in MIXED_GAS
/** This function uses the kinetic theory of gases, combined with other semi-empirical models,
	to predict and approximate several properties of the mixed gas phase that might be necessary
	when running any gas dynamical simulation. This includes mass and energy transfer equations,
	as well as adsorption kinetics in porous adsorbents. */
int calculate_properties(MIXED_GAS *gas_dat, bool is_ideal_gas, double CT);

/// Function runs a series of tests for the EGRET file
/** The test looks at a standard air with 5 primary species of interest and calculates
	the gas properties from 273 K to 373 K. This function can be called from the UI. */
int EGRET_TESTS();

#endif

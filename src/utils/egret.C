/*!
 *  \file egret.cpp egret.h
 *	\brief Estimation of Gas-phase pRopErTies
 *  \author Austin Ladshaw
 *	\date 01/29/2015
 *	\copyright This software was designed and built at the Georgia Institute
 *             of Technology by Austin Ladshaw for PhD research in the area
 *             of adsorption and surface science. Copyright (c) 2015, all
 *             rights reserved.
 */

#include "egret.h"

//Function to initialize the memory for gas data
int initialize_data(int N, MIXED_GAS *gas_dat)
{
	int success = 0;
	if (N <= 0)
	{
		mError(invalid_components);
		return -1;
	}
	gas_dat->N = N;
	gas_dat->species_dat.resize(N);
	gas_dat->binary_diffusion.set_size(N, N);
	gas_dat->molefraction.resize(N);
	return success;
}

//Function to set values of variables used in calculations
int set_variables(double PT, double T, double us, double L, std::vector<double> &y, MIXED_GAS *gas_dat)
{
	int success = 0;
	gas_dat->total_pressure = PT;
	gas_dat->gas_temperature = T;
	gas_dat->velocity = fabs(us);
	gas_dat->char_length = L;
	if (gas_dat->molefraction.size() != y.size())
		gas_dat->molefraction.resize(y.size());
	double ysum = 0.0;
	for (int i=0; i<y.size(); i++)
	{
		ysum = ysum + y[i];
		gas_dat->molefraction[i] = y[i];
		if (y[i] < -1.0E-6 && gas_dat->CheckMolefractions == true)
		{
			mError(invalid_molefraction);
			return -1;
		}
	}
	if ( (ysum > (1.0 + 1.0E-6) || ysum < (1.0 - 1.0E-6) ) && gas_dat->CheckMolefractions == true)
	{
		mError(invalid_gas_sum);
		return -1;
	}
	return success;
}

//Function to calculate the properties of the gas phase
int calculate_properties(MIXED_GAS *gas_dat, bool is_ideal_gas, double CT)
{
	int success = 0;
	
    // Calculation for ideal gas law
    if (is_ideal_gas == true)
    {
        gas_dat->total_dyn_vis = 0.0;
        gas_dat->total_molecular_weight = 0.0;
        gas_dat->total_specific_heat = 0.0;
        
        //Check to see if there is only one gas species and quit early if so
        if (gas_dat->N <= 0)
        {
            mError(invalid_components);
            return -1;
        }
        else if (gas_dat->N == 1)
        {
            gas_dat->species_dat[0].density =  CE3(gas_dat->total_pressure*gas_dat->species_dat[0].molecular_weight,gas_dat->gas_temperature);
            gas_dat->species_dat[0].dynamic_viscosity = Mu(gas_dat->species_dat[0].Sutherland_Viscosity, gas_dat->species_dat[0].Sutherland_Temp, gas_dat->species_dat[0].Sutherland_Const, gas_dat->gas_temperature);
            gas_dat->binary_diffusion.edit(0, 0, D_ii(gas_dat->species_dat[0].density, gas_dat->species_dat[0].dynamic_viscosity));
            gas_dat->total_molecular_weight = gas_dat->species_dat[0].molecular_weight;
            gas_dat->total_specific_heat = gas_dat->species_dat[0].specific_heat;
            gas_dat->total_density = gas_dat->species_dat[0].density;
            gas_dat->species_dat[0].molecular_diffusion = gas_dat->binary_diffusion(0,0);
            gas_dat->total_dyn_vis = gas_dat->species_dat[0].dynamic_viscosity;
            gas_dat->kinematic_viscosity = Nu(gas_dat->total_dyn_vis,gas_dat->total_density);
            gas_dat->Reynolds = ReNum(gas_dat->velocity, gas_dat->char_length, gas_dat->kinematic_viscosity);
            gas_dat->species_dat[0].Schmidt = ScNum(gas_dat->kinematic_viscosity, gas_dat->species_dat[0].molecular_diffusion);
        }
        else
        {
            //Loop for all gas species to establish densities and viscosities
            for (int i=0; i<gas_dat->N; i++)
            {
                gas_dat->species_dat[i].density = CE3(gas_dat->total_pressure*gas_dat->species_dat[i].molecular_weight,gas_dat->gas_temperature);
                gas_dat->species_dat[i].dynamic_viscosity = Mu(gas_dat->species_dat[i].Sutherland_Viscosity, gas_dat->species_dat[i].Sutherland_Temp, gas_dat->species_dat[i].Sutherland_Const, gas_dat->gas_temperature);
            
                //Inner Loop for Binary Diffusion Tensor
                for (int j=0; j<=i; j++)
                {
                    gas_dat->binary_diffusion.edit(i,j,1.0);
                    if (j==i)
                        gas_dat->binary_diffusion.edit(i,j,D_ii(gas_dat->species_dat[i].density, gas_dat->species_dat[i].dynamic_viscosity));
                    else
                    {
                        //Calculate upper triangular portion
                        gas_dat->binary_diffusion.edit(i, j, D_ij(gas_dat->species_dat[i].molecular_weight, gas_dat->species_dat[j].molecular_weight, gas_dat->species_dat[i].density, gas_dat->species_dat[j].density, gas_dat->species_dat[i].dynamic_viscosity, gas_dat->species_dat[j].dynamic_viscosity));
                    
                        //Enforce symmetry of the matrix
                        gas_dat->binary_diffusion.edit(j, i, gas_dat->binary_diffusion(i,j));
                    
                    }
                }
            
                //Additive Properties
                gas_dat->total_molecular_weight = gas_dat->total_molecular_weight + (gas_dat->molefraction[i]*gas_dat->species_dat[i].molecular_weight);
                gas_dat->total_specific_heat = gas_dat->total_specific_heat + (gas_dat->molefraction[i]*gas_dat->species_dat[i].specific_heat);

            }
        
            //Calculate total density
            gas_dat->total_density = CE3(gas_dat->total_pressure*gas_dat->total_molecular_weight, gas_dat->gas_temperature);
        
            //Secondary loop to evaluate the total dynamic viscosity and molecular diffusion
            for (int i=0; i<gas_dat->N; i++)
            {
                double muT_sum = 0.0;
                double Dm_sum = 0.0;
                for (int j=0; j<gas_dat->N; j++)
                {
                    if (j!=i)
                    {
                        //Evaluate summation terms
                        Dm_sum = Dm_sum + (gas_dat->molefraction[j]/gas_dat->binary_diffusion(i,j));
                        muT_sum = muT_sum + (gas_dat->molefraction[j]/Dp_ij(gas_dat->binary_diffusion(i,j),gas_dat->total_pressure));
                    }
                }
                if (Dm_sum < 1e-8 || gas_dat->molefraction[i] >= 1.0)
                    gas_dat->species_dat[i].molecular_diffusion = gas_dat->binary_diffusion(i,i);
                else
                    gas_dat->species_dat[i].molecular_diffusion = (1.0 - gas_dat->molefraction[i]) / Dm_sum;
                if (gas_dat->molefraction[i] != 0.0)
                    gas_dat->total_dyn_vis = gas_dat->total_dyn_vis + (gas_dat->species_dat[i].dynamic_viscosity/(1.0+((113.65*PSI(gas_dat->gas_temperature)*gas_dat->species_dat[i].dynamic_viscosity*gas_dat->gas_temperature)/(gas_dat->molefraction[i]*gas_dat->species_dat[i].molecular_weight))*muT_sum));
            }
        
            //Calculate remaining properties
            gas_dat->kinematic_viscosity = Nu(gas_dat->total_dyn_vis,gas_dat->total_density);
            gas_dat->Reynolds = ReNum(gas_dat->velocity, gas_dat->char_length, gas_dat->kinematic_viscosity);
            for (int i=0; i<gas_dat->N; i++)
                gas_dat->species_dat[i].Schmidt = ScNum(gas_dat->kinematic_viscosity, gas_dat->species_dat[i].molecular_diffusion);
        }
    }
    
    // Calculation for non-ideal gas law
    else
    {
        gas_dat->total_dyn_vis = 0.0;
        gas_dat->total_molecular_weight = 0.0;
        gas_dat->total_specific_heat = 0.0;
        
        //Check to see if there is only one gas species and quit early if so
        if (gas_dat->N <= 0)
        {
            mError(invalid_components);
            return -1;
        }
        else if (gas_dat->N == 1)
        {
            //-----------------------------------------------------------------
            //-----------------------------------------------------------------
            gas_dat->species_dat[0].density = gas_dat->species_dat[0].molecular_weight*CT/1000.0;
            gas_dat->species_dat[0].dynamic_viscosity = Mu(gas_dat->species_dat[0].Sutherland_Viscosity, gas_dat->species_dat[0].Sutherland_Temp, gas_dat->species_dat[0].Sutherland_Const, gas_dat->gas_temperature);
            gas_dat->binary_diffusion.edit(0, 0, D_ii(gas_dat->species_dat[0].density, gas_dat->species_dat[0].dynamic_viscosity));
            gas_dat->total_molecular_weight = gas_dat->species_dat[0].molecular_weight;
            gas_dat->total_specific_heat = gas_dat->species_dat[0].specific_heat;
            gas_dat->total_density = gas_dat->species_dat[0].density;
            gas_dat->species_dat[0].molecular_diffusion = gas_dat->binary_diffusion(0,0);
            gas_dat->total_dyn_vis = gas_dat->species_dat[0].dynamic_viscosity;
            gas_dat->kinematic_viscosity = Nu(gas_dat->total_dyn_vis,gas_dat->total_density);
            gas_dat->Reynolds = ReNum(gas_dat->velocity, gas_dat->char_length, gas_dat->kinematic_viscosity);
            gas_dat->species_dat[0].Schmidt = ScNum(gas_dat->kinematic_viscosity, gas_dat->species_dat[0].molecular_diffusion);
        }
        else
        {
            //Loop for all gas species to establish densities and viscosities
            for (int i=0; i<gas_dat->N; i++)
            {
                //-----------------------------------------------------------------
                //-----------------------------------------------------------------
                gas_dat->species_dat[i].density = gas_dat->molefraction[i]*gas_dat->species_dat[i].molecular_weight*CT/1000.0;
                gas_dat->species_dat[i].dynamic_viscosity = Mu(gas_dat->species_dat[i].Sutherland_Viscosity, gas_dat->species_dat[i].Sutherland_Temp, gas_dat->species_dat[i].Sutherland_Const, gas_dat->gas_temperature);
                            
                //Inner Loop for Binary Diffusion Tensor
                for (int j=0; j<=i; j++)
                {
                    gas_dat->binary_diffusion.edit(i,j,1.0);
                    if (j==i)
                        gas_dat->binary_diffusion.edit(i,j,D_ii(gas_dat->species_dat[i].density, gas_dat->species_dat[i].dynamic_viscosity));
                    else
                    {
                        //Calculate upper triangular portion
                        gas_dat->binary_diffusion.edit(i, j, D_ij(gas_dat->species_dat[i].molecular_weight, gas_dat->species_dat[j].molecular_weight, (gas_dat->species_dat[i].density), (gas_dat->species_dat[j].density), gas_dat->species_dat[i].dynamic_viscosity, gas_dat->species_dat[j].dynamic_viscosity));
                                                                     
                        //Enforce symmetry of the matrix
                        gas_dat->binary_diffusion.edit(j, i, gas_dat->binary_diffusion(i,j));
                                            
                    }
                    
                    if (isnan(gas_dat->binary_diffusion(i,j)) || isinf(gas_dat->binary_diffusion(i,j)) )
                    {
                        gas_dat->binary_diffusion.edit(i, j, 1);
                        gas_dat->binary_diffusion.edit(j, i, gas_dat->binary_diffusion(i,j));
                    }
                }
                            
                //Additive Properties
                gas_dat->total_molecular_weight = gas_dat->total_molecular_weight + (gas_dat->molefraction[i]*gas_dat->species_dat[i].molecular_weight);
                gas_dat->total_specific_heat = gas_dat->total_specific_heat + (gas_dat->molefraction[i]*gas_dat->species_dat[i].specific_heat);

            }
        
            //Calculate total density
            //-----------------------------------------------------------------
            //-----------------------------------------------------------------
            gas_dat->total_density = gas_dat->total_molecular_weight*CT/1000.0;
        
            //Secondary loop to evaluate the total dynamic viscosity and molecular diffusion
            for (int i=0; i<gas_dat->N; i++)
            {
                double muT_sum = 0.0;
                double Dm_sum = 0.0;
                for (int j=0; j<gas_dat->N; j++)
                {
                    if (j!=i)
                    {
                        //Evaluate summation terms
                        Dm_sum = Dm_sum + (gas_dat->molefraction[j]/gas_dat->binary_diffusion(i,j));
                        muT_sum = muT_sum + (gas_dat->molefraction[j]/Dp_ij(gas_dat->binary_diffusion(i,j),gas_dat->total_pressure));
                    }
                }
                if (Dm_sum < 1e-8 || gas_dat->molefraction[i] >= 1.0)
                    gas_dat->species_dat[i].molecular_diffusion = gas_dat->binary_diffusion(i,i);
                else
                    gas_dat->species_dat[i].molecular_diffusion = (1.0 - gas_dat->molefraction[i]) / Dm_sum;
                if (gas_dat->molefraction[i] != 0.0)
                    gas_dat->total_dyn_vis = gas_dat->total_dyn_vis + (gas_dat->species_dat[i].dynamic_viscosity/(1.0+((113.65*PSI(gas_dat->gas_temperature)*gas_dat->species_dat[i].dynamic_viscosity*gas_dat->gas_temperature)/(gas_dat->molefraction[i]*gas_dat->species_dat[i].molecular_weight))*muT_sum));
            }
        
            //Calculate remaining properties
            gas_dat->kinematic_viscosity = Nu(gas_dat->total_dyn_vis,gas_dat->total_density);
            gas_dat->Reynolds = ReNum(gas_dat->velocity, gas_dat->char_length, gas_dat->kinematic_viscosity);
            for (int i=0; i<gas_dat->N; i++)
                gas_dat->species_dat[i].Schmidt = ScNum(gas_dat->kinematic_viscosity, gas_dat->species_dat[i].molecular_diffusion);
        }
    }
	
	return success;
}

//Function to run the EGRET tests: Test Cases will be with N2 (0), O2 (1), and H2O (2)
int EGRET_TESTS()
{
	int success = 0;
	MIXED_GAS dat;
	double time = clock();
	success = initialize_data(5, &dat);
	if (success != 0) {mError(simulation_fail); return -1;}
	
	/*
	 		species 0 = N2
	 		species 1 = O2
	 		species 2 = Ar
	 		species 3 = CO2
	 		species 4 = H2O
	 */
	
	//Set the Constants
	dat.species_dat[0].molecular_weight = 28.016;
	dat.species_dat[1].molecular_weight = 32.0;
	dat.species_dat[2].molecular_weight = 39.948;
	dat.species_dat[3].molecular_weight = 44.009;
	dat.species_dat[4].molecular_weight = 18.0;
	
	dat.species_dat[0].Sutherland_Viscosity = 0.0001781;
	dat.species_dat[1].Sutherland_Viscosity = 0.0002018;
	dat.species_dat[2].Sutherland_Viscosity = 0.0002125;
	dat.species_dat[3].Sutherland_Viscosity = 0.000148;
	dat.species_dat[4].Sutherland_Viscosity = 0.0001043;
	
	dat.species_dat[0].Sutherland_Temp = 300.55;
	dat.species_dat[1].Sutherland_Temp = 292.25;
	dat.species_dat[2].Sutherland_Temp = 273.11;
	dat.species_dat[3].Sutherland_Temp = 293.15;
	dat.species_dat[4].Sutherland_Temp = 298.16;
	
	dat.species_dat[0].Sutherland_Const = 111.0;
	dat.species_dat[1].Sutherland_Const = 127.0;
	dat.species_dat[2].Sutherland_Const = 144.4;
	dat.species_dat[3].Sutherland_Const = 240.0;
	dat.species_dat[4].Sutherland_Const = 784.72;
	
	dat.species_dat[0].specific_heat = 1.04;
	dat.species_dat[1].specific_heat = 0.919;
	dat.species_dat[2].specific_heat = 0.522;
	dat.species_dat[3].specific_heat = 0.846;
	dat.species_dat[4].specific_heat = 1.97;
	
	//Set Variables
	double pellet_radius = 0.08;
	double gas_vel = 1.83;
	double porosity = 0.384;
	double macropore = 2.65E-6;
	std::vector<double> y;
	y.resize(dat.N);
	double T = 273.15;
	do
	{
		y[0] = 0.78084;
		y[1] = 0.209476;
		y[2] = 0.00934;
		y[3] = 0.000314;
		y[4] = 0.00003;
		success = set_variables(101.35, T, gas_vel, pellet_radius*2.0, y, &dat);
		if (success != 0) {mError(simulation_fail); return -1;}
		
		//Calculate Properties
		success = calculate_properties(&dat, true, 0);
		if (success != 0) {mError(simulation_fail); return -1;}
		
		std::cout << "-------------------------------------------\n";
		std::cout << "Temperature (K): " << dat.gas_temperature << std::endl;
		std::cout << "Pressure (kPa): " << dat.total_pressure << std::endl;
		std::cout << "Velocity (cm/s): " << dat.velocity << std::endl;
		std::cout << "Char.Length (cm): " << dat.char_length << std::endl;
		std::cout << "\n";
		dat.binary_diffusion.Display("Binary Diffusion Tensor (cm^2/s)");
		std::cout << "O2 Diffusivity (cm^2/s): " << dat.species_dat[1].molecular_diffusion << std::endl;
		std::cout << "O2 Schmidt Num: " << dat.species_dat[1].Schmidt << std::endl;
		std::cout << "Gas MW (g/mol): " << dat.total_molecular_weight << std::endl;
		std::cout << "Gas Density (g/cm^3): " << dat.total_density << std::endl;
		std::cout << "Gas Viscosity (g/cm/s): " << dat.total_dyn_vis << std::endl;
		std::cout << "Gas Kin. Vis. (cm^2/s): " << dat.kinematic_viscosity << std::endl;
		std::cout << "Gas Specific Heat (J/g/K): " << dat.total_specific_heat << std::endl;
		std::cout << "Reynolds Number: " << dat.Reynolds << std::endl;
		std::cout << "\nO2 Film Mass Transfer Coeff (cm/s): " << FilmMTCoeff(dat.species_dat[1].molecular_diffusion, dat.char_length, dat.Reynolds, dat.species_dat[1].Schmidt) << std::endl;
		double Dp = porosity*dat.species_dat[1].molecular_diffusion;
		double Dk = 9700.0*macropore*pow((T/dat.species_dat[1].molecular_weight),0.5);
		double avgDp = pow(((1/Dp)+(1/Dk)),-1.0);
		std::cout << "\nO2 Effective Pore Diff. (cm^2/s): " << avgDp << std::endl;
		
		std::cout << "\n";
		T+=50.0;
	} while (T <= 573.15);
	
	std::cout << "-------------------------------------------\n";
	time = clock() - time;
	std::cout << "Simulation Runtime: " << (time / CLOCKS_PER_SEC) << " seconds\n";

	return success;
}

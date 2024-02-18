//----------------------------------------
//  Created by Austin Ladshaw on 1/2/14
//  Copyright (c) 2014
//	Austin Ladshaw
//	All rights reserved
//----------------------------------------

/*
 * error.C
 *
 *      v1.0.0
 *
 *      0.0.1 - This class file will be expanded upon as need be for more specific error reporting
 * by all programs which are under development. Currently, serves to give only a generic error
 * message.
 *
 *      1.0.0 - Error messages are flagged by an integer. All current messages are those previously
 * defined within each class file.
 */

#include "error.h"

// Error message to be displayed when exceptions are caught or problems occur
void
error(int flag)
{
  switch (flag)
  {
    case file_dne:
      std::cout << "\nError!\n\nInput File does not exist!" << std::endl;
      break;

    case indexing_error:
      std::cout << "\nError!\n\nIndexing Mistake! Check input file for errors..." << std::endl;
      break;

    case magpie_reverse_error:
      std::cout << "\nError!\n\nNot used in reverse evaluations!" << std::endl;
      break;

    case simulation_fail:
      std::cout << "\nError!\n\nSimulation Failed!" << std::endl;
      break;

    case invalid_components:
      std::cout << "\nError!\n\nInvalid number of components!" << std::endl;
      break;

    case invalid_boolean:
      std::cout << "\nError!\n\nInvalid Boolean Selection!" << std::endl;
      break;

    case invalid_molefraction:
      std::cout << "\nError!\n\nInvalid Mole Fraction!" << std::endl;
      break;

    case invalid_gas_sum:
      std::cout << "\nError!\n\nInvalid Sum of Gas Mole Fractions!" << std::endl;
      break;

    case invalid_solid_sum:
      std::cout << "\nError!\n\nInvalid Sum of Solid Mole Fractions!" << std::endl;
      break;

    case scenario_fail:
      std::cout << "\nError!\n\nScenario simulation failed!" << std::endl;
      break;

    case out_of_bounds:
      std::cout << "\nError!\n\nIndex Out of Bounds of Matrix!" << std::endl;
      break;

    case non_square_matrix:
      std::cout << "\nError!\n\nNon-Square Matrix!" << std::endl;
      break;

    case dim_mis_match:
      std::cout << "\nError!\n\nDimesional Mis-Match for Matrices!" << std::endl;
      break;

    case empty_matrix:
      std::cout << "\nError!\n\nEmpty or Non-Initialized Matrix!" << std::endl;
      break;

    case opt_no_support:
      std::cout << "\nError!\n\nOption not currently supported..." << std::endl;
      break;

    case invalid_fraction:
      std::cout << "\nError!\n\nFractions should be between 0 and 1!" << std::endl;
      break;

    case ortho_check_fail:
      std::cout << "\nWarning!\n\nOrthogonallity Check Failed!" << std::endl;
      break;

    case unstable_matrix:
      std::cout << "\nWarning!\n\nInstability in Coefficient Matrix!" << std::endl;
      break;

    case no_diffusion:
      std::cout << "\nWarning!\n\nNothing to Simulate! No Diffusion Can Occur!" << std::endl;
      break;

    case negative_mass:
      std::cout << "\nWarning!\n\nNegative Mass Encountered!" << std::endl;
      break;

    case negative_time:
      std::cout << "\nError!\n\nNegative Time Encountered!" << std::endl;
      break;

    case matvec_mis_match:
      std::cout << "\nError!\n\nMatrix and Vector Sizes Do Not Match!" << std::endl;
      break;

    case arg_matrix_same:
      std::cout << "\nError!\n\nMatrix argument and storage matrix are the same!" << std::endl;
      break;

    case singular_matrix:
      std::cout << "\nWarning!\n\nMatrix is Singular or Close to Singular!" << std::endl;
      break;

    case matrix_too_small:
      std::cout << "\nError!\n\nMatrix is too small for this function!" << std::endl;
      break;

    case invalid_size:
      std::cout << "\nError!\n\nCan not build size 0 or smaller matrix!" << std::endl;
      break;

    case nullptr_func:
      std::cout << "\nError!\n\nGiven NULL pointer as function!" << std::endl;
      break;

    case invalid_norm:
      std::cout << "\nError!\n\nNorms must be non-negative scalars!" << std::endl;
      break;

    case vector_out_of_bounds:
      std::cout << "\nError!\n\nOut of Bounds of Real Vector!" << std::endl;
      break;

    case zero_vector:
      std::cout << "\nError!\n\nZero vector cannot be evaluated on!" << std::endl;
      break;

    case tensor_out_of_bounds:
      std::cout << "\nError!\n\nOut of Bounds of Real Tensor!" << std::endl;
      break;

    case non_real_edge:
      std::cout << "\nError!\n\nCannot construct edge from same two points!" << std::endl;
      break;

    case nullptr_error:
      std::cout << "\nError!\n\nNULL POINTER ERROR!!!" << std::endl;
      break;

    case invalid_atom:
      std::cout << "\nError!\n\nInvalid or Unsupported Atom!" << std::endl;
      break;

    case invalid_proton:
      std::cout << "\nError!\n\nInvalid number of protons!" << std::endl;
      break;

    case invalid_neutron:
      std::cout << "\nError!\n\nInvalid number of neutrons!" << std::endl;
      break;

    case invalid_electron:
      std::cout << "\nError!\n\nInvalid number of electrons!" << std::endl;
      break;

    case invalid_valence:
      std::cout << "\nError!\n\nInvalid number of valence electrons!" << std::endl;
      break;

    case string_parse_error:
      std::cout << "\nError!\n\nUnexpected value during string parsing!" << std::endl;
      break;

    case unregistered_name:
      std::cout << "\nError!\n\nMolecule formula not registered or not found!" << std::endl;
      break;

    case rxn_rate_error:
      std::cout << "\nError!\n\nReaction rates ratios do not match equilibrium constant!"
                << std::endl;
      break;

    case invalid_species:
      std::cout << "\nError!\n\nSpecies not found in list! Check names for errors." << std::endl;
      break;

    case duplicate_variable:
      std::cout << "\nError!\n\nDuplicate variable found in list! Check names for errors."
                << std::endl;
      break;

    case missing_information:
      std::cout << "\nError!\n\nMissing Information! Cannot complete requested tasks." << std::endl;
      break;

    case invalid_type:
      std::cout << "\nError!\n\nInvalid Type Specification!" << std::endl;
      break;

    case key_not_found:
      std::cout << "\nError!\n\nKey does not exist in the hash table!" << std::endl;
      break;

    case anchor_alias_dne:
      std::cout << "\nError!\n\nAnchor Alias Pair does not exist!" << std::endl;
      break;

    case initial_error:
      std::cout << "\nError!\n\nInitialization of object failed!" << std::endl;
      break;

    case not_a_token:
      std::cout << "\nError!\n\nUnexpected token type or improper input format!" << std::endl;
      break;

    case read_error:
      std::cout
          << "\nError!\n\nRead error has occured! Check input file and file location for mistakes."
          << std::endl;
      break;

    case invalid_console_input:
      std::cout << "\nError!\n\nInvalid input received!" << std::endl;
      break;

    case explicit_invalid:
      std::cout << "\nError!\n\nExplict methods are invalid for Steady-State Problems!"
                << std::endl;
      break;

    case distribution_impossible:
      std::cout << "\nError!\n\nImpossible Particle Distribution!" << std::endl;
      break;

    case invalid_isotope:
      std::cout << "\nError!\n\nInvalid Isotope!" << std::endl;
      break;

    default:
      std::cout << "\nUndefined or Generic Error!!!" << std::endl;
      break;
  }
}

/decl/xgm_gas/oxygen
	id = "oxygen"
	name = "Oxygen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.032	// kg/mol

	flags = XGM_GAS_OXIDIZER

/decl/xgm_gas/nitrogen
	id = "nitrogen"
	name = "Nitrogen"
	specific_heat = 20	// J/(mol*K)
	molar_mass = 0.028	// kg/mol

/decl/xgm_gas/carbon_dioxide
	id = "carbon_dioxide"
	name = "Carbon Dioxide"
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.044	// kg/mol

/decl/xgm_gas/phoron
	id = "phoron"
	name = "Phoron"

	//Note that this has a significant impact on TTV yield.
	//Because it is so high, any leftover phoron soaks up a lot of heat and drops the yield pressure.
	specific_heat = 200	// J/(mol*K)

	//Hypothetical group 14 (same as carbon), period 8 element.
	//Using multiplicity rule, it's atomic number is 162
	//and following a N/Z ratio of 1.5, the molar mass of a monatomic gas is:
	molar_mass = 0.405	// kg/mol

	tile_overlay = "phoron"
	overlay_limit = 0.7
	flags = XGM_GAS_FUEL | XGM_GAS_CONTAMINANT | XGM_GAS_FUSION_FUEL //R-UST port, adding XGM_GAS_FUSION_FUEL flag.
	burn_product = "carbon_dioxide"

/decl/xgm_gas/volatile_fuel
	id = "volatile_fuel"
	name = "Volatile Fuel"
	specific_heat = 253	// J/(mol*K)	C8H18 gasoline. Isobaric, but good enough.
	molar_mass = 0.114	// kg/mol. 		same.

	flags = XGM_GAS_FUEL
	burn_product = "carbon_dioxide"

/decl/xgm_gas/sleeping_agent
	id = "sleeping_agent"
	name = "Sleeping Agent"
	specific_heat = 40	// J/(mol*K)
	molar_mass = 0.044	// kg/mol. N2O

	tile_overlay = "sleeping_agent"
	overlay_limit = 1
	flags = XGM_GAS_OXIDIZER


/decl/xgm_gas/hydrogen
	id = "hydrogen"
	name = "Hydrogen"
	specific_heat = 100	// J/(mol*K)
	molar_mass = 0.002	// kg/mol
	flags = XGM_GAS_FUEL | XGM_GAS_FUSION_FUEL
	burn_product = "steam"
	// symbol_html = "H<sub>2</sub>"
	// symbol = "H2"
	

/decl/xgm_gas/vapor
	id = "steam"
	name = "Steam"
	tile_overlay = "generic"
	overlay_limit = 0.5
	specific_heat = 30	// J/(mol*K)
	molar_mass = 0.020	// kg/mol
	// breathed_product =     /datum/reagent/water
	// condensation_product = /datum/reagent/water
	// condensation_point =   308.15 // 35C. Dew point is ~20C but this is better for gameplay considerations.
	// symbol_html = "H<sub>2</sub>O"
	// symbol = "H2O"


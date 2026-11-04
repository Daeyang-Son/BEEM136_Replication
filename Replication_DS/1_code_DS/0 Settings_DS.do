    capture log close

	cls
	clear all
	set maxvar 10000
	set more off 

	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* Set Global Paths
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	

	gl root "C:\Users\ocean\Desktop\MRes\Research\Replication\Finance and Green Growth\Replication\Replication_DS" 

	gl data				"$root\0_data_DS"
	gl do    			"$root\1_code_DS"
	gl figures			"$root\2_figures_DS"
	gl tables			"$root\3_tables_DS"
	gl logs   			"$root\4_logs_DS"

	cd "$root"
	

	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* INSTALL PACKAGES
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	* ssc install ivreg2, replace
	* ssc install psmatch2, replace
	* ssc install sumup, replace
	* ssc install texsave, replace
	* ssc install univar, replace
	* ssc install regsave, replace
	* ssc install outreg2

	* additional packages for regression (not in the authors' list)
	* ssc install ftools, replace
    * ssc install reghdfe, replace
    * ssc install estout, replace
	
	
	
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* Run analysis do files
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	do "${do}\1 Data merging_DS.do"
	do "${do}\2 Tables_DS.do"
	

	

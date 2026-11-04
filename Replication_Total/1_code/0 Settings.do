capture log close _all

	cls
	clear all
	set maxvar 10000
	set more off 

	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* INPUT PATH WHERE REPLICATION FILES ARE SAVED
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	gl root "C:\Users\ocean\Desktop\MRes\Research\Replication\Finance and Green Growth\Replication\Replication_Total" 

	gl data				"$root\0_data"	
	gl do    			"$root\1_code"
	gl figures			"$root\2_figures"
	gl tables			"$root\3_tables"
	gl logs   			"$root\4_logs"

	cd "$root"
	
	

	* ssc install dataout
	* ssc install ranktest
	* ssc install distinct
	
	
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* Run analysis do files
	*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	do "${do}\1 Data merging.do"
	do "${do}\2 Tables.do"
	do "${do}\3 Charts.do"
	do "${do}\4 Tables Appendix.do"
	do "${do}\5 Tables Online Appendix.do"
	do "${do}\6 Charts Online Appendix.do"

	

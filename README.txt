###########################################################################
# MSD CACHE
###########################################################################
## Compilation command
# Using GUI
#
## Elaboration command to pass the valid test plus args ; DO NOT ADD FILENAME IN "" it should be direct, name of the file should not contain spaces
# vsim -voptargs=+acc work.cache_TB +silent +FILENAME=<filename> +COMPAREFILE=<compare_filename>
# example : 
# vsim -voptargs=+acc work.cache_TB +silent +FILENAME=basic_memory_test.txt +COMPAREFILE=filecompare.txt
# vsim -voptargs=+acc work.cache_TB +silent +FILENAME=PLRU_test1.txt        +COMPAREFILE=PLRU_test1.txt
# vsim -voptargs=+acc work.cache_TB +silent +FILENAME=PLRU_test2.txt        +COMPAREFILE=PLRU_test2.txt
#
# Valid test plus args
# 1) silent
# 2) Silent
# 3) S
# 4) s
# 5) SILENT
# 6) Normal
# 7) normal
# 8) N
# 9) n
# 10) NORMAL
#
#
#
# basic_memory_test.txt contains 0-F in read and write modes.
# tracefile.txt contains >32k memory addresses.
# filecompare.txt contains the reference output for hit and miss in basic_memory_test.txt.
# PLRU_test1.txt & PLRU_test2.txt are for testing the working of PLRU. 
# comparePLRU_test1.txt & comparePLRU_test2.txt contains the reference output for PLRU_test1.txt & PLRU_test2.txt.
# PLRU_test1 = Not Deviating from LRU
# PLRU_test2 = Deviating from LRU

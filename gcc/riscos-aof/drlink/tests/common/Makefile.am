# Drlink test infrastructure : COMMON

AUTOMAKE_OPTIONS = no-dependencies

check_PROGRAMS = common_ok1 common_ok2 common_ok3 common_ok4 common_ok5 common_ok6 common_fail1 common_fail2

common_ok1_SOURCES = test_main.s test_common.s test_comdef.s
common_ok2_SOURCES = test_main.s test_comdef.s test_common.s
common_ok3_SOURCES = test_common.s test_comdef.s test_main.s
common_ok4_SOURCES = test_comdef.s test_common.s test_main.s
common_ok5_SOURCES = test_main.s test_comdef.s
common_ok6_SOURCES = test_comdef.s test_main.s

common_fail1_SOURCES = test_main.s test_common.s
common_fail2_SOURCES = test_common.s test_main.s

TESTS = common_ok1$(EXEEXT) common_ok2$(EXEEXT) common_ok3$(EXEEXT) common_ok4$(EXEEXT) common_ok5$(EXEEXT) common_ok6$(EXEEXT) common_fail1$(EXEEXT) common_fail2$(EXEEXT)
XFAIL_TESTS = common_fail1$(EXEEXT) common_fail2$(EXEEXT)

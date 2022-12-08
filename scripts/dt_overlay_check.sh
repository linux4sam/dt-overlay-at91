#!/bin/bash
# SPDX-License-Identifier: GPL-2.0+
#
# Devicetree Overlay validation script.
#
# Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries
#
# Author: Sergiu Moga <sergiu.moga@microchip.com>

# Variable to keep track of the `make` recipes that the script uses
declare -A MAKE=( 								\
	["all"]="make"								\
	["mrproper"]="make mrproper" 						\
	["defconfig"]="" # updated after parsing options, in setup() function	\
	["dtbs"]="make dtbs" 							\
	["dtbs_check"]="make dtbs_check"					\
	["dt_binding_check"]="make dt_binding_check"				\
		);

# Variable to hold the link between DTSO directory and its related defconfig
declare -A DTSO_DIR_TO_CFG=(							\
	["mpfs_icicle"]="defconfig"						\
	["mpfs_icicle_amp"]="defconfig"
	["sam9x60ek"]="at91_dt_defconfig"					\
	["sama5d2_icp"]="sama5_defconfig"					\
	["sama5d2_ptc_ek"]="sama5_defconfig"					\
	["sama5d2_xplained"]="sama5_defconfig"					\
	["sama5d2_xplained_grts"]="sama5_defconfig"				\
	["sama5d27_som1_ek"]="sama5_defconfig"					\
	["sama5d27_wlsom1_ek"]="sama5_defconfig"				\
	["sama5d3_eds"]="sama5_defconfig"					\
	["sama5d3_xplained"]="sama5_defconfig"					\
	["sama5d4_xplained"]="sama5_defconfig"					\
	["sama7g5ek"]="sama7_defconfig"						\
			);

# Variable to hold the link between DTSO directory and its related devicetree
declare -A DTSO_DIR_TO_DT=(							\
	["mpfs_icicle"]="microchip/mpfs-icicle-kit.dt"				\
	["mpfs_icicle_amp"]="microchip/mpfs-icicle-kit-context-a.dt"		\
	["sam9x60ek"]="at91-sam9x60ek.dt"					\
	["sama5d2_icp"]="at91-sama5d2_icp.dt"					\
	["sama5d2_ptc_ek"]="at91-sama5d2_ptc_ek.dt"				\
	["sama5d2_xplained"]="at91-sama5d2_xplained.dt"				\
	["sama5d2_xplained_grts"]="at91-sama5d2_xplained.dt"			\
	["sama5d27_som1_ek"]="at91-sama5d27_som1_ek.dt"				\
	["sama5d27_wlsom1_ek"]="at91-sama5d27_wlsom1_ek.dt"			\
	["sama5d3_eds"]="at91-sama5d3_eds.dt"					\
	["sama5d3_xplained"]="at91-sama5d3_xplained.dt"				\
	["sama5d4_xplained"]="at91-sama5d4_xplained.dt"				\
	["sama7g5ek"]="at91-sama7g5ek.dt"					\
			);

print_options() {
	echo "Available options:
		-b	obligatory, specify the path to the directory containing
			the Devicetree Overlays meant to be validated.
		-d	optional, specify where to dump all dt-validation errors.
			Default value is stdout.
		-h	output this message.
		-j	optional, choose number of threads, default is 1 thread.
		-k	optional, specify the Linux Kernel directory,
			default value is the \${KERNEL_DIR} environment
			variable. This becomes obligatory if \${KERNEL_DIR}
			is empty.
		-o	optional, set the output directory for the Linux Kernel
			build commands. Default value is the {O} environment
			variable if it is set, otherwise the output files are
			stored in the user's ${KERNEL_DIR} or the path passed
			through the -k option.
		-s	optional, specify where to backup the original
			board file (.dts file), default value is /tmp/dts-name.
		-v	optional, get verbose output of what the script does.";
}

dump_variables() {
	dbg_print "Dumping all major variables...";
	dbg_print "ARCH = ${ARCH}";
	dbg_print "DTSO_DIR = ${DTSO_DIR}";
	dbg_print "ELOG = ${ELOG}";
	dbg_print "O = ${O}";
	dbg_print "KLOG_BLACKLIST = ${KLOG_BLACKLIST}";
	dbg_print "CFG = ${CFG}";
	dbg_print "DTS_PATH = ${DTS_PATH}";
	dbg_print "DTB_PATH = ${DTB_PATH}";
	dbg_print "DTS_BACKUP_PATH = ${DTS_BACKUP_PATH}";
	dbg_print "BACKUP_PATH = ${BACKUP_PATH}";
	dbg_print "THREADS_COUNT = ${THREADS_COUNT}";
	dbg_print "KERNEL_DIR = ${KERNEL_DIR}";
	dbg_print "DTSO_LIST = \n[\n${DTSO_LIST}\n]";
	dbg_print "PSCHEMA_PATH = ${PSCHEMA_PATH}";
	dbg_print "Printing the commands used for Linux Kernel build commands.";
	for RECIPE in "${!MAKE[@]}";
	do
		dbg_print "${MAKE[${RECIPE}]}";
	done;
}

dbg_print() {
	DEFAULT_COLOR=`tput sgr0`;
	DBG_COLOR=`tput setaf 2`;  # green color
	${VERBOSE} && echo -e ${DBG_COLOR}[VERBOSE] ${1}${DEFAULT_COLOR};
}

err_print() {
	DEFAULT_COLOR=`tput sgr0`;
	ERR_COLOR=`tput setaf 1`;  # red color
	echo -e ${ERR_COLOR}[ERROR] ${1}${DEFAULT_COLOR};
}

# Checks whether the returned error code for the last command indicates an issue.
# Error code 0 means success.
# Also take into account error code 1 that sometimes `make` issues if there is
# nothing else to be done, since it is not actually an error worth interrupting
# the whole process for.
is_ok() {
	if [[ $? -ne 0 && $? -ne 1 ]];
	then
		err_print "\"${1}\" FAILED!";
		read -p "Skip and continue? Y/N " OK_TO_SKIP;
		if [[ ${OK_TO_SKIP} == [yY] || \
		      ${OK_TO_SKIP} == [yY][eE][sS] ]];
		then
			continue;
		else
			restore_dts;
			exit 1;
		fi;
	fi;
}

backup_dts() {
	dbg_print "Making a backup of ${DTS_PATH} at ${BACKUP_PATH}.";
	cp ${DTS_PATH} ${DTS_BACKUP_PATH};
}

restore_dts() {
	dbg_print "Restoring ${DTS_PATH}.";
	cp ${DTS_BACKUP_PATH} ${DTS_PATH};
}

# Append the first passed string argument to every MAKE recipe
update_recipes() {
	for RECIPE in "${!MAKE[@]}";
	do
		MAKE[${RECIPE}]+=" ${1}";
	done;
}

# Setup initial variables depending on the value passed through the `-b`
# command line option.
setup() {
	if [[ -z "${KERNEL_DIR}" ]];
	then
		echo "-k Option is required!";
		echo "Otherwise, KERNEL_DIR must be non-empty";
		exit 1;
	fi;

	if [[ -z "${DTSO_DIR}" ]];
	then
		echo "-b Option is required!";
		echo "You must specify absolute path to DTSO directory!"
		exit 1;
	fi;

	if [[ -z "${BACKUP_PATH}" ]];
	then
		BACKUP_PATH=/tmp;
	fi;

	if [[ -z "${O}" ]];
	then
		O=${KERNEL_DIR};
	fi;

	# Update the defconfig MAKE element, now that we know the requested board
	CFG=${DTSO_DIR_TO_CFG[$(basename ${DTSO_DIR})]};
	MAKE["defconfig"]="make ${CFG}";

	# Based on the location of the defconfig find out the architecture
	ARCH=$(
		find ${KERNEL_DIR} -type f -name $(basename ${DTSO_DIR_TO_DT[$(basename ${DTSO_DIR})]})s | # Find defconfig location
		grep -oP '(?<=arch/).*?(?=/)' # Extract the string between "arch/" and "/"
	      );

	# Append the ARCH and KLOG_BLACKLIST filters to the `make` commands
	update_recipes "ARCH=${ARCH} | egrep -v \"\${KLOG_BLACKLIST}\"";

	# Setup Devicetree paths
	DTS_PATH=${KERNEL_DIR}/arch/${ARCH}/boot/dts/${DTSO_DIR_TO_DT[$(basename ${DTSO_DIR})]}s;
	DTS_BACKUP_PATH=${BACKUP_PATH}/$(basename ${DTS_PATH});
	DTB_PATH=${O}/arch/${ARCH}/boot/dts/${DTSO_DIR_TO_DT[$(basename ${DTSO_DIR})]}b;

	# Store all of the dtso files from the DTSO directory into DTSO_LIST
	DTSO_LIST=$(ls ${DTSO_DIR}/*dtso;);

	trap 'handle_interrupt' SIGINT;

	# Build processed-schema.json so that `dt-validate` can make use of it
	dbg_print "Changing directory to ${KERNEL_DIR}.";
	cd ${KERNEL_DIR};
	dbg_print "Running \"${MAKE["defconfig"]}\".";
	eval "${MAKE["defconfig"]}";
	# Ignore errors from dt_binding_check
	dbg_print "Running \"${MAKE["dt_binding_check"]}\".";
	dbg_print "This is going to take a long time the first time it is run.";
	eval "2>/dev/null 1>&2 ${MAKE["dt_binding_check"]}";

	# Store processed-schema.json's path.
	# Since it may also be stored as processed-schema-examples.json, just
	# use a wildcard to make sure and only grab the first result.
	PSCHEMA_PATH=$(								\
			find ${O} -type f -name "processed-schema*" 2>/dev/null |
			head -n1						\
			);
	# If no such file could be found, we cannot proceed further.
	if [[ -z "${PSCHEMA_PATH}" ]];
	then
		err_print "Cannot find processed-schema.json.";
		exit 1;
	fi;
}

# Handler for Ctrl-C
handle_interrupt() {
	dbg_print "Caught Interrupt!";
	restore_dts;
	exit 1;
}

# Default value for variables that do not come with the environment by default
THREADS_COUNT=1;
VERBOSE=false;
# Error output of `realpath` here is unnecessary as we later check for the
# result anyway
KERNEL_DIR=$(realpath -s ${KERNEL_DIR} 2>/dev/null);

# This is used to filter out Kernel build related messages that we do not need,
# such as DTC, or CHECK or LD related outputs that are issued when building,
# since they are unnecessary.
KLOG_BLACKLIST="#|DTC|DTEX|CHECK|YACC|CLEAN|HOSTCC|LINT|CHKDT|SCHEMA|HOSTLD|LD|AR|AS|UPD|LEX"

while getopts a:b:d:hj:k:o:s:v OPTION
do
	case "${OPTION}" in
	b)
		DTSO_DIR=$(realpath -s ${OPTARG});
		;;
	d)
		ELOG=$(realpath -s ${OPTARG});
		;;
	h)
		print_options;
		exit 0;
		;;
	j)
		THREADS_COUNT=${OPTARG};
		update_recipes "-j${THREADS_COUNT}";
		;;
	k)
		KERNEL_DIR=$(realpath -s ${OPTARG});
		;;
	o)
		O=$(realpath -s ${OPTARG});
		update_recipes "O=${O}";
		;;
	s)
		BACKUP_PATH=$(realpath -s ${OPTARG});
		;;
	v)
		VERBOSE=true;
		;;
	esac
done;

setup;

dump_variables;

backup_dts;

for DTSO in ${DTSO_LIST};
do
	dbg_print "Moving back to ${DTSO_DIR}.";
	cd ${DTSO_DIR};

	restore_dts;

	# Consider whatever follows "/plugin/;" in the dtso file as a valid DT
	dbg_print "Dumping ${DTSO} in ${DTS_PATH}.";
	sed '0,/\/plugin\/;/d' ${DTSO} >> ${DTS_PATH};

	dbg_print "Changing directory to ${KERNEL_DIR}.";
	cd ${KERNEL_DIR};

	# Rebuild the DTB
	rm ${DTB_PATH} 2>/dev/null;
	dbg_print "Running \"${MAKE["dtbs"]}\".";
	eval "${MAKE["dtbs"]}";
	is_ok "${MAKE["dtbs"]}";

	# Redirect output to desired log file if given
	if [[ -z "${ELOG}" ]];
	then
		dt-validate -s ${PSCHEMA_PATH} ${DTB_PATH};
	else
		dt-validate -s ${PSCHEMA_PATH} ${DTB_PATH} 2>${ELOG};
	fi;
done;

restore_dts;

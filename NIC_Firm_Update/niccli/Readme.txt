                        =============
                        NICCLI README
                        =============

               Copyright (c) 2025 Broadcom Inc.
                      All rights reserved.
                      October 28th, 2025

Introduction
------------
The NICCLI configuration utility sets the nonvolatile configuration elements of the Broadcom
Ethernet network adapter, such as enabling or disabling RoCE, SR-IOV, and other options.
The NICCLI configuration utility can also perform firmware upgrades. The NICCLI configuration
utility uses the L2 driver in Linux, VMWare, FreeBSD and Windows. In UEFI environment, the
NICCLI configuration interacts with the PCIe hardware. The NICCLI configuration
utility supports both the BCM9574XX, BCM95750X, and BCM957608 family of devices.

SUPPORTED OSes:
--------------------
1. Linux :
    - x86_64
    - aarch64
2. Windows :
    - x86_64
3. ESXI 8/9
    - x86_64
4. FreeBSD :
    - x86_64
5. UEFI :
    - x86_64
    - aarch64

Installing the NICCLI Configuration Utility
-------------------------------------------

This section provides information on installing/executing the NICCLI configuration Utility:

Installing the NICCLI Configuration Utility in Linux

    • Using NICCLI RPM:
        sudo rpm -i niccli -<version>.rpm

    • Using the NICCLI deb package:
        sudo dpkg –i niccli-<version>.deb

    Executing the NICCLI package in Linux

        • Users can execute the niccli binary by using the niccli-<release_version>-linux_<arch>.tar.gz package without
	  installing the rpms/deb packages. The user has to unzip the file and execute the niccli.<arch> in the operating system.

Executing the NICCLI Configuration Utility in Windows

    To install the NICCLI Configuration Utility, unzip the provided Windows package file and use the niccli.exe
    file to install it on Broadcom Ethernet Network interface cards.

Installing the NICCLI Configuration Utility in VMware

    To install the NICCLI Configuration Utility using a vib package:
        esxcli software vib install -v <VIB package> --no-sig-check

    NOTE:
        The vib packaging is under the process of VMware signing.

    To install the NICCLI Configuration Utility using a signed .zip bundle:
        esxcli software vib install -d <zip package>

Executing the NICCLI Configuration Utility in FreeBSD

    To install the NICCLI Configuration Utility, unzip the provided FreeBSD package file and use the niccli.freebsd
    file to install it on Broadcom Ethernet Network interface cards.

Executing the NICCLI Configuration Utility in UEFI

    To install the NICCLI Configuration Utility, unzip the provided uefi package file in uefi environment and use the niccli<arch>.efi
    file to install it on Broadcom Ethernet Network interface cards.

NICCLI Configuration Utility Usage and Commands
-----------------------------------------------
Provides information on PCI and operational inband communication using NICCLI.

The NICCLI Configuration Utility is a management tool that is used to perform operations on Broadcom Ethernet network
adapters. This utility provides support for PCI and operational inband communication. The utility also accepts arguments
to select the communication interface or the specified device in which to communicate from the device list.

NICCLI Configuration Utility Interface and Usage
================================================

The NICCLI configuration utilities provide three different types of interfaces. By default, the utility starts with the interactive
interface. The utility accepts three groups of command arguments based on the existing CLI standards.

<niccli> <HW i/f argument> [util arguments] [Target command]

NICCLI Configuration and Usage on VMWare 8.X onwards
====================================================

The following syntax is used when the signed bundle of NICCLI is installed:
esxcli niccli <command> -c <connection_type> -v <connection_type_value> [command options]

connection_type : The value assigned to the connection type, which can be one of the following <--dev | -c i | --pci>.

-v : Specifies the connection type value.
connection_type_value : Acceptable values include index number, MAC Address, or PCI address

Examples:
    1. esxcli niccli list
    2. esxcli niccli debug -c dev -v 1 --coredump
    3. esxcli niccli link --dev -v BC:97:E1:70:14:10 --status
    4. esxcli niccli debug --pci -v 0000:86:00.00 --coredump

Hardware Interface Group of Arguments
=====================================

The interface arguments depend on the hardware connection type and its specified depending arguments. The NICCLI
configuration utility supports the --pci interface which takes the PCI Bus/Device/Location of the device. Alternatively, the
utility also offers to list all the available Ethernet network adapter PCI devices in the system along with the appropriate
Ethernet/Network interface names.

• The NICCLI configuration utility has the -i/-dev index support which can select when more than one device is found
within the host.

NICCLI Configuration Utility Arguments
======================================

The utility arguments are optional. These are specific to the NICCLI configuration utility itself. E.g. convert all the output
into JSON or increase the logger verbosity, and so forth.

Target Command
==============

The target is nothing but the NICCLI configuration utility connected device. These targets offer a specific set of commands
depending on the connected interface/device. The target-specific commands are executed upon acquiring the connection
with the target.

NICCLI Configuration Utility Commands
=====================================

All the commands that are provided are case-sensitive and operate with any of the interface modes. The following rules
are for the newly defined NICCLI configuration utility syntax. The commands use a specific syntax as follows:

    • < > mandates user to specify the value
    • [ ] is an optional parameter.
    • Parameter syntaxes can also be combined such as [ -i <index value>] optional -i index argument but
      mandatory index value, if -i switch specified.
    • The NICCLI configuration utility provides "help" command with brief information for every command.
    • The NICCLI configuration utility shall accept combinations such as -h, -?, --help' to display the help.
    • Every command also has a detailed help description.
    • The NICCLI configuration utility also displays the supported commands and/or valid command syntax when the user
      executes an invalid command.

The NICCLI configuration supports the user command line argument as follows:

    ./niccli –i <index> <command line>
    ./niccli –pci <domain:bus:device.function> <command line>

NICCLI Configuration Utility Help

    To access the NICCLI configuration utility help, use the following command:
        ./niccli [--help | help | -h]

    Example:
        ./niccli -h

The utility provides three modes of execution:

    • Oneline Mode
        Execute the NICCLI configuration utility on a per-target command basis. In this mode, specify the hardware interface
        and target command with appropriate arguments. The NICCLI configuration utility connects to the target, executes
        the target command, and exits from the application. The return status of the command is the exit status of the NICCLI
        configuration utility.

        To list the available targets for Oneline mode use the following command:
            ./niccli --list

        Use the following command to display the list of available commands for Oneline Mode:
            ./niccli [-i <index of the target> | --pci <NIC pci address>] --help

        Use the following command to display the help for a specific command:
            ./niccli [-i [<index of the target> | <mac addr> | <NIC pci address>]] help <command>

        Example:

            ./niccli -i 1 --help nvm

    • Interactive Mode
        The NICCLI configuration utility starts in interactive console mode if no target command is provided. The interface starts
        with the target prompt upon a successful connection with the target.

        This mode is best suited for connecting to the target and executing multiple operations/commands without
        having to disconnect from the target. This improves performance and time in establishing a connection with the
        target each time while executing a command. This is only for interactive usage and is not designed or meant for
        the scripting.

        To launch in Interactive Mode, use the following command:
            <NIC CLI executable> [-i <index of the target> | --pci <NIC pci address>]


     • Batch Mode
        Write the list of commands into a flat text file and execute them in the NICCLI configuration utility without disconnecting.
        This combines Interactive and OneLine modes without disconnecting the target. If any one of the commands fails, the
        NICCLI configuration utility exits and shall not continue to execute the rest of the commands from the script.

        To launch in Batch Mode, use the following command:
            <NIC CLI executable> [-i <index of the target> | --pci <NIC pci address>] --batch <batch file>

        Batch mode requires a flat text file with utility-supported commands. Supported commands can be listed using
        OneLine mode or Interactive mode. Upon failure of any commands, the utility exits without continuing with other
        commands.

NICCLI Logging
==============

1. By default, the logging will be done in the following locations :
      Linux, FreeBSD         : /var/log
      Windows                : C:\ProgramData\Broadcom\logs
      EFI                    : Current location

2. The niccli logging is not supported in the VMWare operating system, when a signed
   niccli plugin file is installed.

3. Users can disable the default logging by assigning the value 0 to
   DEBUG_LOG_LEVEL_ALL in the "nicclilog.ini" file.

4. In the UEFI environment, continuous file write calls are synchronous and blocks
   execution until all data is transmitted.

5. If the system is still in early boot or pre-OS state, there’s no buffering or
   optimization.This is a limitation from the Preboot environment itself.

Sample nicclilog.ini file.

----------------------------------------------------------------------------
; Configuration file for NICCLI/NICCLID/NICCLIF/NICCLILOM
; Created: 2025-03-21

; Logging Level 0(OFF) 1(DEBUG), 2(VERBOSE), 4(FUNC)
; Logging level can be combined. For E.g.
; DEBUG_LOG_LEVEL_ALL = 3 (1(DEBUG), 2(VERBOSE))

[Logging Level]
DEBUG_LOG_LEVEL_ALL=3

; Logging type can either NULL, DEFAULT, Log_file
;          NULL : Displays the debug prints on the terminal
;                 or command prompt.
;       DEFAULT : Log in default location. (For Eg. /var/log)
;                 Default file name : <utility_name>_d_<time_stamp>.log
;      Log_file : Provided file name will be logged.


[Logging Type]
DEBUG_LOG_FILE=DEFAULT
----------------------------------------------------------------------------

Enabling NICCLI Commands Autocompletion
========================================

1) The user has to copy the niccli-autocomplete file to "/usr/share/bash-completion/completions/".
2) Then run "source /usr/share/bash-completion/completions/niccli-autocomplete" to enable the NICCLI command autocompletion.
3) The user has to run "niccli <tab> <tab>" to see auto-completion commands.

LOGGING:
========
1. By default, the logging will be done in the following locations :
      Linux, FreeBSD         : /var/log
      Windows                : C:\ProgramData\Broadcom\logs
      EFI                    : Current location

2. The niccli logging is not supported in the VMWare operating system, when a signed
   niccli plugin file is installed.

3. Users can disable the default logging by assigning the value 0 to
   DEBUG_LOG_LEVEL_ALL in the "nicclilog.ini" file.

4. In the UEFI environment, Continuous file write calls are synchronous and blocks
   execution until all data is transmitted.

5. If the system is still in early boot or pre-OS state, there’s no buffering or
   optimization. This is a limitation from the Preboot environment itself.

Sample nicclilog.ini file.

----------------------------------------------------------------------------
; Configuration file for NICCLI/NICCLID/NICCLIF/NICCLILOM
; Created: 2025-03-21

; Logging Level 0(OFF), 1(DEBUG), 2(VERBOSE), 4(FUNC)
; Logging level can be combined. For E.g.
; DEBUG_LOG_LEVEL_ALL = 3 (1(DEBUG), 2(VERBOSE))

[Logging Level]
DEBUG_LOG_LEVEL_ALL=3

; Logging type can either NULL, DEFAULT, Log_file
;          NULL : Displays the debug prints on the terminal
;                 or command prompt.
;       DEFAULT : Log in default location. (For Eg. /var/log)
;                 Default file name : <utility_name>_d_<time_stamp>.log
;      Log_file : Provided file name will be logged.


[Logging Type]
DEBUG_LOG_FILE=DEFAULT
----------------------------------------------------------------------------


KNOWN LIMITATIONS/ISSUES & USAGE GUIDELINES:
===========================================
    1) NICCLI framework does not support running multiple instances in parallel, sometimes it may lead to system
       crash and this scenario should be avoided.
    2) White space characters other than plain space like tab etc. are not supported as argument separators in the interactive mode.
    3) Interrupting niccli during the middle of some operations may result in unknown/undefined/unexpected behavior.
    4) QOS commands i.e. pfc, apptlv, up2tc, getqos, ets, listmap, dscp2prio and tcrlmt to work, user has disable the following nvm options "lldp_nearest_bridge",
       "lldp_nearest_non_tpmr_bridge" and "dcbx_mode".
    5) In FreeBSD for DCB commands to work, the user has to make sure the logical link of the interface should be UP. This is BSD layer2 driver (if_bnxt.ko) limitation.
    6) The error codes will be supported only for the online mode, the interactive mode and the batch mode will not have error codes displayed.

    7) Unless --all option is explicitly specified, resmgmt command works based on its default mode
        (for a selected single PF or for all PFs/entire NIC device) which is printed when it's
        executed or its help is displayed. --all option performs the given command/operation
        for all the PFs of the given NIC device.
    8) NICCLI in the Linux secure boot environment displays the "Firmware Reset Counter" and
       "Error Recovery Counter" fields in the show command always as zero as the mmap fails due to security considerations.
    9) For Blade Servers, the Network Interface Card on these servers remains powered during a server reboot. To ensure proper recovery of the card, particularly after a fastboot
       followed by NVM programming, it is essential to completely disconnect the power cables to the server. Failure to perform this step may result in the card returning in an
       unknown or bad condition.
    10) If the user updates certain parameter values on the NIC controller via niccli, the user can query the updated status from niccli.
        However the change may or maynot get reflected if queried from any other utility till reboot or L2 driver unload/load.

    VMWARE LIMITATIONS:
    -------------------
    1) In interactive mode, editing the command by moving the cursor using the left/right arrow will not work. The user has to re-issue the command.

    2) Separate loggings make debugging easier for the developers.
       Since it supports Storage, switch, expanders, NIC products through different ways of communication interfaces,
       we cannot change the existing logging mechanism design/functionality alone for NIC.

    3) This design is well approved by all architects.

    4) Interactive mode will not be supported in the niccli Plugin model.

    5) VMware ESXCLI plugin does not support underscore (_) to be included as part of niccli command name. The command names can only contain lower-case alphanumeric characters, numbers and '-'.
       Because of VMWare ESXCLI Plugin limitation, the esxcli niccli json format has the discrepancy in the command executed and command displayed in json output.

    LINUX INBOX LIMITATIONS:
    -----------------------
    1) In Linux operating systems, When the secure boot is enabled the adapter configuration/query commands using niccli will not work as the
       mapping to the PCI BAR is not allowed by the operating system.
    2) Running multiple instances of niccli at the same time can result in the unexpected outputs and command timeouts.
    3) In multihost environment, race conditions can occur if more than one host attempts to utilize the USHI channel at the
       same time and this can result in the corruption of the control and data registers, timeouts, etc.
    4) When the kernel configuration parameter CONFIG_IO_STRICT_DEVMEM=y is enabled and inbox bnxt_en driver is loaded, niccli
       adapter configuration/query commands will not work. This is because from the user space niccli cannot map the PCI BAR
       to access the hardware. Below are the two Work around's for this issue.
       A) Unbind the L2 driver from the PF.
       B) Enable the iomem=relaxed in the grub and reboot the server.
    5) niccli adapter configuration/query commands in the guest operating system or VM can cause the unexpected outputs and command
       timeouts when the guest operating system is loaded with the inbox bnxt_en driver and the PF is binded to the vfio-pci driver
       in the hypervisor and is attached to the guest operating system or VM. In this case, guest operating system or VM should be loaded with the out-of-box
       bnxt_en driver.
    6) The NICCLI command execution will be slow when inbox/upstream drivers are loaded.
    7) In case of writing/reading huge amounts of data from the hardware to user space, users might notice the considerable delay
       in the command completion when inbox/upstream drivers are loaded.
    8) When logging options such as --verbose, --debug and –log are specified with a filename, only the required and debug specific output
       is written to a specified file. These options need not redirect every output to the given file.


COMMANDS
--------
To get a current list of supported commands and the usage syntax supported by the
niccli utility, use the niccli help option.

$ niccli --help

   NAME
     niccli

   DESCRIPTION
     Broadcom NetXtreme-C/E/S Firmware update, Configuration and Debug utility.
     It supports 3 modes of execution. Interactive mode, Oneline Mode and Batch Mode.

   SYNOPSIS
     niccli [OPTIONS] <COMMAND> [Params]

   OPTIONS
     -v|--version       : Shows the version of the utility
     -h|--help          : Lists the available commands
     -i|--index         : Index of the target
     --search           : Search for a keyword(s) to match the relevant Commands
     --pci              : NIC PCI address
     --dev              : Index or MAC or NIC PCI address or NIC interface
     -j|--json          : List the output in JSON format

   Generic commands (Interface/device not required)
   ------------------------------------------------
     -v|--version       : Shows the version of the utility
     -h|--help          : Lists the available commands
     -l|--list          : Lists all the supported devices with target indexes
     -d|--list_devices  : Lists all the supported devices with basic information
     -e|--list_ethernet : Lists all the supported device interface names
     --batch            : Enter into batch mode
     devid              : Query Broadcom device id's
     quit               : Quits application (applicable in interactive mode only)


   Command categories (require specifying device - index or PCIE BDF or MAC)
   -------------------------------------------------------------------------------
     show                      : Displays NIC device related Information
     nvm                       : Query or Configure device NVM
     fw                        : Firmware manager
     qos                       : Query or configure device QOS parameters
     linkdiag                  : Link Diagnostics
     serdes                    : Plots the SERDES eyes values
     vf                        : Performs VF operations
     udcc                      : User defined congestion control operations
     cable                     : Display the cable information
     link                      : Link Operations
     timesync                  : Performs phy timesync operations
     counters                  : Display and clear the PCIe port counters
     tunnel                    : Performs Custom, GRE Tunnel and RSS(receive side scaling) operations
     msix                      : Query or configure MSIX vector of VF's for each PF
     mh                        : Modify and retrieve the PF count for each PCIe endpoint
     resmgmt                   : Query and Configure resources of the device
     ccparams                  : Query or configure the congestion control(cc) parameters for RoCE.
     debug                     : Dumps device internal configuration registers
     pcie                      : Query and configure the PCIe operations


   EXAMPLES :

   help
     To display the offline help                        : niccli --help | -h

   Common commands (no category)
     View 4-part IDs in of pkg file                     : niccli devid -f BCM957504-N1100GD.pkg
     Display list of supported devices                  : niccli --list

   show
     List basic device details using index              : niccli -i 1 show --all
     List basic device details using --dev              : niccli --dev 1 show --all
     List basic device details using --pci              : niccli --pci 0000:8F:00.0 show --all
     Display package version                            : niccli --dev 0000:3B:00.0 show --pkg_ver
     Display in json format                             : niccli --json --dev 1 show -d
     Capture json output in file                        : niccli --json show.json --dev 1 show -d

   nvm
     Get NVM config option                              : niccli --dev 1 nvm --getoption mac_address --scope 0
     Set NVM config option                              : niccli --dev 1 nvm --setoption mac_address --scope 0 --value 00-62-0b-58-fa-da
     Verify installed firmware                          : niccli --dev eth1 nvm --verify
     View contents of the package file                  : niccli nvm --list -f BCM957504-N1100GD.pkg

   fw
     Install firmware                                   : niccli --dev 1 fw --update -f BCM957504-N1100GD.pkg
     Reset firmware                                     : niccli --dev 0000:3B:00.0 fw --reset

   debug
     Retrieve coredump                                  : niccli --dev 00:62:0B:58:FA:DA debug --coredump

   Enter into interactive mode                          : niccli
   Enter into batch mode                                : niccli --dev 1 --batch batch.txt

   To display the command output in json format         : niccli --json --dev 1 show -d
   To capture the json output in a file                 : niccli --json show.json --dev 1 show -d

   Run 'niccli --dev <index|MAC|PCIe BDF> COMMAND --help' for more information on a command.


fwmanager commands
=================
DESCRIPTION :
     Performs Firmware operations

     1) The online option is  supported only in the Linux and Windows operating systems.
     2) recovery option is supported only in the Linux operating system and UEFI Platform.
     3) reset --immediate option is supported only in the Linux operating systems.

SYNTAX :
     fw <-u|--update> -f <package file> [--force] [-y|--yes]
     fw <-u|--update> <--online> [--force] [-y|--yes]
     fw <-u|--update> -f <package file> <-r|--recovery> [--force] [-y|--yes]
     fw <--reset> [--immediate]
     fw <-l|--livepatch> <--show>
     fw <-l|--livepatch> <-a|--activate> [target_fw]
     fw <-l|--livepatch> <-d|--deactivate> [target_fw]
     fw <-l|--livepatch> <-p|--patch_update> [target_fw] -f <patch file>

OPTIONS :
      -u|--update         : Perform the firmware install/update.
      -f|--file           : This option is to provide the package file.
      --force             : Forces the installation of the package file. This option can
                            also be used with the --recovery option to erase the complete NVM.
     --reset              : This option is to perform the reset operations.
     -y|--yes             : Answer as "yes" in prompts.
     --immediate          : This option is to reset the device without reloading the drivers.
     -l|--livepatch       : Perform the firmware live patch operations.
     --show               : Show the livepatch target firmware versions.
     -a|--activate        : Activate the firmware livepatch from the NVM.
     -d|--deactivate      : Deactivate the firmware livepatch from the NVM.
     -p|--patch_update    : Update the patch file directly to the device i.e. without installing it in NVM
     target_fw            : Target firmware is an optional parameter to activate/deactivate the
                            Livepatch. By default the tool updates all the supported target firmwares.
                            target_fw strings supported are "common_fw" or "secure_fw"
                            on BCM95750x devices. "chimp_fw" string is supported on BCM9574x devices.
     --online             : Fetch firmware image online from Broadcom web server & perform update.
     -r|--recovery        : Recovers the adapter and updates the package file.

EXAMPLES :
     To perform the firmware update
         niccli -i 1 fw --update -f FW.pkg --yes
     To perform the online firmware update
         niccli -i 1 fw --update --online --yes
     To perform the basic adapter recovery
         niccli -i 1 fw --update -f FW.pkg --recovery
     To recover the adapter from the bricked or non-operational state
         niccli -i 1 fw --update -f FW.pkg --recovery --force
     To reset the device
         niccli -i 1 fw --reset
         niccli -i 1 fw --reset --immediate
     To query the livepatch firmware versions
         niccli -i 1 fw --livepatch --show
     To activate the livepatch firmware from the NVM
         niccli -i 1 fw --livepatch --activate
     To deactivate the livepatch firmware from the NVM
         niccli -i 1 fw --livepatch --deactivate
     To update the patch file directly to the device
         niccli -i 1 fw --livepatch --patch_update -f patch.pkg

Config commands
===============

DESCRIPTION :
     NVM configuration option of a device
     This command provides :
          - Display the current settings of the NVM configuration.
          - Configure the current settings of the NVM configuration.
          - Save the current settings of the NVM configuration.

     1) The view option is supported in the Linux, Windows, VMWare and FreeBSD operating systems.
     2) The backup [--cfg] option is supported in the Linux, Windows, VMWare operating systems and UEFI Platform.
     3) The nvm --dir_read and --dir_write options are supported in the Linux, Windows, VMWare and FreeBSD operating systems.
     4) The nvm --dump option is supported in the Linux, Windows, VMWare and FreeBSD operating systems.

SYNTAX :
     nvm --view [-V] [-f <firmware package file name>] [-t|--type <nvm directory name>]
     nvm -l|--list [-V] [-f <firmware package file name>]
     nvm --verify [-V] [-f <firmware package file name>]
     nvm -n|--sync
     nvm -F|--restore_factory_defaults [--silent]
     nvm -r|--dir_read -f <file name>  -t|--type <nvm directory name>
     nvm -w|--dir_write -f <file name>  -t|--type <nvm directory name>
     nvm -S|--saveoptions -f <file name>
     nvm -O|--optionhelp <option name>
     nvm -g|--getoption <option name> [--scope <scope index>]
     nvm -s|--setoption <option names with comma separated>
         -v|--value <option value with comma separated> [--scope <scope index>]
     nvm -L|--listoptions --diff
     nvm -b|--backup [--cfg]
     nvm --dump <--cfg | <-o|--offset> <val> <--length> <val> > -f <filename>

OPTIONS :
     --view                         : View the NVM item data.
     -l|--list                      : Display the NVM components and its associated version details.
     --verify                       : Verify packages & NVM.
     -F|--restore_factory_defaults  : Restores NVM configuration to factory defaults.
     -n|--sync                      : Synchronize SBI, SRT and CRT Primary and Secondary FW images.
                                      Supported on BCM9575xxx and BCM9576xxx devices.
     -r|--dir_read                  : Read the NVM item data and write its contents to a file.
     -w|--dir_write                 : Create or overwrite NVM data item with a file.
     -S|--saveoptions               : Save NVM configuration options on the device to a file.
                                      Only the end user access NVM configuration options are saved.
     -O|--optionhelp                : Detailed help for the NVM configuration option.
     -g|--getoption                 : Get NVM configuration option of a device.
     --setoption                    : Set NVM configuration option of a device.
     -v|--value                     : The value for the specified option. Value can be in hex or decimal format
     --scope                        : The scope can be either of 'function' or 'port' index.
     -L|--listoptions               : Displays current and default NVM configuration options of a device.
     --diff                         : Displays the difference between current and default NVM configuration options of a device.
     --silent                       : Silent option. Do not prompt for the user message.
     -V                             : Verbosity.
     -f                             : Input file name.
     -t|--type                      : Input NVM directory name string.
     -b|--backup                    : Backup NVM contents to a file.
     --cfg                          : This option is used to backup only the nvm config and is applicable only with the --backup option.
     -o|--offset                    : Offset value in hex.
     --length                       : Number of bytes (in hex) to dump (multiple of 4).
     --dump                         : This command extracts the NVRAM content and performs a raw dump into,
                                      the file specified by the user.

EXAMPLE :
     To view the NVM directory entries in detail:
         niccli -i 1 nvm --view -V
     To list the NVM directory entries:
         niccli -i 1 nvm -l -f BCM957504-N1100GD.pkg
     To verify the NVM directory entries:
         niccli -i 1 nvm --verify
     To Sync the primary and secondary firmware images:
         niccli -i 1 nvm -n
     To read NVM directory:
         niccli -i 1 nvm -r -t pkglog -f data.txt
     To write NVM directory:
         niccli -i 1 nvm -w -f data.txt -t pkglog
     To restore the config to factory defaults:
         niccli -i 1 nvm --restore_factory_defaults --silent
     To save the NVM config to a file:
         niccli -i 1 nvm --saveoptions -f output.txt
     To display the current settings for the NVM option:
         niccli -i 1 nvm --getoption mac_address --scope 0
     To configure the current settings of the NVM configuration:
         niccli -i 1 nvm --setoption an_protocol --value 1 --scope 0
         niccli -i 1 nvm -s 1,1 --scope 0,1 -v B0:26:28:99:88:14,B0:26:28:99:88:15
     To backup NVM contents to a file:
         niccli -i 1 nvm --backup
     To backup nvm configuration to a file:
         niccli -i 1 nvm --backup --cfg
     To list the curent and default config settings:
         niccli -i 1 nvm -L --diff
     To get the help of each NVM config:
         niccli -i 1 nvm --optionhelp an_protocol
     To extracts the NVRAM content and performs a raw dump:
         niccli -i 1 nvm --dump --cfg -f cfg.txt
         niccli -i 1 nvm --dump -f nvmdump.bin
         niccli -i 1 nvm --dump -o 0x0 --length 0x10 -f nvmdump.bin

Note: While writing the VPD .txt file using --dir_write command, the user has to add the comment section
      with required VPD tags. If not, the command will fail to write the VPD .txt file.

qos commands
============
DESCRIPTION :
     This command can be used to query and configure the various QOS parameters such as
     ETS, priority to traffic class, application TLV's, receive rate control, tx and rx rate limits,
     transmit(egress) and receive(ingress) buffer threshold input parameters.

     1) This command is supported on Linux, Windows, VMWare and FreeBSD operating systems.
     2) The following options ets, pfc, up2tc, apptlv, dscp2prio,listma, tc, rx_port_rate_limit,
        rx_rate_limit, rx_ep_rate_limit, tx_partition_rate_limit, tx_port_rate_limit and tx_ep_rate_limit
        are supported only in the Linux and FreeBSD operating systems.

SYNTAX :
     qos <-E|--ets> --show
     qos <-E|--ets --tsa <tc[0-7]:[ets|strict], ...> --up2tc <priority[0-7]:tc>, ...> --tcbw <list>
     qos --pfc --enable <pfc list>
     qos --up2tc --pri <priority[0-7]:tc, ...>
     qos --apptlv <-a|--add> [<-d|--del>] --app <priority,selector,protocol>
     qos <-D|--dscp2prio>
     qos <-l|--listmap> --pri2cos
     qos --tc --set <-T|--rate_limit> <list of rate limit>
     qos <-r|--rx_port_rate_limit> --set --max <value> [-p|---persistent]
     qos <-R|--rx_rate_limit> --show [-p|--persistent]
     qos <-X|--rx_ep_rate_limit> --set --ep0 <value> [--ep1 <value>] [--ep2 <value>] [--ep3 <value>] [-p|---persistent]
     qos <-t|--tx_partition_rate_limit> --show [-p|--persistent]
     qos <-t|--tx_partition_rate_limit> --set --max <value> [-p|--persistent]
     qos <-P|--tx_port_rate_limit> --show
     qos <-P|--tx_port_rate_limit> --set -max <value>
     qos <-x|--tx_ep_rate_limit> --show
     qos <-x|--tx_ep_rate_limit> --set <--port> <port number> --ep0 <value> [--ep1 <value>] [--ep2 <value> [--ep3 <value>] [-p|--persistent]
     qos <-n|--ingress> --cosq --show [-p|--persistent]
     qos <-n|--ingress> --cosq --set --state <value> [--mode <value>] [-p|--persistent]
     qos <-e|--egress> --cosq --show [-p|--persistent]
     qos <-e|--egress> --cosq --set --state <value> [-p|--persistent]
     qos -g|--timed_tx_pacing_rate_profile --show
     qos --roce_app_pri --set --pri <0-7>


OPTIONS :
     -E|--ets                     : Query or Configure enhanced transmission selection, priority to traffic class,
                                    traffic class bandwidths and the list of configured application tlvs.
     --tsa                        : Transmission selection algorithm, sets a comma separated list of traffic classes to the
                                    corresponding selection algorithm. Valid algorithms include "ets" and "strict".
     --up2tc                      : Comma separated list mapping user priorities to traffic classes.
     --tcbw                       : Comma separated list of bandwidths for each traffic class the first value being
                                    assigned to traffic class 0 and the second to traffic class 1 and so on.
     --pfc                        : Enable priority based flow control on a given priority.
     -apptlv                      : Configure the priority of the application TLV.
     -a|--add                     : Add the priority of the application TLV.
     -d|--del                     : Delete the priority of the application TLV.
     --app                        : Key to provide the priority, selector, protocol for configuring the application TLV.
     -D|--dscp2prio               : query the dscp to priority mapping.
     -l|--listmap                 : List the priority mapping and related queue id for a given physical function.
     --pri2cos                    : List the priority to traffic class mapping.
     --tc                         : Command to set the rate limit for each traffic class.
     -T|--rate_limit              : Option to provide the comma separated percentage limit for each TC.
     -r|--rx_port_rate_limit      : Configure the receive side port rate limit
     --max                        : The max option specifies an 8-bit rate limit as a percentage of total link bandwidth
                                    with a range of 0 to 100 percent. A value of 0 indicates no rate limit and deletes
                                    the previously configured rate limit.
     -p|--persistent              : Option to write the configuration to NVRAM, but it does not take effect immediately.
     -R|--rx_rate_limit           : Query the configured receive side rate control parameters.
     -X|--rx_ep_rate_limit        : Configure the receive side rate control parameters for a given endpoint.
     -t|--tx_partition_rate_limit : Query and Configure the transmit side partition. Rate limit applies to traffic sent
                                    from a partition, which is one PF and all of its child VFs.
     -P|--tx_port_rate_limit      : Query and Configure the transmit side port rate limit.
     --port                       : Specify the index of the external port of the device.
     --ep(x)                      : Specify the Tx or Rx endpoints rate limit values.
     -x|--tx_ep_rate_limit        : Query and Configure the PCIe endpoint transmit rate control.
     -n|--ingress                 : Query and configure the QoS dynamically at receive buffer thresholds by configuring different input parameters.
     -e|--egress                  : Query and configure the QoS dynamically at transmit buffer thresholds by configuring different input parameters.
     --cosq                       : This option is used to query or set the cosq parameter i.e. cosq state and the mode.
     --state                      : Bitmask field indicating which traffic classes are enabled or disabled. Each bit represents a specific
                                    traffic class, where bit 0 represents traffic class 0 and so on. A value of 0 indicates that the traffic class
                                    is not enabled.
     --mode                       : Bitmask field indicating which traffic class is lossy or lossless. Each bit represents a specific traffic
                                    class, where bit 0 represents traffic class 0 and so on. A value of 0 indicates that the traffic class is
                                    lossy and value 1 indicates that the traffic class is lossless.
     --roce-app-pri               : RoCE Priority.
     --pri=<str>                  : Set RoCE Priority value. The valid range is from 0 to 7.
     -g|--timed_tx_pacing_rate_profile   : Query the timed tx pacing rate profile.

EXAMPLES :
     To show the ETS(enhanced transmission selection) configuration. The command output differs between Linux and VMware.
         niccli -i 1 qos --ets --show
     To configure the ETS(enhanced transmission selection)
         niccli -i 1 qos --ets --tsa 0:ets,1:ets,2:strict,3:strict,4:strict,5:strict,6:strict,7:strict --up2tc 0:0,1:0,2:0,3:0,4:0,5:1,6:0,7:0 --tcbw 70,30
     To enable priority based flow control on a given priority
         niccli -i 1 qos --pfc --enable 5,6
         niccli -i 1 qos --pfc --enable 0xFF
     To set the user priorities to traffic classes
         niccli -i 1 qos --up2tc 0:0,1:0,2:0,3:0,4:0,5:1,6:0,7:0
     To add the priority of the application TLV
         niccli -i 1 qos --apptlv --add --app 5,1,35093
     To delete the priority of the application TLV
         niccli -i 1 qos --apptlv --del --app 5,1,35093
     To query the dscp to priority mapping
         niccli -i 1 qos --dscp2prio
     To list the priority to traffic class mapping
         niccli -i 1 qos --listmap --pri2cos
     To set the rate limit for each traffic class in units of percentage
         niccli -i 1 qos --tc --set --rate_limit 10,20,30
         niccli -i 1 qos --tc --set --rate_limit 10
     To configure receive rate control that applies to all traffic in a receive CoS queue group
         niccli -i 1 qos --rx_port_rate_limit --set --max 40
         niccli -i 1 qos --rx_port_rate_limit --set --max 70 -persistent
     To show the receive side rate limits
         niccli -i 1 qos --rx_rate_limit --show
         niccli -i 1 qos --rx_rate_limit --show --persistent
     To configure endpoint rate limit for all endpoints from one host
         niccli -i 1 qos --rx_ep_rate_limit --set --ep0 0
         niccli -i 1 qos --rx_ep_rate_limit --set --ep0 0 --persistent
     To show the Tx partition rate limit
         niccli -i 1 qos --tx_partition_rate_limit --show
     To configure the Tx partition rate limit
         niccli -i 1 qos --tx_partition_rate_limit --set --max 2
     To show the transmit side port rate limit
         niccli -i 1 qos --tx_port_rate_limit --show
     To show the transmit side port rate limit
         niccli -i 1 qos --tx_port_rate_limit --show
     To configure the transmit side port rate limit
         niccli -i 1 qos --tx_port_rate_limit --set --max 2
     To query the PCIe endpoint transmit rate control
         niccli -i 1 qos --tx_ep_rate_limit --port 0 --show
     To configure the PCIe endpoint transmit rate control for two endpoints
         niccli -i 1 qos --tx_ep_rate_limit --set --port 0 --ep0 50 --ep2 40
     To query the ingress cosq parameters
         niccli -i 1 qos --ingress --cosq --show
     To enable all the 8 traffic classes and mode lossless(1) is configured on traffic class 4
         niccli -i 1 qos --ingress --cosq --set --state 255 --mode 16
     To query the egress cosq parameters
         niccli -i 1 qos --egress --cosq --show
     To configure the egress cosq parameters. Below example enables all the 8 queues
         niccli -i 1 qos --egress --cosq --set --state 255
     To query the timed tx pacing rate profile.
         niccli -i 1 qos --timed_tx_pacing_rate_profile --show
     To change RoCE pririty. This command is supported only in the VMware operating systems.
         esxcli niccli -c i -v 1qos --roce_app_pri --set --pri 0


linkdiag command
================

DESCRIPTION :
     This command is used to perform the link diagnostic tests like PRBS, loopback, DSCDump and TXFIR settings.

     1) fdrstat options are supported on Linux, Windows, VMWare operating system
     2) DSC Dump options are supported on Linux, VMWare and FreeBSD operating systems.
     3) Loopback options are supported only in the Linux operating systems.
     4) PRBS Test options are supported only in the Linux operating systems and UEFI Platform.
     5) TxFir options are supported on Linux, Windows, VMWare and FreeBSD Platforms

SYNTAX :
     linkdiag -T|--txfir --show <-M|--modulation_type> <mod_type> <-l|--lane> <lane_number>
     linkdiag -T|--txfir --set  <-M|--modulation_type> <mod_type> <-l|--lane> <lane_mask>
                 --pre1 <value>  --pre2 <value> [--pre3 <value>] --main <value> --post1 <value>
                 --post2 <value> [--post3 <value> --amp <value> --nlcl <value> --nlcu <value>]
     linkdiag -T|--txfir --show <-M|--modulation_type> <mod_type> <-l|--lane> <lane_number>
     linkdiag -D|--dscdump -l|--lane <lane_number> [-a|--diag_level <level>]
     linkdiag -L|--loopback --show
     linkdiag -L|--loopback [<-P|--phy_remote> | <-p|--phy_local> | <-m|--mac_local> | <-d|--disable>]
     linkdiag -L|--loopback [--external] [--RJ45]
     linkdiag -P|--prbs_test <-e|--enable | -d|--disable> [--mode <mode_value>] [<-r|--rx_lane_mask> <value>]
                 [<-t|--tx_lane_mask> <value>] [<-s|--duration> <value in seconds>] [--tcode]]

OPTIONS :
     -T|--txfir           : This option is used to query and configure the TX FIR (transmitter
                            finite impulse response
     -D|--dscdump         : This option is used to retrieve DSC dump data from a device
     -L|--loopback        : This option is used to query and configure the different loopback Modes
                            i.e. phy loopback, mac loopback and external loopback.
     -P|--prbs_test       : This option is used in port interface debugging to analyze the quality of the link.
                            The test can be run on a port or per lane with a specific polynomial.
                            Note:
                                1) The interface(s) should be fully initialized prior to the testing.
                                2) During the testing, there should not be any queries or configs sent to the card.
                                   "ifdown" the interface(s) is recommended.
     -M|--modulation_type : Modulation types of TxFIR. Supported values are 'NRZ','PAM4','C2MNRZ','C2MPAM4',
                            'PAM4-112','C2MPAM4-112G' and 'LPOPAM4-112G' of the device. The modulation types
                            'PAM4-112','C2MPAM4-112G' and 'LPOPAM4-112G' are only supported on BCM5760x devices.
                            The modulation types 'PAM4' and 'C2MPAM4' are supported on BCM5750x and BCM5760x devices.
     -l|--lane            : TXFIR show command takes the MRS lane number and lane mask for the TXFIR configuration.
                            To collect the dsc dump on all the supported lanes, please provide a value of 65535.
                            DSC dump on all lanes is supported only on BCM9576xx devices.
     --pre1               : This is a mandatory parameter to configure the TXFIR settings. This parameter is
                            supported for all the modulation types and the valid range is from -32768 to 32767.
     --pre2               : This is a mandatory parameter to configure the TXFIR settings. This parameter is
                            supported for all the modulation types and the valid range is from -32768 to 32767.
     --main               : This is a mandatory parameter to configure the TXFIR settings. This parameter is
                            supported for all the modulation types and the valid range is from -32768 to 32767.
     --post1              : This is a mandatory parameter to configure the TXFIR settings. This parameter is
                            supported for all the modulation types and the valid range is from -32768 to 32767.
     --post2              : This is a mandatory parameter to configure the TXFIR settings. This parameter is
                            supported for all the modulation types and the valid range is from -32768 to 32767.
     --pre3               : This is an optional parameter to configure the TXFIR settings. This parameter is
                            supported on following modulation types i.e, 'LPOPAM4-112G', 'PAM4-112', 'C2MPAM4' and
                            'C2MPAM4-112G'. The valid range is from -32768 to 32767.
     --post3              : This is an optional parameter to configure the TXFIR settings. This parameter is
                            supported on following modulation types i.e, 'NRZ','PAM4' and 'C2MNRZ'.
                            The valid range is from -32768 to 32767.
     --amp                : This is an optional parameter to configure the TXFIR settings. This parameter is
                            supported on following modulation types i.e, 'NRZ','PAM4','C2MNRZ','PAM4-112','C2MPAM4'
                            and 'C2MPAM4-112G'. The valid range is from -32768 to 32767.
     --nlcu               : This is an optional parameter to configure the TXFIR settings. This parameter is
                            supported only on 'LPOPAM4-112G' modulation type. The valid range is from -100 to 100.
     --nlcl               : This is an optional parameter to configure the TXFIR settings. This parameter is
                            supported only on 'LPOPAM4-112G' modulation type. The valid value is 0.
     -a|--diag_level      : This is an optional parameter. If the user does not specify this parameter by default DSC
                            dump will be collected on all the supported diag levels.
                            Supported diag levels are as follows:
                                   0 = diag lane
                                   1 = diag core
                                   2 = diag event
                                   3 = diag eye
                                   4 = diag reg core
                                   5 = diag reg lane
                                   6 = diag uc core
                                   7 = diag uc lane
                                   8 = diag lane debug
                                   9 = diag ber vert
                                   10 = diag ber horz
                                   11 = diag event safe
                                   12 = diag timestamp
     -R|--phy_remote      : This option enables loopback of local PHY Rx to peer PHY Tx. The packets transmitted by
                            peer are looped back to the peer at the PHY. No packets will reach the host.
                            The host will see a link down.
     -p|--phy_local       : This option enables a loopback of local TX to local RX at the PHY. Any packets
                            transmitted from the host are looped back to the host. No packets will be transmitted on
                            the line. If any peer is connected, the peer should ignore the link status from the host.
     -m|--mac_local       : This option enables a loopback of local TX to local RX at the MAC. Any packets
                            transmitted from the host are looped back to the host. No packets will be transmitted on
                            the line. If any peer is connected, the peer should ignore the link status from the host.
     -d|--disable         : This option disables the current loopback settings. In case of prbs_test this option
                            disables the PRBS test.
     --external           : This option prepares the PHY from external loopback and suppresses NONCE generation for
                            auto negotiation to work with an external loopback. This option should only be used if
                            the same port external loopback dongle or equivalent is used. Without this option and
                            AN enabled, the host may not see a link up.
     --RJ45               : This test is designed for dual port 10GBase-T where the PRBS test is not applied.
                            A compliant UTP cable is needed to connect between the two ports of the controller
                            because auto-negotiation is required to establish a link Traffic is initiated from one
                            port. The PHY of the other port is put into a remote loopback mode, essentially serving
                            as a loopback plug, to bounce packets back to the initiating port. This test requires the
                            production Linux driver (bnxt_en) to be loaded in order to execute. Packets are sent
                            and received through the Linux operating system network stack.
     -e|--enable          : Enable the PRBS test.
     --mode               : Specify the supported modes. And the supported modes are 'PRBS31','PRBS7','PRBS9'
                            'PRBS11','PRBS15','PRBS23','PRBS58','PRBS49','PRBS10','PRBS20' and 'PRBS13'.
                            The default mode value is PRBS31
     -r|--rx_lane_mask    : Receiver lane mask value.
     -t|--tx_lane_mask    : Transmitter lane mask value.
     -s|--duration        : Duration to run the prbs test. Default time is 10 seconds
     --tcode              : If this option was provided. The prbs test will run on t-code project as well.

EXAMPLES :
     To set the TXFIR settings
         niccli -i 1 linkdiag -T --set --modulation_type LPOPAM4-112G --lane 1 --pre1 1 --pre2 -2 --pre3 10 --main 12
             --post1 -10 --post2 15 --nlcl 0 --nlcu 1
         niccli -i 1 linkdiag -T --set --modulation_type PAM4 --lane 1 --pre1 1 --pre2 -2 --main 12 --amp 10 --post1 -10
             --post2 15 --post3 10
         niccli -i 1 linkdiag -T --set --modulation_type NRZ --lane 1 --pre1 1 --pre2 -2 --main 12 --amp 10 --post1 -10
             --post2 15 --post3 10
         niccli -i 1 linkdiag -T --set --modulation_type PAM4-112 --lane 1 --pre1 1 --pre2 -2 --pre3 5 --main 12 --amp 10
             --post1 -10 --post2 15
     To get the TXFIR settings
         niccli -i 1 linkdiag -T --show --modulation_type LPOPAM4-112G --lane 0
         niccli -i 1 linkdiag -T --show --modulation_type PAM4 --lane 0
         niccli -i 1 linkdiag -T --show --modulation_type NRZ --lane 0
         niccli -i 1 linkdiag -T --show --modulation_type PAM4-112 --lane 0
     To get the DSC Dump
         niccli -i 1 linkdiag -D --lane 0
         niccli -i 1 linkdiag -D --lane 0 --diag_level 2
     To get loopback status
         niccli -i 1 linkdiag --loopback --show
     To disable the loopback mode
         niccli -i 1 linkdiag --loopback --disable
     To enable the mac_local loopback mode
         niccli -i 1 linkdiag --loopback --mac_local
     To enable the phy_local loopback mode
         niccli -i 1 linkdiag --loopback --phy_local
     To enable the phy_remote loopback mode
         niccli -i 1 linkdiag --loopback --phy_remote
     To enable the external loopback mode
         niccli -i 1 linkdiag --loopback --external
     To enable the external RJ45 loopback mode
         niccli -i 1 linkdiag --loopback --external --RJ45
     To enable the PRBS Test with default
         niccli -i 1 linkdiag --prbs_test --enable
     To disable the PRBS Test
         niccli -i 1 linkdiag --prbs_test --disable
     To run the PRBS Test with user provided params
         niccli -i 1 linkdiag --prbs_test --enable --mode PRBS31 --rx_lane_mask 255 --tx_lane_mask 255 --duration 10


serdes command
=================
DESCRIPTION :
     This command is used to plot the serdes ethernet eye, PCI eye scope and margin values of the eye.
     This command is supported only in the Linux operating systems.
     Note:
         1. While plotting the serdes ethernet eye the link toggling is expected.
         2. Serdes ethernet and pci eye shares the resources of the NIC. Therefore, these commands
            cannot be run concurrently. If pci eye is running and you attempt to run ethernet eye
            tool will return failure.

SYNTAX :
     serdes --eye -e|--ethernet [-l|--lane <ethernet lane number>] [<-P|--plot>]
     serdes --eye -p|--pci <-l|--lane> <pci_lane_number> [-P|--plot] [-t|--target_ber <value>]
     serdes --eye -p|--pci -s|--stop

OPTIONS :
     --eye           : This option is used to plot the serdes pci and ethernet eye.
     -e|--ethernet   : This option is used to plot the serdes ethernet eye.
                       By default this options displays only horizontal and
                       vertical margin values, including the test result.
     -p|--pci        : This option is used to plot the serdes pci eye.
     -l--lane        : This option is used to specify the lane number. For pcie serdes test, the maximum value
                       is the device pcie lane width minus 1. Valid values are from 0 to 15.
                       For ethernet serdes test the valid range is from 0 to 7.
     -P|--plot       : This is an optional parameter. When user specifies this option, will plot the eye and
                       displays the horizontal and vertical margin values, including the test result.
     -t|--targetber  : This option is used to specify the target bit error rate. By default serdes pci eye
                       is plotted with BER "1e-8". This option is only supported on BCM9575xxx and above devices.
                       The supported target BER values are "1e-8", "1e-9", "1e-10" and "1e-11"
     -s|--stop       : This option is used to stop the running serdes pci eye plotting.
                       This option is only supported on BCM9575xxx and above devices.

EXAMPLES :
     To plot the ethernet serdes eye
         niccli -i 1 serdes --eye -e -P
         niccli -i 1 serdes --eye --ethernet --plot
     To plot the ethernet serdes eye with specific lane number
         niccli -i 1 serdes --eye -e -l 0 -P
         niccli -i 1 serdes --eye --ethernet --lane 0 --plot
     To get the PCI serdes eye margins and Rx settings with specific lane number
         niccli -i 1 serdes --eye --pci --lane 0
         niccli -i 1 serdes --eye -p -l 0
     To plot the PCI serdes eye with specific lane number
         niccli -i 1 serdes --eye --pci --lane 0 --plot
         niccli -i 1 serdes --eye -p -l 0 -P
     To plot the PCI serdes eye with specific lane number and target BER
         niccli -i 1 serdes --eye --pci --lane 0 --plot --target_ber 1e-8
         niccli -i 1 serdes --eye -p -l 0 -P -t 1e-8
     To stop the PCI serdes eye test
         niccli -i 1 serdes --eye --pci --stop
         niccli -i 1 serdes --eye -p -s

cable command
===============
DESCRIPTION :
     Query/Decode Module EEPROM information and optical diagnostics.
     This command is supported on Linux, Windows, FreeBSD and VMWare operating systems.

SYNTAX :
     cable -m|--module_info --show
     cable -r|--read_module_eeprom [-p|--page_number <page number> -o|--offset <byte offset>
           -l|--length <number of bytes> -b|--bank <bank number> -i|--i2c_address <i2c addr>]
     cable -w|--write_module_eeprom -p|--page_number <page number> -o|--offset <byte offset>
           -v|--value <bytes>
     cable -M|--module_loopback -t|--loopback_type <type> [--lane <module_lane_number>]

OPTIONS:
     -m|--module_info         : Get the module information
     -r|--read_module_eeprom  : Read the module EEPROM in hex format
     -w|--write_module_eeprom : Write the bytes into the module EEPROM
     -i|--i2c_address         : I2C address of a page. Value less than 0x7f expected
                                Most of the EEPROMs use 0x50 or 0x51
     -p|--page_number         : The page number that is being accessed over I2C
     -l|--length              : Length of EEPROM data to read or write
     -o|--offset              : Offset within the page that is being accessed over I2C
     -b|--bank                : The bank number of the page that is being accessed over I2C
     -v|--value               : Bytes to write into module EEPROM
     -M|--module_loopback     : This option is used to perform the various module loopbacks. This operation
                                is supported only on CMIS 4.0 and above supported modules.
     -t|--loopback_type       : This option is used to run the module loopback on the specified loopback type.
                                The supported module loopback types are as below:
                                       1 - Media Side Output Loopback
                                       2 - Media Side Input Loopback
                                       3 - Host Side Output Loopback
                                       4 - Host Side Input Loopback
     --lane                   : This is an optional parameter. If user specify this option with a valid lane number,
                                then the module loopback will be run on the specified lane.
     --show                   : Displays the information in detail.

EXAMPLES:
     To show the module information
         niccli -i 1 cable -m --show
         niccli -i 1 cable --module_info --show
     To Read the module eeprom
         niccli -i 1 cable -r -p 0 -o 0 -l 128 -b 0 -i 0x50
         niccli -i 1 cable --read_module_eeprom --page_number 0 --offset 0 --length 128 --bank 0 --i2c_address 0x50
     To Write to module eeprom
         niccli -i 1 cable -w -p 0 -o 0 -v 20
         niccli -i 1 cable --write_module_eeprom --page_number 0 --offset 0 --value 20
     To run the 'Media Side Output Loopback'
         niccli -i 1 cable -M -t 1 -l 0
         niccli -i 1 cable --module_loopback --loopback_type 1 --lane 0
     To run the 'Media Side Input Loopback'
         niccli -i 1 cable -M -t 2 -l 0
         niccli -i 1 cable --module_loopback --loopback_type 2 --lane 0
     To run the 'Host Side Output Loopback'
         niccli -i 1 cable -M -t 3 -l 0
         niccli -i 1 cable --module_loopback --loopback_type 3 --lane 0
     To run the 'Host Side Input Loopback'
         niccli -i 1 cable -M -t 4 -l 0
         niccli -i 1 cable --module_loopback --loopback_type 4 --lane 0

link command
=============

DESCRIPTION :
     This command is used to query the link status, BER information, physical counters
     and configure the port state. This command is supported on Linux, Windows, FreeBSD and VMWare operating systems

SYNTAX :
     link -s|--status
     link -c|--counters --show
     link -p|--port_state <port state value>
     link -S|--port_speed [--speed <value>] [--lanes <number_of_lanes>] -a|--autoneg <on/off> [--fec <value>] [-t|--training <on/off>]
     link -P|--precoding <enable/disable>

OPTIONS :
     -s|--status      : Shows the link status and related information
     -c|--counters    : Show physical counters and BER Info
     -p|--port_state  : Configures the portstate. The valid values are 0(Down), 1(UP) and 2(Toggle)
     -S|--port_speed  : Configures the port speed for the number of lanes, Link training, Autoneg and FEC.
     --speed          : Option to provide the speed value in MB.
     --lanes          : Option to provide the number of lanes. The valid values are 1,2,4 and 8
     -a|--autoneg     : Option to on/off the autoneg speed. The valid values are "on", "off"
     -t|--training    : Option to on/off the link training. The valid values are "on", "off"
     --fec            : This option is to configure the provided FEC type. The valid values are:
                          1 - Autoneg
                          2 - CL74 Fire Code
                          3 - CL91 Reed Solomon
                          4 - RS544 1xN
                          5 - RS544 2xN
                          6 - RS272 1xN
                          7 - RS272 2xN
     -p|--precoding   : This options is used to forward transformation of data that helps mitigate channel-induced
                        signal distortion. The valid values are "enable" and "disable".

EXAMPLES :
     To get the link information
         niccli -i 1 link -s
         niccli -i 1 link --status
     To get the physical counters and BER information
         niccli -i 1 link -c --show
         niccli -i 1 link --counters --show
     To configure the port state to down
         niccli -i 1 link -p 0
         niccli -i 1 link --port_state 0
     To configure the port state to up
         niccli -i 1 link -p 1
         niccli -i 1 link --port_state 1
     To toggle the port state
         niccli -i 1 link -p 2
         niccli -i 1 link --port_state 2
     To set the port link speed to autoneg
         link --port_speed --autoneg on
     To set the port link speed to 100G on 4 lanes and associated params
         link --port_speed --autoneg off --speed 100000 --lanes 4 --fec 3 --training on
     To enable the precoding
         niccli -i 1 link --precoding enable
     To disable the precoding
         niccli -i 1 link --precoding disable

Note:
    1) As a prerequisite, user has to run the "linkdiag --fdrstat --start" command to query the
       link BER and physical counters on BCM576xxx devices.
    2) All the counters are accumulated since board reset.
    3) RS corrected errors, RS uncorrectable errors, and CRC Error Frames can be cleared by using command "link --counters --clear".
    4) Effective Physical Errors and Raw Physical Errors can be restarted by cleared by using
       command "linkdiag --fdrstat --stop" on BCM576xxx devices.
    5) RS corrected errors refers to corrected errors from FEC.
    6) RS uncorrectable errors refers to uncorrectable errors from FEC.
    7) CRC Error Frames refers to error frames from CRC.
    8) Effective Physical Errors refers to uncorrectable codewords from FDR on BCM576xxx devices.
    9) Effective Physical BER refers to BER based on Effective Physical Errors on BCM576xxx devices.
   10) Raw Physical Errors refers to symbol errors from FDR on BCM576xxx devices.
   11) Raw Physical BER refers to BER based on Raw Physical Errors on BCM576xxx devices.
   12) Precoding enable/disable operation will toggle the link. At this time firmware does not service
       other commands that operate on the PHY. System logs may indicate command timeouts.
   13) When a port is connected to BMC, firmware doesn't honour the link toggle via port_state option.
   14) BER information and physical counters are only supported on BCM576xxx devices.
   15) In the FreeBSD operating system, the "link --counters --show" command does not support
       the fields "RS corrected errors" and "RS uncorrectable errors."

debug command
=================
DESCRIPTION :
     Dumps device internal configuration registers. The dump file can be used by the Broadcom
     Support for hardware troubleshooting

     1) Snapdump option is supported on Linux, Windows, FreeBSD and VMWare operating systems.
     2) Debug --token options are supported on Linux, Windows and FreeBSD operating systems.

SYNTAX :
     debug -c|--coredump [-d|--ddr] [-l|--l1cc] [-f <file name>]
     debug -s|--snapdump [-f <file name>]
     debug -D|--drv_dbg_mask --show -T|--drv_type <value>
     debug -D|--drv_dbg_mask --value <value> -T|--drv_type <value>
     debug -K|--token -a|--supported_claims [–-show |-f <output_filename>]
     debug -K|--token -A|--active_claims> [–-show |-f <output_filename>]
     debug -K|--token -G|--generate -f|--file <claims_file> [-o|--output_file <unsigned_CBOR_file>]
     debug -K|--token -I|--insert -N|--signature_file <signature file> -f|--file <claims_file> [-o|--output_file <signed_CBOR_file>]
     debug -K|--token -E|--enable -f|--file <signed_CBOR_file>
     debug -K|--token -B|--disable

OPTIONS :
     -c|--coredump      : Retrieves the register dump and crashdump from the firmware.
     -s|--snapdump      : Retrieves the register dump, crashdump, firmware log, driver logs and host tool logs.
     -d|--ddr           : Retrieves crashdump from the DDR if available and this option is only applicable to the coredump command.
     -l|--l1cc          : Retrieves the context l1 cache and this option is only applicable to the coredump command.
     -f|--file          : Option to provide the file name.
     -D|--drv_dbg_mask  : This option is used to set the driver debug mask value.
     -T|--drv_type      : This option is used to set the driver debug mask for the given driver type.
                          The valid values for this option are:
                          0 - Bnxtnet
                          1 - RoCE
     -K|--token         : Perform debug token operations.
     -a|--supported_claims : Retrieves the supported debug tokens. Below are the supported tokens.
                             fwcli      : Provides access to the production firmware command list. The valid values are from 0 to 2.
                             diagrw_en  : Enable or disable the GRC register access. The valid values are 0 and 1.
                             persist    : Persist the token until expired. The valid values are 0 and 1.
                             exp        : Expiration time to indicate when the token expires. Value is an epoch based 64-bit integer value.
                                          The value indicates the number of seconds relative to 1970-01-01T00:00Z in UTC time.
     -A|--active_claims : Retrieves the active debug tokens.
     -G|--generate      : Generate the unsigned debug token binary for the provided debug claims.
     -I|--insert        : Insert the signature into the unsigned debug token binary for the provided debug claims.
                          Note: The debug tokens in the claims file for the generate and insert command should match.
     -N|--signature_file : Option to provide the signature file.
     -E|--enable        : Enable the debug token.
     -B|--disable       : Disable the debug token.

EXAMPLES :
     To collect the codedump
         niccli -i 1 debug -c
         niccli -i 1  debug --coredump
         niccli -i 1 debug --coredump -f test.core
     To collect the crashdump from the DDR
         niccli -i 1 debug --coredump --ddr
     To collect the coredump with L1 context cache
         niccli -i 1 debug --coredump --l1cc
     To collect the snapdump
         niccli -i 1 debug -s
         niccli -i 1 debug --snapdump
     To retrieve the firmware supported debug token claims and dump into JSON file
         debug --token --supported_claims --file supported_claims.json
     To retrieve the active debug token claims configured by the firmware and dump into JSON file
         debug --token --active_claims --file active_claims.json
     To generate the unsigned debug token binary file for the provided debug claims
         debug --token --generate --file supported_claims.json --output_file niccwt_P2200_unsigned.cbor
     To insert the signature into the unsigned debug token binary file
         debug --token --insert --signature_file sig.txt --file active_claims.json --output_file niccwt_P2200_signed.cbor
     To enable the debug token using signed debug token binary file
         debug --token --enable --file niccwt_P2200_signed.cbor
     To disable the debug token
         debug --token --disable

NOTE:

1) Below commands are supported only in the VMWare operating systems.

     To query the debug mask of RoCE Device.
         esxcli niccli --dev -v vmnic4 debug --drv_dbg_mask --show --drv_type 1
     To configure the debug mask.
         esxcli niccli --dev -v debug --drv_dbg_mask --value 0x1 --drv_type 0


show command
============
DESCRIPTION :
     This command will display all the basic details of the device

     1) pcb_gen2_otp option is supported only in the Linux operating systems.
     2) recommendations options are supported only in the Linux, Windows, VMWare and FreeBSD operating systems.
     3) list_ethernet command is supported only in the Linux, Windows, VMWare and FreeBSD operating systems.

SYNTAX :
     niccli --list
     niccli -l | --list_devices
     niccli -e | --list_ethernet
     show -d | --device_info
     show -p | --pkg_ver [-f <firmware package file(s)>]
     show -D | --device_ids [-f <firmware package file(s)>]
     show -c | --certificate [-s | --slot <number>]
     show -n | --nvm_measurement
     show --all
     show --health
     show -r | --recommendations [--nvm [-f <firmware package>]] [--pcie] [-V]

OPTIONS :
     -p | --pkg_ver            :     Display firmware package version installed
                                     on the device or in the package file.

     -f                        :     Display firmware package file information.

     -D | --device_ids         :     Display Broadcom device id information.

     -d | --device_info        :     Display the basic details of the device

     --all                     :     Display all the details of the device.

     -c | --certificate        :     Display the imported certificate chain on the device.
                                     This command is supported on BCM9575xxx and BCM9576xxx devices.

     -s | --slot               :     Slot number is where the certificate chain on the device is imported.
                                     The valid values are from 0 to 7. The default value is 0.

     -n | --nvm_measurement    :     Display whether the NVM configuration that is active in the system
                                     has been changed or not. To facilitate this, a hash is generated
                                     based on nvm configuration.The hash represents the measurement
                                     of the configuration.This command is supported on BCM9575xxx
                                     and BCM9576xxx devices.
     --nvm                     :     This option is used to show the nvm self debug recommendations to the user.
                                     This option is only supported on BCM9575xxx and BCM9576xxx devices.
     --health                  :     Display the device health.
     -r | --recommendations    :     Display the self debug recommendations to the user.
                                     This option is only supported on BCM9575xxx and BCM9576xxx devices.
     --pcie                    :     This option is used to show the PCIe self debug recommendations to the user.
                                     This option is only supported on BCM9575xxx and BCM9576xxx devices.
     -V                        :     Verbosity, which shows the detailed information.
     -g | --pcb_gen2_otp       :     Display the PCB gen2 device OTP. This command is supported on BCM9574xxx devices.

 EXAMPLES :
     To list all the supported devices with target indexes
         niccli --list
     To list all the supported devices with basic information
         niccli -l
         niccli --list_devices
     To list all the supported device interface names
         niccli -e
         niccli --list_ethernet
     To display firmware package version installed on the device or in the package file
         niccli -i 1 show -p -f BCM957508-N2100G.pkg
         niccli -i 1 show --pkg_ver
     To display the basic details of the device
         niccli -i 1 show -d
         niccli -i 1 show --device_info
     To display the device health of the interface
         niccli -i 1 show --health
     To display the imported certificate chain on the device
         niccli -i 1 show -c -s 1
         niccli -i 1 show --certificate --slot 0
     To display whether the NVM configuration that is active in the system
         niccli -i 1 show -n
         niccli -i 1 show --nvmmeasurement
     To display Broadcom device id information
         niccli -i 1 show -D -f BCM957508-N2100G.pkg
         niccli -i 1 show --device_pci_ids -f BCM957608-P2200GQF00.pkg
     To display all the details of the device
         niccli -i 1 show --all
     To display the recommendation for self debug.
         niccli -i 1 show -r
         niccli -i 1 show --recommendations
         niccli -i 1 show --recommendations --pcie
         niccli -i 1 show --recommendations -V
         niccli -i 1 show --recommendations --nvm
         niccli -i 1 show --recommendations --nvm -f BCM957508-N2100G.pkg
         niccli -i 1 show --recommendations --nvm -f BCM957508-N2100G.pkg -V

timesync command
===============
DESCRIPTION :
     Query and configure the number of MSI-X max vectors values for VF's per each PF
     This command is supported on Linux, Windows, FreeBSDand VMWare operating systems.

SYNTAX :
     timesync < -d | --dutycycle> <--period> <value> --up <value>

     timesync <--dll> <-s | --source> <value> <-q | --frequency> <value>

     timesync <--ptp> --show
     timesync <--ptp> --set <-p | --primary_pf> <pid> [<-v | --primary_vf> <vfid>]
                                     [<-P | --secondary_pf> <pfid>] [<-V | --secondary_vf> <vfid>]

     timesync <--synce> --show
     timesync <--synce> --set <-Q | --frequency_profile> <value> [<-c | --primary_clock_state> <value>]
                                     [<-C | --secondary_clock_state> <value>]

     timesync --tsio --show
     timesync <--tsio> <-t | --tsio_function_pin> <idx> <-u | --pin_usage_string> <value>
                                     <--state> <value>

OPTIONS :
     -d|--dutycycle   : To set duty cycle on TSIO outgoing signal.
     --period         : value for period will be treated as in nanoseconds.
     --up             : Up flag is used to set the duty cycle and should be less than the period value.
     --dll            : To set the DLL source for PHC.
     -s | --source    : The valid values range from 0 to 4.
     -q | --frequency : The valid values range from 0 to 3.
     -p| --ptp        : PTP extended parameters operation.
     --show           : Displays timesync operation.
     --set            : Configures timesync operation.
     -p | --primary_pf : Primary physical function ID.
     -v | --primary_vf : Primary virtual function ID belongs to primary PF ID.
     -P | --secondary_pf : Secondary physical function ID.
     -V | --secondary_vf : secondary virtual function ID belongs to secondary PF ID.
     --synce          : Configure and display the synchronous ethernet frequency profile.
                                     primary and secondary clock state. This command is supported only on BCM9575xxx devices.

     -Q | --frequency_profile : Frequency profile for SyncE recovered clock. Supported profiles are "25MHz"
     -c | --primary_clock_state : Enable or disable primary clock for PF or port, overriding previous primary clock setting.
     -C | --secondary_clock_state : Enable or disable secondary clock for PF or port,overriding previous secondary clock setting.
     --tsio           : Displays or Configures tsio function capability on the pin
     -t | --tsio_function_pin : Pin Index.Valid Index 0 to 3
     -u | --pin_usage_string : Pin usage string.
     --state          : Enable/Disable function capability on the pin

EXAMPLES :
     Setting duty cycle on TSIO outgoing signal
         niccli -i 1 timesync -d --period 1 --up 0
         niccli -i 1 timesync --dutycycle --period 1 --up 0

     To configure the DLL source for PHC
         niccli -i 1 timesync --dll -s 1 -q 3
         niccli -i 1 timesync --dll --source 1 --frequency 3

         To perform PTP extended parameters operation
         niccli -i 1 timesync --synce --show
         niccli -i 1 timesync --synce --set -Q 25MHz
         niccli -i 1 timesync --synce --set --frequency_profile 25MHz

         To perform TSIO function capability on the pin
         niccli -i 1 timesync --tsio --show
         niccli -i 1 timesync --tsio -t 3 -u 1 --state 1
         niccli -i 1 timesync --tsio --tsio_function_pin 3 --pin_usage_string 1 --state 1

         To perform PTP extended parameters operation.
         niccli -i 1 timesync --ptp --show
         niccli -i 1 timesync --ptp --set -p 1 -v 1
         niccli -i 1 timesync --ptp --set --primary_pf 1 --secondary_pf 1

Counters command
================
DESCRIPTION :
     This command is used to display the L2/RoCE, Port, PCIe counters and clear the port counters.
     This command is supported only in the Linux, Windows, FreeBSD and VMWare operating systems.

SYNTAX :
     counters -p | --pcie [-V]
     counters -c | --clear
     counters -P | --port [--dir <rx/tx>]
     counters -r | --roce
     counters --l2

OPTIONS :
     -p | --pcie      : Display PCIe Counters.
     -c | --clear     : Clear the port counters.
     -V               : Display the detailed information of the PCIe Counters.
     -P | --port      : This option is used to get the port statistics. By default Tx statistics will be collected.
     -r | --roce      : This option is used to get the RoCE statistics.
     --dir            : This is an optional parameter. This option is used to collect the port stats for Rx/Tx direction.
     --l2             : This option is used to get the L2 statistics.

EXAMPLES :
     To display the PCIe counters
         niccli -i 1 counters -p
         niccli -i 1 counters --pcie
     To clear the port counters
         niccli -i 1 counters -c
         niccli -i 1 counters --clear
     To display the port counters
         niccli -i 1 counters --port --dir rx
     To display the RoCE counters
         niccli -i 1 counters --roce
     To display the L2 counters
         niccli -i 1 counters --l2

vf configuration commands
=========================
DESCRIPTION :
     Performs VF operations.This command is supported only in the Linux operating systems.

SYNTAX :
     vf <-t|--trust> --set <-v|--vf_index> <idx> <--state> <enable/disable>
     vf <-t|--trust> --show <-v|--vf_index> <idx>
     vf <-a|--add_ntuple_filter> <-m|--macaddress> <value> <-p|--dest_port> <value>
        <-P|--dst_port_mask> <value> <-v|--vf_index> <idx> <-T|--ip_type> <value>
     vf <-d|--free_ntuple_filter> <-l|--filter_id> <value>
     vf <-M|--peer_mem_map> <--hpa> <list of values> <--gpa> <list of values>
        <--size> <list of values> [--ds_port <value>]

OPTIONS :
     -t|--trust              : Perform the trusted VF operations.
     -v|--vf_index           : Provide the VF index.
     --state                 : Option to enable or disable the trusted VF.
     -a|--add_ntuple_filter  : Option to add the ntuple flow filter.
     -d|--free_ntuple_filter : Option to free the ntuple flow filter.
     -m|--macaddress         : MAC address in format xx:xx:xx:xx:xx:xx.
     -p|--dest_port          : Option to provide the destination port.
     -P|--dst_port_mask      : Option to provide the destination port mask.
     -T|--ip_type            : Option to provide the IP type. The valid values are:
                               1 - IPV4, 2 - IPV6, 3 - ARP-REPLY
     -M|--peer_mem_map       : Option to configure the GPU host and guest physical address mapping.
     --hpa                   : This option is used to specify the list of host physical addresses.
                               Max 8 entries are supported. User has to provide the list with a comma
                               separated for each host physical address. The value should be in the hex-decimal.
     --gpa                   : This option is used to specify the list of guest physical addresses.
                               Max 8 entries are supported. User has to provide the list with a comma
                               separated for each guest physical address. The value should be in the hex-decimal.
     --size                  : This option is a comma separated list in kilobytes for each mapping.
                               Max 8 entries are supported. The value should be in the hex-decimal.
     --ds_port               : This is an optional parameter. And this option is to used to configure the
                               PCI ID of the PCIe switch downstream port. The valid range is from 1 to 65535.

EXAMPLES :
     To query trusted vf state
         niccli -i 1 vf --trust --show --vf_index 1
     To enable trusted vf state
         niccli -i 1 vf --trust --set --vf_index 1 --state enable
     To add ntuple flow filter for the specified MAC and destination port
         niccli -i 1 vf --add_ntuple_filter --macaddress 00:01:02:03:04:a3 -p 1023 -P 0xFFFF -v 1 -T 1
     To free ntuple flow filter for the specified filter id
         niccli -i 1 vf --free_ntuple_filter --filter_id F06C0000D6C22414
     To configure the GPU host and guest physical address mapping
         niccli -i 1 vf --peer_mem_map --hpa 0x1FFFFFFF,0x2FFFFFFF,0x3FFFFFFF,0x4FFFFFFF
            --gpa 0x9FFFFFFF,0xAFFFFFFF,0xBFFFFFFF,0xCFFFFFFF
            --size 0x10000,0x10000,0x8000,0x8000
         niccli -i 1 vf --peer_mem_map --hpa 0x1FFFFFFF,0x2FFFFFFF,0x3FFFFFFF,0x4FFFFFFF
            --gpa 0x9FFFFFFF,0xAFFFFFFF,0xBFFFFFFF,0xCFFFFFFF
            --size 0x10000,0x10000,0x8000,0x8000 --ds_port 20

cfgtunnel commands
==================
DESCRIPTION :
     Performs Custom, GRE Tunnel and RSS(receive side scaling) operations.
     This command is supported on Linux, Windows, FreeBSD and VMWare operating systems.

SYNTAX :
     tunnel --cfg --vxlan <-t|--type> <ipv4|ipv6> --show
     tunnel --cfg --vxlan <--add> <-t|--type> <ipv4|ipv6> <-p|--dest_port> <value>
     tunnel --cfg --vxlan <--del> <-t|--type> <ipv4|ipv6> <-p|--dest_port> <value>
     tunnel --cfg <--rss> --show
     tunnel --cfg <--rss> --set <--mode> <inner/outer>
     tunnel --cfg <-g|--gre_tunnel_offload> --show
     tunnel --cfg <-g|--gre_tunnel_offload> --set --state <enable/disable>

OPTIONS :
     --cfg                   : Perform Custom, GRE Tunnel and RSS(receive side scaling) operations.
     --vxlan                 : Option to query or configure vxlan type.
     -t|--type               : Option to provide the IP type. The valid values are "ipv4" and "ipv6".
     -p|--dest_port          : Option to provide the destination port. Valid range is 0-65535.
     --rss                   : Option to query and configure RSS(receive side scaling).
     --mode                  : Option to configure the RSS mode. The valid values are "inner" and "outer".
     -g|--gre_tunnel_offload : Option to query and configure the custom GRE tunnel offload.
     --state                 : Option to enable or disable the non udp port based GRE tunnel offload.


EXAMPLES :
     To show the custom tunnel configuration
         niccli -i 1 tunnel --cfg --vxlan --type ipv4 --show
     To add the custom tunnel configuration on destination port
         niccli -i 1 tunnel --cfg --vxlan --add --type ipv4 --dest_port 1024
     To delete the custom tunnel configuration on destination port
         niccli -i 1 tunnel --cfg --vxlan --del --type ipv4 --dest_port 1024
     To show the RSS mode configuration
         niccli -i 1 tunnel --cfg --rss --show
     To configure the RSS inner mode
         niccli -i 1  tunnel --cfg --rss --set --mode inner
     To show the state of GRE tunnel offload
         niccli -i 1 tunnel --cfg --gre_tunnel_offload --show
     To enable the non udp port based GRE tunnel offload
         niccli -i 1 tunnel --cfg --gre_tunnel_offload --set --state enable

msix commands
=============
DESCRIPTION :
     Query and configure the number of MSI-X max vectors values for VF's per each PF
     This command is supported only in the Linux and Windows operating systems.

SYNTAX :
     msix -m|--max_vectors --show [--all | --pf <pf number>]
     msix -m|--max_vectors --set [--pf <pf number>]

OPTIONS :
     -m|--max_vectors : Retrieves the register dump and crashdump from the firmware.
     --pf             : PF Number to query the table of 8 rows for msix max vectors.
     --show           : Get the msix max vectors for PF.
     --set            : Confiure the msix max vectors for PF.
     --all            : Displays msix max vectors for all the PF's.

EXAMPLES :
     To display the MSI-X max vectors values
         niccli -i 1 msix --max_vectors --show --pf 0
     To display all the values of MSI-X max vectors
         niccli -i 1 msix --max_vectors --show --all
     To configure the MSI-X max vectors values for PF 0
         niccli -i 1 msix --max_vectors --set --pf 0

mh command
============
DESCRIPTION :
     Query and configure the Broadcom Multi-Host PF information.
     This command is supported only in the Linux, FreeBSD and Windows operating systems.

SYNTAX :
     mh -p|--pf_alloc --show
     mh -p|--pf_alloc --set --ep0 <pf_cnt> --ep1 <pf_cnt> --ep2 <pf_cnt> --ep3 <pf_cnt>

OPTIONS :
     -p|--pf_alloc    : PF Number to query Multi-Host PF information
     --show           : Query Multi-Host PF information
     --set            : Configure the Multi-Host PF information
     --ep0            : number of PF to be written on EP0
     --ep1            : number of PF to be written on EP1
     --ep2            : number of PF to be written on EP2
     --ep3            : number of PF to be written on EP3

     NOTE: The number of non-zero values can be for 2 endpoints or 4 endpoints.
     NOTE: The supported values for PF count are from 0 to 2.

EXAMPLES :
     To display the Multi-Host PF information
         niccli -i 1 mh --pf_alloc --show
     To configure the Multi-Host PF information
         niccli -i 1 mh --pf_alloc --set --ep0 0 --ep1 0 --ep2 0 --ep3 0

ring resource command
====================
DESCRIPTION :
     Query and Configure resources of the device.
     This command is supported on Linux, Windows, FreeBSD and VMWare operating systems.

SYNTAX :
     resmgmt [--pf/--all] [<-p|--profile> | < --min > |< --max > | <-r | --roce_max> | < -m | --max_completion_rings> |
                                     < -s | --strategy >] --show
     resmgmt [--pf/--all] --set [<-p|--profile> | < --min > |< --max > | <-r | --roce_max> | < -m | --max_completion_rings>]
                                     [< --bw <bandwidth of each pf with comma separated>] [< -s | --strategy > < minimal/maximal/minimal-static>]

OPTIONS :
     -p|--profile     : Active profile of the device
     -r|--roce_max    : RoCE enabled PF's on the device(supported only for Stratus & Cumulus-B/WHP)
     -m|--max_completion_rings : maximum completion rings for each active PF
     -s|--strategy    : strategy associated with each active PF.
     --min            : Minimum bandwidth associated with each active PF
     --max            : Maximum bandwidth associated with each active PF
     --show           : Displays resources of the device
     --set            : Configures resources of the device
     --bw             : Bandwidth to configure for PF N. This is applicable for min, max, roce_max and max_cmpl

EXAMPLES :
     To query resources of the device
         niccli -i 1 resmgmt --all --profile --show
     To configure resources of the device
         niccli -i 1 resmgmt --pf --set --bw 1,2,3 --strategy minimal


Congestion Control command
==========================
DESCRIPTION :
     This command is used to query and configure the congestion control(cc) parameters for RoCE.
     This command is supported on Linux, Windows, FreeBSD and VMWare operating systems.

SYNTAX :
     ccparams -d|--dump
     ccparams --set -f <configuration file>

OPTIONS :
     -d|--dump        : Dumps the congestion control parameters into a configuration <xxx>.CFG file.
                        The file will be generated in the same directory where the executable is running.
     --set            : To configure the congestion control parameters using a <xxx>.CFG file.
     -f               : Configuration file to configure the congestion control (cc) parameters.

EXAMPLES :
     To dump the congestion control params
         niccli -i 1 ccparams -d
         niccli -i 1 ccparams --dump
     To configure the congestion control params
         niccli -i 1 ccparams --set -f BCM957608-P2200GQF00_congestion_control_20250210_025627_19427.CFG

PCIe operations command
=======================
DESCRIPTION :
     Query and configure the PCIe operations. This command is supported on Linux, Windows, VMWare and FreeBSD operating systems.

SYNTAX :
     pcie <-c|--compliance> --state <0/1>
     pcie <-c|--compliance> --show

OPTIONS :
     -c|--compliance    : This option is used to query or configure the pcie compliance operations.
     --state            : This option is used to configure the pcie compliance state to enable/disable.
                          The valid values for this option are:
                              0 - Disable
                              1 - Enable
     --show             : This option is used to query the pcie compliance state.

EXAMPLES :
     niccli -i 1 pcie --compliance --show
     niccli -i 1 pcie --compliance --state 0


RoCE commands
==============

DESCRIPTION :
     Query and configure the congestion notification and TOS DSCP parameters
     This command is supported only in the VMWare operating systems.

SYNTAX :
     roce --cnp --show
     roce --cnp --set [--state <0/1>] --dscp <value>  -p|--priority <value> -E|--tos-ecn <value>
     roce --stats --show
     roce --set -T|--tos-dscp <value>

OPTIONS :
     --show           : Gets parameters of the bnxtroce driver.
     --set            : Sets congestion notification parameters for the bnxtroce driver.
     --state          : congestion control Disable(0)/enable(1) setting
     --dscp           : DSCP value for congestion notification packets (0-0x3F, default: 0).
     -p|--priority    : priority value for congestion notification packets.
     -E|--tos-ecn     : IP TOS ECN value settings 1 (0x1b) , 2(0x10b).
     --stats          : Gets the stats for the NIC
     -T|--tos-dscp    : IP TOS DSCP value for RoCEv2 Traffic

EXAMPLES :
1) To display the cnp parameter
     esxcli niccli roce --dev -v vmnic4 --cnp --show

2) To configure the cnp parameters
     esxcli niccli roce --dev -v vmnic4 --cnp --set --dscp 0 --state 0 -E 1

3) To display the stats of bnxtroce driver
     esxcli niccli roce --dev -v vmnic4 --stats --show

4)To configure the information of bnxtroce driver
    esxcli niccli roce --dev -v vmnic4 --set --tos-dscp 0x1


NOTE: This command is supported only in the VMWare operating systems.

UDCC commands
=============

DESCRIPTION :
     This command is used to query and configure user defined congestion control of IFA 2.0 (In-band Flow Analyzer)
     to improve the accuracy of network congestion estimation using network telemetry such as network latency
     and/or destination port utilization.

     This command is supported only in the Linux operating systems.

SYNTAX :
     udcc <-a|--ifa> --show
     udcc <-a|--ifa> --set [-p|--probe_pad_cnt <value>] [-t|--format <value>] [-g|--gns <value>]
           [-l|--hop_limit <value>] [-e|--req_vec <value>]

OPTIONS :
     --show             : This option is used to show the udcc configuration details.
     --set              : This option is used to configure the udcc parameters.
     -p|--probe_pad_cnt : This is an optional parameter used to configure the UDCC probe pad count.
                          The supported probe pad count values are as below :
                              0 - No custom changes to probe packet.
                              1 - The UDCC probe packet header's "PADCNT" field is set to 1
                              2 - The UDCC probe packet header's "PADCNT" field is set to 2
                              3 - The UDCC probe packet header's "PADCNT" field is set to 3
     -t|--format        : This is an optional parameter used to configure the UDCC probe format type.
                          The Supported UDCC probe format types are as below :
                              0 - MAD (Management Datagram)
                              1 - IFA 2.0 (Inband Flow Analyzer)
     -g|--gns           : This is an optional parameter used to configure the global name space.
                          The valid range is from 0 to 15.
     -l|--hop_limit     : This is an optional parameter used to configure the hop limit value.
                          The valid range is from 0 to 255.
     -e|--req_vec       : This is an optional parameter used to configure the request vector value.
                          The valid range is from 0 to 255.

EXAMPLES :
     To show the UDCC IFA 2.0 (Inband Flow Analyzer) details
       niccli -i 1 udcc --ifa --show
     To set the UDCC IFA 2.0 (Inband Flow Analyzer) parameters
       niccli -i 1 udcc --ifa --set --probe_pad_cnt 1 --format 1 --gns 15 --hop_limit 255 --req_vec 255

/* End of file */

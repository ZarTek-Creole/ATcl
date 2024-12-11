################################################################################
#                                                                              #
#                                  aTCL Script                                 #
#                                                                              #
################################################################################
#                                                                              #
#   Script Name  : aTCL Script                                                 #
#   Description  : A secure and modular TCL script for managing bot commands   #
#                  on IRC. Provides enhanced functionality, logging, and       #
#                  security measures.                                          #
#                                                                              #
#   Author       : ZarTek-Creole                                               #
#   GitHub       : https://github.com/ZarTek-Creole                            #
#   Script URL   : https://github.com/ZarTek-Creole/ATcl                       #
#   Version      : 1.6                                                         #
#                                                                              #
################################################################################
#                                                                              #
#                               Documentation                                  #
#                                                                              #
#   This script offers the following features:                                 #
#                                                                              #
#   1. Secure command execution:                                               #
#      - Only authorized users (bot owners) can execute commands.              #
#      - Commands are validated against a denylist before execution.           #
#                                                                              #
#   2. Modular design:                                                         #
#      - Uses namespaces for better encapsulation and organization.            #
#      - Dedicated functions for key responsibilities, such as command         #
#        execution, error handling, and logging.                               #
#                                                                              #
#   3. Enhanced logging and error handling:                                    #
#      - Centralized error management with user-friendly messages.             #
#      - Logs include details about executed commands and their arguments.     #
#                                                                              #
#   4. Accurate timing:                                                        #
#      - Execution time is measured with microsecond precision.                #
#      - Dynamic formatting for both microseconds (µs) and milliseconds (ms).  #
#                                                                              #
#   5. Comprehensive documentation:                                            #
#      - Each function is documented with clear descriptions of arguments,     #
#        return values, and behavior.                                          #
#                                                                              #
################################################################################
#                                                                              #
#                                Changelog                                     #
#                                                                              #
#   Version 1.6                                                                #
#   - Modularized the code with namespaces and separated responsibilities.     #
#   - Added `safeEval` for secure command execution with validation.           #
#   - Enhanced execution time precision with microseconds support.             #
#   - Introduced `formatExecutionTime` for dynamic time formatting.            #
#   - Improved readability with aligned variables and clear comments.          #
#   - Centralized error logging with `logError`.                               #
#   - Cleaned up multi-line responses and error messages.                      #
#                                                                              #
#   Version 1.0                                                                #
#   - Initial release with basic command execution and logging.                #
#                                                                              #
################################################################################
#                                                                              #
#                                Notes                                         #
#                                                                              #
#   - This script is part of the aTCL project. Contributions and feedback      #
#     are welcome via the GitHub repository linked above.                      #
#                                                                              #
#   - Ensure that your bot's configuration aligns with the variable            #
#     definitions at the beginning of the script.                              #
#                                                                              #
################################################################################


# Namespace for bot configuration
namespace eval ::atcl {

    # List of bot allowUsers (string)
    variable allowUsers                 "ZarTek Maloya Frozzak aMakafyta nkR _F0X_"

    # Denied commands for execution (list)
    variable deniedCommands             {}

    # List of commands to bind (string)
    variable listCommands               "atcl ${::botnick}tcl ${::nick}tcl"

    # Event binding for cleanup before rehash
    bind evnt -|- prerehash             ::atcl::deInit

    # Command bindings: Links public commands to the debug handler
    foreach bindCommand ${listCommands} {
        bind pub - "${bindCommand}"     ::atcl::tcl
    }
}

# Cleanup function to unload the module
# Args:
#     args (list): List of arguments (unused, optional for compatibility)
# Description:
#     Deletes the namespace and logs the unload event.
proc ::atcl::deInit {args} {
    catch {
        namespace delete [namespace current]
    }
    putlog "atcl: Module unloaded."
}

# Format execution time
# Args:
#     startTime (int): Start time in microseconds
#     endTime (int): End time in microseconds
# Returns:
#     string: Formatted execution time as "X.XXms" or "XXXµs"
proc ::atcl::formatExecutionTime {startTime endTime} {
    # Calculate elapsed time in microseconds
    set elapsed                        [expr {$endTime - $startTime}]

    # If less than 1ms, use µs
    if {$elapsed < 1000} {
        return "${elapsed}µs"
    }

    # Otherwise, convert to ms with 1 decimal place
    set elapsedMs                      [expr {$elapsed / 1000.0}]
    if {$elapsedMs < 0.1} {
        return "0.1ms"
    } else {
        return [format "%.1fms" $elapsedMs]
    }
}

# Safe evaluation function for commands
# Args:
#     command (string): Command to evaluate
#     args (list): List of arguments for the command
# Returns:
#     string: The result of the evaluation or a cleaned error message
proc ::atcl::safeEval {command args} {
    set args                           [join $args]
    try {
        if {[llength ${args}] == 0} {
            # Command without arguments
            return [eval $command]
        } elseif {[llength ${args}] > 0} {
            # Command with arguments
            return [eval $command [join $args]]
        } else {
            # Default case: should not occur
            error "Unexpected command structure"
        }
    } on return {result code} {
        # Return the actual result value
        return ${result}
    } on error {errorMessage} {
        # Only keep the first line of the error message for clarity
        error [lindex [split $errorMessage "\n"] 0]
    }
}

# Check if the user is a bot owner
# Args:
#     nick (string): The nickname of the user
#     chan (string): The channel where the command is executed
# Raises:
#     Error if the user is not a bot owner
# Description:
#     Validates whether the user is part of the bot allowUsers.
proc ::atcl::isBotOwner {nick chan} {
    variable allowUsers
    if {[lsearch -exact ${allowUsers} ${nick}] == -1} {
        set msg                        "${nick} access denied. Only allowed for the owner."
        ::atcl::logError ${msg} ${chan}
        error ${msg}
    }
}

# Validate commands against the denied list
# Args:
#     command (string): The command to validate
# Returns:
#     int: 1 if the command is allowed, 0 otherwise
# Description:
#     Prevents the execution of commands listed in `deniedCommands`.
proc ::atcl::isCommandDenied {command} {
    variable deniedCommands
    return [expr {!([lsearch -exact ${deniedCommands} ${command}] != -1)}]
}

# Log errors and notify users
# Args:
#     message (string): The error message to log and send
#     chan (string): The channel where the message is sent
# Description:
#     Logs the error in the bot's logs and sends a notification to the user.
proc ::atcl::logError {message chan} {
    putlog "Error: ${message}"
    putnow "PRIVMSG ${chan} :${message}"
}

# Main debug command handler
# Args:
#     nick (string): The nickname of the user
#     host (string): The hostname of the user
#     hand (string): The user handle
#     chan (string): The channel where the command is executed
#     args (list): The arguments passed to the command
# Description:
#     Handles command execution, validates permissions, and formats the response.
proc ::atcl::tcl {nick host hand chan args} {
    set args                           [split [join $args]]
    putlog "atcl: ${nick} ${host} ${hand} ${chan} ${args}"

    # Validate if the user is authorized
    ::atcl::isBotOwner ${nick} ${chan}

    # Ensure a command is provided
    if {[llength ${args}] == 0} {
        ::atcl::logError "No command provided." ${chan}
        return
    }
    set command                        [lrange ${args} 0 0]
    set commandArgs                    [lrange ${args} 1 end]

    # Check if the command is allowed
    if {![atcl::isCommandDenied ${command}]} {
        ::atcl::logError "Access denied for command: ${command}" ${chan}
        return
    }

    # Log command execution
    putcmdlog "atcl: ${nick} ${host} ${hand} ${chan} ${command} ${commandArgs}"

    # Measure execution time
    set start                          [clock microseconds]
    try {
        # Execute the command safely
        set result                    [::atcl::safeEval ${command} ${commandArgs}]
        set count                     [regexp -all -inline {\n} $result]
        if {$count != 0} {
            set result                "\n'\n${result}\n'"
        }
        set response                  "Execution successful: ${result}"
    } on error {errorMessage} {
        # Clean the error message for user output
        set cleanedError              [lindex [split $errorMessage "\n"] 0]
        set response                  "Execution failed: ${cleanedError}"
    }
    set end                            [clock microseconds]

    # Format execution time
    set executionTimeStr               [::atcl::formatExecutionTime $start $end]
    append response                   " - ${executionTimeStr}"

    # Split multi-line responses for better user output
    set response                       [split ${response} "\n"]
    foreach line ${response} {
        putnow "PRIVMSG ${chan} :${line}"
    }
}

# Log module loading
putlog "\[aTCL Script v1.6\] Module loaded with enhanced security, optimizations, and centralized error handling."

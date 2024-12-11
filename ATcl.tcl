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
#   Version      : 1.1                                                         #
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
#   Version 1.1                                                                #
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
#   - Corrected the main command handler to handle empty and multi-line        #
#     responses more effectively.                                              #
#   - Refactored the code to centralize repetitive patterns into utility        #
#     functions.                                                               #
#   - Improved logging and error handling readability.                         #
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
    variable allowUsers                 "MyName"

    # Denied commands for execution (list)
    variable deniedCommands             {die exec}

    # List of commands to bind (string)
    variable listCommands               "atcl ${::botnick}tcl ${::nick}tcl"

    # Event binding for cleanup before rehash
    bind evnt -|- prerehash             ::atcl::deInit

    # Command bindings: Links public commands to the debug handler
    foreach bindCommand ${listCommands} {
        bind pub - "${bindCommand}"     ::atcl::tcl
    }
}

# Utility: Log a message and send to the channel
# ------------------------------------------------------------------------------
# Args:
#     message (string): The message to log and send.
#     chan (string): The channel for the message.
# Returns:
#     None
# Description:
#     Logs a message to the bot's log and sends it to a specified channel.
proc ::atcl::logAndSend {message chan} {
    putlog "atcl: ${message}"
    putnow "PRIVMSG ${chan} :${message}"
}

# Cleanup function to unload the module
# ------------------------------------------------------------------------------
# Args:
#     args (list): Unused, optional arguments for compatibility.
# Returns:
#     None
# Description:
#     Deletes the namespace and logs the unload event.
proc ::atcl::deInit {args} {
    catch {namespace delete [namespace current]}
    putlog "atcl: Module unloaded."
}

# Format execution time
# ------------------------------------------------------------------------------
# Args:
#     startTime (int): Start time in microseconds.
#     endTime (int): End time in microseconds.
# Returns:
#     string: Formatted execution time as "X.XXms" or "XXXµs".
# Description:
#     Calculates and formats the elapsed time between two timestamps.
proc ::atcl::formatExecutionTime {startTime endTime} {
    set elapsed                        [expr {$endTime - $startTime}]; # Calculate elapsed time
    # Check for microseconds
    if {$elapsed < 1000} { return "${elapsed}µs" }
    # Convert to milliseconds
    return [format "%.1fms" [expr {$elapsed / 1000.0}]]
}

# Safe evaluation function for commands
# ------------------------------------------------------------------------------
# Args:
#     command (string): The command to evaluate.
#     args (list): List of arguments for the command.
# Returns:
#     string: The result of the evaluation or a cleaned error message.
# Description:
#     Evaluates a command with arguments safely and captures any errors.
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
# ------------------------------------------------------------------------------
# Args:
#     nick (string): Nickname of the user.
#     chan (string): Channel where the command is executed.
# Returns:
#     None
# Raises:
#     Error: If the user is not a bot owner.
# Description:
#     Checks if a user is authorized as a bot owner.
proc ::atcl::isBotOwner {nick chan} {
    variable allowUsers
    if {[lsearch -exact ${allowUsers} ${nick}] == -1} {
        ::atcl::logAndSend "${nick} access denied. Only allowed for the owner." \
                           ${chan}
        error "${nick} access denied."
    }
}

# Validate commands against the denied list
# ------------------------------------------------------------------------------
# Args:
#     command (string): The command to validate.
# Returns:
#     int: 1 if the command is allowed, 0 otherwise.
# Description:
#     Validates whether a command is allowed to execute.
proc ::atcl::isCommandDenied {command} {
    variable deniedCommands
    return [expr {[lsearch -exact ${deniedCommands} ${command}] == -1}]
}

# Main debug command handler
# ------------------------------------------------------------------------------
# Args:
#     nick (string): Nickname of the user.
#     host (string): Hostname of the user.
#     hand (string): User handle.
#     chan (string): Channel where the command is executed.
#     args (list): Arguments passed to the command.
# Returns:
#     None
# Description:
#     Handles command execution, validates permissions, and sends formatted responses.
proc ::atcl::tcl {nick host hand chan args} {
    set args                           [split [join $args]]
    putlog "atcl: ${nick} ${host} ${hand} ${chan} ${args}"

    # Validate user
    ::atcl::isBotOwner ${nick} ${chan}

    # Ensure a command is provided
    if {[llength ${args}] == 0} {
        ::atcl::logAndSend "No command provided." ${chan}
        return
    }

    set command                        [lindex ${args} 0]
    set commandArgs                    [lrange ${args} 1 end]

    # Check command validity
    if {![::atcl::isCommandDenied ${command}]} {
        ::atcl::logAndSend "Access denied for command: ${command}" ${chan}
        return
    }

    # Log command execution
    putcmdlog "atcl: ${nick} ${host} ${hand} ${chan} ${command} ${commandArgs}"

    # Measure execution time
    set start                          [clock microseconds]
    try {
        set result [::atcl::safeEval ${command} ${commandArgs}]
        # Check for empty result
        if {[string length ${result}] == 0} {
            set response                 "Execution successful"
        } else {
          #  Check for multi-line result
          if {[regexp -all -inline {\n} ${result}] != 0} {
              set response               "Execution successful\n'\n${result}\n'"; # Add newlines for multi-line results
          } else  {
              set response               "Execution successful: ${result}";       # Single-line result
          }
        }
    } on error {errorMessage} {
        set response                   "Execution failed: ${errorMessage}";     # Log error
    }
    set end                             [clock microseconds];                   # Measure execution time
    append response " - [::atcl::formatExecutionTime ${start} ${end}]";         # Add execution time to response

    # Send response
    foreach line [split ${response} "\n"] {
        putnow "PRIVMSG ${chan} :${line}"
    }
}

# Log module loading
putlog "\[aTCL Script v1.1\] Module loaded with enhanced security, optimizations, and centralized error handling."

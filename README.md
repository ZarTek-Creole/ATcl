# aTCL Script


|  |  |
| --- | --- |
| ![aTCL Logo](https://s3.amazonaws.com/i.snag.gy/M62ldk.jpg) | ![aTCL Logo](https://dummyimage.com/600x200/918191/1e28b3&text=ATcl+Script) |

aTCL Script is a **TCL module** for **Eggdrop bots**, enabling secure execution of TCL commands directly from IRC. It includes access control, command validation, logging, and precise execution timing for enhanced usability and security.
---

![GitHub release (latest by date)](https://img.shields.io/github/v/release/ZarTek-Creole/ATcl)
![GitHub issues](https://img.shields.io/github/issues/ZarTek-Creole/ATcl)
![GitHub license](https://img.shields.io/github/license/ZarTek-Creole/ATcl)
![GitHub stars](https://img.shields.io/github/stars/ZarTek-Creole/ATcl)
![GitHub forks](https://img.shields.io/github/forks/ZarTek-Creole/ATcl)
![GitHub contributors](https://img.shields.io/github/contributors/ZarTek-Creole/ATcl)
![GitHub last commit](https://img.shields.io/github/last-commit/ZarTek-Creole/ATcl)

---

## Table of Contents

1. [Features](#features)
2. [Getting Started](#getting-started)
   - [Installation](#installation)
3. [Usage Examples](#usage-examples)
   - [Basic Command Execution](#1-basic-command-execution)
   - [Access Denied for Unauthorized Users](#2-access-denied-for-unauthorized-users)
   - [Error Handling](#3-error-handling)
   - [Multi-Line Results](#4-multi-line-results)
   - [Restricted Commands](#5-restricted-commands)
4. [Configuration](#configuration)
   - [Variables](#variables)
5. [Changelog](#changelog)
6. [Evaluation](#evaluation)
7. [Contributing](#contributing)
8. [License](#license)
9. [Contact](#contact)

---

## Features

- **TCL command execution via IRC**:
  - Execute TCL commands securely in real-time from IRC channels.
  - Ideal for bot administrators and advanced bot customization.

- **Access control**:
  - Define a list of allowed users (bot owners).
  - Restrict specific commands using a denylist for additional security.

- **Detailed logging**:
  - Logs all executed commands, including the user, arguments, and results.
  - Includes error logs for debugging and tracking.

- **Precise execution timing**:
  - Tracks the execution time of commands with microsecond precision.
  - Results are dynamically formatted for readability in microseconds (`µs`) or milliseconds (`ms`).

- **Multi-line and dynamic outputs**:
  - Handles and formats outputs spanning multiple lines for readability.

---

## Getting Started

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ZarTek-Creole/ATcl.git
   cd ATcl
   ```

2. **Add the script to your bot**:
   - Copy the `atcl.tcl` script to your Eggdrop's script directory.
   - Load the script in your bot's configuration file:
     ```tcl
     source scripts/atcl.tcl
     ```

3. **Configure the script**:
   - Open `atcl.tcl` and modify the variables:
     - `allowUsers`: Define who can execute commands.
     - `deniedCommands`: Specify commands that are restricted.

4. **Restart your bot**:
   - Reload your Eggdrop bot to apply the changes and enable aTCL.

---

## Usage Examples

### 1. **Basic Command Execution**
From IRC, you can execute a basic TCL command:
```plaintext
<~Owner> atcl return "Hello, World!"
<@Bot> Execution successful: Hello, World! - 0.5ms
```

### 2. **Access Denied for Unauthorized Users**
Unauthorized users will receive a clear error message:
```plaintext
<~RandomUser> atcl expr {1 + 1}
<@Bot> RandomUser access denied. Only allowed for the owner.
```

### 3. **Error Handling**
If an invalid command is executed, the error is returned:
```plaintext
<~Owner> atcl invalidCommand
<@Bot> Execution failed: invalidCommand: command not found - 0.3ms
```

### 4. **Multi-Line Results**
For commands that return multi-line outputs:
```plaintext
<~Owner> atcl list a b c
<@Bot> Execution successful: 
'
a
b
c
'
 - 0.7ms
```

### 5. **Restricted Commands**
If a restricted command (from `deniedCommands`) is attempted:
```plaintext
<~Owner> atcl exec ls
<@Bot> Access denied for command: exec
```

---

## Configuration

The script allows easy customization via variables:

### Variables

- **`allowUsers`**:
  Define the list of authorized users. Example:
  ```tcl
  variable allowUsers "User1 Admin Owner"
  ```

- **`deniedCommands`**:
  Define the list of restricted commands. Example:
  ```tcl
  variable deniedCommands {exec fork eval}
  ```

- **`listCommands`**:
  Define the IRC commands that trigger the script. Example:
  ```tcl
  variable listCommands "atcl ${::botnick}tcl ${::nick}tcl"
  ```

---

## Changelog

### Version 1.1
- Enhanced readability with aligned variables and consistent formatting.
- Added explicit type documentation for variables.
- Converted docstrings to TCL-compatible comments.
- Refactored multi-line handling for better output.
- Modularized the code with namespaces and separated responsibilities.
- Added `safeEval` for secure command execution with validation.
- Enhanced execution time precision with microseconds support.
- Introduced `formatExecutionTime` for dynamic time formatting.
- Improved readability with aligned variables and clear comments.
- Centralized error logging with `logError`.
- Cleaned up multi-line responses and error messages.

### Version 1.0
- Initial release with basic command execution and logging.

---

## Evaluation

| **Criteria**              | **Rating**   |
|----------------------------|--------------|
| Feature Completeness       | ⭐⭐⭐⭐⭐       |
| Documentation Clarity      | ⭐⭐⭐⭐⭐       |
| Code Readability           | ⭐⭐⭐⭐⭐       |
| Ease of Configuration      | ⭐⭐⭐⭐⭐       |
| Security Features          | ⭐⭐⭐⭐⭐       |
| Error Handling             | ⭐⭐⭐⭐⭐       |

---

## Contributing

Contributions are welcome!  
If you'd like to contribute, please fork the repository and submit a pull request.  

For bug reports or feature requests, open an issue in the [GitHub Issues](https://github.com/ZarTek-Creole/ATcl/issues) section.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contact

For support, feature requests, or feedback, contact **[ZarTek-Creole](https://github.com/ZarTek-Creole)** via GitHub.

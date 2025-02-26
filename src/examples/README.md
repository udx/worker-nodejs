# UDX Worker Node.js Examples

This directory contains example services that demonstrate how to use the UDX Worker with Node.js applications.

## Examples

### Simple Server
A basic HTTP server example that demonstrates:
- Setting up a Node.js HTTP server
- Configuring worker services
- Handling environment variables
- Proper logging format

To use this example:
1. Copy the `simple-server` directory to your project
2. Update the service configuration in `.config/worker/services.yaml` as needed
3. Start the worker with the example service

## Directory Structure
Each example follows this structure:
```
example-name/
├── .config/
│   └── worker/
│       └── services.yaml    # Worker service configuration
└── index.js                # Main application code
```

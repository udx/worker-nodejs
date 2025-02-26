const http = require("http");
const port = process.env.APP_PORT || 8080;

// Create a simple HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("Welcome to UDX Worker Node.js! Example server is running.");
});

// Start the server
server.listen(port, () => {
  console.log(`[${new Date().toISOString()}] Server started on http://localhost:${port}/`);

  // Log a status message every 5 seconds
  setInterval(() => {
    console.log(`[${new Date().toISOString()}] Server is running...`);
  }, 5000);
});

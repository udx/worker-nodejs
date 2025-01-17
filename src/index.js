const http = require("http");
const port = process.env.APP_PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("Welcome to UDX Worker Node.js! Environment is set up correctly.");
});

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);

  // Run timer to print a message every 5 seconds
  setInterval(() => {
    process.stdout.write("Still running...\n");
  }, 2000);

  process.stdout.write("\n");
});

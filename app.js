// app.js
const express = require("express");
const app = express();
const port = process.env.PORT || 3001;

// Middleware to parse JSON body
app.use(express.json());

// ✅ Token for secure route (you can change it or use env var)
const VALID_TOKEN = process.env.API_TOKEN || "mysecrettoken";

// Middleware for Bearer token authentication
const authenticate = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const queryToken = req.query.token;

  let token = null;

  if (authHeader && authHeader.startsWith("Bearer ")) {
    token = authHeader.split(" ")[1];
  } else if (queryToken) {
    token = queryToken;
  }

  if (token === VALID_TOKEN) {
    next();
  } else {
    res.status(401).json({ message: "Unauthorized: Invalid or missing token" });
  }
};

// Simple routes
app.get("/", (req, res) => {
  res.send("Hello World! Welcome to Node.js");
});

app.get("/1", (req, res) => {
  res.send("Hello World! Welcome to 1");
});

app.get("/2", (req, res) => {
  res.send("Hello World! Welcome to 2");
});

app.get("/status", (req, res) => {
  res.json({
    status: "Server is running",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

app.post("/echo", (req, res) => {
  res.json({
    message: "You sent:",
    body: req.body,
  });
});

// 🔒 Secure API (requires token)
app.get("/secure", authenticate, (req, res) => {
  res.json({
    message: "You have accessed a secure API!",
    user: "Authorized User",
    time: new Date().toISOString(),
  });
});

// Start the server
app.listen(port, () => {
  console.log(`✅ Server running on http://localhost:${port}`);
});


const express = require("express");

const app = express();
const PORT = 3000;

// Home page
app.get("/", (req, res) => {
    res.send("CI/CD Rollback Project is Running");
});

// Health check endpoint
app.get("/health", (req, res) => {
    res.status(200).json({
        status: "healthy"
    });
});

app.listen(PORT, () => {
    console.log(`Application running on port ${PORT}`);
});

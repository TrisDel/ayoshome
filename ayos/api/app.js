const express = require('express');
const { exec } = require('child_process');
const cors = require('cors'); // Import the cors middleware
const app = express();
const port = 3000;

// Use the cors middleware to enable CORS for all routes
app.use(cors());

app.get('/db', (req, res) => {
  // Example system command: a Perl script that outputs JSON
  const command = '/ayos/api/dashboard.pl';

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return res.status(500).json({ error: `Error executing command: ${error.message}` });
    }

    if (stderr) {
      console.error(`Command stderr: ${stderr}`);
      return res.status(500).json({ error: `Command stderr: ${stderr}` });
    }

    try {
      // Parse the JSON output from the command
      const jsonOutput = JSON.parse(stdout);
      // Send the parsed JSON as the response
      res.json(jsonOutput);
    } catch (parseError) {
      console.error(`Error parsing JSON: ${parseError.message}`);
      return res.status(500).json({ error: `Error parsing JSON: ${parseError.message}` });
    }
  });
});

app.listen(port, () => {
  console.log(`API listening at http://localhost:${port}`);
});

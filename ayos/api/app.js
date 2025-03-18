const express = require('express');
const { exec } = require('child_process');
const app = express();
const port = 3000;

app.get('/db', (req, res) => {
  // Example system command: listing files in the current directory
  const command = 'ls'; // Use 'dir' for Windows

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing command: ${error.message}`);
      return res.status(500).send(`Error executing command: ${error.message}`);
    }

    if (stderr) {
      console.error(`Command stderr: ${stderr}`);
      return res.status(500).send(`Command stderr: ${stderr}`);
    }

    res.send(`Command output: ${stdout}`);
  });
});

app.listen(port, () => {
  console.log(`API listening at http://localhost:${port}`);
});


/**
 * Import Dependencies
 */
import express from 'express';

/**
 * Initialise Express Application
 */
const app = express();

app.listen(3000, () => {
  console.log(`Server running: http://localhost:3000`);
});

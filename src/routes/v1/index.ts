/**
 * Import node modules
 */
import { Router } from 'express';
const router = Router();

/**
 * Root route
 */
router.get('/', (req, res) => {
  res.status(200).json({
    message: 'API is live',
    status: 'ok',
    version: '1.0.0',
  });
});

export default router;

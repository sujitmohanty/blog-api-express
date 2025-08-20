/**
 * Import dependency
 */
import { Router } from 'express';

/**
 * Import Controllers
 */
import register from '@/controllers/v1/auth/register';

const router = Router();

router.post('/register', register);

export default router;

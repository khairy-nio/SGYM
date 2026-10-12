import { Router, Request, Response } from 'express';
import { prisma } from '../lib/prisma.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { authenticateToken, requireRole, AuthenticatedRequest } from '../middlewares/auth.middleware.js';

const router = Router();

// GET /api/v1/gyms
router.get('/', async (req: Request, res: Response) => {
  try {
    const gyms = await prisma.gym.findMany({
      orderBy: { rating: 'desc' },
    });
    sendSuccess(res, gyms, 'Gyms fetched successfully');
  } catch (error: any) {
    sendError(res, 'Failed to fetch gyms', 500, error.message);
  }
});

// GET /api/v1/gyms/:id
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const gym = await prisma.gym.findUnique({
      where: { id: req.params.id },
    });
    if (!gym) {
      sendError(res, 'Gym not found', 404);
      return;
    }
    sendSuccess(res, gym, 'Gym fetched successfully');
  } catch (error: any) {
    sendError(res, 'Failed to fetch gym', 500, error.message);
  }
});

// POST /api/v1/gyms (Owner only)
router.post(
  '/',
  authenticateToken,
  requireRole(['GYM_OWNER', 'ADMIN']),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { name, address, city, phone, about, facilities, imageUrl } = req.body;
      const gym = await prisma.gym.create({
        data: {
          name,
          address,
          city,
          phone,
          about,
          facilities: typeof facilities === 'string' ? facilities : JSON.stringify(facilities || []),
          imageUrl: imageUrl || 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
          ownerId: req.user!.id,
        },
      });

      // Update user gymId
      await prisma.user.update({
        where: { id: req.user!.id },
        data: { gymId: gym.id },
      });

      sendSuccess(res, gym, 'Gym created successfully', 201);
    } catch (error: any) {
      sendError(res, 'Failed to create gym', 500, error.message);
    }
  }
);

export default router;

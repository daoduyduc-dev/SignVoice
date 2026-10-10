import { Router, Request, Response, NextFunction } from 'express';
import { Favorite } from '../models/Favorite.model';
import { requireAuth } from '../common/middlewares/auth.middleware';
import { AppError } from '../common/errors/AppError';
import { ErrorCodes } from '../common/errors/errorCodes';
import { Types } from 'mongoose';

const router = Router();

// All favorites routes require authentication
router.use(requireAuth);

/**
 * @route GET /api/v1/favorites
 * @desc Get user's favorites
 * @access Private
 */
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication required', 401, ErrorCodes.AUTH_REQUIRED);
    }
    
    const { limit, skip } = req.query;
    
    const favorites = await Favorite.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(limit ? parseInt(limit as string) : 20)
      .skip(skip ? parseInt(skip as string) : 0)
      .populate({
        path: 'entryId',
        select: 'word definition videoUrl thumbnailUrl categoryId status',
        match: { status: 'PUBLISHED' },
      })
      .exec();
    
    res.status(200).json({
      success: true,
      data: favorites,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/v1/favorites
 * @desc Add favorite
 * @access Private
 */
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication required', 401, ErrorCodes.AUTH_REQUIRED);
    }
    
    const { entryId, notes } = req.body;
    
    if (!entryId || !Types.ObjectId.isValid(entryId)) {
      throw new AppError('Valid entry ID required', 400, ErrorCodes.BAD_REQUEST);
    }
    
    const favorite = await Favorite.findOneAndUpdate(
      { userId: req.user.id, entryId },
      { $set: { notes } },
      { upsert: true, new: true, runValidators: true }
    );
    
    res.status(201).json({
      success: true,
      data: favorite,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/v1/favorites/:entryId
 * @desc Remove favorite
 * @access Private
 */
router.delete('/:entryId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication required', 401, ErrorCodes.AUTH_REQUIRED);
    }
    
    const { entryId } = req.params;
    
    if (!Types.ObjectId.isValid(entryId)) {
      throw new AppError('Invalid entry ID', 400, ErrorCodes.BAD_REQUEST);
    }
    
    const result = await Favorite.deleteOne({
      userId: req.user.id,
      entryId,
    });
    
    if (result.deletedCount === 0) {
      throw new AppError('Favorite not found', 404, ErrorCodes.FAVORITE_NOT_FOUND);
    }
    
    res.status(200).json({
      success: true,
      data: { message: 'Favorite removed' },
    });
  } catch (error) {
    next(error);
  }
});

export default router;

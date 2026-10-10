import { Router } from 'express';
import * as dictionaryController from '../controllers/dictionary.controller';
import { authenticate, requireAuth, requirePermission } from '../common/middlewares/auth.middleware';
import { validate } from '../common/middlewares/validate.middleware';
import { staffCreateDictionarySchema, staffUpdateDictionarySchema } from '../validation/admin.validation';

const router = Router();

/**
 * @route GET /api/v1/dictionary/popular
 * @desc Get popular entries
 * @access Public
 */
router.get('/popular', dictionaryController.getPopularEntries);

/**
 * @route GET /api/v1/dictionary
 * @desc Get published dictionary entries with filters
 * @access Public (with optional auth for history tracking)
 */
router.get('/', authenticate, dictionaryController.getEntries);

/**
 * @route GET /api/v1/dictionary/:id
 * @desc Get dictionary entry by ID
 * @access Public (with optional auth for history tracking)
 */
router.get('/:id', authenticate, dictionaryController.getEntryById);

/**
 * @route POST /api/v1/dictionary
 * @desc Create draft entry
 * @access Private (STAFF/ADMIN)
 */
router.post('/', requireAuth, requirePermission('dictionary:write'), validate(staffCreateDictionarySchema), dictionaryController.createEntry);

/**
 * @route PATCH /api/v1/dictionary/:id
 * @desc Update draft entry
 * @access Private (STAFF/ADMIN)
 */
router.patch('/:id', requireAuth, requirePermission('dictionary:write'), validate(staffUpdateDictionarySchema), dictionaryController.updateEntry);

/**
 * @route POST /api/v1/dictionary/:id/publish
 * @desc Publish entry
 * @access Private (ADMIN)
 */
router.post('/:id/publish', requireAuth, requirePermission('content:publish'), dictionaryController.publishEntry);

/**
 * @route POST /api/v1/dictionary/:id/archive
 * @desc Archive entry
 * @access Private (ADMIN)
 */
router.post('/:id/archive', requireAuth, requirePermission('content:publish'), dictionaryController.archiveEntry);

export default router;

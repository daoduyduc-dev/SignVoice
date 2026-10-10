import { Router } from 'express';
import * as staffController from '../controllers/staff.controller';
import { requireAuth, requireStaff, requirePermission } from '../common/middlewares/auth.middleware';
import * as management from '../controllers/admin-management.controller';
import { validate } from '../common/middlewares/validate.middleware';
import { adminUpdateDictionarySchema } from '../validation/admin.validation';

const router = Router();

// All routes require STAFF or ADMIN role
router.use(requireAuth, requireStaff);

/**
 * GET /api/v1/staff/content
 * @desc Get content items for moderation with filters
 * @access Private (STAFF/ADMIN)
 */
router.get('/content', requirePermission('dictionary:read'), staffController.getContentForModeration);

/**
 * GET /api/v1/staff/content/:id
 * @desc Get single content item details
 * @access Private (STAFF/ADMIN)
 */
router.get('/content/:id', requirePermission('dictionary:read'), staffController.getContentById);

/**
 * PATCH /api/v1/staff/content/:id
 * @desc Update content item
 * @access Private (STAFF/ADMIN)
 */
router.patch('/content/:id', requirePermission('dictionary:write'), validate(adminUpdateDictionarySchema), management.updateDictionary);

/**
 * POST /api/v1/staff/content/:id/approve
 * @desc Approve content item
 * @access Private (STAFF/ADMIN)
 */
router.post('/content/:id/approve', requirePermission('content:publish'), staffController.approveContent);

/**
 * POST /api/v1/staff/content/:id/reject
 * @desc Reject content item with reason
 * @access Private (STAFF/ADMIN)
 */
router.post('/content/:id/reject', requirePermission('dictionary:write'), staffController.rejectContent);

/**
 * GET /api/v1/staff/users
 * @desc Get users with basic filtering (for support)
 * @access Private (STAFF/ADMIN)
 */
router.get('/users', requirePermission('users:read'), staffController.getUsers);

/**
 * GET /api/v1/staff/users/:id
 * @desc Get user details (for support)
 * @access Private (STAFF/ADMIN)
 */
router.get('/users/:id', requirePermission('users:read'), staffController.getUserDetails);

/**
 * GET /api/v1/staff/reports
 * @desc Get user reports/issues
 * @access Private (STAFF/ADMIN)
 */
router.get('/reports', staffController.getReports);

/**
 * PATCH /api/v1/staff/reports/:id
 * @desc Update report status
 * @access Private (STAFF/ADMIN)
 */
router.patch('/reports/:id', staffController.updateReport);

/**
 * GET /api/v1/staff/stats
 * @desc Get staff dashboard statistics
 * @access Private (STAFF/ADMIN)
 */
router.get('/stats', staffController.getStaffStats);

export default router;

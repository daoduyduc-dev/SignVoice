import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';
import { AppError } from '../errors/AppError';
import { ErrorCodes } from '../errors/errorCodes';

/**
 * Validation middleware factory
 * Validates request against Zod schema
 */
export function validate(schema: AnyZodObject) {
  return async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      const parsed = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      if (parsed.body !== undefined) req.body = parsed.body;
      if (parsed.query !== undefined) req.query = parsed.query;
      if (parsed.params !== undefined) req.params = parsed.params;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const messages = error.errors.map(err => {
          const path = err.path.slice(1).join('.'); // Remove 'body', 'query', or 'params' prefix
          return `${path}: ${err.message}`;
        });
        
        next(new AppError(
          messages.join(', '),
          400,
          ErrorCodes.VALIDATION_ERROR
        ));
        return;
      }
      next(error);
    }
  };
}

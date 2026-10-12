import { Response } from 'express';

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string | any;
  meta?: any;
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message: string = 'Operation successful',
  statusCode: number = 200,
  meta?: any
): Response {
  const responseBody: ApiResponse<T> = {
    success: true,
    message,
    data,
    meta,
  };
  return res.status(statusCode).json(responseBody);
}

export function sendError(
  res: Response,
  message: string = 'An error occurred',
  statusCode: number = 500,
  error?: any
): Response {
  const responseBody: ApiResponse = {
    success: false,
    message,
    error: error || undefined,
  };
  return res.status(statusCode).json(responseBody);
}

import { prisma } from '../lib/prisma.js';
import { hashPassword, comparePassword } from '../utils/password.js';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from '../utils/jwt.js';
import {
  SignupInput,
  LoginInput,
  ResetPasswordInput,
  UpdateProfileInput,
  ChangePasswordInput,
} from '../validators/auth.validator.js';

export class AuthService {
  /**
   * Register a new user (Consumer or Gym Owner)
   */
  static async signup(data: SignupInput) {
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      const error: any = new Error('An account with this email already exists.');
      error.statusCode = 409;
      throw error;
    }

    const hashedPassword = await hashPassword(data.password);

    // If gym owner, create gym record if gymName is provided
    let createdGymId: string | undefined;
    if (data.role === 'GYM_OWNER' && data.gymName) {
      const gym = await prisma.gym.create({
        data: {
          name: data.gymName,
          address: 'Cairo, Egypt',
          city: 'Cairo',
          rating: 5.0,
          reviewCount: 0,
          distance: 0.8,
          imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
          facilities: JSON.stringify(['Olympic Weights', 'Cardio Area', 'Locker Rooms']),
          phone: data.phone || '+20 100 000 0000',
        },
      });
      createdGymId = gym.id;
    }

    const user = await prisma.user.create({
      data: {
        email: data.email,
        password: hashedPassword,
        fullName: data.fullName,
        phone: data.phone || null,
        role: data.role,
        gymId: createdGymId || null,
        avatarUrl:
          data.role === 'GYM_OWNER'
            ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'
            : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      },
    });

    // Link gym to owner
    if (createdGymId) {
      await prisma.gym.update({
        where: { id: createdGymId },
        data: { ownerId: user.id },
      });
    }

    const tokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = generateAccessToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    // Save refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt,
      },
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        avatarUrl: user.avatarUrl,
        role: user.role,
        gymId: user.gymId,
        createdAt: user.createdAt,
      },
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: '1d',
      },
    };
  }

  /**
   * Authenticate user with Email & Password
   */
  static async login(data: LoginInput) {
    const user = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (!user) {
      const error: any = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    if (!user.isActive) {
      const error: any = new Error('Your account has been deactivated. Please contact support.');
      error.statusCode = 403;
      throw error;
    }

    const isValidPassword = await comparePassword(data.password, user.password);
    if (!isValidPassword) {
      const error: any = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    const tokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = generateAccessToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    // Save refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt,
      },
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        avatarUrl: user.avatarUrl,
        role: user.role,
        gymId: user.gymId,
        createdAt: user.createdAt,
      },
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: '1d',
      },
    };
  }

  /**
   * Refresh access token using refresh token
   */
  static async refreshToken(refreshTokenStr: string) {
    let payload;
    try {
      payload = verifyRefreshToken(refreshTokenStr);
    } catch {
      const error: any = new Error('Invalid or expired refresh token');
      error.statusCode = 401;
      throw error;
    }

    const storedToken = await prisma.refreshToken.findUnique({
      where: { token: refreshTokenStr },
      include: { user: true },
    });

    if (!storedToken || storedToken.expiresAt < new Date()) {
      if (storedToken) {
        await prisma.refreshToken.delete({ where: { id: storedToken.id } });
      }
      const error: any = new Error('Refresh token has expired or is invalid. Please log in again.');
      error.statusCode = 401;
      throw error;
    }

    const user = storedToken.user;
    if (!user || !user.isActive) {
      const error: any = new Error('User not found or deactivated');
      error.statusCode = 401;
      throw error;
    }

    // Token rotation
    await prisma.refreshToken.delete({ where: { id: storedToken.id } });

    const tokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const newAccessToken = generateAccessToken(tokenPayload);
    const newRefreshToken = generateRefreshToken(tokenPayload);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await prisma.refreshToken.create({
      data: {
        token: newRefreshToken,
        userId: user.id,
        expiresAt,
      },
    });

    return {
      tokens: {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: '1d',
      },
    };
  }

  /**
   * Generate 6-digit OTP for password reset
   */
  static async forgotPassword(email: string) {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Don't leak if email exists or not for security, but return simulated success
      return {
        message: 'If an account exists with this email, a reset code has been sent.',
        otp: process.env.NODE_ENV === 'development' ? '123456' : undefined,
      };
    }

    // Generate random 6-digit OTP (or fixed 123456 in dev for predictable testing)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    // Invalidate previous OTPs for this email
    await prisma.passwordResetOtp.updateMany({
      where: { email, used: false },
      data: { used: true },
    });

    await prisma.passwordResetOtp.create({
      data: {
        email,
        otp,
        expiresAt,
      },
    });

    return {
      message: 'Password reset code has been generated.',
      otp: process.env.NODE_ENV === 'development' ? otp : undefined,
    };
  }

  /**
   * Verify OTP & Reset Password
   */
  static async resetPassword(data: ResetPasswordInput) {
    const resetRecord = await prisma.passwordResetOtp.findFirst({
      where: {
        email: data.email,
        otp: data.otp,
        used: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!resetRecord) {
      const error: any = new Error('Invalid or expired reset code');
      error.statusCode = 400;
      throw error;
    }

    const user = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    const hashedPassword = await hashPassword(data.newPassword);

    await prisma.user.update({
      where: { id: user.id },
      data: { password: hashedPassword },
    });

    // Mark OTP as used
    await prisma.passwordResetOtp.update({
      where: { id: resetRecord.id },
      data: { used: true },
    });

    // Invalidate existing sessions
    await prisma.refreshToken.deleteMany({
      where: { userId: user.id },
    });

    return {
      message: 'Password has been successfully updated. You can now log in.',
    };
  }

  /**
   * Get current authenticated user
   */
  static async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        phone: true,
        avatarUrl: true,
        role: true,
        gymId: true,
        createdAt: true,
        addresses: {
          select: {
            id: true,
            label: true,
            street: true,
            city: true,
            building: true,
            floor: true,
            apartment: true,
            isDefault: true,
          },
        },
      },
    });

    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    return user;
  }

  /**
   * Update Profile
   */
  static async updateProfile(userId: string, data: UpdateProfileInput) {
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        fullName: data.fullName,
        phone: data.phone,
        avatarUrl: data.avatarUrl,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        phone: true,
        avatarUrl: true,
        role: true,
        gymId: true,
        createdAt: true,
      },
    });

    return updatedUser;
  }

  /**
   * Change password while authenticated
   */
  static async changePassword(userId: string, data: ChangePasswordInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    const isValid = await comparePassword(data.currentPassword, user.password);
    if (!isValid) {
      const error: any = new Error('Incorrect current password');
      error.statusCode = 400;
      throw error;
    }

    const hashedPassword = await hashPassword(data.newPassword);

    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return {
      message: 'Password changed successfully',
    };
  }

  /**
   * Log out user and invalidate refresh token
   */
  static async logout(refreshTokenStr?: string, userId?: string) {
    if (refreshTokenStr) {
      await prisma.refreshToken.deleteMany({
        where: { token: refreshTokenStr },
      });
    } else if (userId) {
      await prisma.refreshToken.deleteMany({
        where: { userId },
      });
    }

    return {
      message: 'Logged out successfully',
    };
  }
}

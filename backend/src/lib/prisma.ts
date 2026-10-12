import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';

const DATA_DIR = path.resolve(process.cwd(), 'data');
const DB_FILE = path.join(DATA_DIR, 'db.json');

export interface UserRecord {
  id: string;
  email: string;
  password: string;
  fullName: string;
  phone?: string | null;
  avatarUrl?: string | null;
  role: string;
  isActive: boolean;
  gymId?: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface RefreshTokenRecord {
  id: string;
  token: string;
  userId: string;
  expiresAt: string;
  createdAt: string;
}

export interface PasswordResetOtpRecord {
  id: string;
  email: string;
  otp: string;
  expiresAt: string;
  used: boolean;
  createdAt: string;
}

export interface AddressRecord {
  id: string;
  userId: string;
  label: string;
  street: string;
  city: string;
  building?: string | null;
  floor?: string | null;
  apartment?: string | null;
  isDefault: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface GymRecord {
  id: string;
  name: string;
  address: string;
  city: string;
  rating: number;
  reviewCount: number;
  distance: number;
  imageUrl: string;
  logoUrl?: string | null;
  coverUrl?: string | null;
  isOpen: boolean;
  openingHours: string;
  closingHours: string;
  phone?: string | null;
  about?: string | null;
  facilities: string;
  ownerId?: string | null;
  createdAt: string;
  updatedAt: string;
}

interface DatabaseSchema {
  users: UserRecord[];
  refreshTokens: RefreshTokenRecord[];
  passwordResetOtps: PasswordResetOtpRecord[];
  addresses: AddressRecord[];
  gyms: GymRecord[];
}

function generateId(): string {
  return 'id_' + Math.random().toString(36).substring(2, 11) + Date.now().toString(36);
}

class JsonDatabase {
  private data: DatabaseSchema = {
    users: [],
    refreshTokens: [],
    passwordResetOtps: [],
    addresses: [],
    gyms: [],
  };

  constructor() {
    this.init();
  }

  private init() {
    if (!fs.existsSync(DATA_DIR)) {
      fs.mkdirSync(DATA_DIR, { recursive: true });
    }

    if (fs.existsSync(DB_FILE)) {
      try {
        const content = fs.readFileSync(DB_FILE, 'utf-8');
        this.data = JSON.parse(content);
        return;
      } catch {
        // Fallback to seeding
      }
    }

    this.seedDefaultData();
    this.save();
  }

  private seedDefaultData() {
    const passwordHash = bcrypt.hashSync('Password123!', 10);
    const now = new Date().toISOString();

    const gym1Id = 'gym_pulse_001';
    const gym2Id = 'gym_iron_002';
    const consumerId = 'user_consumer_001';
    const ownerId = 'user_owner_001';

    this.data.gyms = [
      {
        id: gym1Id,
        name: 'Pulse Fitness',
        address: '15 Makram Ebeid, Nasr City',
        city: 'Nasr City',
        rating: 4.8,
        reviewCount: 342,
        distance: 1.2,
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        logoUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=100',
        coverUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900',
        isOpen: true,
        openingHours: '06:00 AM',
        closingHours: '11:00 PM',
        phone: '+20 100 111 2222',
        about: "Pulse Fitness is Cairo's premier fitness destination, offering state-of-the-art equipment and expert coaching.",
        facilities: JSON.stringify([
          'Olympic Weights',
          'Cardio Zone',
          'Swimming Pool',
          'Sauna',
          'Personal Training',
          'Group Classes',
          'Nutrition Bar',
          'Locker Rooms',
        ]),
        ownerId,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: gym2Id,
        name: 'Iron Forge Gym',
        address: '42 Road 9, Maadi',
        city: 'Maadi',
        rating: 4.9,
        reviewCount: 512,
        distance: 2.8,
        imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800',
        logoUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=100',
        coverUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=900',
        isOpen: true,
        openingHours: '05:30 AM',
        closingHours: '12:00 AM',
        phone: '+20 100 222 3333',
        about: 'Hardcore bodybuilding and powerlifting facility with competition-grade equipment and specialized coaching.',
        facilities: JSON.stringify(['Eleiko Barbells', 'Power Racks', 'Cardio Floor', 'Showers', 'Supplement Store']),
        ownerId: null,
        createdAt: now,
        updatedAt: now,
      },
    ];

    this.data.users = [
      {
        id: consumerId,
        email: 'user@gymio.com',
        password: passwordHash,
        fullName: 'Mohamed Ahmed',
        phone: '+20 100 123 4567',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        role: 'USER',
        isActive: true,
        gymId: null,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: ownerId,
        email: 'owner@pulsefitness.com',
        password: passwordHash,
        fullName: 'Coach Tarek Mansour',
        phone: '+20 100 999 8888',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        role: 'GYM_OWNER',
        isActive: true,
        gymId: gym1Id,
        createdAt: now,
        updatedAt: now,
      },
    ];

    this.data.addresses = [
      {
        id: 'addr_001',
        userId: consumerId,
        label: 'Home',
        street: '15 Makram Ebeid St',
        city: 'Nasr City, Cairo',
        building: 'Bld 14',
        floor: '3rd Floor',
        apartment: 'Apt 302',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'addr_002',
        userId: consumerId,
        label: 'Office',
        street: 'Smart Village, Building B12',
        city: '6th of October',
        building: 'Tower 4',
        floor: '5th Floor',
        apartment: null,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      },
    ];
  }

  private save() {
    try {
      fs.writeFileSync(DB_FILE, JSON.stringify(this.data, null, 2), 'utf-8');
    } catch (err) {
      console.error('Failed to save database file:', err);
    }
  }

  // ── USER MODEL METHODS ──────────────────────────────────
  user = {
    findUnique: async ({ where, select }: { where: { email?: string; id?: string }; select?: any }) => {
      const u = this.data.users.find(
        (user) => (where.email && user.email === where.email) || (where.id && user.id === where.id)
      );
      return u || null;
    },
    create: async ({ data }: { data: any }) => {
      const now = new Date().toISOString();
      const user: UserRecord = {
        id: generateId(),
        email: data.email,
        password: data.password,
        fullName: data.fullName,
        phone: data.phone || null,
        avatarUrl: data.avatarUrl || null,
        role: data.role || 'USER',
        isActive: true,
        gymId: data.gymId || null,
        createdAt: now,
        updatedAt: now,
      };
      this.data.users.push(user);
      this.save();
      return user;
    },
    update: async ({ where, data, select }: { where: { id: string }; data: any; select?: any }) => {
      const index = this.data.users.findIndex((u) => u.id === where.id);
      if (index === -1) throw new Error('User not found');
      this.data.users[index] = {
        ...this.data.users[index],
        ...data,
        updatedAt: new Date().toISOString(),
      };
      this.save();
      return this.data.users[index];
    },
  };

  // ── REFRESH TOKEN METHODS ───────────────────────────────
  refreshToken = {
    create: async ({ data }: { data: any }) => {
      const tokenRecord: RefreshTokenRecord = {
        id: generateId(),
        token: data.token,
        userId: data.userId,
        expiresAt: data.expiresAt instanceof Date ? data.expiresAt.toISOString() : data.expiresAt,
        createdAt: new Date().toISOString(),
      };
      this.data.refreshTokens.push(tokenRecord);
      this.save();
      return tokenRecord;
    },
    findUnique: async ({ where, include }: { where: { token: string }; include?: any }): Promise<any> => {
      const token = this.data.refreshTokens.find((r) => r.token === where.token);
      if (!token) return null;
      if (include?.user) {
        const user = this.data.users.find((u) => u.id === token.userId);
        return { ...token, expiresAt: new Date(token.expiresAt), user };
      }
      return { ...token, expiresAt: new Date(token.expiresAt) };
    },
    delete: async ({ where }: { where: { id: string } }) => {
      const index = this.data.refreshTokens.findIndex((r) => r.id === where.id);
      if (index !== -1) {
        const deleted = this.data.refreshTokens.splice(index, 1)[0];
        this.save();
        return deleted;
      }
      return null;
    },
    deleteMany: async ({ where }: { where: { token?: string; userId?: string } }) => {
      const beforeCount = this.data.refreshTokens.length;
      this.data.refreshTokens = this.data.refreshTokens.filter((r) => {
        if (where.token && r.token === where.token) return false;
        if (where.userId && r.userId === where.userId) return false;
        return true;
      });
      this.save();
      return { count: beforeCount - this.data.refreshTokens.length };
    },
  };

  // ── PASSWORD RESET OTP METHODS ─────────────────────────
  passwordResetOtp = {
    create: async ({ data }: { data: any }) => {
      const record: PasswordResetOtpRecord = {
        id: generateId(),
        email: data.email,
        otp: data.otp,
        expiresAt: data.expiresAt instanceof Date ? data.expiresAt.toISOString() : data.expiresAt,
        used: false,
        createdAt: new Date().toISOString(),
      };
      this.data.passwordResetOtps.push(record);
      this.save();
      return record;
    },
    findFirst: async ({ where, orderBy }: { where: any; orderBy?: any }) => {
      const now = new Date();
      return (
        this.data.passwordResetOtps.find((r) => {
          if (where.email && r.email !== where.email) return false;
          if (where.otp && r.otp !== where.otp) return false;
          if (where.used !== undefined && r.used !== where.used) return false;
          if (where.expiresAt?.gt && new Date(r.expiresAt) <= now) return false;
          return true;
        }) || null
      );
    },
    update: async ({ where, data }: { where: { id: string }; data: any }) => {
      const index = this.data.passwordResetOtps.findIndex((r) => r.id === where.id);
      if (index !== -1) {
        this.data.passwordResetOtps[index] = {
          ...this.data.passwordResetOtps[index],
          ...data,
        };
        this.save();
        return this.data.passwordResetOtps[index];
      }
      return null;
    },
    updateMany: async ({ where, data }: { where: any; data: any }) => {
      let count = 0;
      this.data.passwordResetOtps.forEach((r, idx) => {
        if (where.email && r.email !== where.email) return;
        if (where.used !== undefined && r.used !== where.used) return;
        this.data.passwordResetOtps[idx] = { ...r, ...data };
        count++;
      });
      this.save();
      return { count };
    },
  };

  // ── GYM METHODS ─────────────────────────────────────────
  gym = {
    findMany: async (args?: any) => {
      return [...this.data.gyms].sort((a, b) => b.rating - a.rating);
    },
    findUnique: async ({ where }: { where: { id: string } }) => {
      return this.data.gyms.find((g) => g.id === where.id) || null;
    },
    create: async ({ data }: { data: any }) => {
      const now = new Date().toISOString();
      const gym: GymRecord = {
        id: generateId(),
        name: data.name,
        address: data.address,
        city: data.city,
        rating: data.rating || 5.0,
        reviewCount: data.reviewCount || 0,
        distance: data.distance || 1.0,
        imageUrl: data.imageUrl,
        logoUrl: data.logoUrl || null,
        coverUrl: data.coverUrl || null,
        isOpen: data.isOpen !== undefined ? data.isOpen : true,
        openingHours: data.openingHours || '06:00 AM',
        closingHours: data.closingHours || '11:00 PM',
        phone: data.phone || null,
        about: data.about || null,
        facilities: data.facilities,
        ownerId: data.ownerId || null,
        createdAt: now,
        updatedAt: now,
      };
      this.data.gyms.push(gym);
      this.save();
      return gym;
    },
    update: async ({ where, data }: { where: { id: string }; data: any }) => {
      const index = this.data.gyms.findIndex((g) => g.id === where.id);
      if (index === -1) throw new Error('Gym not found');
      this.data.gyms[index] = {
        ...this.data.gyms[index],
        ...data,
        updatedAt: new Date().toISOString(),
      };
      this.save();
      return this.data.gyms[index];
    },
  };

  // ── ADDRESS METHODS ─────────────────────────────────────
  address = {
    findMany: async ({ where }: { where: { userId: string } }) => {
      return this.data.addresses.filter((a) => a.userId === where.userId);
    },
  };
}

export const prisma = new JsonDatabase();

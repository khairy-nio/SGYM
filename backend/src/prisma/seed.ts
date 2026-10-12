import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Clean old data
  await prisma.refreshToken.deleteMany();
  await prisma.passwordResetOtp.deleteMany();
  await prisma.address.deleteMany();
  await prisma.gym.deleteMany();
  await prisma.user.deleteMany();

  const defaultHashedPassword = await bcrypt.hash('Password123!', 10);

  // 1. Create Default Gym
  const gym1 = await prisma.gym.create({
    data: {
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
    },
  });

  const gym2 = await prisma.gym.create({
    data: {
      name: 'Iron Forge Gym',
      address: '42 Road 9, Maadi',
      city: 'Maadi',
      rating: 4.9,
      reviewCount: 512,
      distance: 2.8,
      imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800',
      isOpen: true,
      openingHours: '05:30 AM',
      closingHours: '12:00 AM',
      phone: '+20 100 222 3333',
      about: 'Hardcore bodybuilding and powerlifting facility with competition-grade equipment and specialized coaching.',
      facilities: JSON.stringify(['Eleiko Barbells', 'Power Racks', 'Cardio Floor', 'Showers', 'Supplement Store']),
    },
  });

  // 2. Create Consumer User
  const consumerUser = await prisma.user.create({
    data: {
      email: 'user@gymio.com',
      password: defaultHashedPassword,
      fullName: 'Mohamed Ahmed',
      phone: '+20 100 123 4567',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      role: 'USER',
      addresses: {
        create: [
          {
            label: 'Home',
            street: '15 Makram Ebeid St',
            city: 'Nasr City, Cairo',
            building: 'Bld 14',
            floor: '3rd Floor',
            apartment: 'Apt 302',
            isDefault: true,
          },
          {
            label: 'Office',
            street: 'Smart Village, Building B12',
            city: '6th of October',
            building: 'Tower 4',
            floor: '5th Floor',
            isDefault: false,
          },
        ],
      },
    },
  });

  // 3. Create Gym Owner User
  const ownerUser = await prisma.user.create({
    data: {
      email: 'owner@pulsefitness.com',
      password: defaultHashedPassword,
      fullName: 'Coach Tarek Mansour',
      phone: '+20 100 999 8888',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      role: 'GYM_OWNER',
      gymId: gym1.id,
    },
  });

  // Link gym to owner
  await prisma.gym.update({
    where: { id: gym1.id },
    data: { ownerId: ownerUser.id },
  });

  console.log('✅ Seed completed successfully!');
  console.log('-------------------------------------------');
  console.log('👤 Consumer Demo:  user@gymio.com / Password123!');
  console.log('🏋️ Owner Demo:     owner@pulsefitness.com / Password123!');
  console.log('🏢 Seeded Gyms:    2 Gyms (Pulse Fitness, Iron Forge)');
  console.log('-------------------------------------------');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

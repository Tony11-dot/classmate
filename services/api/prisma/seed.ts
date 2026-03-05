import { PrismaClient, TutorCharacterSubject } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {

  await prisma.tutorCharacter.createMany({
    data: [
      {
        name: "NOVA",
        subject: TutorCharacterSubject.GENERAL
      },
      {
        name: "Dr. Maxwell",
        subject: TutorCharacterSubject.PHYSICS
      },
      {
        name: "Euler",
        subject: TutorCharacterSubject.MATH
      }
    ],
    skipDuplicates: true
  })

  console.log("Tutor characters seeded")
}

main()
  .catch(e => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })

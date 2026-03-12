import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {

  const rows = [
    {
      subject: 'Computer Science',
      topicLabel: 'Conditions',
      year: 2024,
      season: 'summer',
      examCode: 'CS-001',
      questionIndex: 1,
      promptLatex: `Given the code: if (x > 0 && y < 5) { print("A"); } else { print("B"); } What prints for x=3,y=7?`,
      solutionLatex: `x>0 true, y<5 false -> condition false -> B prints`,
      difficulty: 'hard',
      points: 10
    },
    {
      subject: 'Math',
      topicLabel: 'Quadratic equations',
      year: 2023,
      season: 'winter',
      examCode: 'MATH-001',
      questionIndex: 2,
      promptLatex: `Solve x^2 - 5x + 6 = 0`,
      solutionLatex: `(x-2)(x-3)=0 -> x=2,3`,
      difficulty: 'medium',
      points: 10
    },
    {
      subject: 'Physics',
      topicLabel: 'Electricity',
      year: 2022,
      season: 'summer',
      examCode: 'PHY-001',
      questionIndex: 3,
      promptLatex: `Resistor 4Ω connected to 12V battery. Find current.`,
      solutionLatex: `I = V/R = 12/4 = 3A`,
      difficulty: 'easy',
      points: 8
    }
  ];

  for (const r of rows) {
    await prisma.bagrutQuestion.create({ data: r });
  }

  console.log("Seeded Bagrut questions");
}

main()
.then(()=>prisma.$disconnect())
.catch(async e=>{
  console.error(e);
  await prisma.$disconnect();
  process.exit(1);
});

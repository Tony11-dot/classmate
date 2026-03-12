import { PrismaClient } from '@prisma/client'
import fs from 'fs'

const prisma = new PrismaClient()

async function main() {
  const raw = fs.readFileSync('dataset/bagrut_questions.json', 'utf8')
  const data = JSON.parse(raw)

  if (!Array.isArray(data)) {
    throw new Error('dataset/bagrut_questions.json must be an array')
  }

  let inserted = 0
  let skipped = 0

  for (const q of data) {
    const exists = await prisma.bagrutQuestion.findFirst({
      where: {
        subject: String(q.subject),
        topicLabel: String(q.topicLabel),
        year: Number(q.year),
        season: String(q.season),
        examCode: String(q.examCode),
        questionIndex: Number(q.questionIndex),
      },
    })

    if (exists) {
      skipped++
      continue
    }

    await prisma.bagrutQuestion.create({ data: q })
    inserted++
  }

  console.log(JSON.stringify({ inserted, skipped, total: data.length }, null, 2))
}

main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })

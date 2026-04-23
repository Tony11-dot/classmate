import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';
import { clampTime, fillOptionsWithSafeFallback, uniqueFirst } from './practice-engine.utils';

@Injectable()
export class BroadCatalogDeterministicEngine implements PracticeEngine {
  readonly supportedModes = [
    'practice',
    'flashcards',
    'speedRound',
    'examPrep',
    'conceptBuilder',
    'adaptive',
  ] as const;

  supports(req: PracticeEngineRequest): boolean {
    const subject = this.norm(req.subject);
    const topic = this.topic(req);

    if (
      [
        'computer science',
        'chemistry',
        'biology',
        'english',
        'arabic',
        'hebrew',
      ].includes(subject)
    ) {
      return true;
    }

    if (subject === 'math') {
      return topic.includes('algebra') || topic.includes('inequal');
    }

    if (subject === 'physics') {
      return topic.includes('mechanics');
    }

    return false;
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
    const out: GeneratedQuestion[] = [];
    for (let i = 0; i < count; i++) {
      out.push(this.build(req, i));
    }
    return out;
  }

  private build(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    const subject = this.norm(req.subject);
    const topic = this.topic(req);

    if (subject === 'math') {
      return topic.includes('inequal')
        ? this.mathInequalities(req, seed)
        : this.mathAlgebra(req, seed);
    }

    if (subject === 'physics') {
      return this.physicsMechanics(req, seed);
    }

    if (subject === 'computer science') {
      return this.computerScience(req, topic, seed);
    }

    if (subject === 'chemistry') {
      return this.chemistry(req, topic, seed);
    }

    if (subject === 'biology') {
      return this.biology(req, topic, seed);
    }

    if (subject === 'english') {
      return this.english(req, topic, seed);
    }

    if (subject === 'arabic') {
      return this.arabic(req, topic, seed);
    }

    return this.hebrew(req, topic, seed);
  }

  private mathAlgebra(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    const m = this.pick(seed, [2, 3, 4, 5]);
    const x = this.pick(seed + 1, [2, 3, 4, 5, 6]);
    const c = this.pick(seed + 2, [1, 2, 4, 6]);
    const y = m * x + c;
    return this.question({
      req,
      topicMatchNote: 'Algebra',
      prompt: `For y = ${m}x + ${c}, what is the value of y when x = ${x}?`,
      correct: `${y}`,
      distractors: [`${m * x}`, `${m + x + c}`, `${y + 2}`],
      explanation: `Substitute x = ${x}: y = ${m}(${x}) + ${c} = ${m * x} + ${c} = ${y}.`,
      timeSeconds: this.timeFor(req, 24),
      seed,
    });
  }

  private mathInequalities(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    const x = this.pick(seed, [3, 4, 5, 6]);
    const add = this.pick(seed + 1, [1, 2, 3]);
    const right = x + add;
    return this.question({
      req,
      topicMatchNote: 'Inequalities',
      prompt: `Solve the inequality x + ${add} > ${right}.`,
      correct: `x > ${x}`,
      distractors: [`x < ${x}`, `x ≥ ${x}`, `x = ${x}`],
      explanation: `Subtract ${add} from both sides: x > ${right - add}, so x > ${x}.`,
      timeSeconds: this.timeFor(req, 26),
      seed,
    });
  }

  private physicsMechanics(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    if (seed % 2 === 0) {
      const speed = this.pick(seed, [4, 5, 6, 8]);
      const time = this.pick(seed + 1, [3, 4, 5, 6]);
      const distance = speed * time;
      return this.question({
        req,
        topicMatchNote: 'Mechanics',
        prompt: `A body moves at a constant speed of ${speed} m/s for ${time} s. How far does it travel?`,
        correct: `${distance} m`,
        distractors: [`${speed + time} m`, `${speed} m`, `${distance + speed} m`],
        explanation: `Distance = speed × time = ${speed} × ${time} = ${distance} m.`,
        timeSeconds: this.timeFor(req, 24),
        seed,
      });
    }

    const mass = this.pick(seed, [2, 3, 4, 5]);
    const accel = this.pick(seed + 1, [2, 3, 4]);
    const force = mass * accel;
    return this.question({
      req,
      topicMatchNote: 'Mechanics',
      prompt: `A ${mass} kg object accelerates at ${accel} m/s². What resultant force acts on it?`,
      correct: `${force} N`,
      distractors: [`${mass + accel} N`, `${accel} N`, `${force + mass} N`],
      explanation: `Use Newton's second law: F = ma = ${mass} × ${accel} = ${force} N.`,
      timeSeconds: this.timeFor(req, 28),
      seed,
    });
  }

  private computerScience(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (this.isProgrammingLanguageBasicsTopic(topic)) {
      return this.programmingLanguageBasics(req, seed);
    }

    if (topic.includes('nested')) {
      const n = this.pick(seed, [82, 67, 91, 74]);
      const answer = n >= 90 ? 'A' : n >= 75 ? 'B' : 'C';
      const language = this.requestedCodeLanguage(req);
      return this.question({
        req,
        topicMatchNote: language === 'csharp' ? 'Nested Conditions C#' : 'Nested Conditions',
        prompt: this.nestedConditionsPrompt(n, language),
        correct: answer,
        distractors: ['A', 'B', 'C'].filter((item) => item !== answer),
        explanation: `Check the conditions from top to bottom. For score = ${n}, the first matching branch prints "${answer}".`,
        timeSeconds: this.timeFor(req, 24),
        seed,
      });
    }

    if (topic.includes('boolean')) {
      const a = this.pick(seed, [7, 9, 5, 8]);
      const b = this.pick(seed + 1, [4, 6, 3, 7]);
      const c = this.pick(seed + 2, [2, 5, 1, 6]);
      const result = a > b && b > c;
      return this.question({
        req,
        topicMatchNote: 'Boolean Logic',
        prompt: `What is the value of the expression (${a} > ${b}) && (${b} > ${c})?`,
        correct: result ? 'true' : 'false',
        distractors: [result ? 'false' : 'true', '0', 'undefined'],
        explanation: `Both comparisons must be true for && to be true. Here the expression is ${result ? 'true' : 'false'}.`,
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('if / else') || (topic.includes('if') && topic.includes('else'))) {
      const a = this.pick(seed, [2, 4, 6, 3]);
      const b = this.pick(seed + 1, [5, 1, 7, 3]);
      const yes = a < b;
      const language = this.requestedCodeLanguage(req);
      return this.question({
        req,
        topicMatchNote: 'If / Else',
        prompt: `What does this print?\n\n${this.wrapCodeFence(
          [
            `if (${a} < ${b}) print("YES");`,
            'else print("NO");',
          ].join('\n'),
          language,
        )}`,
        correct: yes ? 'YES' : 'NO',
        distractors: [yes ? 'NO' : 'YES', 'Both YES and NO', 'Nothing'],
        explanation: `${a} < ${b} is ${yes ? 'true' : 'false'}, so the program prints "${yes ? 'YES' : 'NO'}".`,
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    if (topic.includes('condition')) {
      const a = this.pick(seed, [6, 3, 8, 2]);
      const b = this.pick(seed + 1, [5, 7, 1, 4]);
      const answer = a > b ? 'Condition is true' : 'Condition is false';
      return this.question({
        req,
        topicMatchNote: 'Conditions',
        prompt: `If the condition is (${a} > ${b}), which statement is correct?`,
        correct: answer,
        distractors: [answer === 'Condition is true' ? 'Condition is false' : 'Condition is true', 'The condition is undefined', 'The condition causes an error'],
        explanation: `Compare the two values directly: ${a} > ${b} is ${a > b ? 'true' : 'false'}.`,
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('loop')) {
      const start = this.pick(seed, [0, 1, 2, 3]);
      const end = start + this.pick(seed + 1, [3, 4, 5]);
      return this.question({
        req,
        topicMatchNote: 'Loops',
        prompt: `How many times does this loop run?\n\nfor (int i = ${start}; i < ${end}; i++) { ... }`,
        correct: `${end - start}`,
        distractors: [`${end - start + 1}`, `${end}`, `${start}`],
        explanation: `The loop uses i = ${start}, ${start + 1}, ... , ${end - 1}. That is ${end - start} iterations.`,
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('function')) {
      const x = this.pick(seed, [2, 3, 4, 5]);
      const answer = x * x + 1;
      return this.question({
        req,
        topicMatchNote: 'Functions',
        prompt: `If f(x) = x * x + 1, what is f(${x})?`,
        correct: `${answer}`,
        distractors: [`${x * 2 + 1}`, `${x * x}`, `${answer + 2}`],
        explanation: `Substitute x = ${x}: f(${x}) = ${x} * ${x} + 1 = ${answer}.`,
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('array')) {
      const values = [3, 7, 9, 12];
      const idx = this.pick(seed, [0, 1, 2, 3]);
      return this.question({
        req,
        topicMatchNote: 'Arrays',
        prompt: `Given arr = [${values.join(', ')}], what is arr[${idx}]?`,
        correct: `${values[idx]}`,
        distractors: values.filter((value) => value !== values[idx]).slice(0, 3).map(String),
        explanation: `Array indexing starts at 0, so arr[${idx}] is ${values[idx]}.`,
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('string')) {
      const word = this.pick(seed, ['class', 'nova', 'school', 'logic']);
      return this.question({
        req,
        topicMatchNote: 'Strings',
        prompt: `What is the length of the string "${word}"?`,
        correct: `${word.length}`,
        distractors: [`${word.length - 1}`, `${word.length + 1}`, '0'],
        explanation: `Count the characters in "${word}". It has ${word.length} characters.`,
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('variable')) {
      const a = this.pick(seed, [3, 5, 7, 9]);
      const b = this.pick(seed + 1, [2, 4, 6, 1]);
      const answer = a + b * 2;
      return this.question({
        req,
        topicMatchNote: 'Variables',
        prompt: `Given int a = ${a}; int b = ${b}; int c = a + b * 2; what is c?`,
        correct: `${answer}`,
        distractors: [`${(a + b) * 2}`, `${a * b + 2}`, `${answer - b}`],
        explanation: `Do multiplication first: ${b} * 2 = ${b * 2}. Then ${a} + ${b * 2} = ${answer}.`,
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    return this.question({
      req,
      topicMatchNote: 'Algorithms',
      prompt: 'What is the time complexity of scanning an array once from left to right?',
      correct: 'O(n)',
      distractors: ['O(1)', 'O(n^2)', 'O(log n)'],
      explanation: 'A single pass touches each of the n items once, so the time complexity is O(n).',
      timeSeconds: this.timeFor(req, 24),
      seed,
    });
  }

  private programmingLanguageBasics(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    const language = this.requestedCodeLanguage(req);
    if (language === 'html') {
      return this.htmlBasics(req, seed);
    }

    const languageName = this.languageDisplayName(language);
    const topicMatchNote = `${languageName} basics`;
    const difficulty = this.norm(String(req.difficulty ?? 'medium'));
    const timeSeconds = this.programmingBasicsTimeFor(req, difficulty);

    switch (seed % 5) {
      case 0: {
        const declaration = this.languageVariableDeclaration(language, seed);
        return this.question({
          req,
          topicMatchNote,
          prompt: `Which ${languageName} declaration correctly stores the integer value 5 in a variable named count?`,
          correct: declaration,
          distractors: this.languageVariableDistractors(language, declaration, seed),
          explanation: `${languageName} basics require the right type-and-name syntax. ${declaration} is the valid declaration for this integer variable.`,
          timeSeconds,
          seed,
        });
      }
      case 1: {
        const snippet = this.languageBranchingSnippet(language, difficulty, seed);
        return this.question({
          req,
          topicMatchNote,
          prompt: `In ${languageName} basics, what is printed by this snippet?\n\n${this.wrapCodeFence(snippet.code, language)}`,
          correct: snippet.correct,
          distractors: snippet.distractors,
          explanation: `Trace the ${languageName} control flow carefully. ${snippet.explanation}`,
          timeSeconds,
          seed,
        });
      }
      case 2: {
        const snippet = this.languageLoopSnippet(language, difficulty, seed);
        return this.question({
          req,
          topicMatchNote,
          prompt: `For this ${languageName} basics loop, how many times does the loop body run?\n\n${this.wrapCodeFence(snippet.code, language)}`,
          correct: snippet.correct,
          distractors: snippet.distractors,
          explanation: snippet.explanation,
          timeSeconds,
          seed,
        });
      }
      case 3: {
        const snippet = this.languageCollectionSnippet(language, difficulty, seed);
        return this.question({
          req,
          topicMatchNote,
          prompt: `Which value does this ${languageName} basics snippet print?\n\n${this.wrapCodeFence(snippet.code, language)}`,
          correct: snippet.correct,
          distractors: snippet.distractors,
          explanation: snippet.explanation,
          timeSeconds,
          seed,
        });
      }
      default: {
        const signature = this.languageFunctionSignature(language, seed);
        return this.question({
          req,
          topicMatchNote,
          prompt: `Which function signature is valid for a basic ${languageName} function that takes an integer named value and returns an integer?`,
          correct: signature,
          distractors: this.languageFunctionDistractors(language, signature, seed),
          explanation: `${signature} matches a basic ${languageName} function with one integer parameter and an integer return value.`,
          timeSeconds,
          seed,
        });
      }
    }
  }

  private chemistry(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (topic.includes('periodic')) {
      const entries = [
        ['Na', 'Sodium'],
        ['O', 'Oxygen'],
        ['C', 'Carbon'],
        ['H', 'Hydrogen'],
      ] as const;
      const item = this.pick(seed, entries);
      return this.question({
        req,
        topicMatchNote: 'Periodic Table',
        prompt: `Which element has the symbol ${item[0]}?`,
        correct: item[1],
        distractors: entries.map((entry) => entry[1]).filter((name) => name !== item[1]).slice(0, 3),
        explanation: `${item[0]} is the chemical symbol for ${item[1]}.`,
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('bond')) {
      return this.question({
        req,
        topicMatchNote: 'Chemical Bonds',
        prompt: 'What type of bond is typically formed between sodium and chlorine?',
        correct: 'Ionic bond',
        distractors: ['Covalent bond', 'Hydrogen bond', 'Metallic bond'],
        explanation: 'Sodium transfers an electron to chlorine, so the bond is ionic.',
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    if (topic.includes('reaction')) {
      return this.question({
        req,
        topicMatchNote: 'Reactions',
        prompt: 'In the reaction 2H₂ + O₂ → 2H₂O, what is formed as the product?',
        correct: 'Water',
        distractors: ['Hydrogen', 'Oxygen', 'Carbon dioxide'],
        explanation: 'The formula H₂O is water, so water is the product.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('stoichi')) {
      return this.question({
        req,
        topicMatchNote: 'Stoichiometry',
        prompt: 'How many hydrogen atoms are there in one molecule of H₂O?',
        correct: '2',
        distractors: ['1', '3', '4'],
        explanation: 'The subscript 2 after H means there are 2 hydrogen atoms in H₂O.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('acid') || topic.includes('base')) {
      return this.question({
        req,
        topicMatchNote: 'Acids and Bases',
        prompt: 'Which statement is correct about acids in water?',
        correct: 'They have a pH below 7',
        distractors: ['They have a pH above 7', 'They are always neutral', 'They contain no ions'],
        explanation: 'Acids have a pH below 7, while bases have a pH above 7.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    const atoms = [
      ['Oxygen', '8'],
      ['Carbon', '6'],
      ['Hydrogen', '1'],
      ['Nitrogen', '7'],
    ] as const;
    const item = this.pick(seed, atoms);
    return this.question({
      req,
      topicMatchNote: 'Atoms and Elements',
      prompt: `What is the atomic number of ${item[0]}?`,
      correct: item[1],
      distractors: atoms.map((entry) => entry[1]).filter((value) => value !== item[1]).slice(0, 3),
      explanation: `${item[0]} has ${item[1]} protons, so its atomic number is ${item[1]}.`,
      timeSeconds: this.timeFor(req, 18),
      seed,
    });
  }

  private biology(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (topic.includes('genetic')) {
      return this.question({
        req,
        topicMatchNote: 'Genetics',
        prompt: 'What is a gene?',
        correct: 'A segment of DNA that carries information for a trait',
        distractors: [
          'A type of cell membrane',
          'An organelle that makes protein',
          'A sugar used in respiration',
        ],
        explanation: 'Genes are segments of DNA that contain hereditary information.',
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    if (topic.includes('ecology')) {
      return this.question({
        req,
        topicMatchNote: 'Ecology',
        prompt: 'Which organism is usually a producer in a food chain?',
        correct: 'Green plant',
        distractors: ['Hawk', 'Rabbit', 'Fungus'],
        explanation: 'Producers make their own food, usually by photosynthesis. Green plants are producers.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('human')) {
      return this.question({
        req,
        topicMatchNote: 'Human Body',
        prompt: 'Which organ pumps blood around the human body?',
        correct: 'Heart',
        distractors: ['Lung', 'Liver', 'Kidney'],
        explanation: 'The heart pumps blood through the circulatory system.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('photosynthesis')) {
      return this.question({
        req,
        topicMatchNote: 'Photosynthesis',
        prompt: 'Where in the cell does photosynthesis mainly occur?',
        correct: 'Chloroplast',
        distractors: ['Nucleus', 'Mitochondrion', 'Ribosome'],
        explanation: 'Photosynthesis occurs mainly in chloroplasts.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    return this.question({
      req,
      topicMatchNote: 'Cells',
      prompt: 'Which organelle is known as the powerhouse of the cell?',
      correct: 'Mitochondria',
      distractors: ['Nucleus', 'Ribosome', 'Cell wall'],
      explanation: 'Mitochondria release usable energy for the cell, so they are called the powerhouse of the cell.',
      timeSeconds: this.timeFor(req, 18),
      seed,
    });
  }

  private english(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (topic.includes('tense')) {
      return this.question({
        req,
        topicMatchNote: 'Tenses',
        prompt: 'Choose the sentence in the present simple tense.',
        correct: 'She walks to school every day.',
        distractors: ['She is walking to school now.', 'She walked to school yesterday.', 'She has walked to school.'],
        explanation: 'The present simple is used for habits and routines, so “She walks to school every day.” is correct.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (topic.includes('vocabulary')) {
      return this.question({
        req,
        topicMatchNote: 'Vocabulary',
        prompt: 'Choose the word closest in meaning to “rapid”.',
        correct: 'fast',
        distractors: ['slow', 'quiet', 'late'],
        explanation: '“Rapid” means quick or fast.',
        timeSeconds: this.timeFor(req, 16),
        seed,
      });
    }

    if (topic.includes('reading') || topic.includes('comprehension')) {
      return this.question({
        req,
        topicMatchNote: 'Reading Comprehension',
        prompt: 'Read the sentence: “Maya studied every evening, so she felt calm before the exam.” Why did Maya feel calm?',
        correct: 'She prepared consistently.',
        distractors: ['The exam was cancelled.', 'She forgot about the exam.', 'Her friends answered for her.'],
        explanation: 'The sentence links regular studying with feeling calm, so her preparation caused the confidence.',
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('conditional')) {
      return this.question({
        req,
        topicMatchNote: 'Conditionals',
        prompt: 'Choose the correct first conditional sentence.',
        correct: 'If it rains, we will stay inside.',
        distractors: ['If it will rain, we stay inside.', 'If it rains, we stayed inside.', 'If it rained, we will stay inside.'],
        explanation: 'The first conditional uses present simple in the if-clause and will + base verb in the main clause.',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    return this.question({
      req,
      topicMatchNote: 'Grammar',
      prompt: 'Choose the correct sentence.',
      correct: 'She goes to school every day.',
      distractors: ['She go to school every day.', 'She going to school every day.', 'She gone to school every day.'],
      explanation: 'With third-person singular in the present simple, the verb takes -s: “She goes”.',
      timeSeconds: this.timeFor(req, 18),
      seed,
    });
  }

  private arabic(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (topic.includes('vocabulary') || topic.includes('مفردات')) {
      return this.question({
        req,
        topicMatchNote: 'Vocabulary',
        prompt: 'ما المرادف الأقرب لكلمة "سريع"؟',
        correct: 'عاجل',
        distractors: ['بطيء', 'هادئ', 'بعيد'],
        explanation: 'كلمة "عاجل" تدل على السرعة، فهي الأقرب معنى إلى "سريع".',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (
      topic.includes('reading') ||
      topic.includes('comprehension') ||
      topic.includes('قراءة') ||
      topic.includes('فهم')
    ) {
      const topicMatchNote =
        topic.includes('comprehension') || topic.includes('فهم')
          ? 'Comprehension'
          : 'Reading';

      return this.question({
        req,
        topicMatchNote,
        prompt: 'اقرأ: "استيقظ سامر مبكرًا لأنه أراد أن يراجع دروسه قبل الامتحان". لماذا استيقظ سامر مبكرًا؟',
        correct: 'ليُراجع دروسه قبل الامتحان',
        distractors: ['لأنه نسي موعد الحافلة', 'لأنه أراد اللعب', 'لأن الامتحان أُلغي'],
        explanation: 'الجملة تصرّح مباشرة أنه استيقظ مبكرًا لكي يراجع دروسه قبل الامتحان.',
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('writing') || topic.includes('كتابة')) {
      return this.question({
        req,
        topicMatchNote: 'Writing',
        prompt: 'أي جملة تصلح بدايةً مناسبة لفقرةٍ عن أهمية القراءة؟',
        correct: 'القراءة توسّع معرفة الطالب وتغذّي تفكيره.',
        distractors: ['الكتاب يطير فوق النافذة بسرعة.', 'لا علاقة للقراءة بتطوير الإنسان.', 'القراءة تعني النوم في كل وقت.'],
        explanation: 'الجملة الصحيحة تعبّر عن فكرة واضحة ومناسبة لموضوع أهمية القراءة.',
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    return this.question({
      req,
      topicMatchNote: 'Grammar',
      prompt: 'في الجملة: "ذهبَ الطالبُ إلى المدرسةِ"، ما نوع كلمة "الطالبُ"؟',
      correct: 'فاعل مرفوع',
      distractors: ['مفعول به منصوب', 'مبتدأ مرفوع', 'اسم مجرور'],
      explanation: 'في الجملة الفعلية "ذهبَ الطالبُ"، من قام بالفعل هو "الطالبُ"، لذلك هو فاعل مرفوع.',
      timeSeconds: this.timeFor(req, 20),
      seed,
    });
  }

  private hebrew(req: PracticeEngineRequest, topic: string, seed: number): GeneratedQuestion {
    if (topic.includes('vocabulary') || topic.includes('אוצר')) {
      return this.question({
        req,
        topicMatchNote: 'Vocabulary',
        prompt: 'מהי המילה הקרובה ביותר במשמעות ל"מהיר"?',
        correct: 'זריז',
        distractors: ['איטי', 'כבד', 'רחוק'],
        explanation: 'המילה "זריז" היא הקרובה ביותר במשמעות ל"מהיר".',
        timeSeconds: this.timeFor(req, 18),
        seed,
      });
    }

    if (
      topic.includes('reading') ||
      topic.includes('comprehension') ||
      topic.includes('קריאה') ||
      topic.includes('הבנת')
    ) {
      const topicMatchNote =
        topic.includes('comprehension') || topic.includes('הבנת')
          ? 'Comprehension'
          : 'Reading';

      return this.question({
        req,
        topicMatchNote,
        prompt: 'קרא/י: "נועה התאמנה כל השבוע ולכן הרגישה מוכנה למבחן". מדוע נועה הרגישה מוכנה?',
        correct: 'כי היא התאמנה כל השבוע',
        distractors: ['כי המבחן בוטל', 'כי היא שכחה מהחומר', 'כי חברה שלה ענתה במקומה'],
        explanation: 'המשפט מציג ישירות שהאימונים לאורך השבוע גרמו לה להרגיש מוכנה.',
        timeSeconds: this.timeFor(req, 22),
        seed,
      });
    }

    if (topic.includes('writing') || topic.includes('כתיבה')) {
      return this.question({
        req,
        topicMatchNote: 'Writing',
        prompt: 'איזה משפט מתאים לפתיחה של פסקה על חשיבות הלמידה?',
        correct: 'למידה קבועה עוזרת לתלמיד להבין את העולם ולהתקדם.',
        distractors: ['המחברת אוכלת ארוחת בוקר כל יום.', 'אין שום ערך ללמידה בבית הספר.', 'הלמידה פירושה לעצום עיניים תמיד.'],
        explanation: 'משפט פתיחה טוב צריך להיות ברור, תקין ומתאים לנושא הפסקה.',
        timeSeconds: this.timeFor(req, 20),
        seed,
      });
    }

    return this.question({
      req,
      topicMatchNote: 'Grammar',
      prompt: 'בחר/י את המשפט התקין מבחינה לשונית.',
      correct: 'היא הולכת לבית הספר כל יום.',
      distractors: ['היא הולך לבית הספר כל יום.', 'היא הלכו לבית הספר כל יום.', 'היא הולכים לבית הספר כל יום.'],
      explanation: 'הנושא הוא "היא", ולכן הפועל התקין הוא "הולכת".',
      timeSeconds: this.timeFor(req, 18),
      seed,
    });
  }

  private question(args: {
    req: PracticeEngineRequest;
    topicMatchNote: string;
    prompt: string;
    correct: string;
    distractors: string[];
    explanation: string;
    timeSeconds: number;
    seed: number;
  }): GeneratedQuestion {
    const options = this.shuffle(
      fillOptionsWithSafeFallback(
        uniqueFirst([args.correct, ...args.distractors], 4),
        args.correct,
        args.seed,
      ),
      args.seed,
    );

    return {
      prompt: args.prompt,
      options,
      correctIndex: options.indexOf(args.correct),
      correctAnswerText: args.correct,
      explanation: args.explanation,
      recommendedTimeSeconds: args.timeSeconds,
      topicMatchNote: args.topicMatchNote,
    };
  }

  private nestedConditionsPrompt(score: number, language: string): string {
    return `What does this print for score = ${score}?\n\n${this.wrapCodeFence(
      this.nestedConditionsCode(language),
      language,
    )}`;
  }

  private nestedConditionsCode(language: string): string {
    switch (language) {
      case 'csharp':
        return [
          'if (score >= 90)',
          '    Console.WriteLine("A");',
          'else if (score >= 75)',
          '    Console.WriteLine("B");',
          'else',
          '    Console.WriteLine("C");',
        ].join('\n');
      case 'javascript':
        return [
          'if (score >= 90) console.log("A");',
          'else if (score >= 75) console.log("B");',
          'else console.log("C");',
        ].join('\n');
      case 'python':
        return [
          'if score >= 90:',
          '    print("A")',
          'elif score >= 75:',
          '    print("B")',
          'else:',
          '    print("C")',
        ].join('\n');
      case 'java':
        return [
          'if (score >= 90)',
          '    System.out.println("A");',
          'else if (score >= 75)',
          '    System.out.println("B");',
          'else',
          '    System.out.println("C");',
        ].join('\n');
      default:
        return [
          'if (score >= 90) print("A");',
          'else if (score >= 75) print("B");',
          'else print("C");',
        ].join('\n');
    }
  }

  private wrapCodeFence(code: string, language: string): string {
    const label = language === 'csharp' ? 'csharp' : language;
    return '```' + label + '\n' + code + '\n```';
  }

  private isProgrammingLanguageBasicsTopic(topic: string): boolean {
    const hasKnownLanguage =
      /(c#|c sharp|csharp|python|javascript|java|html|hypertext markup)/i.test(
        topic,
      );
    const hasBasicsSignal =
      /\b(basic|basics|fundamental|fundamentals|intro|introduction|syntax|starter|getting started|beginner)\b/i.test(
        topic,
      );
    return hasKnownLanguage && hasBasicsSignal;
  }

  private programmingBasicsTimeFor(
    req: PracticeEngineRequest,
    difficulty: string,
  ): number {
    if (difficulty === 'olympiad') {
      return clampTime(req.timePreferenceSeconds, 65);
    }
    if (difficulty === 'hard') {
      return clampTime(req.timePreferenceSeconds, 45);
    }
    return clampTime(req.timePreferenceSeconds, 28);
  }

  private languageDisplayName(language: string): string {
    switch (language) {
      case 'html':
        return 'HTML';
      case 'csharp':
        return 'C#';
      case 'javascript':
        return 'JavaScript';
      case 'python':
        return 'Python';
      case 'java':
        return 'Java';
      default:
        return 'Dart';
    }
  }

  private languageVariableDeclaration(language: string, seed: number): string {
    const name = this.pick(seed, ['count', 'total', 'score', 'index']);
    const value = this.pick(seed + 1, [5, 7, 9, 11]);
    switch (language) {
      case 'csharp':
        return `int ${name} = ${value};`;
      case 'javascript':
        return `let ${name} = ${value};`;
      case 'python':
        return `${name} = ${value}`;
      case 'java':
        return `int ${name} = ${value};`;
      default:
        return `int ${name} = ${value};`;
    }
  }

  private languageVariableDistractors(language: string, correct: string, seed: number): string[] {
    const name = this.pick(seed, ['count', 'total', 'score', 'index']);
    const value = this.pick(seed + 1, [5, 7, 9, 11]);
    const pool = (() => {
      switch (language) {
        case 'csharp':
          return [`${name} int = ${value};`, `int = ${value} ${name};`, `${name} = int ${value};`];
        case 'javascript':
          return [`int ${name} = ${value};`, `${name} := ${value}`, `let ${name} : ${value}`];
        case 'python':
          return [`int ${name} = ${value}`, `${name} := int ${value}`, `${name} = ${value}; int`];
        case 'java':
          return [`${name} int = ${value};`, `let ${name} = ${value};`, `${name} := ${value}`];
        default:
          return [`${name} int = ${value};`, `let ${name} = ${value};`, `${name} := ${value}`];
      }
    })();

    return pool.filter((item) => item !== correct).slice(0, 3);
  }

  private languageBranchingSnippet(language: string, difficulty: string, seed: number): {
    code: string;
    correct: string;
    distractors: string[];
    explanation: string;
  } {
    const advanced = difficulty === 'hard' || difficulty === 'olympiad';
    const advancedScore = this.pick(seed, [14, 18, 22, 26]);
    const basicScore = this.pick(seed, [6, 8, 9, 4]);

    switch (language) {
      case 'csharp': {
        if (advanced) {
          return {
            code: [
              `int score = ${advancedScore};`,
              'if (score % 4 == 2 && score > 10)',
              '    Console.WriteLine("A");',
              'else if (score % 3 == 2)',
              '    Console.WriteLine("B");',
              'else',
              '    Console.WriteLine("C");',
            ].join('\n'),
            correct: 'A',
            distractors: ['B', 'C', 'Nothing'],
            explanation: `${advancedScore} % 4 == 2 and ${advancedScore} > 10, so the first branch runs and prints A.`,
          };
        }
        return {
          code: [
            `int score = ${basicScore};`,
            'if (score >= 10)',
            '    Console.WriteLine("High");',
            'else',
            '    Console.WriteLine("Low");',
          ].join('\n'),
          correct: 'Low',
          distractors: ['High', 'Both High and Low', 'Nothing'],
          explanation: `${basicScore} is not at least 10, so execution goes to the else branch and prints Low.`,
        };
      }
      case 'python': {
        return advanced
            ? {
                code: [
                  `score = ${advancedScore}`,
                  'if score % 4 == 2 and score > 10:',
                  '    print("A")',
                  'elif score % 3 == 2:',
                  '    print("B")',
                  'else:',
                  '    print("C")',
                ].join('\n'),
                correct: 'A',
                distractors: ['B', 'C', 'Nothing'],
                explanation: 'Both conditions in the first branch are true, so Python prints A.',
              }
            : {
                code: [
                  `score = ${basicScore}`,
                  'if score >= 10:',
                  '    print("High")',
                  'else:',
                  '    print("Low")',
                ].join('\n'),
                correct: 'Low',
                distractors: ['High', 'Both High and Low', 'Nothing'],
                explanation: '8 is below 10, so the else branch prints Low.',
              };
      }
      case 'javascript': {
        return advanced
            ? {
                code: [
                  `const score = ${advancedScore};`,
                  'if (score % 4 === 2 && score > 10) console.log("A");',
                  'else if (score % 3 === 2) console.log("B");',
                  'else console.log("C");',
                ].join('\n'),
                correct: 'A',
                distractors: ['B', 'C', 'Nothing'],
                explanation: 'The first boolean condition is true, so JavaScript logs A.',
              }
            : {
                code: [
                  `const score = ${basicScore};`,
                  'if (score >= 10) console.log("High");',
                  'else console.log("Low");',
                ].join('\n'),
                correct: 'Low',
                distractors: ['High', 'Both High and Low', 'Nothing'],
                explanation: '8 does not satisfy the if condition, so JavaScript logs Low.',
              };
      }
      default: {
        return advanced
            ? {
                code: [
                  `int score = ${advancedScore};`,
                  'if (score % 4 == 2 && score > 10)',
                  '    System.out.println("A");',
                  'else if (score % 3 == 2)',
                  '    System.out.println("B");',
                  'else',
                  '    System.out.println("C");',
                ].join('\n'),
                correct: 'A',
                distractors: ['B', 'C', 'Nothing'],
                explanation: 'The first Java condition is true, so the code prints A.',
              }
            : {
                code: [
                  `int score = ${basicScore};`,
                  'if (score >= 10)',
                  '    System.out.println("High");',
                  'else',
                  '    System.out.println("Low");',
                ].join('\n'),
                correct: 'Low',
                distractors: ['High', 'Both High and Low', 'Nothing'],
                explanation: '8 is below 10, so Java executes the else branch and prints Low.',
              };
      }
    }
  }

  private languageLoopSnippet(language: string, difficulty: string, seed: number): {
    code: string;
    correct: string;
    distractors: string[];
    explanation: string;
  } {
    const advanced = difficulty === 'hard' || difficulty === 'olympiad';
    const basicEnd = this.pick(seed, [4, 5, 6, 7]);
    const advancedStart = this.pick(seed, [2, 3, 4, 5]);
    const advancedEnd = advancedStart + 8;
    const code = (() => {
      switch (language) {
        case 'csharp':
          return advanced
              ? [`for (int i = ${advancedStart}; i <= ${advancedEnd}; i += 2)`, '    Console.WriteLine(i);'].join('\n')
              : [`for (int i = 0; i < ${basicEnd}; i++)`, '    Console.WriteLine(i);'].join('\n');
        case 'python':
          return advanced
              ? [`for i in range(${advancedStart}, ${advancedEnd + 1}, 2):`, '    print(i)'].join('\n')
              : [`for i in range(${basicEnd}):`, '    print(i)'].join('\n');
        case 'javascript':
          return advanced
              ? [`for (let i = ${advancedStart}; i <= ${advancedEnd}; i += 2) console.log(i);`].join('\n')
              : [`for (let i = 0; i < ${basicEnd}; i++) console.log(i);`].join('\n');
        default:
          return advanced
              ? [`for (int i = ${advancedStart}; i <= ${advancedEnd}; i += 2)`, '    System.out.println(i);'].join('\n')
              : [`for (int i = 0; i < ${basicEnd}; i++)`, '    System.out.println(i);'].join('\n');
      }
    })();

    const advancedCount = ((advancedEnd - advancedStart) / 2 + 1).toString();
    const basicCount = basicEnd.toString();

    return advanced
        ? {
            code,
            correct: advancedCount,
            distractors: [String(Number(advancedCount) - 1), String(Number(advancedCount) + 1), String(advancedEnd)].slice(0, 3),
            explanation: `The counter takes every second value from ${advancedStart} through ${advancedEnd}, so the loop body runs ${advancedCount} times.`,
          }
        : {
            code,
            correct: basicCount,
            distractors: [String(basicEnd - 1), String(basicEnd + 1), '0'],
            explanation: `The loop runs for i = 0 up to i = ${basicEnd - 1}, so it executes ${basicCount} times.`,
          };
  }

  private languageCollectionSnippet(language: string, difficulty: string, seed: number): {
    code: string;
    correct: string;
    distractors: string[];
    explanation: string;
  } {
    const advanced = difficulty === 'hard' || difficulty === 'olympiad';
    const values = this.pick(seed, [
      [2, 4, 6, 8],
      [3, 6, 9, 12],
      [5, 10, 15, 20],
      [1, 4, 7, 10],
    ] as const);

    switch (language) {
      case 'csharp':
        return advanced
            ? {
                code: [
                  `int[] values = {${values.join(', ')}};`,
                  'int index = values.Length - 2;',
                  'Console.WriteLine(values[index]);',
                ].join('\n'),
                correct: String(values[2]),
                distractors: [String(values[1]), String(values[3]), String(values[0])],
                explanation: `values.Length is 4, so index becomes 2 and values[2] is ${values[2]}.`,
              }
            : {
                code: [
                  `int[] values = {${values.join(', ')}};`,
                  'Console.WriteLine(values[1]);',
                ].join('\n'),
                correct: String(values[1]),
                distractors: [String(values[0]), String(values[2]), String(values[3])],
                explanation: `C# arrays use zero-based indexing, so values[1] is ${values[1]}.`,
              };
      case 'python':
        return advanced
            ? {
                code: [`values = [${values.join(', ')}]`, 'index = len(values) - 2', 'print(values[index])'].join('\n'),
                correct: String(values[2]),
                distractors: [String(values[1]), String(values[3]), String(values[0])],
                explanation: `len(values) is 4, so index is 2 and values[2] equals ${values[2]}.`,
              }
            : {
                code: [`values = [${values.join(', ')}]`, 'print(values[1])'].join('\n'),
                correct: String(values[1]),
                distractors: [String(values[0]), String(values[2]), String(values[3])],
                explanation: `Python lists are zero-indexed, so values[1] is ${values[1]}.`,
              };
      case 'javascript':
        return advanced
            ? {
                code: [`const values = [${values.join(', ')}];`, 'const index = values.length - 2;', 'console.log(values[index]);'].join('\n'),
                correct: String(values[2]),
                distractors: [String(values[1]), String(values[3]), String(values[0])],
                explanation: `values.length is 4, so the chosen index is 2 and the printed value is ${values[2]}.`,
              }
            : {
                code: [`const values = [${values.join(', ')}];`, 'console.log(values[1]);'].join('\n'),
                correct: String(values[1]),
                distractors: [String(values[0]), String(values[2]), String(values[3])],
                explanation: `JavaScript arrays start at index 0, so values[1] is ${values[1]}.`,
              };
      default:
        return advanced
            ? {
                code: [`int[] values = {${values.join(', ')}};`, 'int index = values.length - 2;', 'System.out.println(values[index]);'].join('\n'),
                correct: String(values[2]),
                distractors: [String(values[1]), String(values[3]), String(values[0])],
                explanation: `values.length is 4, so index is 2 and the array prints ${values[2]}.`,
              }
            : {
                code: [`int[] values = {${values.join(', ')}};`, 'System.out.println(values[1]);'].join('\n'),
                correct: String(values[1]),
                distractors: [String(values[0]), String(values[2]), String(values[3])],
                explanation: `Java arrays use zero-based indexing, so values[1] is ${values[1]}.`,
              };
    }
  }

  private languageFunctionSignature(language: string, seed: number): string {
    const name = this.pick(seed, ['DoubleValue', 'ScaleValue', 'ShiftValue', 'ClampValue']);
    switch (language) {
      case 'csharp':
        return `int ${name}(int value)`;
      case 'javascript':
        return `function ${name.charAt(0).toLowerCase()}${name.slice(1)}(value)`;
      case 'python':
        return `def ${name.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '')}(value):`;
      case 'java':
        return `int ${name.charAt(0).toLowerCase()}${name.slice(1)}(int value)`;
      default:
        return `int ${name.charAt(0).toLowerCase()}${name.slice(1)}(int value)`;
    }
  }

  private languageFunctionDistractors(language: string, correct: string, seed: number): string[] {
    const name = this.pick(seed, ['DoubleValue', 'ScaleValue', 'ShiftValue', 'ClampValue']);
    const camel = `${name.charAt(0).toLowerCase()}${name.slice(1)}`;
    const snake = name.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '');
    const pool = (() => {
      switch (language) {
        case 'csharp':
          return [`int ${name} = (int value)`, `${name} int(value)`, `function ${name}(value)`];
        case 'javascript':
          return [`int ${camel}(int value)`, `def ${snake}(value):`, `function = ${camel}(value)`];
        case 'python':
          return [`int ${snake}(int value)`, `def ${snake} = (value):`, `function ${snake}(value)`];
        case 'java':
          return [`function ${camel}(value)`, `def ${camel}(value):`, `${camel} int(value)`];
        default:
          return [`function ${camel}(value)`, `def ${camel}(value):`, `${camel} int(value)`];
      }
    })();

    return pool.filter((item) => item !== correct).slice(0, 3);
  }

  private requestedCodeLanguage(req: PracticeEngineRequest): string {
    const haystack = this.topicDescriptor(req);
    if (haystack.includes('html') || haystack.includes('hypertext markup')) {
      return 'html';
    }
    if (haystack.includes('c#') || haystack.includes('csharp') || haystack.includes('c sharp')) {
      return 'csharp';
    }
    if (haystack.includes('javascript')) return 'javascript';
    if (haystack.includes('python') || haystack.includes('pyhon') || haystack.includes('phyton')) {
      return 'python';
    }
    if (haystack.includes('java')) return 'java';
    return 'dart';
  }

  private htmlBasics(req: PracticeEngineRequest, seed: number): GeneratedQuestion {
    const difficulty = this.norm(String(req.difficulty ?? 'medium'));
    const advanced = difficulty === 'hard' || difficulty === 'olympiad';
    const timeSeconds = this.programmingBasicsTimeFor(req, difficulty);

    switch (seed % 5) {
      case 0:
        return this.question({
          req,
          topicMatchNote: 'HTML basics',
          prompt: 'Which HTML element is the best semantic choice for the main page heading?',
          correct: '<h1>',
          distractors: ['<p>', '<div>', '<span>'],
          explanation: '<h1> represents the top-level heading of the page, so it is the correct semantic choice.',
          timeSeconds,
          seed,
        });
      case 1:
        return this.question({
          req,
          topicMatchNote: 'HTML basics',
          prompt: advanced
              ? 'Which HTML snippet creates a clickable link that opens https://classmate.app in a new tab with the correct destination attribute?'
              : 'Which HTML snippet creates a clickable link to https://classmate.app?',
          correct: advanced
              ? '<a href="https://classmate.app" target="_blank" rel="noreferrer">Open Classmate</a>'
              : '<a href="https://classmate.app">Open Classmate</a>',
          distractors: advanced
              ? [
                  '<a src="https://classmate.app" target="_blank">Open Classmate</a>',
                  '<link href="https://classmate.app">Open Classmate</link>',
                  '<a url="https://classmate.app">Open Classmate</a>',
                ]
              : [
                  '<a src="https://classmate.app">Open Classmate</a>',
                  '<link href="https://classmate.app">Open Classmate</link>',
                  '<a url="https://classmate.app">Open Classmate</a>',
                ],
          explanation: 'Links use the <a> tag and the destination URL goes in the href attribute.',
          timeSeconds,
          seed,
        });
      case 2:
        return this.question({
          req,
          topicMatchNote: 'HTML basics',
          prompt: 'Which attribute provides alternative text for an image in HTML?',
          correct: 'alt',
          distractors: ['href', 'title', 'srcset'],
          explanation: 'The alt attribute gives a text alternative for the image when it cannot be seen or loaded.',
          timeSeconds,
          seed,
        });
      case 3:
        return this.question({
          req,
          topicMatchNote: 'HTML basics',
          prompt: advanced
              ? 'Which HTML snippet correctly creates an ordered list with two items, "Plan" and "Build"?'
              : 'Which HTML element should you use for a numbered list?',
          correct: advanced
              ? '<ol><li>Plan</li><li>Build</li></ol>'
              : '<ol>',
          distractors: advanced
              ? [
                  '<ul><li>Plan</li><li>Build</li></ul>',
                  '<ol><item>Plan</item><item>Build</item></ol>',
                  '<list><li>Plan</li><li>Build</li></list>',
                ]
              : ['<ul>', '<dl>', '<list>'],
          explanation: advanced
              ? 'A numbered list uses <ol> and each entry must be inside an <li> element.'
              : 'An ordered, numbered list uses the <ol> element.',
          timeSeconds,
          seed,
        });
      default:
        return this.question({
          req,
          topicMatchNote: 'HTML basics',
          prompt: advanced
              ? 'Which HTML snippet correctly labels a text input for an email field?'
              : 'Which HTML element creates a text input box inside a form?',
          correct: advanced
              ? '<label for="email">Email</label><input id="email" type="text">'
              : '<input type="text">',
          distractors: advanced
              ? [
                  '<label>Email</label><textbox id="email"></textbox>',
                  '<input for="email" type="text"><label id="email">Email</label>',
                  '<label id="email">Email</label><input type="textbox">',
                ]
              : ['<textarea type="text">', '<button type="text">', '<label type="text">'],
          explanation: advanced
              ? 'The label uses for="email" to target the input with id="email", which is the correct accessible pairing.'
              : 'A single-line text field is created with the input element and type="text".',
          timeSeconds,
          seed,
        });
    }
  }

  private topic(req: PracticeEngineRequest): string {
    return this.topicDescriptor(req);
  }

  private topicDescriptor(req: PracticeEngineRequest): string {
    const strictTopicText = String(req.strictPromptSummary ?? '')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .find((line) => /^topic\s*:/i.test(line))
      ?.replace(/^topic\s*:/i, '')
      .trim() ?? '';

    return this.norm(`${req.topicLabel} ${req.topicPathText} ${strictTopicText}`);
  }

  private timeFor(req: PracticeEngineRequest, fallback: number): number {
    return clampTime(req.timePreferenceSeconds, fallback);
  }

  private norm(value: string): string {
    return String(value ?? '').toLowerCase().replace(/\s+/g, ' ').trim();
  }

  private pick<T>(seed: number, items: readonly T[]): T {
    return items[((seed % items.length) + items.length) % items.length];
  }

  private shuffle(items: string[], seed: number): string[] {
    const out = items.slice();
    for (let i = out.length - 1; i > 0; i--) {
      const j = Math.abs((seed + i * 17) % (i + 1));
      const tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }
    return out;
  }
}
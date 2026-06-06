// Smart, language-agnostic CSV → user-rows mapper.
//
// Schools hand us CSVs with headers in any of our five languages (and any
// casing / spacing / diacritics). Rather than force a fixed template, we
// detect what each column MEANS from a multilingual synonym dictionary, then
// map every row to a normalized user DTO. Role values and grade numbers are
// normalized the same way, so "طالب", "תלמיד", "Student", "élève" all become
// STUDENT and "الصف 10" / "Grade 10" / "כיתה י" → 10 where a digit is present.

export type CanonField =
  | 'name' | 'nameAr' | 'nameHe' | 'nameFr' | 'nameRu'
  | 'username' | 'password' | 'email' | 'phone'
  | 'role' | 'grade' | 'parentUsername' | 'childUsernames';

/** Lowercase, strip diacritics, collapse whitespace, drop punctuation. Keeps
 *  letters of any script (Arabic/Hebrew/Cyrillic/Latin) and digits. */
export function normHeader(s: string): string {
  return String(s ?? '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '') // Latin/Cyrillic combining marks
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .trim();
}

// Synonyms per canonical field. Compared against the normalized header; a
// header matches a field if it EQUALS or CONTAINS one of the synonyms.
const FIELD_SYNONYMS: Record<CanonField, string[]> = {
  nameAr: ['name ar', 'arabic name', 'الاسم بالعربية', 'الاسم عربي', 'اسم عربي', 'שם בערבית'],
  nameHe: ['name he', 'hebrew name', 'الاسم بالعبرية', 'שם בעברית', 'שם עברי'],
  nameFr: ['name fr', 'french name', 'nom francais', 'الاسم بالفرنسية'],
  nameRu: ['name ru', 'russian name', 'имя на русском', 'الاسم بالروسية'],
  name: ['name', 'full name', 'fullname', 'student name', 'display name', 'name en', 'english name',
         'الاسم', 'اسم', 'الاسم الكامل', 'שם', 'שם מלא', 'nom', 'nom complet', 'имя', 'фио', 'полное имя'],
  username: ['username', 'user name', 'user', 'login', 'login name', 'handle',
             'اسم المستخدم', 'المستخدم', 'שם משתמש', 'משתמש', 'identifiant', 'логин', 'имя пользователя'],
  password: ['password', 'pass', 'pwd', 'كلمة المرور', 'كلمة السر', 'סיסמה', 'סיסמא',
             'mot de passe', 'пароль'],
  email: ['email', 'e mail', 'mail', 'البريد', 'البريد الالكتروني', 'بريد', 'אימייל', 'דואל',
          'דואר אלקטרוני', 'courriel', 'почта', 'электронная почта'],
  phone: ['phone', 'phone number', 'mobile', 'cell', 'tel', 'telephone',
          'الهاتف', 'هاتف', 'جوال', 'رقم الهاتف', 'טלפון', 'נייד', 'מספר טלפון',
          'telephone', 'portable', 'телефон', 'мобильный'],
  role: ['role', 'type', 'user type', 'account type', 'الدور', 'النوع', 'نوع المستخدم',
         'תפקיד', 'סוג', 'rôle', 'role', 'type utilisateur', 'роль', 'тип'],
  grade: ['grade', 'class', 'level', 'year', 'grade level', 'class level',
          'الصف', 'صف', 'المستوى', 'الفصل', 'כיתה', 'שכבה', 'classe', 'niveau', 'класс', 'уровень'],
  parentUsername: ['parent', 'guardian', 'parent username', 'parent user', 'father', 'mother',
                   'ولي الامر', 'ولي', 'الاب', 'الام', 'اسم ولي الامر', 'הורה', 'אפוטרופוס', 'שם הורה',
                   'родитель', 'опекун'],
  childUsernames: ['children', 'child', 'students', 'kids', 'child username', 'children usernames',
                   'الابناء', 'الاولاد', 'الطلاب', 'ילדים', 'תלמידים', 'enfants', 'дети', 'ученики'],
};

// Order matters: more specific fields first so e.g. "arabic name" maps to
// nameAr before the generic "name" contains-match grabs it.
const FIELD_ORDER: CanonField[] = [
  'nameAr', 'nameHe', 'nameFr', 'nameRu', 'parentUsername', 'childUsernames',
  'username', 'password', 'email', 'phone', 'role', 'grade', 'name',
];

export function detectField(header: string): CanonField | null {
  const h = normHeader(header);
  if (!h) return null;
  for (const field of FIELD_ORDER) {
    for (const syn of FIELD_SYNONYMS[field]) {
      const n = normHeader(syn);
      if (h === n || h.includes(n) || n.includes(h)) return field;
    }
  }
  return null;
}

const ROLE_SYNONYMS: Record<string, string[]> = {
  STUDENT: ['student', 'pupil', 'طالب', 'طالبة', 'تلميذ', 'תלמיד', 'תלמידה', 'eleve', 'etudiant', 'ученик', 'ученица', 'студент'],
  TEACHER: ['teacher', 'instructor', 'معلم', 'معلمة', 'مدرس', 'مدرسة', 'אסטרא', 'מורה', 'enseignant', 'professeur', 'prof', 'учитель', 'преподаватель'],
  PARENT: ['parent', 'guardian', 'father', 'mother', 'ولي', 'ولي الامر', 'اب', 'ام', 'والد', 'والدة', 'הורה', 'אפוטרופוס', 'родитель', 'опекун'],
  ADMIN: ['admin', 'administrator', 'principal', 'مدير', 'مديرة', 'مسؤول', 'مدير المدرسة', 'מנהל', 'מנהלת', 'administrateur', 'directeur', 'администратор', 'директор'],
  SECRETARY: ['secretary', 'سكرتير', 'سكرتيرة', 'امين السر', 'מזכיר', 'מזכירה', 'secretaire', 'секретарь'],
};

export function normalizeRole(value: string): string | null {
  const v = normHeader(value);
  if (!v) return null;
  for (const [role, syns] of Object.entries(ROLE_SYNONYMS)) {
    for (const s of syns) {
      const n = normHeader(s);
      if (v === n || v.includes(n)) return role;
    }
  }
  return null;
}

/** Pull the first integer out of a possibly-localized grade cell. */
export function parseGrade(value: string): number | undefined {
  const m = String(value ?? '').match(/\d{1,2}/);
  if (!m) return undefined;
  const n = Number(m[0]);
  return Number.isFinite(n) && n >= 1 && n <= 20 ? n : undefined;
}

/** Minimal RFC-4180-ish CSV parser: quotes, escaped quotes, embedded commas
 *  and newlines. Returns a matrix of trimmed-of-BOM string cells. */
export function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let cell = '';
  let inQuotes = false;
  const s = text.replace(/^﻿/, ''); // strip BOM
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (inQuotes) {
      if (c === '"') {
        if (s[i + 1] === '"') { cell += '"'; i++; }
        else inQuotes = false;
      } else cell += c;
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ',' || c === ';' || c === '\t') {
      row.push(cell); cell = '';
    } else if (c === '\n') {
      row.push(cell); rows.push(row); row = []; cell = '';
    } else if (c === '\r') {
      // ignore; handled by \n
    } else cell += c;
  }
  // last cell/row
  if (cell.length || row.length) { row.push(cell); rows.push(row); }
  // drop fully-empty rows
  return rows.filter((r) => r.some((x) => String(x).trim() !== ''));
}

export interface MappedRow {
  dto: Record<string, any>;        // shape accepted by user-create
  parentUsername?: string;         // link this (student) row to a parent
  childUsernames?: string[];       // link this (parent) row to children
  rowNumber: number;               // 1-based data row index for error reporting
}

/** Detects the delimiter+headers, maps each data row to a user DTO. */
export function mapCsvToRows(text: string): { mapped: MappedRow[]; headerMap: Record<number, CanonField> } {
  const matrix = parseCsv(text);
  if (!matrix.length) return { mapped: [], headerMap: {} };
  const headers = matrix[0];
  const headerMap: Record<number, CanonField> = {};
  headers.forEach((h, idx) => {
    const f = detectField(h);
    if (f) headerMap[idx] = f;
  });

  const mapped: MappedRow[] = [];
  for (let r = 1; r < matrix.length; r++) {
    const cells = matrix[r];
    const dto: Record<string, any> = {};
    let parentUsername: string | undefined;
    let childUsernames: string[] | undefined;
    for (const [idxStr, field] of Object.entries(headerMap)) {
      const val = String(cells[Number(idxStr)] ?? '').trim();
      if (!val) continue;
      switch (field) {
        case 'role': dto.role = normalizeRole(val) ?? val.toUpperCase(); break;
        case 'grade': dto.grade = parseGrade(val); break;
        case 'username': dto.username = val.toLowerCase(); break;
        case 'email': dto.email = val.toLowerCase(); break;
        case 'parentUsername': parentUsername = val.toLowerCase(); break;
        case 'childUsernames':
          childUsernames = val.split(/[,;|]+/).map((x) => x.trim().toLowerCase()).filter(Boolean);
          break;
        default: dto[field] = val; // name, nameAr.., password, phone
      }
    }
    mapped.push({ dto, parentUsername, childUsernames, rowNumber: r });
  }
  return { mapped, headerMap };
}

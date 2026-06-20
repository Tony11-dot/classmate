/**
 * Localized notification copy.
 *
 * Every domain event that notifies a human passes a `template` (a stable
 * `key` + a small `args` bag) to the hub. The hub looks up each recipient's
 * stored `language` and renders the title/body in THAT language — so a
 * student set to Arabic and their parent set to French each get the same
 * event in their own tongue, both for the in-app inbox and the system push.
 *
 * Copy is intentionally minimal and plain — "New grade" / "Sarah added a 100
 * in Math" — never machine codes like "GRADE_POSTED". The machine `type` still
 * travels separately (for icons / deep-link routing); this file is display only.
 */

export type NotifLocale = 'en' | 'ar' | 'he' | 'fr' | 'ru' | 'ps';

export type NotifKey =
  | 'grade'
  | 'assignment'
  | 'material'
  | 'meeting'
  | 'exam'
  | 'form'
  | 'diploma'
  | 'message'
  | 'announcement'
  | 'attendance_absent'
  | 'attendance_late'
  | 'classroom_invite';

export interface NotifTemplate {
  key: NotifKey;
  args?: Record<string, string | number | null | undefined>;
}

const LOCALES: NotifLocale[] = ['en', 'ar', 'he', 'fr', 'ru', 'ps'];

/** Coerce any stored/header language value to one of our supported locales. */
export function normalizeLocale(raw?: string | null): NotifLocale {
  const v = String(raw ?? '')
    .trim()
    .toLowerCase()
    .split(/[-_]/)[0];
  return (LOCALES as string[]).includes(v) ? (v as NotifLocale) : 'en';
}

// Titles: short headline per key per locale.
const TITLES: Record<NotifKey, Record<NotifLocale, string>> = {
  grade: {
    en: 'New grade',
    ar: 'علامة جديدة',
    he: 'ציון חדש',
    fr: 'Nouvelle note',
    ru: 'Новая оценка',
    ps: 'نوې نمره',
  },
  assignment: {
    en: 'New assignment',
    ar: 'واجب جديد',
    he: 'מטלה חדשה',
    fr: 'Nouveau devoir',
    ru: 'Новое задание',
    ps: 'نوې دنده',
  },
  material: {
    en: 'New material',
    ar: 'مادة جديدة',
    he: 'חומר חדש',
    fr: 'Nouveau document',
    ru: 'Новый материал',
    ps: 'نوي توکي',
  },
  meeting: {
    en: 'New meeting',
    ar: 'اجتماع جديد',
    he: 'מפגש חדש',
    fr: 'Nouvelle réunion',
    ru: 'Новая встреча',
    ps: 'نوې غونډه',
  },
  exam: {
    en: 'New exam',
    ar: 'امتحان جديد',
    he: 'מבחן חדש',
    fr: 'Nouvel examen',
    ru: 'Новый экзамен',
    ps: 'نوې ازموینه',
  },
  form: {
    en: 'New form',
    ar: 'نموذج جديد',
    he: 'טופס חדש',
    fr: 'Nouveau formulaire',
    ru: 'Новая форма',
    ps: 'نوې فورمه',
  },
  diploma: {
    en: 'New certificate',
    ar: 'شهادة جديدة',
    he: 'תעודה חדשה',
    fr: 'Nouveau certificat',
    ru: 'Новый сертификат',
    ps: 'نوې سند',
  },
  message: {
    en: 'New message',
    ar: 'رسالة جديدة',
    he: 'הודעה חדשה',
    fr: 'Nouveau message',
    ru: 'Новое сообщение',
    ps: 'نوی پیغام',
  },
  announcement: {
    en: 'New announcement',
    ar: 'إعلان جديد',
    he: 'הכרזה חדשה',
    fr: 'Nouvelle annonce',
    ru: 'Новое объявление',
    ps: 'نوی اعلان',
  },
  attendance_absent: {
    en: 'Attendance',
    ar: 'الحضور',
    he: 'נוכחות',
    fr: 'Présence',
    ru: 'Посещаемость',
    ps: 'حاضري',
  },
  attendance_late: {
    en: 'Attendance',
    ar: 'الحضور',
    he: 'נוכחות',
    fr: 'Présence',
    ru: 'Посещаемость',
    ps: 'حاضري',
  },
  classroom_invite: {
    en: 'New class',
    ar: 'صف جديد',
    he: 'כיתה חדשה',
    fr: 'Nouvelle classe',
    ru: 'Новый класс',
    ps: 'نوی ټولګی',
  },
};

// Bodies: one sentence per key per locale, with {placeholders}.
const BODIES: Record<NotifKey, Record<NotifLocale, string>> = {
  grade: {
    en: '{teacher} added a {grade} in {subject}',
    ar: 'أضاف {teacher} علامة {grade} في {subject}',
    he: '{teacher} הוסיף ציון {grade} ב{subject}',
    fr: '{teacher} a ajouté un {grade} en {subject}',
    ru: '{teacher} поставил(а) {grade} по {subject}',
    ps: '{teacher} په {subject} کې {grade} نمره ورزیاته کړه',
  },
  assignment: {
    en: '{teacher} posted {title} in {subject}',
    ar: 'نشر {teacher} {title} في {subject}',
    he: '{teacher} פרסם {title} ב{subject}',
    fr: '{teacher} a publié {title} en {subject}',
    ru: '{teacher} добавил(а) {title} по {subject}',
    ps: '{teacher} په {subject} کې {title} خپور کړ',
  },
  material: {
    en: '{teacher} shared {title} in {subject}',
    ar: 'شارك {teacher} {title} في {subject}',
    he: '{teacher} שיתף {title} ב{subject}',
    fr: '{teacher} a partagé {title} en {subject}',
    ru: '{teacher} поделил(ся) {title} по {subject}',
    ps: '{teacher} په {subject} کې {title} شریک کړ',
  },
  meeting: {
    en: '{teacher} scheduled {title}',
    ar: 'حدد {teacher} موعد {title}',
    he: '{teacher} קבע את {title}',
    fr: '{teacher} a programmé {title}',
    ru: '{teacher} назначил(а) {title}',
    ps: '{teacher} د {title} مهال ټاکلی',
  },
  exam: {
    en: '{teacher} scheduled {title} in {subject}',
    ar: 'حدد {teacher} موعد {title} في {subject}',
    he: '{teacher} קבע את {title} ב{subject}',
    fr: '{teacher} a programmé {title} en {subject}',
    ru: '{teacher} назначил(а) {title} по {subject}',
    ps: '{teacher} په {subject} کې د {title} مهال ټاکلی',
  },
  form: {
    en: '{teacher} posted {title}',
    ar: 'نشر {teacher} {title}',
    he: '{teacher} פרסם {title}',
    fr: '{teacher} a publié {title}',
    ru: '{teacher} опубликовал(а) {title}',
    ps: '{teacher} {title} خپور کړ',
  },
  diploma: {
    en: 'You earned {title}',
    ar: 'لقد حصلت على {title}',
    he: 'קיבלת את {title}',
    fr: 'Vous avez obtenu {title}',
    ru: 'Вы получили {title}',
    ps: 'تاسو {title} ترلاسه کړ',
  },
  message: {
    en: '{sender}: {preview}',
    ar: '{sender}: {preview}',
    he: '{sender}: {preview}',
    fr: '{sender} : {preview}',
    ru: '{sender}: {preview}',
    ps: '{sender}: {preview}',
  },
  announcement: {
    en: '{title}',
    ar: '{title}',
    he: '{title}',
    fr: '{title}',
    ru: '{title}',
    ps: '{title}',
  },
  attendance_absent: {
    en: 'You were marked absent',
    ar: 'تم تسجيلك غائبًا',
    he: 'סומנת כנעדר',
    fr: 'Vous avez été marqué absent',
    ru: 'Вас отметили отсутствующим',
    ps: 'تاسو غیر حاضر نښه شوي',
  },
  attendance_late: {
    en: 'You were marked late',
    ar: 'تم تسجيلك متأخرًا',
    he: 'סומנת כמאחר',
    fr: 'Vous avez été marqué en retard',
    ru: 'Вас отметили опоздавшим',
    ps: 'تاسو ناوخته نښه شوي',
  },
  classroom_invite: {
    en: 'You were added to {subject}',
    ar: 'تمت إضافتك إلى {subject}',
    he: 'נוספת ל{subject}',
    fr: 'Vous avez été ajouté à {subject}',
    ru: 'Вас добавили в {subject}',
    ps: 'تاسو {subject} ته ورزیات شوئ',
  },
};

function interpolate(
  template: string,
  args: Record<string, string | number | null | undefined>,
): string {
  return template
    .replace(/\{(\w+)\}/g, (_m, k: string) => {
      const v = args[k];
      return v == null ? '' : String(v);
    })
    // tidy artefacts from missing args (double spaces, dangling separators)
    .replace(/\s{2,}/g, ' ')
    .replace(/\s+([:.,،])/g, '$1')
    .trim();
}

/** Render a notification's title + body in the given locale. */
export function renderNotif(
  template: NotifTemplate,
  locale: NotifLocale,
): { title: string; body: string } {
  const key = template.key;
  const args = template.args ?? {};
  const title = TITLES[key]?.[locale] ?? TITLES[key]?.en ?? '';
  const bodyTpl = BODIES[key]?.[locale] ?? BODIES[key]?.en ?? '';
  return { title, body: interpolate(bodyTpl, args) };
}

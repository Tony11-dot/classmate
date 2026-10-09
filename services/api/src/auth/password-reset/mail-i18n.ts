/**
 * Copy for everything the account flows send outside the app: the reset /
 * password-changed / verification-code emails, their SMS twins, the
 * forgot-password outcome messages and the /reset-password web page.
 *
 * Same languages the app ships with real translations. Pashto is a pseudo
 * locale in the app (ARB), so it falls back to English here.
 */

export type MailLocale = 'en' | 'he' | 'ar' | 'fr' | 'ru';

const LOCALES: MailLocale[] = ['en', 'he', 'ar', 'fr', 'ru'];

function pick(raw?: string | null): MailLocale | null {
  const v = String(raw ?? '').trim().toLowerCase().split(/[-_]/)[0];
  return (LOCALES as string[]).includes(v) ? (v as MailLocale) : null;
}

/** The first supported language among the candidates, else English. */
export function mailLocale(...candidates: (string | null | undefined)[]): MailLocale {
  for (const c of candidates) {
    const l = pick(c);
    if (l) return l;
  }
  return 'en';
}

/** First supported language in an Accept-Language header, in the browser’s order. */
export function localeFromAcceptLanguage(header?: string | null): MailLocale | null {
  if (!header) return null;
  const ranked = header
    .split(',')
    .map((part, i) => {
      const [tag, ...params] = part.trim().split(';');
      const q = params.map((p) => p.trim()).find((p) => p.startsWith('q='));
      return { tag, q: q ? Number(q.slice(2)) || 0 : 1, i };
    })
    .filter((e) => e.q > 0)
    .sort((a, b) => b.q - a.q || a.i - b.i);
  for (const e of ranked) {
    const l = pick(e.tag);
    if (l) return l;
  }
  return null;
}

export const isRtl = (l: MailLocale) => l === 'he' || l === 'ar';

type B = (s: string) => string;

export interface MailCopy {
  minutes: (n: number) => string;
  hi: (name: string | null) => string;
  questions: string;
  tagline: string;
  privacy: string;
  terms: string;
  buttonFallback: string;
  reset: {
    subject: (account: string) => string;
    preheader: (min: string) => string;
    title: string;
    intro: (account: string) => string;
    useButton: (b: B, min: string) => string;
    useLink: (min: string) => string;
    button: string;
    note: string;
  };
  changed: {
    subject: (account: string) => string;
    preheader: (admin: string) => string;
    title: string;
    who: (admin: string, account: string) => string;
    allSet: string;
    useButton: (b: B, min: string) => string;
    useLink: (min: string) => string;
    button: string;
  };
  code: {
    subject: (code: string, label: string) => string;
    preheader: (code: string, min: string) => string;
    title: string;
    enter: string;
    after: (b: B, min: string) => string;
    note: string;
    textLine: (label: string, code: string) => string;
    textEnter: (min: string) => string;
  };
  sms: {
    reset: (label: string, url: string, min: string) => string;
    changed: (label: string, admin: string, url: string, min: string) => string;
    code: (label: string, code: string, min: string) => string;
  };
  forgot: {
    sentEmail: string;
    sentSms: string;
    noUser: string;
    noEmail: string;
    noPhone: string;
    emailNotVerified: string;
    phoneNotVerified: string;
  };
  page: {
    title: string;
    sub: string;
    newLabel: string;
    confirmLabel: string;
    chkLen: string;
    chkMatch: string;
    save: string;
    saving: string;
    show: string;
    hide: string;
    errShort: string;
    errMatch: string;
    errMissing: string;
    errTooMany: string;
    errNetwork: string;
    errGeneric: string;
    expiredTitle: string;
    expiredBody: string;
    usedTitle: string;
    usedBody: string;
    invalidTitle: string;
    invalidBody: string;
    newLink: string;
    signIn: string;
    doneTitle: string;
    doneBody: string;
    signInWeb: string;
    help: string;
  };
}

const en: MailCopy = {
  minutes: (n) => (n === 1 ? '1 minute' : `${n} minutes`),
  hi: (name) => (name ? `Hi ${name},` : 'Hi,'),
  questions: 'Questions? Reply to this email or write to',
  tagline: 'One app. Your whole school.',
  privacy: 'Privacy',
  terms: 'Terms',
  buttonFallback: 'Button not working? Copy this link into your browser:',
  reset: {
    subject: (account) => `Reset your ${account} password`,
    preheader: (min) => `Choose a new password. The link works for ${min}.`,
    title: 'Reset your password',
    intro: (account) => `We received a request to reset the password on your ${account} account.`,
    useButton: (b, min) => `Use the button below to choose a new one. It works for the next ${b(min)}, once.`,
    useLink: (min) => `Open this link to choose a new one. It works for the next ${min}, once:`,
    button: 'Choose a new password',
    note: "Didn’t ask for this? Ignore this email. Your password stays the same.",
  },
  changed: {
    subject: (account) => `Your ${account} password was changed`,
    preheader: (admin) => `${admin} changed your password. Not expecting it? Set your own.`,
    title: 'Your password was changed',
    who: (admin, account) => `${admin}, an administrator at ${account}, just changed your password.`,
    allSet: "If you asked them to, you’re all set. Sign in with the new password they gave you.",
    useButton: (b, min) =>
      `${b("Wasn’t expecting this,")} or want to pick your own? Use the button below within the next ${b(min)}.`,
    useLink: (min) => `Wasn’t expecting this, or want to pick your own? Use this link within the next ${min}:`,
    button: 'Set my own password',
  },
  code: {
    subject: (code, label) => `${code} is your ${label} verification code`,
    preheader: (code, min) => `Your code is ${code}. It expires in ${min}.`,
    title: 'Your verification code',
    enter: "Enter this code in the app to confirm it’s you.",
    after: (b, min) => `It expires in ${b(min)}. Asked for more than one? Any of your last three codes works.`,
    note: "Didn’t ask for a code? Ignore this email. Nothing changes until the code is entered.",
    textLine: (label, code) => `Your ${label} verification code is: ${code}`,
    textEnter: (min) => `Enter it in the app. It expires in ${min}.`,
  },
  sms: {
    reset: (label, url, min) => `${label}: reset your password — ${url} (expires in ${min}). If you didn’t ask, ignore this.`,
    changed: (label, admin, url, min) =>
      `${label}: your password was changed by ${admin}. Set your own here: ${url} (expires in ${min}).`,
    code: (label, code, min) => `${label} code: ${code} (expires in ${min}). If you didn’t ask, ignore this.`,
  },
  forgot: {
    sentEmail: 'We just sent a reset link to your email. The link expires in 1 hour.',
    sentSms: 'We just sent a reset link to your phone. The link expires in 1 hour.',
    noUser: "We couldn’t find an account with that email or username. Double-check and try again.",
    noEmail: "This account doesn’t have an email on file. Try SMS, or ask an admin to reset your password.",
    noPhone: "This account doesn’t have a phone on file. Try email, or ask an admin to reset your password.",
    emailNotVerified: "Your email isn’t verified yet. Log in and verify it in Profile → Email → Verify, then try again.",
    phoneNotVerified: "Your phone isn’t verified yet. Log in and verify it in Profile → Phone → Verify, then try again.",
  },
  page: {
    title: 'Choose a new password',
    sub: "For your ClassMate account. You’ll use it to sign in on every device.",
    newLabel: 'New password',
    confirmLabel: 'Confirm new password',
    chkLen: 'At least 8 characters',
    chkMatch: 'Both passwords match',
    save: 'Save new password',
    saving: 'Saving…',
    show: 'Show password',
    hide: 'Hide password',
    errShort: 'Use at least 8 characters.',
    errMatch: "The two passwords don’t match.",
    errMissing: 'This link is missing its reset code. Open the link from your email or text again, or ask for a new one.',
    errTooMany: 'Too many tries with this link. Wait a few minutes, then try again.',
    errNetwork: 'No connection. Check your internet and try again.',
    errGeneric: 'Something went wrong. Try again.',
    expiredTitle: 'This link has expired',
    expiredBody: 'Reset links work for one hour. Ask for a new one and try again.',
    usedTitle: 'This link was already used',
    usedBody: 'Each reset link works once. If you already chose a new password, just sign in. If not, ask for a new link.',
    invalidTitle: "This link doesn’t work",
    invalidBody: 'It may have been copied only in part. Open it again from your email or text, or ask for a new one.',
    newLink: 'Get a new link',
    signIn: 'Sign in',
    doneTitle: 'Password updated',
    doneBody: "Open the ClassMate app and sign in with your new password. You’ve been signed out on your other devices.",
    signInWeb: 'Sign in on the web',
    help: 'Need help?',
  },
};

const he: MailCopy = {
  minutes: (n) => (n === 1 ? 'דקה אחת' : n === 2 ? 'שתי דקות' : `${n} דקות`),
  hi: (name) => (name ? `שלום ${name},` : 'שלום,'),
  questions: 'שאלות? אפשר להשיב למייל הזה או לכתוב אל',
  tagline: 'אפליקציה אחת. כל בית הספר.',
  privacy: 'פרטיות',
  terms: 'תנאי שימוש',
  buttonFallback: 'הכפתור לא עובד? אפשר להעתיק את הקישור הזה לדפדפן:',
  reset: {
    subject: (account) => `איפוס הסיסמה לחשבון ${account}`,
    preheader: (min) => `בחירת סיסמה חדשה. הקישור תקף למשך ${min}.`,
    title: 'איפוס סיסמה',
    intro: (account) => `קיבלנו בקשה לאפס את הסיסמה בחשבון ${account} שלך.`,
    useButton: (b, min) => `אפשר לבחור סיסמה חדשה בכפתור שלמטה. הקישור תקף למשך ${b(min)}, לשימוש אחד בלבד.`,
    useLink: (min) => `אפשר לבחור סיסמה חדשה בקישור הזה. הוא תקף למשך ${min}, לשימוש אחד בלבד:`,
    button: 'בחירת סיסמה חדשה',
    note: 'לא ביקשת את זה? אפשר להתעלם מהמייל. הסיסמה שלך לא תשתנה.',
  },
  changed: {
    subject: (account) => `הסיסמה שלך בחשבון ${account} שונתה`,
    preheader: (admin) => `הסיסמה שלך שונתה על ידי ${admin}. לא ציפית לזה? אפשר לבחור סיסמה משלך.`,
    title: 'הסיסמה שלך שונתה',
    who: (admin, account) => `הסיסמה שלך שונתה עכשיו על ידי ${admin} מצוות הניהול של ${account}.`,
    allSet: 'אם ביקשת זאת, הכול מוכן. אפשר להתחבר עם הסיסמה החדשה שקיבלת.',
    useButton: (b, min) =>
      `${b('לא ציפית לזה,')} או שעדיף לך לבחור סיסמה משלך? אפשר להשתמש בכפתור שלמטה במשך ${b(min)}.`,
    useLink: (min) => `לא ציפית לזה, או שעדיף לך לבחור סיסמה משלך? אפשר להשתמש בקישור הזה במשך ${min}:`,
    button: 'בחירת סיסמה משלי',
  },
  code: {
    subject: (code, label) => `${code} הוא קוד האימות שלך ב־${label}`,
    preheader: (code, min) => `הקוד שלך: ${code}. הוא תקף למשך ${min}.`,
    title: 'קוד האימות שלך',
    enter: 'כדי לאשר שזה באמת החשבון שלך, יש להזין את הקוד הזה באפליקציה.',
    after: (b, min) => `הקוד תקף למשך ${b(min)}. ביקשת יותר מקוד אחד? כל אחד משלושת הקודים האחרונים יעבוד.`,
    note: 'לא ביקשת קוד? אפשר להתעלם מהמייל. שום דבר לא ישתנה עד שהקוד יוזן.',
    textLine: (label, code) => `קוד האימות שלך ב־${label}: ${code}`,
    textEnter: (min) => `יש להזין אותו באפליקציה. הוא תקף למשך ${min}.`,
  },
  sms: {
    reset: (label, url, min) => `${label}: לאיפוס הסיסמה ${url} (תקף ${min}). לא ביקשת? אפשר להתעלם.`,
    changed: (label, admin, url, min) =>
      `${label}: הסיסמה שלך שונתה על ידי ${admin}. לבחירת סיסמה משלך: ${url} (תקף ${min}).`,
    code: (label, code, min) => `קוד ${label}: ${code} (תקף ${min}). לא ביקשת? אפשר להתעלם.`,
  },
  forgot: {
    sentEmail: 'שלחנו קישור איפוס למייל שלך. הקישור תקף לשעה אחת.',
    sentSms: 'שלחנו קישור איפוס לטלפון שלך. הקישור תקף לשעה אחת.',
    noUser: 'לא מצאנו חשבון עם המייל או שם המשתמש האלה. כדאי לבדוק ולנסות שוב.',
    noEmail: 'לחשבון הזה אין מייל שמור. אפשר לנסות ב־SMS, או לבקש מצוות הניהול לאפס את הסיסמה.',
    noPhone: 'לחשבון הזה אין טלפון שמור. אפשר לנסות במייל, או לבקש מצוות הניהול לאפס את הסיסמה.',
    emailNotVerified: 'המייל שלך עדיין לא אומת. אפשר להתחבר, לאמת אותו בפרופיל ולנסות שוב.',
    phoneNotVerified: 'הטלפון שלך עדיין לא אומת. אפשר להתחבר, לאמת אותו בפרופיל ולנסות שוב.',
  },
  page: {
    title: 'בחירת סיסמה חדשה',
    sub: 'לחשבון ClassMate שלך. היא תשמש להתחברות בכל המכשירים.',
    newLabel: 'סיסמה חדשה',
    confirmLabel: 'אימות הסיסמה החדשה',
    chkLen: 'לפחות 8 תווים',
    chkMatch: 'שתי הסיסמאות זהות',
    save: 'שמירת הסיסמה החדשה',
    saving: 'שומר…',
    show: 'הצגת הסיסמה',
    hide: 'הסתרת הסיסמה',
    errShort: 'צריך לפחות 8 תווים.',
    errMatch: 'שתי הסיסמאות לא זהות.',
    errMissing: 'בקישור הזה חסר קוד האיפוס. אפשר לפתוח שוב את הקישור מהמייל או מההודעה, או לבקש קישור חדש.',
    errTooMany: 'יותר מדי ניסיונות עם הקישור הזה. כדאי לחכות כמה דקות ולנסות שוב.',
    errNetwork: 'אין חיבור. כדאי לבדוק את האינטרנט ולנסות שוב.',
    errGeneric: 'משהו השתבש. כדאי לנסות שוב.',
    expiredTitle: 'פג תוקף הקישור',
    expiredBody: 'קישורי איפוס תקפים לשעה אחת. אפשר לבקש קישור חדש ולנסות שוב.',
    usedTitle: 'כבר השתמשו בקישור הזה',
    usedBody: 'כל קישור איפוס עובד פעם אחת. אם כבר בחרת סיסמה חדשה, אפשר פשוט להתחבר. אחרת, אפשר לבקש קישור חדש.',
    invalidTitle: 'הקישור לא תקין',
    invalidBody: 'ייתכן שהקישור הועתק רק בחלקו. אפשר לפתוח אותו שוב מהמייל או מההודעה, או לבקש קישור חדש.',
    newLink: 'בקשת קישור חדש',
    signIn: 'התחברות',
    doneTitle: 'הסיסמה עודכנה',
    doneBody: 'אפשר לפתוח את אפליקציית ClassMate ולהתחבר עם הסיסמה החדשה. החיבור שלך בשאר המכשירים נותק.',
    signInWeb: 'התחברות באתר',
    help: 'צריך עזרה?',
  },
};

function arMinutes(n: number): string {
  if (n === 1) return 'دقيقة واحدة';
  if (n === 2) return 'دقيقتين';
  if (n >= 3 && n <= 10) return `${n} دقائق`;
  return `${n} دقيقة`;
}

const ar: MailCopy = {
  minutes: arMinutes,
  hi: (name) => (name ? `مرحبًا ${name}،` : 'مرحبًا،'),
  questions: 'لديك سؤال؟ ردّ على هذه الرسالة أو اكتب إلى',
  tagline: 'تطبيق واحد. مدرستك كلها.',
  privacy: 'الخصوصية',
  terms: 'الشروط',
  buttonFallback: 'الزر لا يعمل؟ انسخ هذا الرابط إلى المتصفح:',
  reset: {
    subject: (account) => `إعادة تعيين كلمة مرور ${account}`,
    preheader: (min) => `اختر كلمة مرور جديدة. الرابط صالح لمدة ${min}.`,
    title: 'إعادة تعيين كلمة المرور',
    intro: (account) => `تلقّينا طلبًا لإعادة تعيين كلمة المرور لحسابك في ${account}.`,
    useButton: (b, min) => `استخدم الزر أدناه لاختيار كلمة مرور جديدة. الرابط صالح لمدة ${b(min)} ولمرة واحدة فقط.`,
    useLink: (min) => `افتح هذا الرابط لاختيار كلمة مرور جديدة. الرابط صالح لمدة ${min} ولمرة واحدة فقط:`,
    button: 'اختيار كلمة مرور جديدة',
    note: 'لم تطلب ذلك؟ تجاهل هذه الرسالة. ستبقى كلمة المرور كما هي.',
  },
  changed: {
    subject: (account) => `تم تغيير كلمة مرور حسابك في ${account}`,
    preheader: (admin) => `غيّر ${admin} كلمة مرورك. لم تكن تتوقع ذلك؟ اختر كلمة مرور بنفسك.`,
    title: 'تم تغيير كلمة المرور',
    who: (admin, account) => `قام ${admin}، من إدارة ${account}، بتغيير كلمة مرورك للتو.`,
    allSet: 'إذا كنت قد طلبت ذلك، فكل شيء جاهز. سجّل الدخول بكلمة المرور الجديدة التي أُعطيت لك.',
    useButton: (b, min) =>
      `${b('لم تكن تتوقع ذلك')} أو تريد اختيار كلمة مرور بنفسك؟ استخدم الزر أدناه خلال ${b(min)}.`,
    useLink: (min) => `لم تكن تتوقع ذلك أو تريد اختيار كلمة مرور بنفسك؟ استخدم هذا الرابط خلال ${min}:`,
    button: 'اختيار كلمة مروري',
  },
  code: {
    subject: (code, label) => `${code} هو رمز التحقق الخاص بك في ${label}`,
    preheader: (code, min) => `رمزك هو ${code}. صالح لمدة ${min}.`,
    title: 'رمز التحقق الخاص بك',
    enter: 'أدخل هذا الرمز في التطبيق لتأكيد أنك صاحب الحساب.',
    after: (b, min) => `الرمز صالح لمدة ${b(min)}. طلبت أكثر من رمز؟ أي رمز من آخر ثلاثة رموز يعمل.`,
    note: 'لم تطلب رمزًا؟ تجاهل هذه الرسالة. لن يتغير شيء ما لم يُدخَل الرمز.',
    textLine: (label, code) => `رمز التحقق الخاص بك في ${label}: ${code}`,
    textEnter: (min) => `أدخله في التطبيق. صالح لمدة ${min}.`,
  },
  sms: {
    reset: (label, url, min) => `${label}: لإعادة تعيين كلمة المرور ${url} (صالح ${min}). إن لم تطلب ذلك فتجاهل الرسالة.`,
    changed: (label, admin, url, min) =>
      `${label}: غيّر ${admin} كلمة مرورك. لاختيار كلمة مرور بنفسك: ${url} (صالح ${min}).`,
    code: (label, code, min) => `رمز ${label}: ${code} (صالح ${min}). إن لم تطلبه فتجاهل الرسالة.`,
  },
  forgot: {
    sentEmail: 'أرسلنا رابط إعادة التعيين إلى بريدك الإلكتروني. الرابط صالح لمدة ساعة.',
    sentSms: 'أرسلنا رابط إعادة التعيين إلى هاتفك. الرابط صالح لمدة ساعة.',
    noUser: 'لم نجد حسابًا بهذا البريد الإلكتروني أو اسم المستخدم. تحقّق وحاول مجددًا.',
    noEmail: 'لا يوجد بريد إلكتروني مسجّل لهذا الحساب. جرّب الرسالة النصية، أو اطلب من الإدارة إعادة تعيين كلمة مرورك.',
    noPhone: 'لا يوجد رقم هاتف مسجّل لهذا الحساب. جرّب البريد الإلكتروني، أو اطلب من الإدارة إعادة تعيين كلمة مرورك.',
    emailNotVerified: 'لم يتم التحقق من بريدك الإلكتروني بعد. سجّل الدخول وتحقّق منه في الملف الشخصي، ثم حاول مجددًا.',
    phoneNotVerified: 'لم يتم التحقق من هاتفك بعد. سجّل الدخول وتحقّق منه في الملف الشخصي، ثم حاول مجددًا.',
  },
  page: {
    title: 'اختر كلمة مرور جديدة',
    sub: 'لحسابك في ClassMate. ستستخدمها لتسجيل الدخول على كل أجهزتك.',
    newLabel: 'كلمة المرور الجديدة',
    confirmLabel: 'تأكيد كلمة المرور الجديدة',
    chkLen: '8 أحرف على الأقل',
    chkMatch: 'كلمتا المرور متطابقتان',
    save: 'حفظ كلمة المرور الجديدة',
    saving: 'جارٍ الحفظ…',
    show: 'إظهار كلمة المرور',
    hide: 'إخفاء كلمة المرور',
    errShort: 'استخدم 8 أحرف على الأقل.',
    errMatch: 'كلمتا المرور غير متطابقتين.',
    errMissing: 'ينقص هذا الرابطَ رمزُ إعادة التعيين. افتح الرابط من البريد أو الرسالة مرة أخرى، أو اطلب رابطًا جديدًا.',
    errTooMany: 'محاولات كثيرة بهذا الرابط. انتظر بضع دقائق ثم حاول مجددًا.',
    errNetwork: 'لا يوجد اتصال. تحقّق من الإنترنت وحاول مجددًا.',
    errGeneric: 'حدث خطأ ما. حاول مجددًا.',
    expiredTitle: 'انتهت صلاحية هذا الرابط',
    expiredBody: 'روابط إعادة التعيين صالحة لمدة ساعة واحدة. اطلب رابطًا جديدًا وحاول مجددًا.',
    usedTitle: 'تم استخدام هذا الرابط من قبل',
    usedBody: 'كل رابط يعمل مرة واحدة فقط. إذا اخترت كلمة مرور جديدة بالفعل فسجّل الدخول بها، وإلا فاطلب رابطًا جديدًا.',
    invalidTitle: 'هذا الرابط غير صالح',
    invalidBody: 'ربما نُسخ الرابط بشكل ناقص. افتحه مرة أخرى من البريد أو الرسالة، أو اطلب رابطًا جديدًا.',
    newLink: 'طلب رابط جديد',
    signIn: 'تسجيل الدخول',
    doneTitle: 'تم تحديث كلمة المرور',
    doneBody: 'افتح تطبيق ClassMate وسجّل الدخول بكلمة المرور الجديدة. تم تسجيل خروجك من أجهزتك الأخرى.',
    signInWeb: 'تسجيل الدخول عبر الويب',
    help: 'تحتاج مساعدة؟',
  },
};

const fr: MailCopy = {
  minutes: (n) => (n === 1 ? '1 minute' : `${n} minutes`),
  hi: (name) => (name ? `Bonjour ${name},` : 'Bonjour,'),
  questions: 'Une question ? Répondez à cet e-mail ou écrivez à',
  tagline: 'Une seule app. Toute votre école.',
  privacy: 'Confidentialité',
  terms: 'Conditions',
  buttonFallback: 'Le bouton ne fonctionne pas ? Copiez ce lien dans votre navigateur :',
  reset: {
    subject: (account) => `Réinitialisez votre mot de passe ${account}`,
    preheader: (min) => `Choisissez un nouveau mot de passe. Le lien est valable ${min}.`,
    title: 'Réinitialiser votre mot de passe',
    intro: (account) => `Nous avons reçu une demande de réinitialisation du mot de passe de votre compte ${account}.`,
    useButton: (b, min) => `Utilisez le bouton ci-dessous pour en choisir un nouveau. Il est valable ${b(min)}, une seule fois.`,
    useLink: (min) => `Ouvrez ce lien pour en choisir un nouveau. Il est valable ${min}, une seule fois :`,
    button: 'Choisir un nouveau mot de passe',
    note: "Vous n’avez rien demandé ? Ignorez cet e-mail. Votre mot de passe reste inchangé.",
  },
  changed: {
    subject: (account) => `Votre mot de passe ${account} a été modifié`,
    preheader: (admin) => `${admin} a modifié votre mot de passe. Vous ne vous y attendiez pas ? Choisissez le vôtre.`,
    title: 'Votre mot de passe a été modifié',
    who: (admin, account) => `${admin}, de l’administration de ${account}, vient de modifier votre mot de passe.`,
    allSet: "Si vous l’avez demandé, tout est prêt. Connectez-vous avec le nouveau mot de passe qui vous a été remis.",
    useButton: (b, min) =>
      `${b('Vous ne vous y attendiez pas,')} ou vous préférez choisir le vôtre ? Utilisez le bouton ci-dessous dans les ${b(min)}.`,
    useLink: (min) => `Vous ne vous y attendiez pas, ou vous préférez choisir le vôtre ? Utilisez ce lien dans les ${min} :`,
    button: 'Choisir mon mot de passe',
  },
  code: {
    subject: (code, label) => `${code} est votre code de vérification ${label}`,
    preheader: (code, min) => `Votre code est ${code}. Il expire dans ${min}.`,
    title: 'Votre code de vérification',
    enter: "Saisissez ce code dans l’app pour confirmer qu’il s’agit bien de vous.",
    after: (b, min) =>
      `Il expire dans ${b(min)}. Vous en avez demandé plusieurs ? N’importe lequel de vos trois derniers codes fonctionne.`,
    note: "Vous n’avez pas demandé de code ? Ignorez cet e-mail. Rien ne change tant que le code n’est pas saisi.",
    textLine: (label, code) => `Votre code de vérification ${label} : ${code}`,
    textEnter: (min) => `Saisissez-le dans l’app. Il expire dans ${min}.`,
  },
  sms: {
    reset: (label, url, min) =>
      `${label} : réinitialisez votre mot de passe — ${url} (valable ${min}). Pas vous ? Ignorez ce message.`,
    changed: (label, admin, url, min) =>
      `${label} : votre mot de passe a été modifié par ${admin}. Choisissez le vôtre : ${url} (valable ${min}).`,
    code: (label, code, min) => `Code ${label} : ${code} (valable ${min}). Pas vous ? Ignorez ce message.`,
  },
  forgot: {
    sentEmail: 'Nous venons d’envoyer un lien de réinitialisation à votre adresse e-mail. Il expire dans 1 heure.',
    sentSms: 'Nous venons d’envoyer un lien de réinitialisation sur votre téléphone. Il expire dans 1 heure.',
    noUser: "Aucun compte ne correspond à cet e-mail ou nom d’utilisateur. Vérifiez et réessayez.",
    noEmail:
      "Ce compte n’a pas d’adresse e-mail enregistrée. Essayez par SMS, ou demandez à un administrateur de réinitialiser votre mot de passe.",
    noPhone:
      "Ce compte n’a pas de numéro de téléphone enregistré. Essayez par e-mail, ou demandez à un administrateur de réinitialiser votre mot de passe.",
    emailNotVerified: "Votre e-mail n’est pas encore vérifié. Connectez-vous, vérifiez-le dans votre profil, puis réessayez.",
    phoneNotVerified: "Votre téléphone n’est pas encore vérifié. Connectez-vous, vérifiez-le dans votre profil, puis réessayez.",
  },
  page: {
    title: 'Choisissez un nouveau mot de passe',
    sub: 'Pour votre compte ClassMate. Il servira à vous connecter sur tous vos appareils.',
    newLabel: 'Nouveau mot de passe',
    confirmLabel: 'Confirmez le nouveau mot de passe',
    chkLen: 'Au moins 8 caractères',
    chkMatch: 'Les deux mots de passe correspondent',
    save: 'Enregistrer le mot de passe',
    saving: 'Enregistrement…',
    show: 'Afficher le mot de passe',
    hide: 'Masquer le mot de passe',
    errShort: 'Utilisez au moins 8 caractères.',
    errMatch: 'Les deux mots de passe ne correspondent pas.',
    errMissing: 'Il manque le code de réinitialisation dans ce lien. Rouvrez le lien depuis votre e-mail ou SMS, ou demandez-en un nouveau.',
    errTooMany: 'Trop de tentatives avec ce lien. Patientez quelques minutes, puis réessayez.',
    errNetwork: 'Pas de connexion. Vérifiez votre accès à Internet et réessayez.',
    errGeneric: "Une erreur s’est produite. Réessayez.",
    expiredTitle: 'Ce lien a expiré',
    expiredBody: 'Les liens de réinitialisation sont valables une heure. Demandez-en un nouveau et réessayez.',
    usedTitle: 'Ce lien a déjà été utilisé',
    usedBody:
      "Chaque lien ne fonctionne qu’une fois. Si vous avez déjà choisi un nouveau mot de passe, connectez-vous. Sinon, demandez un nouveau lien.",
    invalidTitle: "Ce lien n’est pas valide",
    invalidBody: "Il a peut-être été copié en partie. Rouvrez-le depuis votre e-mail ou SMS, ou demandez-en un nouveau.",
    newLink: 'Demander un nouveau lien',
    signIn: 'Se connecter',
    doneTitle: 'Mot de passe mis à jour',
    doneBody:
      "Ouvrez l’app ClassMate et connectez-vous avec votre nouveau mot de passe. Vos autres appareils ont été déconnectés.",
    signInWeb: 'Se connecter sur le web',
    help: "Besoin d’aide ?",
  },
};

function ruMinutes(n: number): string {
  const m10 = n % 10;
  const m100 = n % 100;
  if (m10 === 1 && m100 !== 11) return `${n} минуту`;
  if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return `${n} минуты`;
  return `${n} минут`;
}

const ru: MailCopy = {
  minutes: ruMinutes,
  hi: (name) => (name ? `Здравствуйте, ${name}!` : 'Здравствуйте!'),
  questions: 'Есть вопросы? Ответьте на это письмо или напишите на',
  tagline: 'Одно приложение. Вся ваша школа.',
  privacy: 'Конфиденциальность',
  terms: 'Условия',
  buttonFallback: 'Кнопка не работает? Скопируйте эту ссылку в браузер:',
  reset: {
    subject: (account) => `Сброс пароля ${account}`,
    preheader: (min) => `Выберите новый пароль. Ссылка действует ${min}.`,
    title: 'Сброс пароля',
    intro: (account) => `Мы получили запрос на сброс пароля вашего аккаунта ${account}.`,
    useButton: (b, min) => `Нажмите кнопку ниже, чтобы выбрать новый. Ссылка действует ${b(min)} и только один раз.`,
    useLink: (min) => `Откройте эту ссылку, чтобы выбрать новый пароль. Она действует ${min} и только один раз:`,
    button: 'Выбрать новый пароль',
    note: 'Это были не вы? Просто проигнорируйте письмо. Ваш пароль не изменится.',
  },
  changed: {
    subject: (account) => `Ваш пароль ${account} изменён`,
    preheader: (admin) => `Ваш пароль изменил администратор ${admin}. Не ожидали? Задайте свой.`,
    title: 'Ваш пароль изменён',
    who: (admin, account) => `Ваш пароль только что изменил администратор ${account}: ${admin}.`,
    allSet: 'Если вы об этом просили, всё готово. Войдите с новым паролем, который вам выдали.',
    useButton: (b, min) =>
      `${b('Не ожидали этого')} или хотите выбрать пароль сами? Воспользуйтесь кнопкой ниже в течение ${b(min)}.`,
    useLink: (min) => `Не ожидали этого или хотите выбрать пароль сами? Откройте эту ссылку в течение ${min}:`,
    button: 'Задать свой пароль',
  },
  code: {
    subject: (code, label) => `${code} — ваш код подтверждения ${label}`,
    preheader: (code, min) => `Ваш код: ${code}. Он действует ${min}.`,
    title: 'Ваш код подтверждения',
    enter: 'Введите этот код в приложении, чтобы подтвердить, что это вы.',
    after: (b, min) => `Он действует ${b(min)}. Запрашивали несколько кодов? Подойдёт любой из трёх последних.`,
    note: 'Не запрашивали код? Проигнорируйте это письмо. Ничего не изменится, пока код не введён.',
    textLine: (label, code) => `Ваш код подтверждения ${label}: ${code}`,
    textEnter: (min) => `Введите его в приложении. Он действует ${min}.`,
  },
  sms: {
    reset: (label, url, min) => `${label}: сброс пароля — ${url} (действует ${min}). Если это не вы, проигнорируйте.`,
    changed: (label, admin, url, min) =>
      `${label}: ваш пароль изменил администратор ${admin}. Задать свой: ${url} (действует ${min}).`,
    code: (label, code, min) => `Код ${label}: ${code} (действует ${min}). Если это не вы, проигнорируйте.`,
  },
  forgot: {
    sentEmail: 'Мы отправили ссылку для сброса на вашу почту. Она действует 1 час.',
    sentSms: 'Мы отправили ссылку для сброса на ваш телефон. Она действует 1 час.',
    noUser: 'Не нашли аккаунт с таким email или именем пользователя. Проверьте и попробуйте снова.',
    noEmail: 'У этого аккаунта не указан email. Попробуйте SMS или попросите администратора сбросить пароль.',
    noPhone: 'У этого аккаунта не указан телефон. Попробуйте email или попросите администратора сбросить пароль.',
    emailNotVerified: 'Ваш email ещё не подтверждён. Войдите, подтвердите его в профиле и попробуйте снова.',
    phoneNotVerified: 'Ваш телефон ещё не подтверждён. Войдите, подтвердите его в профиле и попробуйте снова.',
  },
  page: {
    title: 'Выберите новый пароль',
    sub: 'Для вашего аккаунта ClassMate. С ним вы будете входить на всех устройствах.',
    newLabel: 'Новый пароль',
    confirmLabel: 'Повторите новый пароль',
    chkLen: 'Не меньше 8 символов',
    chkMatch: 'Пароли совпадают',
    save: 'Сохранить новый пароль',
    saving: 'Сохраняем…',
    show: 'Показать пароль',
    hide: 'Скрыть пароль',
    errShort: 'Используйте не меньше 8 символов.',
    errMatch: 'Пароли не совпадают.',
    errMissing: 'В ссылке нет кода сброса. Откройте ссылку из письма или SMS ещё раз или запросите новую.',
    errTooMany: 'Слишком много попыток с этой ссылкой. Подождите несколько минут и попробуйте снова.',
    errNetwork: 'Нет соединения. Проверьте интернет и попробуйте снова.',
    errGeneric: 'Что-то пошло не так. Попробуйте снова.',
    expiredTitle: 'Срок действия ссылки истёк',
    expiredBody: 'Ссылки для сброса действуют один час. Запросите новую и попробуйте снова.',
    usedTitle: 'Эта ссылка уже использована',
    usedBody: 'Каждая ссылка работает один раз. Если вы уже задали новый пароль, просто войдите. Если нет, запросите новую ссылку.',
    invalidTitle: 'Ссылка недействительна',
    invalidBody: 'Возможно, ссылка скопирована не полностью. Откройте её ещё раз из письма или SMS или запросите новую.',
    newLink: 'Запросить новую ссылку',
    signIn: 'Войти',
    doneTitle: 'Пароль обновлён',
    doneBody: 'Откройте приложение ClassMate и войдите с новым паролем. На других устройствах вы вышли из аккаунта.',
    signInWeb: 'Войти в веб-версии',
    help: 'Нужна помощь?',
  },
};

const COPY: Record<MailLocale, MailCopy> = { en, he, ar, fr, ru };

export function mailCopy(locale: MailLocale): MailCopy {
  return COPY[locale];
}

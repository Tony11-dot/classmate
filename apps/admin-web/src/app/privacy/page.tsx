import Link from 'next/link';

export const metadata = {
  title: 'Privacy Policy · ClassMate',
};

const sections: Array<{ heading: string; body: string[] }> = [
  {
    heading: 'Who we are',
    body: [
      'ClassMate is a school operating system built and operated by Tony Aboud. ' +
        'We provide a mobile and web application that schools deploy to manage students, ' +
        'teachers, parents, and administrators. This Privacy Policy describes how we ' +
        'collect, use, and protect personal information when you use the ClassMate ' +
        'mobile app (iOS, Android), the web app at classmateapp.org/app, and the ' +
        'underlying API services.',
    ],
  },
  {
    heading: 'Data we collect',
    body: [
      'Account data — your school provisions your account. We store the name, email, ' +
        'phone number (optional), language preference, and role (Student, Teacher, ' +
        'Parent, Secretary, or Admin) that the school has set for you. We do not allow ' +
        'self-signup; accounts only exist when a school admin creates them.',
      'Usage data — we record which screens you visit and which features you use to ' +
        'maintain the service. We log API request metadata (timestamps, response codes) ' +
        'for security and reliability.',
      'Content data — anything you upload (homework attachments, messages, voice notes, ' +
        'classroom announcements, exam files) is stored on our servers so the recipients ' +
        'inside your school can see it.',
      'Device data — when you receive push notifications, we store the device token your ' +
        'OS gives us. You can revoke this at any time in your OS notification settings.',
    ],
  },
  {
    heading: 'How we use it',
    body: [
      'We use your data only to run the service: route a message to its recipient, show ' +
        'a teacher their classroom roster, post a grade to the parent of the student it ' +
        'belongs to, deliver a push notification, generate an AI tutor reply via NOVA, ' +
        'and so on.',
      'We do not sell personal data. We do not share personal data with advertisers. We ' +
        'do not build a profile of you for ad targeting. We have no third-party analytics ' +
        'beyond what is strictly needed to operate the service.',
    ],
  },
  {
    heading: 'Subprocessors',
    body: [
      'We use a small number of providers to run the service, each bound by their own ' +
        'security and privacy commitments: Railway (application hosting), Google Cloud ' +
        '(Firebase Authentication, Firebase Cloud Messaging for push notifications), ' +
        'Anthropic (NOVA AI tutor responses), RevenueCat (subscription management), ' +
        'Resend (transactional email), and Twilio (SMS for password reset).',
      'NOVA queries sent to Anthropic are not used to train their models per our ' +
        'enterprise agreement.',
    ],
  },
  {
    heading: 'Children',
    body: [
      'ClassMate is used by schools and may be deployed to users under 13. We rely on ' +
        'the school as the verifiable parental consent provider per COPPA. Schools must ' +
        'have parental consent in place before provisioning any underage account. We ' +
        'collect only what is strictly necessary to operate the educational service for ' +
        'a child account; we never use child data for marketing or advertising.',
    ],
  },
  {
    heading: 'Your rights',
    body: [
      'You can review, export, or delete your account data at any time by emailing ' +
        'support@classmateapp.org. Schools can also delete or export data on your behalf. ' +
        'Deletion is permanent and propagates to all subprocessors within 30 days.',
    ],
  },
  {
    heading: 'Security',
    body: [
      'Passwords are stored as bcrypt hashes. All traffic between client and server uses ' +
        'HTTPS. Database backups are encrypted at rest. We notify schools within 72 ' +
        'hours of any breach involving their data.',
    ],
  },
  {
    heading: 'Contact',
    body: [
      'Privacy questions, data subject requests, or breach reports: support@classmateapp.org. ' +
        'We respond within one working day.',
    ],
  },
];

export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16">
      <Link
        href="/"
        className="text-sm text-(--muted) hover:text-foreground"
      >
        ← Back to ClassMate
      </Link>
      <h1 className="mt-6 text-4xl font-semibold tracking-tight">Privacy Policy</h1>
      <p className="mt-2 text-sm text-(--muted)">
        Last updated: 28 May 2026
      </p>

      <div className="mt-10 space-y-10">
        {sections.map((section) => (
          <section key={section.heading}>
            <h2 className="text-xl font-semibold">{section.heading}</h2>
            <div className="mt-3 space-y-3">
              {section.body.map((paragraph, i) => (
                <p key={i} className="text-base leading-relaxed text-(--foreground)/85">
                  {paragraph}
                </p>
              ))}
            </div>
          </section>
        ))}
      </div>
    </main>
  );
}

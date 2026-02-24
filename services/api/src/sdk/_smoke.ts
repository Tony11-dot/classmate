import { HttpClient } from './http-client';
import { AuthSdk } from './auth.sdk';
import { ClassroomsSdk } from './classrooms.sdk';

const BASE = process.env.SDK_BASE ?? 'http://127.0.0.1:3001';

let token = '';

const http = new HttpClient({
  baseUrl: BASE,
  getToken: () => token,
});

const auth = new AuthSdk(http);
const classrooms = new ClassroomsSdk(http);

(async () => {
  const login = await auth.login({ email: 'student1@classmate.app', password: 'dev' });
  token = login.token;

  const list = await classrooms.listStudent();
  console.log('student classrooms:', list.length);

  if (list[0]?.id) {
    const detail = await classrooms.getStudent(list[0].id);
    console.log('detail:', detail.id);
  }
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

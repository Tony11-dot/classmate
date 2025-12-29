import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const result = await this.auth.login(body.email, body.password);
    if (!result) return { error: 'Invalid credentials' };
    return result;
  }
}

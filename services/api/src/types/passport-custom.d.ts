declare module 'passport-custom' {
  import { Strategy as PassportStrategy } from 'passport-strategy';

  export type VerifyFunction = (
    req: any,
    done: (error: any, user?: any, info?: any) => void
  ) => void | Promise<void>;

  export class Strategy extends PassportStrategy {
    name: string;
    constructor(verify: VerifyFunction);
  }
}

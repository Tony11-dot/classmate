export class NotificationsSdk {
  constructor(private readonly http?: any) {}

  async list(): Promise<any[]> {
    return [];
  }

  async seenAll(): Promise<void> {
    return;
  }

  async create(input: any): Promise<any> {
    return input;
  }
}
